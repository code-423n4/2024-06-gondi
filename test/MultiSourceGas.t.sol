// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.21;

import "src/lib/AuctionLoanLiquidator.sol";
import "src/lib/LiquidationDistributor.sol";
import "src/lib/LiquidationHandler.sol";
import "src/lib/loans/MultiSourceLoan.sol";
import "src/lib/loans/LoanManagerParameterSetter.sol";
import "src/lib/pools/LidoEthBaseInterestAllocator.sol";
import "src/lib/pools/FeeManager.sol";
import "src/lib/pools/Pool.sol";
import "src/lib/pools/PoolOfferHandler.sol";
import "src/lib/utils/Interest.sol";
import "test/loans/MultiSourceCommons.sol";

contract MultiSourceLoanTest is MultiSourceCommons {
    Pool private _pool;

    LidoEthBaseInterestAllocator private _baseInterestAllocator;
    address private _lp = address(99999);
    PoolOfferHandler private _poolOfferHandler;
    LoanManagerParameterSetter private _loanManagerParameterSetter;

    function setUp() public override {
        _poolOfferHandler = new PoolOfferHandler(30 days, 3 days);
        _loanManagerParameterSetter = new LoanManagerParameterSetter(address(_poolOfferHandler), 3 days);

        _maxTranches = 20;
        super.setUp();
        _setupPool();
    }

    function testEmitMultiGas() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, 100);
        vm.startPrank(_borrower);
        IMultiSourceLoan.OfferExecution[] memory offerExecution = new IMultiSourceLoan.OfferExecution[](1);
        offerExecution[0] = IMultiSourceLoan.OfferExecution(loanOffer, loanOffer.principalAmount, "");
        uint256 a = gasleft();
        _msLoan.emitLoan(
            IMultiSourceLoan.LoanExecutionData(
                IMultiSourceLoan.ExecutionData(
                    offerExecution,
                    collateralTokenId,
                    loanOffer.duration,
                    loanOffer.expirationTime,
                    _borrower,
                    abi.encode()
                ),
                _borrower,
                abi.encode(0)
            )
        );
        uint256 b = gasleft();
        vm.stopPrank();
        console.logString("Emit Multi Source:");
        console.logUint(a - b);
    }

    function testEmitWithPoolGas() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, 100);
        _setHandlerOffer(loanOffer);
        loanOffer.lender = address(_pool);
        vm.startPrank(_borrower);
        IMultiSourceLoan.OfferExecution[] memory offerExecution = new IMultiSourceLoan.OfferExecution[](1);
        offerExecution[0] = IMultiSourceLoan.OfferExecution(loanOffer, loanOffer.principalAmount, "");
        console.logString("1");
        uint256 a = gasleft();
        _msLoan.emitLoan(
            IMultiSourceLoan.LoanExecutionData(
                IMultiSourceLoan.ExecutionData(
                    offerExecution,
                    collateralTokenId,
                    loanOffer.duration,
                    loanOffer.expirationTime,
                    _borrower,
                    abi.encode()
                ),
                _borrower,
                abi.encode(0)
            )
        );
        uint256 b = gasleft();
        vm.stopPrank();
        console.logString("Emit Multi Source:");
        console.logUint(a - b);
    }

    function testRefinanceManyPartialSourcesGas() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        uint256 newRefis = _maxTranches - 1;
        uint256 principalAmount = loan.principalAmount;

        uint256 baseAddress = 4000;
        console.logString("Refinance Many Partial:");
        for (uint256 i = 0; i < newRefis;) {
            vm.warp(block.timestamp + 1 days);
            IMultiSourceLoan.RenegotiationOffer memory refiOffer =
                _getSampleRenegotiationNewTranche(loanId, loan, loan.tranche[0].principalAmount, loan.tranche[0].aprBps);
            address thisUser = address(uint160(baseAddress + i));
            _addUser(thisUser, principalAmount * 20, address(_msLoan));

            refiOffer.lender = thisUser;
            uint256 a = gasleft();
            vm.prank(_borrower);
            (loanId, loan) = _msLoan.addNewTranche(refiOffer, loan, abi.encode());
            uint256 b = gasleft();
            console.logString("Gas cost refinance. Refi: ");
            console.logUint(i);
            console.logUint(a - b);
            console.logString("------");
            unchecked {
                ++i;
            }
        }
    }

    function testRefinanceFullWithManySourcesGas() public {
        uint256 tranches = _msLoan.getMaxTranches();
        uint256 mintedAmount = 1e18;
        testToken.mint(_borrower, mintedAmount);
        vm.prank(_borrower);
        testToken.approve(address(_msLoan), mintedAmount);
        console.logString("Refinance Many Full:");
        for (uint256 i = 2; i < tranches;) {
            vm.warp(1);
            _maxTranches = i;
            /// @dev `_setupRefinanceFull` returns a loan with _maxTranches - 1
            (uint256 loanId, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
                _setupRefinanceFull();

            vm.prank(_refinanceLender);
            uint256 a = gasleft();
            (loanId, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
            uint256 b = gasleft();
            console.logUint(i);
            console.logUint(a - b);
            console.logString("------");

            vm.startPrank(_borrower);
            _msLoan.repayLoan(
                IMultiSourceLoan.LoanRepaymentData(IMultiSourceLoan.SignableRepaymentData(loanId, "", false), loan, "")
            );
            collateralCollection.approve(address(_msLoan), collateralTokenId);
            vm.stopPrank();
            unchecked {
                ++i;
            }
        }
    }

    function testRepayGas() public {
        uint256 sources = _msLoan.getMaxTranches();
        uint256 mintedAmount = 1e18;
        testToken.mint(_borrower, mintedAmount);
        vm.prank(_borrower);
        testToken.approve(address(_msLoan), mintedAmount);
        console.logString("Repay (different sources):");
        for (uint256 i = 2; i < sources;) {
            vm.warp(1);
            _maxTranches = i;
            /// @dev `_setupRefinanceFull` returns a loan with _maxTranches - 1
            (uint256 loanId, IMultiSourceLoan.Loan memory loan,) = _setupRefinanceFull();

            vm.startPrank(_borrower);
            uint256 a = gasleft();
            _msLoan.repayLoan(
                IMultiSourceLoan.LoanRepaymentData(IMultiSourceLoan.SignableRepaymentData(loanId, "", false), loan, "")
            );
            uint256 b = gasleft();
            collateralCollection.approve(address(_msLoan), collateralTokenId);
            vm.stopPrank();
            console.logUint(i);
            console.logUint(a - b);
            console.logString("------");
            unchecked {
                ++i;
            }
        }
    }

    function testLiquidationGas() public {
        uint256 sources = _msLoan.getMaxTranches();
        LiquidationDistributor distributor = new LiquidationDistributor(address(_loanManagerRegistry));
        AuctionLoanLiquidator liquidator = new AuctionLoanLiquidator(
            address(distributor), address(currencyManager), address(collectionManager), TRIGGER_FEE, 3 days
        );
        vm.prank(liquidator.owner());
        distributor.setLiquidator(address(liquidator));
        vm.prank(liquidator.owner());
        liquidator.addLoanContract(address(_msLoan));
        vm.prank(_msLoan.owner());
        _msLoan.updateLiquidationContract(address(liquidator));
        console.logString("Liquidation (different sources):");
        uint256 mintedAmount = 1e18;
        testToken.mint(_borrower, mintedAmount);
        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), mintedAmount);
        testToken.approve(_msLoan.getLiquidator(), mintedAmount);
        vm.stopPrank();
        for (uint256 i = 3; i < sources;) {
            vm.warp(1);
            _maxTranches = i;
            /// @dev `_setupRefinanceFull` returns a loan with _maxTranches - 2
            (uint256 loanId, IMultiSourceLoan.Loan memory loan,) = _setupRefinanceFull();

            vm.warp(loan.startTime + loan.duration + 1);
            uint256 a = gasleft();
            console.logString("Liquidation");
            bytes memory encodedAuction = _msLoan.liquidateLoan(loanId, loan);
            IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));
            uint256 b = gasleft();

            console.logUint(loan.tranche.length);
            console.logUint(a - b);

            vm.startPrank(_borrower);
            auction =
                liquidator.placeBid(address(collateralCollection), collateralTokenId, auction, loan.principalAmount / 2);

            vm.warp(block.timestamp + _msLoan.getLiquidationAuctionDuration() + 1);
            assertEq(collateralCollection.ownerOf(collateralTokenId), address(liquidator));
            a = gasleft();
            liquidator.settleAuction(auction, loan);
            b = gasleft();
            console.logString("Settlement");
            console.logUint(a - b);
            console.logString("------");
            assertEq(collateralCollection.ownerOf(collateralTokenId), _borrower);
            collateralCollection.approve(address(_msLoan), collateralTokenId);
            vm.stopPrank();

            unchecked {
                ++i;
            }
        }
    }

    function _setupPool() private {
        Pool.OptimalIdleRange memory optimalIdleRange = IPool.OptimalIdleRange(5e19, 75e18, 0);
        _pool = new Pool(
            address(new FeeManager(IFeeManager.Fees(50, 500))),
            address(_loanManagerParameterSetter),
            3 days,
            optimalIdleRange,
            4,
            testToken,
            "Pool",
            "POOL",
            6
        );
        _baseInterestAllocator = new LidoEthBaseInterestAllocator(
            address(_pool), payable(address(_curvePool)), payable(address(testToken)), address(_lido), 1000, 1 days
        );

        ILoanManager.ProposedCaller[] memory proposedCaller = new LoanManager.ProposedCaller[](1);
        proposedCaller[0] = ILoanManager.ProposedCaller(address(_msLoan), true);
        vm.startPrank(_pool.owner());

        _pool.setBaseInterestAllocator(address(_baseInterestAllocator));
        _pool.confirmBaseInterestAllocator();
        _loanManagerParameterSetter.setLoanManager(address(_pool));
        _loanManagerParameterSetter.requestAddCallers(proposedCaller);
        _loanManagerRegistry.addLoanManager(address(_pool));

        vm.warp(_pool.UPDATE_WAITING_TIME() + 1);
        _loanManagerParameterSetter.addCallers(proposedCaller);
        vm.warp(1);
        vm.stopPrank();

        uint256 amount = 1e19;
        testToken.mint(_lp, amount);
        vm.startPrank(_lp);
        testToken.approve(address(_pool), amount);
        _pool.deposit(amount, address(this));
        vm.stopPrank();
    }

    function _setHandlerOffer(IMultiSourceLoan.LoanOffer memory _offer) private {
        PoolOfferHandler.TermsKey[] memory termKeys = new PoolOfferHandler.TermsKey[](1);
        PoolOfferHandler.Terms[] memory terms = new PoolOfferHandler.Terms[](1);
        termKeys[0] = PoolOfferHandler.TermsKey(_offer.nftCollateralAddress, _offer.duration, 0);
        terms[0] = PoolOfferHandler.Terms(_offer.principalAmount, 10);
        vm.startPrank(_poolOfferHandler.owner());
        _poolOfferHandler.setTerms(termKeys, terms);
        vm.warp(_poolOfferHandler.NEW_TERMS_WAITING_TIME() + 1);
        _poolOfferHandler.confirmTerms();
        vm.stopPrank();
        vm.warp(1);
    }
}
