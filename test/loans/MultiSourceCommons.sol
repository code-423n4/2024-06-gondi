// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@delegate/DelegateRegistry.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/loans/MultiSourceLoan.sol";
import "src/lib/loans/LoanManagerRegistry.sol";
import "src/lib/utils/Interest.sol";
import "test/loans/TestLoanSetup.sol";
import "test/utils/MockedCurve.sol";
import "test/utils/MockedLido.sol";
import "test/TestNFTFlashAction.sol";

abstract contract MultiSourceCommons is TestLoanSetup {
    using FixedPointMathLib for uint256;
    using Interest for uint256;

    uint256 internal constant _PRINCIPAL_DELTA = 1e6;
    uint256 internal constant _INITIAL_PRINCIPAL = 1e8;

    MultiSourceLoan internal _msLoan;
    MultiSourceLoan internal _msLoanWithFee;
    LoanManagerRegistry internal _loanManagerRegistry;
    uint256 internal _maxTranches = 20;
    uint256 internal _minLockPeriod = 0;
    DelegateRegistry internal _delegationRegistry;
    INFTFlashAction internal _flashActionContract;

    address internal _borrower;
    address internal _originalLender;
    address internal _refinanceLender;

    address payable internal _weth = payable(address(new SampleToken()));
    MockedLido internal _lido = new MockedLido();
    MockedCurve internal _curvePool = new MockedCurve(_lido);
    uint128 internal immutable _fee = 100;
    address internal immutable _protocol = address(8888);

    function setUp() public virtual {
        _lido.setTotalShares(1e18);
        _lido.setTotalPooledEther(1e18);
        baseSetup();
        _delegationRegistry = new DelegateRegistry();
        _flashActionContract = new TestNFTFlashAction();
        _loanManagerRegistry = new LoanManagerRegistry();
        _msLoan = new MultiSourceLoan(
            liquidationContract,
            protocolFee,
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            _minLockPeriod,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );
        loanSetUp(address(_msLoan));

        _msLoanWithFee = new MultiSourceLoan(
            liquidationContract,
            WithProtocolFee.ProtocolFee({fraction: _fee, recipient: _protocol}),
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            _minLockPeriod,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );

        _borrower = userA;
        _originalLender = userB;
        _refinanceLender = userC;
    }

    function _getInitialLoan() internal returns (uint256, IMultiSourceLoan.Loan memory) {
        return _getInitialLoanWithPrincipalReceiver(_borrower);
    }

    function _getInitialLoanWithPrincipalReceiver(address principalReceiver)
        internal
        returns (uint256, IMultiSourceLoan.Loan memory)
    {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.duration = 30 days;
        return _msLoan.emitLoan(
            IMultiSourceLoan.LoanExecutionData(_sampleExecutionData(loanOffer, principalReceiver), _borrower, "")
        );
    }

    function _sampleLoanExecutionData(IMultiSourceLoan.LoanOffer memory _offer)
        internal
        view
        returns (IMultiSourceLoan.LoanExecutionData memory)
    {
        return IMultiSourceLoan.LoanExecutionData(_sampleExecutionData(_offer, _borrower), _borrower, "");
    }

    function _sampleMultipleOffersLoanExecutionData(IMultiSourceLoan.LoanOffer[] memory _offers)
        internal
        view
        returns (IMultiSourceLoan.LoanExecutionData memory)
    {
        IMultiSourceLoan.OfferExecution[] memory offerExecution = new IMultiSourceLoan.OfferExecution[](_offers.length);
        uint256 totalAmountAhead = 0;
        for (uint256 i = 0; i < _offers.length; i++) {
            uint256 amount = _offers[i].principalAmount - totalAmountAhead;
            offerExecution[i] = IMultiSourceLoan.OfferExecution(_offers[i], amount, "");
            totalAmountAhead = _offers[i].principalAmount;
        }
        IMultiSourceLoan.ExecutionData memory executionData = IMultiSourceLoan.ExecutionData(
            offerExecution,
            _offers[0].nftCollateralTokenId,
            _offers[0].duration,
            _offers[0].expirationTime,
            _borrower,
            ""
        );
        return IMultiSourceLoan.LoanExecutionData(executionData, _borrower, "");
    }

    function _getSampleRefinancePartial(
        uint256 _loanId,
        uint256[] memory _trancheIndex,
        IMultiSourceLoan.Loan memory _loan
    ) internal view returns (IMultiSourceLoan.RenegotiationOffer memory) {
        uint256 currentAmount = 0;
        for (uint256 i = 0; i < _trancheIndex.length;) {
            currentAmount += _loan.tranche[_trancheIndex[i]].principalAmount;
            unchecked {
                ++i;
            }
        }

        return IMultiSourceLoan.RenegotiationOffer(
            1,
            _loanId,
            _refinanceLender,
            0,
            _trancheIndex,
            currentAmount,
            _loan.tranche[_trancheIndex[0]].aprBps * 2 / 3,
            /// @dev assuming lowest apr on first tranche
            block.timestamp + 15 days,
            0
        );
    }

    function _getSampleRefinanceFull(
        uint256 _loanId,
        IMultiSourceLoan.Loan memory _loan
    ) internal view returns (IMultiSourceLoan.RenegotiationOffer memory) {
        uint256[] memory trancheIndex = new uint256[](_loan.tranche.length);
        return _getSampleRefinancePartial(_loanId, trancheIndex, _loan);
    }

    function _setupMultipleRefi(uint256 _newRefis)
        internal
        returns (uint256 loanId, IMultiSourceLoan.Loan memory loan)
    {
        (loanId, loan) = _getInitialLoan();
        IMultiSourceLoan.RenegotiationOffer memory refiOffer;
        address thisUser;
        IMultiSourceLoan.Tranche memory tranche = loan.tranche[0];

        uint256 baseAddress = 4000;
        uint256 delta = 1 days;
        uint256[] memory first = new uint256[](1);
        first[0] = 0;
        for (uint256 i = 0; i < _newRefis;) {
            vm.warp(block.timestamp + delta);
            tranche = loan.tranche[0];
            thisUser = address(uint160(baseAddress + i));
            refiOffer = _getSampleRenegotiationNewTranche(loanId, loan, tranche.principalAmount, tranche.aprBps + 10);
            refiOffer.lender = thisUser;
            /// add extra tranche
            _addUser(thisUser, refiOffer.principalAmount, address(_msLoan));

            refiOffer.lender = thisUser;
            vm.prank(_borrower);
            (loanId, loan) = _msLoan.addNewTranche(refiOffer, loan, abi.encode());
            unchecked {
                ++i;
            }
        }
    }

    function _setupRefinanceFull()
        internal
        returns (
            uint256 loanId,
            IMultiSourceLoan.Loan memory loan,
            IMultiSourceLoan.RenegotiationOffer memory refiOffer
        )
    {
        (loanId, loan) = _setupMultipleRefi(_maxTranches - 2);

        uint256 delta = 1 days;
        vm.warp(block.timestamp + delta);
        uint256 owed = 0;
        for (uint256 i = 0; i < loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        uint256 totalLenders = loan.tranche.length;
        /// @dev All 0s - this is ignored in a refiFull
        uint256[] memory trancheIndex = new uint256[](totalLenders);

        refiOffer = IMultiSourceLoan.RenegotiationOffer(
            1, // renegotiationId
            loanId,
            _refinanceLender,
            0, // fee
            trancheIndex,
            loan.principalAmount,
            loan.tranche[0].aprBps.mulDivDown(9000, 10000), // 10% less
            block.timestamp + 10,
            loan.duration
        );

        testToken.mint(_refinanceLender, owed);
        vm.prank(_refinanceLender);
        testToken.approve(address(_msLoan), owed);
    }

    function _sampleExecutionData(IMultiSourceLoan.LoanOffer memory _offer, address _principalReceiver)
        internal
        pure
        returns (IMultiSourceLoan.ExecutionData memory)
    {
        IMultiSourceLoan.OfferExecution[] memory offerExecution = new IMultiSourceLoan.OfferExecution[](1);
        offerExecution[0] = IMultiSourceLoan.OfferExecution(_offer, _offer.principalAmount, "");
        return IMultiSourceLoan.ExecutionData(
            offerExecution, _offer.nftCollateralTokenId, _offer.duration, _offer.expirationTime, _principalReceiver, ""
        );
    }

    /// @dev Helper to avoid EVM stack issues
    function _setupEmitLoanWithFee()
        internal
        returns (uint256 balanceProtocol, uint256 balanceLender, uint256 balanceBorrower)
    {
        _setupLoanWithFee();
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.ExecutionData memory executionData = _sampleExecutionData(loanOffer, _borrower);
        executionData.callbackData = abi.encode(0);
        IMultiSourceLoan.LoanExecutionData memory data =
            IMultiSourceLoan.LoanExecutionData(executionData, _borrower, abi.encode(0));

        balanceProtocol = testToken.balanceOf(_protocol);
        balanceLender = testToken.balanceOf(_originalLender);
        balanceBorrower = testToken.balanceOf(_borrower);

        vm.startPrank(_borrower);
        _msLoanWithFee.emitLoan(data);
        vm.stopPrank();
    }

    function _setupLoanWithFee() internal {
        vm.mockCall(
            _borrower,
            abi.encodeWithSelector(ILoanCallback.afterPrincipalTransfer.selector),
            abi.encode(ILoanCallback.afterPrincipalTransfer.selector)
        );
        vm.mockCall(
            _borrower,
            abi.encodeWithSelector(ILoanCallback.afterNFTTransfer.selector),
            abi.encode(ILoanCallback.afterNFTTransfer.selector)
        );
        loanSetUp(address(_msLoanWithFee));
    }

    function _sampleRepaymentData(uint256 _loanId, IMultiSourceLoan.Loan memory _loan)
        internal
        pure
        returns (IMultiSourceLoan.LoanRepaymentData memory)
    {
        return IMultiSourceLoan.LoanRepaymentData(IMultiSourceLoan.SignableRepaymentData(_loanId, "", false), _loan, "");
    }

    function _getSampleRenegotiationNewTranche(
        uint256 _loanId,
        IMultiSourceLoan.Loan memory _loan,
        uint256 _principalAmount,
        uint256 _aprBps
    ) internal view returns (IMultiSourceLoan.RenegotiationOffer memory) {
        uint256[] memory trancheIndex = new uint256[](1);
        trancheIndex[0] = _loan.tranche.length;
        return IMultiSourceLoan.RenegotiationOffer(
            1, // renegotiationId
            _loanId,
            _refinanceLender,
            0, // fee
            trancheIndex,
            _principalAmount, // principalAmount
            _aprBps,
            block.timestamp + 10,
            _loan.duration
        );
    }
}
