// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@seaport/seaport-types/src/lib/ConsiderationStructs.sol";
import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/tokens/WETH.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "../../interfaces/external/IReservoir.sol";
import "../../interfaces/callbacks/IPurchaseBundler.sol";
import "../../interfaces/callbacks/ILoanCallback.sol";
import "../../interfaces/external/ICryptoPunksMarket.sol";
import "../../interfaces/external/IWrappedPunk.sol";
import "../utils/WithProtocolFee.sol";
import "../loans/MultiSourceLoan.sol";
import "../utils/BytesLib.sol";
import "../AddressManager.sol";
import "../InputChecker.sol";

contract PurchaseBundler is IPurchaseBundler, ILoanCallback, ERC721TokenReceiver, WithProtocolFee {
    using FixedPointMathLib for uint256;
    using BytesLib for bytes;
    using InputChecker for address;
    using SafeTransferLib for ERC20;
    using SafeTransferLib for WETH;

    uint256 private constant _PRECISION = 10000;
    uint256 private constant _MAX_TAX = 5000;
    uint256 public constant TAX_UPDATE_NOTICE = 7 days;

    AddressManager private immutable _marketplaceContractsAddressManager;
    WETH private immutable _weth;

    Taxes private _pendingTaxes;
    uint256 private _pendingTaxesSetTime;
    Taxes private _taxes;

    address private _pendingMultiSourceLoanAddress;

    MultiSourceLoan private _multiSourceLoan;
    ICryptoPunksMarket private immutable _punkMarket;
    IWrappedPunk private immutable _wrappedPunk;
    address private immutable _punkProxy;

    event BNPLLoansStarted(uint256[] loanIds);
    event SellAndRepayExecuted(uint256[] loanIds);
    event MultiSourceLoanPendingUpdate(address newAddress);
    event MultiSourceLoanUpdated(address newAddress);
    event TaxesPendingUpdate(Taxes newTaxes);
    event TaxesUpdated(Taxes taxes);

    error MarketplaceAddressNotWhitelisted();
    error OnlyWethSupportedError();

    error OnlyLoanCallableError();
    error InvalidAddressUpdateError();
    error CouldNotReturnEthError();
    error InvalidTaxesError(Taxes newTaxes);

    constructor(
        address _multiSourceLoanAddress,
        address _marketplaceContracts,
        address payable _wethAddress,
        address payable _punkMarketAddress,
        address payable _wrappedPunkAddress,
        Taxes memory __taxes,
        uint256 _minWaitTime,
        ProtocolFee memory __protocolFee
    ) WithProtocolFee(tx.origin, _minWaitTime, __protocolFee) {
        _multiSourceLoanAddress.checkNotZero();
        _marketplaceContracts.checkNotZero();

        _multiSourceLoan = MultiSourceLoan(_multiSourceLoanAddress);
        _marketplaceContractsAddressManager = AddressManager(_marketplaceContracts);
        _weth = WETH(_wethAddress);
        _punkMarket = ICryptoPunksMarket(_punkMarketAddress);
        _wrappedPunk = IWrappedPunk(_wrappedPunkAddress);

        _wrappedPunk.registerProxy();
        _punkProxy = _wrappedPunk.proxyInfo(address(this));
        _taxes = __taxes;
        _pendingTaxesSetTime = type(uint256).max;
    }

    modifier onlyLoanContract() {
        if (msg.sender != address(_multiSourceLoan)) {
            revert OnlyLoanCallableError();
        }
        _;
    }

    /// @inheritdoc IPurchaseBundler
    /// @dev Buy calls emit loan -> Before trying to transfer the NFT but after transfering the principal
    /// emitLoan will call the afterPrincipalTransfer Hook, which will execute the purchase.
    function buy(bytes[] calldata _executionData)
        external
        payable
        returns (uint256[] memory, IMultiSourceLoan.Loan[] memory)
    {
        bytes[] memory encodedOutput = _multiSourceLoan.multicall(_executionData);
        uint256[] memory loanIds = new uint256[](encodedOutput.length);
        IMultiSourceLoan.Loan[] memory loans = new IMultiSourceLoan.Loan[](encodedOutput.length);
        uint256 total = encodedOutput.length;
        for (uint256 i; i < total;) {
            (loanIds[i], loans[i]) = abi.decode(encodedOutput[i], (uint256, IMultiSourceLoan.Loan));
            unchecked {
                ++i;
            }
        }

        /// Return any remaining funds to sender.
        uint256 remainingBalance;
        assembly {
            remainingBalance := selfbalance()
        }
        if (remainingBalance != 0) {
            (bool success,) = payable(msg.sender).call{value: remainingBalance}("");
            if (!success) {
                revert CouldNotReturnEthError();
            }
        }
        emit BNPLLoansStarted(loanIds);
        return (loanIds, loans);
    }

    /// @dev Similar to buy. Hook is called after the NFT transfer but before transfering WETH for repayment.
    /// @inheritdoc IPurchaseBundler
    function sell(bytes[] calldata _executionData) external {
        _multiSourceLoan.multicall(_executionData);
        uint256[] memory loanIds = new uint256[](_executionData.length);
        uint256 total = _executionData.length;
        for (uint256 i = 0; i < total;) {
            (IMultiSourceLoan.LoanRepaymentData memory _repaymentData) =
                abi.decode(_executionData[i][4:], (IMultiSourceLoan.LoanRepaymentData));
            loanIds[i] = _repaymentData.data.loanId;
            unchecked {
                ++i;
            }
        }
        emit SellAndRepayExecuted(loanIds);
    }

    /// @inheritdoc ILoanCallback
    function afterPrincipalTransfer(IMultiSourceLoan.Loan calldata _loan, uint256 _fee, bytes calldata _executionData)
        external
        onlyLoanContract
        returns (bytes4)
    {
        ExecutionInfo memory purchaseBundlerExecutionInfo = abi.decode(_executionData, (ExecutionInfo));
        IReservoir.ExecutionInfo memory executionInfo = purchaseBundlerExecutionInfo.reservoirExecutionInfo;
        if (!_marketplaceContractsAddressManager.isWhitelisted(executionInfo.module)) {
            revert MarketplaceAddressNotWhitelisted();
        }
        if (_loan.principalAddress != address(_weth)) {
            revert OnlyWethSupportedError();
        }
        uint256 borrowed = _loan.principalAmount - _fee;
        /// @dev Get WETH from the borrower and unwrap it since listings expect native ETH.
        _weth.withdraw(borrowed);

        (bool success,) = executionInfo.module.call{value: executionInfo.value}(executionInfo.data);
        if (!success) {
            revert InvalidCallbackError();
        }
        /// @dev If contract must be owner we transfer the NFT to the purchaseBundler contract.
        if (executionInfo.module == address(_punkMarket)) {
            /// @dev Wrap punk and transfer it to the borrower (loan is in Wrapped Punks).
            _punkMarket.transferPunk(address(_punkProxy), _loan.nftCollateralTokenId);
            _wrappedPunk.mint(_loan.nftCollateralTokenId);
            _wrappedPunk.transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);
        } else if (purchaseBundlerExecutionInfo.contractMustBeOwner) {
            ERC721(_loan.nftCollateralAddress).transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);
        }

        _handleTax(_loan, _taxes.buyTax);

        return this.afterPrincipalTransfer.selector;
    }

    /// @inheritdoc ILoanCallback
    /// @dev See notes for `afterPrincipalTransfer`.
    function afterNFTTransfer(IMultiSourceLoan.Loan calldata _loan, bytes calldata _executionData)
        external
        onlyLoanContract
        returns (bytes4)
    {
        ExecutionInfo memory purchaseBundlerExecutionInfo = abi.decode(_executionData, (ExecutionInfo));
        IReservoir.ExecutionInfo memory executionInfo = purchaseBundlerExecutionInfo.reservoirExecutionInfo;
        if (!_marketplaceContractsAddressManager.isWhitelisted(executionInfo.module)) {
            revert MarketplaceAddressNotWhitelisted();
        }
        bool success;
        /// @dev Similar to `afterPrincipalTransfer`, we use the matchOrder method to avoid extra transfers.
        /// Note that calling fullfilment on seaport will fail on this contract.
        if (executionInfo.module == address(_punkMarket)) {
            /// @dev Unwrap punk
            _wrappedPunk.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);
            _wrappedPunk.burn(_loan.nftCollateralTokenId);

            /// @dev Execute sell, claim ETH from the contract and wrap it before sending it to the borrower.
            (success,) = executionInfo.module.call(executionInfo.data);
            _punkMarket.withdraw();
            uint256 balance = address(this).balance;
            _weth.deposit{value: balance}();
            /// @dev Not using executionInfo.value to avoid capital remaining here.
            /// This costs extra gas but was suggested by QS.
            _weth.safeTransfer(_loan.borrower, balance);
        } else if (!purchaseBundlerExecutionInfo.contractMustBeOwner) {
            (success,) = executionInfo.module.call(executionInfo.data);
        } else {
            ERC721 collection = ERC721(_loan.nftCollateralAddress);
            collection.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);
            collection.approve(executionInfo.module, _loan.nftCollateralTokenId);
            (success,) = executionInfo.module.call(executionInfo.data);
            ERC20 asset = ERC20(_loan.principalAddress);
            uint256 balance = asset.balanceOf(address(this));
            /// @dev Not using executionInfo.value to avoid capital remaining here.
            /// This costs extra gas but was suggested by QS.
            asset.safeTransfer(_loan.borrower, balance);
        }
        if (!success) {
            revert InvalidCallbackError();
        }
        _handleTax(_loan, _taxes.sellTax);
        return this.afterNFTTransfer.selector;
    }

    /// @inheritdoc IPurchaseBundler
    function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {
        _newAddress.checkNotZero();

        _pendingMultiSourceLoanAddress = _newAddress;

        emit MultiSourceLoanPendingUpdate(_newAddress);
    }

    /// @inheritdoc IPurchaseBundler
    function finalUpdateMultiSourceLoanAddress(address _newAddress) external onlyOwner {
        if (_pendingMultiSourceLoanAddress != _newAddress) {
            revert InvalidAddressUpdateError();
        }

        _multiSourceLoan = MultiSourceLoan(_newAddress);
        _pendingMultiSourceLoanAddress = address(0);

        emit MultiSourceLoanUpdated(_newAddress);
    }

    /// @inheritdoc IPurchaseBundler
    function getMultiSourceLoanAddress() external view override returns (address) {
        return address(_multiSourceLoan);
    }

    /// @inheritdoc IPurchaseBundler
    function getTaxes() external view returns (Taxes memory) {
        return _taxes;
    }

    /// @inheritdoc IPurchaseBundler
    function getPendingTaxes() external view returns (Taxes memory) {
        return _pendingTaxes;
    }

    /// @inheritdoc IPurchaseBundler
    function getPendingTaxesSetTime() external view returns (uint256) {
        return _pendingTaxesSetTime;
    }

    /// @inheritdoc IPurchaseBundler
    function updateTaxes(Taxes calldata _newTaxes) external onlyOwner {
        if (_newTaxes.buyTax > _MAX_TAX || (_newTaxes.sellTax > _MAX_TAX)) {
            revert InvalidTaxesError(_newTaxes);
        }

        _pendingTaxes = _newTaxes;
        _pendingTaxesSetTime = block.timestamp;

        emit TaxesPendingUpdate(_newTaxes);
    }

    /// @inheritdoc IPurchaseBundler
    function setTaxes() external onlyOwner {
        if (block.timestamp < _pendingTaxesSetTime + TAX_UPDATE_NOTICE) {
            revert TooEarlyError(_pendingTaxesSetTime);
        }
        Taxes memory taxes = _pendingTaxes;
        _taxes = taxes;

        emit TaxesUpdated(taxes);
    }

    function _handleTax(IMultiSourceLoan.Loan memory _loan, uint256 _tax) private {
        if (_tax == 0) {
            return;
        }

        ProtocolFee memory protocolFee = _protocolFee;

        address principalAddress = _loan.principalAddress;
        address borrower = _loan.borrower;
        uint256 totalFeeTax;
        uint256 totalTranches = _loan.tranche.length;
        for (uint256 i; i < totalTranches;) {
            IMultiSourceLoan.Tranche memory tranche = _loan.tranche[i];
            uint256 taxCost = tranche.principalAmount.mulDivUp(_tax, _PRECISION);
            uint256 feeTax = taxCost.mulDivUp(protocolFee.fraction, _PRECISION);
            totalFeeTax += feeTax;
            ERC20(principalAddress).safeTransferFrom(borrower, tranche.lender, taxCost - feeTax);
            unchecked {
                ++i;
            }
        }
        if (totalFeeTax != 0) {
            ERC20(principalAddress).safeTransferFrom(borrower, protocolFee.recipient, totalFeeTax);
        }
    }

    fallback() external payable {}

    receive() external payable {}
}
