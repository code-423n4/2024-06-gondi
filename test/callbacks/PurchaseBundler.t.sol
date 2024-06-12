// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "@solmate/tokens/WETH.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/interfaces/external/IReservoir.sol";
import "src/interfaces/loans/IBaseLoan.sol";
import "src/interfaces/loans/IMultiSourceLoan.sol";
import "src/lib/AddressManager.sol";
import "src/lib/callbacks/PurchaseBundler.sol";
import "src/lib/loans/MultiSourceLoan.sol";
import "src/lib/utils/Interest.sol";
import "test/loans/MultiSourceCommons.sol";

contract PurchaseBundlerTest is MultiSourceCommons {
    using Interest for IMultiSourceLoan.Loan;
    using FixedPointMathLib for uint256;

    address private constant _sampleMarketplace = address(1000);
    bytes private constant _sampleData = abi.encode("1111111");

    PurchaseBundler private _purchaseBundler;
    AddressManager private _marketplaceContractsWhitelist;
    WETH private _mockedWeth;
    address payable private _punkMarketAddress;
    address payable private _wrappedPunkAddress;
    address payable private _seaportAddress;
    address private _punksProxy;

    function setUp() public override {
        _seaportAddress = payable(address(9996));
        _punksProxy = address(9997);
        _punkMarketAddress = payable(address(9998));
        _wrappedPunkAddress = payable(address(9999));
        vm.etch(_wrappedPunkAddress, "0xGarbage");
        vm.mockCall(_wrappedPunkAddress, abi.encodeWithSignature("registerProxy()"), abi.encode());
        vm.mockCall(_wrappedPunkAddress, abi.encodeWithSignature("proxyInfo(address)"), abi.encode(_punksProxy));
        vm.mockCall(_wrappedPunkAddress, abi.encodeWithSignature("mint(uint256)"), abi.encode());
        vm.mockCall(
            _wrappedPunkAddress, abi.encodeWithSignature("safeTransferFrom(address,address,uint256)"), abi.encode()
        );

        super.setUp();
        _marketplaceContractsWhitelist = new AddressManager(new address[](0));
        _mockedWeth = new WETH();
        _purchaseBundler = new PurchaseBundler(
            address(_msLoan),
            address(_marketplaceContractsWhitelist),
            payable(address(_mockedWeth)),
            _punkMarketAddress,
            _wrappedPunkAddress,
            IPurchaseBundler.Taxes(0, 0),
            3 days,
            WithProtocolFee.ProtocolFee(address(0), 0)
        );
        vm.startPrank(_marketplaceContractsWhitelist.owner());
        _marketplaceContractsWhitelist.add(_sampleMarketplace);
        _marketplaceContractsWhitelist.add(_punkMarketAddress);
        _marketplaceContractsWhitelist.add(_seaportAddress);
        vm.stopPrank();
        AddressManager am = AddressManager(_msLoan.getCurrencyManager());
        vm.prank(am.owner());
        AddressManager(am).add(address(_mockedWeth));

        uint256 lenderBalance = 1e18;
        vm.deal(_originalLender, lenderBalance);
        vm.startPrank(_originalLender);
        _mockedWeth.deposit{value: lenderBalance}();
        _mockedWeth.approve(address(_msLoan), lenderBalance);
        vm.stopPrank();
        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(address(_purchaseBundler));

        vm.mockCall(_sampleMarketplace, _sampleData, abi.encode());

        vm.etch(_punkMarketAddress, "0xGarbage");
        vm.mockCall(_punkMarketAddress, abi.encodeWithSignature("transferPunk(address,uint256)"), abi.encode());
    }

    function testZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressZeroError()"));
        new PurchaseBundler(
            address(0),
            address(_marketplaceContractsWhitelist),
            payable(address(_mockedWeth)),
            _punkMarketAddress,
            _wrappedPunkAddress,
            IPurchaseBundler.Taxes(0, 0),
            3 days,
            WithProtocolFee.ProtocolFee(address(0), 0)
        );

        vm.expectRevert(abi.encodeWithSignature("AddressZeroError()"));
        new PurchaseBundler(
            address(_msLoan),
            address(0),
            payable(address(_mockedWeth)),
            _punkMarketAddress,
            _wrappedPunkAddress,
            IPurchaseBundler.Taxes(0, 0),
            3 days,
            WithProtocolFee.ProtocolFee(address(0), 0)
        );
    }

    function testBuy1() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        bytes[] memory executionData = new bytes[](1);
        executionData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.emitLoan.selector,
            _getSampleExecutionData(price, principalAmount, _sampleMarketplace, _purchaseBundler)
        );

        vm.startPrank(_borrower);
        collateralCollection.safeTransferFrom(_borrower, address(_purchaseBundler), collateralTokenId);
        collateralCollection.setApprovalForAll(address(_msLoan), true);
        vm.stopPrank();

        vm.expectCall(_sampleMarketplace, price, _sampleData);
        _purchaseBundler.buy{value: price - principalAmount}(executionData);
    }

    function testBuyFail() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        bytes[] memory executionData = new bytes[](1);
        IMultiSourceLoan.LoanExecutionData memory lde =
            _getSampleExecutionData(price, principalAmount, _sampleMarketplace, _purchaseBundler);
        lde.executionData.offerExecution[0].offer.lender = address(999);
        executionData[0] = abi.encodeWithSelector(IMultiSourceLoan.emitLoan.selector, lde);

        vm.startPrank(_borrower);
        collateralCollection.safeTransferFrom(_borrower, address(_purchaseBundler), collateralTokenId);
        collateralCollection.setApprovalForAll(address(_msLoan), true);
        vm.stopPrank();

        vm.expectRevert();
        _purchaseBundler.buy{value: price - principalAmount}(executionData);
    }

    function testBuyReturn() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        bytes[] memory executionData = new bytes[](1);
        executionData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.emitLoan.selector,
            _getSampleExecutionData(price, principalAmount, _sampleMarketplace, _purchaseBundler)
        );

        vm.startPrank(_borrower);
        collateralCollection.safeTransferFrom(_borrower, address(_purchaseBundler), collateralTokenId);
        collateralCollection.setApprovalForAll(address(_msLoan), true);
        vm.stopPrank();

        uint256 originalBalance = address(this).balance;
        uint256 extra = 10;

        _purchaseBundler.buy{value: price - principalAmount + extra}(executionData);

        /// @dev We are mocking this call so it all comes back. Otherwise this would be balance - (price - principalAmount)
        assertEq(address(this).balance, originalBalance + principalAmount);
    }

    function testBuyFailWhitelist() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        IMultiSourceLoan.LoanExecutionData memory data =
            _getSampleExecutionData(price, principalAmount, address(99999), _purchaseBundler);

        vm.deal(address(_purchaseBundler), price - principalAmount);
        IMultiSourceLoan.Loan memory loan = _getSampleLoan(data);
        vm.expectRevert(abi.encodeWithSignature("MarketplaceAddressNotWhitelisted()"));
        vm.prank(address(_msLoan));
        _purchaseBundler.afterPrincipalTransfer(loan, 0, data.executionData.callbackData);
    }

    function testBuyFailInvalidCallback() public {
        address otherMarketplace = address(8888);
        vm.prank(_marketplaceContractsWhitelist.owner());
        _marketplaceContractsWhitelist.add(otherMarketplace);

        uint256 price = 100;
        uint256 principalAmount = 50;
        IMultiSourceLoan.LoanExecutionData memory data =
            _getSampleExecutionData(price, principalAmount, otherMarketplace, _purchaseBundler);

        vm.mockCallRevert(otherMarketplace, price, _sampleData, abi.encode("REVERT"));

        vm.deal(address(_purchaseBundler), price - principalAmount);
        vm.deal(address(_borrower), principalAmount);
        vm.startPrank(address(_borrower));
        _mockedWeth.deposit{value: principalAmount}();
        _mockedWeth.approve(address(_purchaseBundler), principalAmount);
        _mockedWeth.transfer(address(_purchaseBundler), principalAmount);
        vm.stopPrank();
        IMultiSourceLoan.Loan memory loan = _getSampleLoan(data);
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        vm.prank(address(_msLoan));
        _purchaseBundler.afterPrincipalTransfer(loan, 0, data.executionData.callbackData);
    }

    function testBuyFailOnlyWeth() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        WETH fakeWeth = new WETH();
        IMultiSourceLoan.LoanExecutionData memory raw =
            _getSampleExecutionData(price, principalAmount, _sampleMarketplace, _purchaseBundler);
        raw.executionData.offerExecution[0].offer.principalAddress = address(fakeWeth);

        vm.deal(_originalLender, 2e18);
        vm.startPrank(_originalLender);
        fakeWeth.deposit{value: 1e18}();
        fakeWeth.approve(address(_msLoan), 1e18);
        vm.stopPrank();
        AddressManager am = AddressManager(_msLoan.getCurrencyManager());
        vm.prank(am.owner());
        am.add(address(fakeWeth));

        IMultiSourceLoan.Loan memory loan = _getSampleLoan(raw);
        vm.expectRevert(abi.encodeWithSignature("OnlyWethSupportedError()"));
        vm.prank(address(_msLoan));
        _purchaseBundler.afterPrincipalTransfer(loan, 0, raw.executionData.callbackData);
    }

    function testBuyPunk() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        bytes[] memory encodedData = new bytes[](1);
        IMultiSourceLoan.LoanExecutionData memory raw =
            _getSampleExecutionData(price, principalAmount, _punkMarketAddress, _purchaseBundler);

        address borrower = raw.borrower;
        uint256 tokenId = raw.executionData.tokenId;

        encodedData[0] = abi.encodeWithSelector(IMultiSourceLoan.emitLoan.selector, raw);

        vm.expectCall(
            _punkMarketAddress, abi.encodeWithSignature("transferPunk(address,uint256)", _punksProxy, tokenId)
        );
        vm.expectCall(_wrappedPunkAddress, abi.encodeWithSignature("mint(uint256)", tokenId));
        vm.expectCall(
            _wrappedPunkAddress,
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)", address(_purchaseBundler), borrower, tokenId
            )
        );
        _purchaseBundler.buy{value: price - principalAmount}(encodedData);
    }

    function testBuyWithTaxes() public {
        PurchaseBundler withFeesAndTaxes = _setUpWithTaxes();
        vm.prank(_borrower);
        collateralCollection.safeTransferFrom(_borrower, address(withFeesAndTaxes), collateralTokenId);
        uint256 price = 1e15;
        uint256 principalAmount = 1e14;
        bytes[] memory executionData = new bytes[](1);
        executionData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.emitLoan.selector,
            _getSampleExecutionData(price, principalAmount, _sampleMarketplace, withFeesAndTaxes)
        );

        /// @dev Taxes = 100
        uint256 taxes = principalAmount.mulDivUp(100, 10000);
        uint256 protocolFee = taxes.mulDivUp(100, 10000);
        vm.deal(_borrower, taxes);
        vm.startPrank(_borrower);
        _mockedWeth.deposit{value: taxes}();
        _mockedWeth.approve(address(withFeesAndTaxes), taxes);
        vm.stopPrank();

        uint256 currentBalance = _mockedWeth.balanceOf(_borrower);
        uint256 currentLenderBalance = _mockedWeth.balanceOf(_originalLender);
        vm.expectCall(_sampleMarketplace, price, _sampleData);
        withFeesAndTaxes.buy{value: price - principalAmount}(executionData);
        assertEq(currentBalance - taxes, _mockedWeth.balanceOf(_borrower));
        assertEq(currentLenderBalance + taxes - protocolFee - principalAmount, _mockedWeth.balanceOf(_originalLender));
    }

    function testSell() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        vm.warp(1 days);

        uint256 borrowerBalance = testToken.balanceOf(_borrower);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        uint256 profit = 100;
        uint256 price = owed + profit;
        uint256 purchaseBundlerBalance = testToken.balanceOf(address(_purchaseBundler));

        bytes[] memory repaymentData = new bytes[](1);
        repaymentData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.repayLoan.selector,
            _getSampleSaleDataAndMint(loanId, loan, _sampleMarketplace, price, _purchaseBundler)
        );
        vm.expectCall(_sampleMarketplace, _sampleData);
        vm.startPrank(_borrower);
        collateralCollection.setApprovalForAll(address(_purchaseBundler), true);
        _purchaseBundler.sell(repaymentData);
        vm.stopPrank();

        assertEq(borrowerBalance + profit, testToken.balanceOf(_borrower));
        assertEq(purchaseBundlerBalance, testToken.balanceOf(address(_purchaseBundler)));
    }

    function testSellInvalidCallback() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        address otherMarketplace = address(8888);
        vm.prank(_marketplaceContractsWhitelist.owner());
        _marketplaceContractsWhitelist.add(otherMarketplace);

        IMultiSourceLoan.LoanRepaymentData memory repaymentData =
            _getSampleSaleDataAndMint(loanId, loan, otherMarketplace, 100, _purchaseBundler);

        vm.prank(address(_msLoan));
        collateralCollection.transferFrom(address(_msLoan), loan.borrower, loan.nftCollateralTokenId);
        vm.prank(loan.borrower);
        collateralCollection.setApprovalForAll(address(_purchaseBundler), true);

        vm.mockCallRevert(otherMarketplace, _sampleData, abi.encode("REVERT"));
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        vm.prank(address(_msLoan));
        _purchaseBundler.afterNFTTransfer(loan, repaymentData.data.callbackData);
    }

    function testSellFailWhitelist() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        IMultiSourceLoan.LoanRepaymentData memory repaymentData =
            _getSampleSaleDataAndMint(loanId, loan, address(99999), 0, _purchaseBundler);
        vm.expectRevert(abi.encodeWithSignature("MarketplaceAddressNotWhitelisted()"));
        vm.prank(address(_msLoan));
        _purchaseBundler.afterNFTTransfer(loan, repaymentData.data.callbackData);
    }

    function testAfterNFTTransferPunk() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        address borrower = loan.borrower;
        uint256 tokenId = loan.nftCollateralTokenId;
        uint256 salePrice = loan.principalAmount * 2;
        IMultiSourceLoan.LoanRepaymentData memory repaymentData =
            _getSampleSaleDataAndMint(loanId, loan, _punkMarketAddress, salePrice, _purchaseBundler);

        vm.prank(_borrower);
        vm.expectCall(
            _wrappedPunkAddress,
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)", borrower, address(_purchaseBundler), tokenId
            )
        );
        vm.expectCall(_wrappedPunkAddress, abi.encodeWithSignature("burn(uint256)", tokenId));
        vm.expectCall(_punkMarketAddress, abi.encodeWithSignature("withdraw()"));
        vm.deal(address(_purchaseBundler), salePrice);
        uint256 borrowerBalance = _mockedWeth.balanceOf(borrower);
        vm.prank(address(_msLoan));
        _purchaseBundler.afterNFTTransfer(loan, repaymentData.data.callbackData);

        assertEq(borrowerBalance + salePrice, _mockedWeth.balanceOf(borrower));
    }

    function testBuySeaport() public {
        uint256 price = 100;
        uint256 principalAmount = 50;
        bytes[] memory executionData = new bytes[](1);
        executionData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.emitLoan.selector,
            _getSampleExecutionData(price, principalAmount, _seaportAddress, _purchaseBundler)
        );

        vm.startPrank(_borrower);
        collateralCollection.setApprovalForAll(address(_msLoan), true);
        vm.stopPrank();

        vm.expectCall(_seaportAddress, price, _sampleData);
        _purchaseBundler.buy{value: price - principalAmount}(executionData);
    }

    function testSellSeaport() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        vm.warp(1 days);

        uint256 borrowerBalance = testToken.balanceOf(_borrower);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(_borrower, owed);
        vm.prank(_borrower);
        testToken.approve(address(_msLoan), owed);

        /// @dev For this test, this is irrelevant.
        uint256 price = owed + 100;

        IMultiSourceLoan.LoanRepaymentData memory repaymentData =
            _getSampleSaleDataAndMint(loanId, loan, _seaportAddress, price, _purchaseBundler);
        repaymentData.data.shouldDelegate = true;
        bytes[] memory encodedData = new bytes[](1);
        encodedData[0] = abi.encodeWithSelector(IMultiSourceLoan.repayLoan.selector, repaymentData);
        vm.expectCall(_seaportAddress, _sampleData);
        vm.expectCall(
            address(_delegationRegistry),
            abi.encodeWithSelector(
                IDelegateRegistry.delegateERC721.selector,
                loan.borrower,
                loan.nftCollateralAddress,
                loan.nftCollateralTokenId,
                bytes32(""),
                true
            )
        );
        _purchaseBundler.sell(encodedData);

        assertEq(borrowerBalance, testToken.balanceOf(_borrower));
    }

    function testSellWithTaxes() public {
        PurchaseBundler withFeesAndTaxes = _setUpWithTaxes();
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        vm.warp(1 days);

        uint256 borrowerBalance = testToken.balanceOf(_borrower);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        uint256 profit = 100;
        uint256 price = owed + profit;
        uint256 purchaseBundlerBalance = testToken.balanceOf(address(withFeesAndTaxes));
        uint256 lenderBalance = testToken.balanceOf(_originalLender);

        bytes[] memory repaymentData = new bytes[](1);
        repaymentData[0] = abi.encodeWithSelector(
            IMultiSourceLoan.repayLoan.selector,
            _getSampleSaleDataAndMint(loanId, loan, _sampleMarketplace, price, withFeesAndTaxes)
        );

        uint256 taxes = loan.principalAmount.mulDivUp(100, 10000);
        uint256 protocolFee = taxes.mulDivUp(100, 10000);
        vm.deal(_borrower, taxes);
        vm.startPrank(_borrower);
        collateralCollection.setApprovalForAll(address(withFeesAndTaxes), true);
        testToken.mint(_borrower, taxes);
        testToken.approve(address(withFeesAndTaxes), taxes);
        vm.stopPrank();
        vm.expectCall(_sampleMarketplace, _sampleData);
        withFeesAndTaxes.sell(repaymentData);

        assertEq(borrowerBalance + profit, testToken.balanceOf(_borrower));
        assertEq(purchaseBundlerBalance, testToken.balanceOf(address(_purchaseBundler)));
        assertEq(lenderBalance + taxes - protocolFee + owed, testToken.balanceOf(_originalLender));
    }

    function testUpdateMultiSourceLoan() public {
        address otherAddress = address(9999);
        PurchaseBundler other_purchaseBundler = _getOtherPurchaseBundler();

        vm.startPrank(other_purchaseBundler.owner());
        other_purchaseBundler.updateMultiSourceLoanAddressFirst(otherAddress);
        assertEq(other_purchaseBundler.getMultiSourceLoanAddress(), address(_msLoan));
        other_purchaseBundler.finalUpdateMultiSourceLoanAddress(otherAddress);
        assertEq(other_purchaseBundler.getMultiSourceLoanAddress(), otherAddress);
        vm.stopPrank();
    }

    function testUpdateMultiSourceLoanFail() public {
        address otherAddress = address(9999);
        PurchaseBundler other_purchaseBundler = _getOtherPurchaseBundler();

        vm.prank(other_purchaseBundler.owner());
        other_purchaseBundler.updateMultiSourceLoanAddressFirst(otherAddress);

        vm.prank(other_purchaseBundler.owner());
        vm.expectRevert(abi.encodeWithSignature("InvalidAddressUpdateError()"));
        other_purchaseBundler.finalUpdateMultiSourceLoanAddress(address(1));
    }

    function _getSampleLoan(IMultiSourceLoan.LoanExecutionData memory _executionData)
        private
        view
        returns (IMultiSourceLoan.Loan memory)
    {
        IMultiSourceLoan.Tranche[] memory tranche = new IMultiSourceLoan.Tranche[](1);
        IMultiSourceLoan.LoanOffer memory offer = _executionData.executionData.offerExecution[0].offer;
        tranche[0] =
            IMultiSourceLoan.Tranche(1, 0, offer.principalAmount, offer.lender, 0, block.timestamp, offer.aprBps);
        return IMultiSourceLoan.Loan(
            _executionData.borrower,
            _executionData.executionData.tokenId,
            offer.nftCollateralAddress,
            offer.principalAddress,
            offer.principalAmount,
            block.timestamp,
            offer.duration,
            tranche,
            0
        );
    }

    function _getSampleExecutionData(
        uint256 _price,
        uint256 _principalAmount,
        address _marketplace,
        PurchaseBundler _purchaseBundlerContract
    ) private returns (IMultiSourceLoan.LoanExecutionData memory) {
        uint256 downpayment = _price - _principalAmount;
        vm.deal(_borrower, downpayment);
        vm.prank(_borrower);
        _mockedWeth.approve(address(_purchaseBundlerContract), downpayment);
        IMultiSourceLoan.LoanOffer memory offer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _principalAmount);
        offer.principalAddress = address(_mockedWeth);
        bool contractMustBeOwner = _marketplace != _seaportAddress;
        bytes memory reservoirExecutionInfo = abi.encode(
            IPurchaseBundler.ExecutionInfo(
                IReservoir.ExecutionInfo(_marketplace, _sampleData, _price), contractMustBeOwner
            )
        );
        IMultiSourceLoan.ExecutionData memory executionData =
            _sampleExecutionData(offer, address(_purchaseBundlerContract));
        executionData.callbackData = reservoirExecutionInfo;
        return IMultiSourceLoan.LoanExecutionData(executionData, _borrower, bytes(""));
    }

    function _getSampleSaleDataAndMint(
        uint256 _loanId,
        IMultiSourceLoan.Loan memory _loan,
        address _marketplace,
        uint256 _price,
        PurchaseBundler _purchaseBundlerContract
    ) private returns (IMultiSourceLoan.LoanRepaymentData memory) {
        uint256 owed = _loan.getTotalOwed(block.timestamp);
        testToken.mint(address(_purchaseBundlerContract), _price);
        vm.prank(_borrower);
        testToken.approve(address(_msLoan), owed);
        bool contractMustBeOwner = _marketplace != _seaportAddress;
        IReservoir.ExecutionInfo memory reservoirExecutiondata =
            IReservoir.ExecutionInfo(_marketplace, _sampleData, _price);
        bytes memory executionInfo =
            abi.encode(IPurchaseBundler.ExecutionInfo(reservoirExecutiondata, contractMustBeOwner));
        return IMultiSourceLoan.LoanRepaymentData(
            IMultiSourceLoan.SignableRepaymentData(_loanId, executionInfo, false), _loan, ""
        );
    }

    function _getOtherPurchaseBundler() private returns (PurchaseBundler) {
        return new PurchaseBundler(
            address(_msLoan),
            address(_marketplaceContractsWhitelist),
            payable(address(_mockedWeth)),
            _punkMarketAddress,
            _wrappedPunkAddress,
            IPurchaseBundler.Taxes(0, 0),
            3 days,
            WithProtocolFee.ProtocolFee(address(0), 0)
        );
    }

    function _setUpWithTaxes() private returns (PurchaseBundler) {
        PurchaseBundler withFeesAndTaxes = new PurchaseBundler(
            address(_msLoan),
            address(_marketplaceContractsWhitelist),
            payable(address(_mockedWeth)),
            _punkMarketAddress,
            _wrappedPunkAddress,
            IPurchaseBundler.Taxes(100, 100),
            3 days,
            WithProtocolFee.ProtocolFee(address(0), 100)
        );

        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(address(withFeesAndTaxes));
        vm.prank(_borrower);
        collateralCollection.setApprovalForAll(address(_msLoan), true);
        return withFeesAndTaxes;
    }

    fallback() external payable {}

    receive() external payable {}
}
