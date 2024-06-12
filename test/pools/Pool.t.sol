// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/loans/LoanManagerParameterSetter.sol";
import "src/lib/pools/FeeManager.sol";
import "src/lib/pools/LidoEthBaseInterestAllocator.sol";
import "src/lib/pools/Pool.sol";
import "src/lib/pools/PoolOfferHandler.sol";
import "src/lib/pools/WithdrawalQueue.sol";
import "src/lib/utils/Interest.sol";
import "test/loans/MultiSourceCommons.sol";
import "test/utils/SampleToken.sol";

contract PoolTest is MultiSourceCommons {
    using FixedPointMathLib for uint256;
    using Interest for uint256;

    uint256 private constant _BPS = 10000;
    address private constant _user = address(11111);

    uint32 private _maxDuration = 365 days;
    PoolOfferHandler private _poolOfferHandler;
    LoanManagerParameterSetter private _loanManagerParameterSetter;
    LidoEthBaseInterestAllocator private _baseAllocator;
    uint256 private _maxTotalWithdrawalQueues = 4;

    uint16 private constant _bps = 10000;
    uint256 private constant _duration = 30 days;
    uint256 private constant _apr = 1000;
    uint256 private constant _principal = 1e18;

    Pool.OptimalIdleRange private _optimalIdleRange = IPool.OptimalIdleRange(5e18, 1e19, 75e17);

    SampleToken private _asset = new SampleToken();
    Pool private _pool;

    function setUp() public override {
        super.setUp();

        _poolOfferHandler = new PoolOfferHandler(_maxDuration, 3 days);
        _loanManagerParameterSetter = new LoanManagerParameterSetter(address(_poolOfferHandler), 3 days);
        _pool = _getPool();
        _baseAllocator = new LidoEthBaseInterestAllocator(
            address(_pool), payable(address(_curvePool)), payable(address(_asset)), address(_lido), 1000, 1 days
        );

        PoolOfferHandler.TermsKey[] memory termKeys = new PoolOfferHandler.TermsKey[](1);
        PoolOfferHandler.Terms[] memory terms = new PoolOfferHandler.Terms[](1);
        termKeys[0] = PoolOfferHandler.TermsKey(address(collateralCollection), _duration, 0);
        terms[0] = PoolOfferHandler.Terms(_principal, _apr);
        vm.startPrank(_poolOfferHandler.owner());
        _poolOfferHandler.setTerms(termKeys, terms);
        vm.warp(_poolOfferHandler.NEW_TERMS_WAITING_TIME() + 1);
        _poolOfferHandler.confirmTerms();
        vm.stopPrank();
        vm.warp(1);

        ILoanManager.ProposedCaller[] memory pendingCaller = new ILoanManager.ProposedCaller[](1);
        pendingCaller[0] = ILoanManager.ProposedCaller(address(this), true);

        vm.startPrank(_pool.owner());
        _loanManagerParameterSetter.setLoanManager(address(_pool));
        _loanManagerParameterSetter.requestAddCallers(pendingCaller);
        _pool.setBaseInterestAllocator(address(_baseAllocator));
        _pool.confirmBaseInterestAllocator();

        vm.warp(_pool.UPDATE_WAITING_TIME() + 1);
        _loanManagerParameterSetter.addCallers(pendingCaller);
        vm.warp(1);
        vm.stopPrank();

        _asset.mint(_user, 1e18);
        vm.deal(address(_asset), 1e19);
        vm.deal(address(_curvePool), 1e19);
    }

    function testInitializationVars() public {
        assertTrue(_pool.isActive());

        Pool.DeployedQueue memory deployedQueue = _pool.getDeployedQueue(0);

        assertTrue(deployedQueue.contractAddress != address(0));
        assertEq(deployedQueue.deployedTime, uint32(block.timestamp));

        /// (365 * 24 * 3600 + 7 * 24 * 3600) / 4
        uint256 LOAN_BUFFER_TIME = 7 days;
        uint256 expectedMinTime = (_maxDuration + LOAN_BUFFER_TIME) / _maxTotalWithdrawalQueues;

        assertEq(_pool.getMinTimeBetweenWithdrawalQueues(), expectedMinTime);
    }

    function testOptimalIdleRange() public {
        Pool pool = _getPool();

        (uint80 min, uint80 max, uint80 mid) = pool.getOptimalIdleRange();

        assertEq(min, _optimalIdleRange.min);
        assertEq(max, _optimalIdleRange.max);
        assertEq(mid, (_optimalIdleRange.min + _optimalIdleRange.max) / 2);

        Pool.OptimalIdleRange memory updated =
            IPool.OptimalIdleRange(_pool.PRINCIPAL_PRECISION() / 10, _pool.PRINCIPAL_PRECISION() / 5, 0);
        vm.prank(pool.owner());
        pool.setOptimalIdleRange(updated);

        (min, max, mid) = pool.getOptimalIdleRange();
        assertEq(min, updated.min);
        assertEq(max, updated.max);
        assertEq(mid, (updated.min + updated.max) / 2);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        pool.setOptimalIdleRange(_optimalIdleRange);
    }

    function testReallocate() public {
        uint256 deposit = 1e5;
        _deposit(deposit);

        uint256 toBeReallocated = _pool.totalAssets().mulDivDown(
            _pool.PRINCIPAL_PRECISION() - _optimalIdleRange.mid, _pool.PRINCIPAL_PRECISION()
        );
        _curvePool.setNextDy(toBeReallocated);
        uint256 reallocated = _pool.reallocate();

        assertEq(reallocated, toBeReallocated);
    }

    function testSetBaseInterestAllocator() public {
        Pool pool = _getPool();

        LidoEthBaseInterestAllocator allocator = new LidoEthBaseInterestAllocator(
            address(pool), payable(address(_curvePool)), payable(address(_asset)), address(_lido), 1000, 1 days
        );

        assertEq(pool.getProposedBaseInterestAllocator(), address(0));
        assertEq(pool.getProposedBaseInterestAllocatorSetTime(), type(uint256).max);
        assertEq(pool.getBaseInterestAllocator(), address(0));

        vm.expectRevert(bytes("UNAUTHORIZED"));
        pool.setBaseInterestAllocator(address(allocator));

        vm.startPrank(_pool.owner());
        pool.setBaseInterestAllocator(address(allocator));
        pool.confirmBaseInterestAllocator();
        assertEq(pool.getBaseInterestAllocator(), address(allocator));

        pool.setBaseInterestAllocator(address(_baseAllocator));

        assertEq(pool.getProposedBaseInterestAllocator(), address(_baseAllocator));
        assertEq(pool.getProposedBaseInterestAllocatorSetTime(), block.timestamp);
        assertEq(pool.getBaseInterestAllocator(), address(allocator));

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        pool.confirmBaseInterestAllocator();

        vm.warp(_pool.UPDATE_WAITING_TIME() + 1);

        pool.confirmBaseInterestAllocator();

        assertEq(pool.getBaseInterestAllocator(), address(_baseAllocator));
        assertEq(pool.getProposedBaseInterestAllocatorSetTime(), type(uint256).max);

        vm.stopPrank();
    }

    function testSetOfferHandler() public {
        LoanManagerParameterSetter poolLoanManagerParameterSetter =
            new LoanManagerParameterSetter(address(_poolOfferHandler), 3 days);
        Pool wrongPool = _getPool();
        Pool pool = new Pool(
            address(new FeeManager(IFeeManager.Fees(0, 0))),
            address(poolLoanManagerParameterSetter),
            3 days,
            _optimalIdleRange,
            _maxTotalWithdrawalQueues,
            _asset,
            "Pool",
            "POOL",
            6
        );
        vm.startPrank(poolLoanManagerParameterSetter.owner());
        vm.expectRevert(abi.encodeWithSignature("InvalidInputError()"));
        poolLoanManagerParameterSetter.setLoanManager(address(wrongPool));

        poolLoanManagerParameterSetter.setLoanManager(address(pool));
        vm.stopPrank();

        address newOfferHandler = address(1111);

        vm.mockCall(newOfferHandler, abi.encodeWithSignature("getMaxDuration()"), abi.encode(_maxDuration - 1));

        vm.expectRevert(bytes("UNAUTHORIZED"));
        poolLoanManagerParameterSetter.setOfferHandler(newOfferHandler);

        vm.startPrank(_loanManagerParameterSetter.owner());
        poolLoanManagerParameterSetter.setOfferHandler(newOfferHandler);

        assertEq(poolLoanManagerParameterSetter.getProposedOfferHandler(), newOfferHandler);

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        poolLoanManagerParameterSetter.confirmOfferHandler(newOfferHandler);

        vm.warp(pool.UPDATE_WAITING_TIME() + 1);

        vm.expectRevert(abi.encodeWithSignature("InvalidInputError()"));
        poolLoanManagerParameterSetter.confirmOfferHandler(address(2222));

        poolLoanManagerParameterSetter.confirmOfferHandler(newOfferHandler);

        assertEq(poolLoanManagerParameterSetter.getProposedOfferHandlerSetTime(), type(uint256).max);
        assertEq(pool.getOfferHandler(), newOfferHandler);

        vm.stopPrank();
    }

    function testPausePool() public {
        Pool pool = _getPool();

        assertEq(pool.isActive(), true);

        vm.prank(pool.owner());
        pool.pausePool();

        assertEq(pool.isActive(), false);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        pool.pausePool();
    }

    function testDeposit() public {
        uint256 tokens = 1;
        uint256 expectedShares = 10 ** _pool.decimalsOffset();

        uint256 shares = _deposit(tokens);

        assertEq(shares, expectedShares);
    }

    function testMint() public {
        uint256 shares = 10 ** _pool.decimalsOffset();
        uint256 expectedAssets = 1;

        vm.startPrank(_user);
        _asset.approve(address(_pool), expectedAssets);
        uint256 assets = _pool.mint(shares, _user);
        vm.stopPrank();

        assertEq(assets, expectedAssets);
    }

    function testWithdraw() public {
        uint256 tokens = 1;

        _deposit(tokens);
        vm.prank(_user);
        uint256 withdrawn = _pool.withdraw(tokens, _user, _user);

        assertEq(withdrawn, 10 ** _pool.decimalsOffset());
    }

    function testRedeem() public {
        uint256 shares = 10 ** _pool.decimalsOffset();

        vm.startPrank(_user);
        _asset.approve(address(_pool), 1);
        _pool.mint(shares, _user);
        uint256 redeemed = _pool.redeem(shares, _user, _user);
        vm.stopPrank();

        assertEq(redeemed, 1);
    }

    function testDepositNotActiveError() public {
        Pool pool = _getPool();

        vm.prank(pool.owner());
        pool.pausePool();

        vm.expectRevert(abi.encodeWithSignature("PoolStatusError()"));
        pool.deposit(1000, address(1111));
    }

    function testMintNotActiveError() public {
        Pool pool = _getPool();

        vm.prank(pool.owner());
        pool.pausePool();

        vm.expectRevert(abi.encodeWithSignature("PoolStatusError()"));
        pool.mint(1000, address(1111));
    }

    function testValidateOffer() public {
        _deposit(_principal);

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());

        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);
        Pool.OutstandingValues memory outstandingValues = _pool.getOutstandingValues();

        assertEq(outstandingValues.principalAmount, uint128(offerExecution.amount));
        assertEq(outstandingValues.accruedInterest, 0);
        assertEq(outstandingValues.sumApr, offerExecution.offer.aprBps * offerExecution.amount);
        assertEq(outstandingValues.lastTs, block.timestamp);
    }

    function testValidateNotActiveError() public {
        _deposit(_principal);
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());

        vm.prank(_pool.owner());
        _pool.pausePool();

        vm.expectRevert(abi.encodeWithSignature("PoolStatusError()"));
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);
    }

    function testInsufficientAssetsError() public {
        _deposit(_principal - 1);
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());

        vm.expectRevert(abi.encodeWithSignature("InsufficientAssetsError()"));
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);
    }

    function testLoanRepaymentNoWithdrawals() public {
        _deposit(_principal);

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());
        uint256 startTs = 1; // this is block.timestamp here
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);

        uint256 deltaTs = 2 days;
        vm.warp(startTs + deltaTs);

        _pool.loanRepayment(1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, startTs);

        Pool.OutstandingValues memory outstandinValues = _pool.getOutstandingValues();

        assertEq(outstandinValues.principalAmount, 0);
        assertEq(outstandinValues.accruedInterest, 0);
        assertEq(outstandinValues.sumApr, 0);
        assertEq(outstandinValues.lastTs, block.timestamp);
    }

    function testRepaymentWithFees() public {
        /// Fees = 1%, 10%
        IFeeManager.Fees memory newFees = IFeeManager.Fees(1e18, 1e19);
        FeeManager feeManager = FeeManager(address(_pool.getFeeManager()));
        vm.prank(feeManager.owner());
        feeManager.setProposedFees(newFees);
        vm.warp(feeManager.WAIT_TIME() + 1);
        vm.prank(feeManager.owner());
        feeManager.confirmFees(newFees);
        vm.warp(1);

        _deposit(_principal);

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());
        uint256 startTs = 1; // this is block.timestamp here
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);

        uint256 deltaTs = 2 days;
        vm.warp(startTs + deltaTs);

        _pool.loanRepayment(1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, startTs);

        uint256 interestPaid = offerExecution.amount.getInterest(offerExecution.offer.aprBps, deltaTs);
        uint256 fees = offerExecution.amount.mulDivDown(newFees.managementFee, feeManager.PRECISION())
            + interestPaid.mulDivDown(newFees.performanceFee, feeManager.PRECISION());

        Pool.OutstandingValues memory outstandingValues = _pool.getOutstandingValues();

        assertEq(_pool.getCollectedFees(), fees);
        assertEq(_pool.totalAssets(), _asset.balanceOf(address(_pool)) - fees);
        assertEq(outstandingValues.principalAmount, 0);
        assertEq(outstandingValues.sumApr, 0);
        assertEq(outstandingValues.accruedInterest, 0);

        address owner = _pool.owner();
        uint256 ownerPreviousBalance = _asset.balanceOf(owner);
        vm.prank(owner);
        _pool.collectFees(owner);

        assertEq(ownerPreviousBalance + fees, _asset.balanceOf(owner));
    }

    function testLiquidationWithFees() public {
        /// Fees = 1%, 10%
        IFeeManager.Fees memory newFees = IFeeManager.Fees(1e18, 1e19);
        FeeManager feeManager = FeeManager(address(_pool.getFeeManager()));
        vm.prank(feeManager.owner());
        feeManager.setProposedFees(newFees);
        vm.warp(feeManager.WAIT_TIME() + 1);
        vm.prank(feeManager.owner());
        feeManager.confirmFees(newFees);
        vm.warp(1);

        _deposit(_principal);

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());
        uint256 startTs = 1; // this is block.timestamp here
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);

        uint256 deltaTs = 2 days;
        vm.warp(startTs + deltaTs);

        uint256 received = offerExecution.amount / 2;
        _pool.loanLiquidation(
            address(this), 1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, received, startTs
        );

        uint256 fees = received.mulDivDown(newFees.managementFee, feeManager.PRECISION());

        Pool.OutstandingValues memory outstandingValues = _pool.getOutstandingValues();

        assertEq(_pool.getCollectedFees(), fees);
        // assertEq(_pool.totalAssets(), _asset.balanceOf(address(_pool)) - fees);
        assertEq(outstandingValues.principalAmount, 0);
        assertEq(outstandingValues.sumApr, 0);
        assertEq(outstandingValues.accruedInterest, 0);
    }

    function testDeployWithdrawalQueue() public {
        (uint256 withdrawn,) = _setupWithdrawal();
        uint256 totalShares = _pool.totalSupply();
        uint256 minTime = _pool.getMinTimeBetweenWithdrawalQueues();

        Pool.DeployedQueue memory deployedQueue = _pool.getDeployedQueue(1);
        assertEq(deployedQueue.contractAddress, address(0));
        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(1));
        vm.warp(minTime + 1);

        Pool.OutstandingValues memory poolOS = _pool.getOutstandingValues();
        _pool.deployWithdrawalQueue();

        deployedQueue = _pool.getDeployedQueue(0);
        Pool.OutstandingValues memory queueOS = _pool.getOutstandingValuesForQueue(0);
        Pool.QueueAccounting memory queueAcc = _pool.getAccountingValuesForQueue(0);

        assertEq(_pool.getAvailableToWithdraw(), 0);

        assertEq(queueOS.principalAmount, poolOS.principalAmount);
        assertEq(queueOS.accruedInterest, poolOS.accruedInterest);
        assertEq(queueOS.sumApr, poolOS.sumApr);
        assertEq(queueOS.lastTs, poolOS.lastTs);

        assertEq(queueAcc.thisQueueFraction, withdrawn.mulDivDown(_pool.PRINCIPAL_PRECISION(), totalShares));
        assertEq(
            queueAcc.netPoolFraction, (totalShares - withdrawn).mulDivDown(_pool.PRINCIPAL_PRECISION(), totalShares)
        );

        assertEq(withdrawn + _pool.totalSupply(), totalShares);

        assertEq(_asset.balanceOf(deployedQueue.contractAddress), 0);

        deployedQueue = _pool.getDeployedQueue(1);
        assertTrue(deployedQueue.contractAddress != address(0));
        assertEq(deployedQueue.deployedTime, uint32(block.timestamp));
    }

    function testDeployWithdrawalQueueTooSoon() public {
        Pool pool = _getPool();
        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        pool.deployWithdrawalQueue();
    }

    function testDeployWithdrawalQueueWithLastPending() public {
        uint256 totalQueues = _maxTotalWithdrawalQueues + 1;
        address[] memory queueAddresses = new address[](totalQueues);
        uint256[] memory withdrawnShares = new uint256[](totalQueues);
        uint256[] memory totalShares = new uint256[](totalQueues);
        uint256[] memory origBalances = new uint256[](totalQueues);
        uint256[] memory principals = new uint256[](totalQueues);
        uint256[] memory aprs = new uint256[](totalQueues);
        uint256 minTime = _pool.getMinTimeBetweenWithdrawalQueues();
        uint256 repayment;
        IMultiSourceLoan.OfferExecution memory offerExecution;
        for (uint256 i = 0; i < totalQueues;) {
            /// Cleaning the first one with pending
            if (i == totalQueues - 1) {
                repayment = principals[0] + principals[0].getInterest(aprs[0], block.timestamp - 1);
                _asset.mint(address(_pool), repayment);
                _pool.loanRepayment(0, principals[0], aprs[0], 0, 0, 1);
            }
            vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(i + 1));
            uint256 shares = _deposit(_principal * 2);
            totalShares[i] = _pool.totalSupply();
            _lido.setTotalPooledEther(_lido.getTotalPooledEther().mulDivUp(10050, 10000));
            offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());

            principals[i] = offerExecution.amount;
            aprs[i] = offerExecution.offer.aprBps;
            vm.prank(_user);
            _pool.redeem(shares / 2, _user, _user);
            withdrawnShares[i] = shares / 2;
            _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);
            vm.prank(address(_pool));
            _asset.transfer(address(0), offerExecution.amount);

            vm.warp(minTime * (i + 1) + 1);
            _pool.deployWithdrawalQueue();

            Pool.DeployedQueue memory thisQueue = _pool.getDeployedQueue(i);
            origBalances[i] = _asset.balanceOf(thisQueue.contractAddress);
            queueAddresses[i] = thisQueue.contractAddress;
            unchecked {
                ++i;
            }
        }

        /// Check repayment distribution
        uint256 remainder = repayment;
        for (uint256 i; i < totalQueues - 1;) {
            address thisQueue = queueAddresses[i];
            uint256 expected = remainder.mulDivDown(withdrawnShares[i], totalShares[i]);
            assertEq(_asset.balanceOf(thisQueue), origBalances[i] + expected);
            remainder -= expected;
            if (i > 0) {
                Pool.OutstandingValues memory queueOS = _pool.getOutstandingValuesForQueue(i);
                assertEq(queueOS.principalAmount, principals[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    function testLoanRepaymentWithWithdrawals() public {
        (, IMultiSourceLoan.OfferExecution memory offerExecution) = _setupWithdrawal();

        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(2));
        vm.warp(_pool.getMinTimeBetweenWithdrawalQueues() + 1);

        Pool.OutstandingValues memory poolOSPreDeploy = _pool.getOutstandingValues();
        _pool.deployWithdrawalQueue();

        uint256 receivedFirst = _pool.getTotalReceived(0);

        uint256 accruedInterest =
            offerExecution.amount.getInterest(offerExecution.offer.aprBps - protocolFee.fraction, block.timestamp - 1);
        uint256 repayment = offerExecution.amount + accruedInterest;

        Pool.OutstandingValues memory poolOS = _pool.getOutstandingValues();
        Pool.OutstandingValues memory queueOS = _pool.getOutstandingValuesForQueue(0);

        assertEq(poolOS.principalAmount, 0);
        assertEq(poolOS.accruedInterest, 0);
        assertEq(poolOS.sumApr, 0);

        assertEq(queueOS.principalAmount, poolOSPreDeploy.principalAmount);
        assertEq(queueOS.accruedInterest, poolOSPreDeploy.accruedInterest);
        assertEq(queueOS.sumApr, poolOSPreDeploy.sumApr);
        assertEq(queueOS.lastTs, poolOSPreDeploy.lastTs);

        _asset.mint(address(_pool), repayment);
        _pool.loanRepayment(1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, 1);

        queueOS = _pool.getOutstandingValuesForQueue(0);

        assertEq(queueOS.principalAmount, 0);
        assertEq(queueOS.accruedInterest, 0);
        assertEq(queueOS.sumApr, 0);

        assertEq(_pool.getTotalReceived(0), receivedFirst + repayment);
    }

    function testLoanRepaymentWithWithdrawalsAndMultipleOutstanding() public {
        /// Deposit = 2 * principal - One loan outstanding
        _deposit(_principal);
        (, IMultiSourceLoan.OfferExecution memory offerExecution) = _setupWithdrawal();

        IMultiSourceLoan.OfferExecution memory secondOfferExecution =
            _getBaseOfferExecution(_baseAllocator.getBaseApr());
        secondOfferExecution.amount = _principal / 2;
        _pool.validateOffer(abi.encode(secondOfferExecution), protocolFee.fraction);
        vm.prank(address(_pool));
        _asset.transfer(address(0), secondOfferExecution.amount);
        Pool.OutstandingValues memory outstandingValues = _pool.getOutstandingValues();

        uint256 expectedSumApr = (
            offerExecution.offer.aprBps * offerExecution.amount
                + secondOfferExecution.offer.aprBps * secondOfferExecution.amount
        ).mulDivDown(_BPS - protocolFee.fraction, _BPS);
        assertEq(outstandingValues.sumApr, expectedSumApr);
        assertEq(outstandingValues.accruedInterest, 0);

        // no pending withdrawals or assets at base rate
        uint256 balancePreDeploy = _asset.balanceOf(address(_pool));
        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(3));
        vm.warp(_pool.getMinTimeBetweenWithdrawalQueues() + 1);
        _pool.deployWithdrawalQueue();

        Pool.OutstandingValues memory queueOS = _pool.getOutstandingValuesForQueue(0);
        Pool.QueueAccounting memory queueAccounting = _pool.getAccountingValuesForQueue(0);
        uint256 balanceQueue = balancePreDeploy.mulDivUp(queueAccounting.thisQueueFraction, _pool.PRINCIPAL_PRECISION());
        Pool.DeployedQueue memory deployedQueue = _pool.getDeployedQueue(0);

        assertEq(_pool.getTotalReceived(0), 0);
        assertEq(_asset.balanceOf(address(_pool)), balancePreDeploy - balanceQueue);
        assertEq(_asset.balanceOf(deployedQueue.contractAddress), balanceQueue);

        /// First
        uint256 interestFirst = offerExecution.amount.getInterest(
            offerExecution.offer.aprBps.mulDivDown(_BPS - protocolFee.fraction, _BPS), block.timestamp - 1
        );
        uint256 interestSecond = secondOfferExecution.amount.getInterest(
            secondOfferExecution.offer.aprBps.mulDivDown(_BPS - protocolFee.fraction, _BPS), block.timestamp - 1
        );

        uint256 firstRepayment = offerExecution.amount + interestFirst;
        _pool.loanRepayment(1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, 1);
        _asset.mint(address(_pool), firstRepayment);

        queueOS = _pool.getOutstandingValuesForQueue(0);
        queueAccounting = _pool.getAccountingValuesForQueue(0);

        uint256 poolReceived =
            _pool.getTotalReceived(0).mulDivUp(queueAccounting.netPoolFraction, _pool.PRINCIPAL_PRECISION());
        uint256 poolOutstandingValue = (secondOfferExecution.amount + interestSecond).mulDivDown(
            queueAccounting.netPoolFraction, _pool.PRINCIPAL_PRECISION()
        );
        uint256 queueClaimable = _pool.getTotalReceived(0) - poolReceived;

        assertEq(_pool.getTotalReceived(0), firstRepayment);
        assertEq(queueAccounting.netPoolFraction, _pool.PRINCIPAL_PRECISION() - queueAccounting.thisQueueFraction);
        assertApproxEqAbs(_pool.getAvailableToWithdraw(), queueClaimable, 1);
        assertApproxEqAbs(_getTotalOutstandingValue(_pool), poolOutstandingValue, 1);
        assertApproxEqAbs(
            _pool.totalAssets(),
            _asset.balanceOf(address(_pool)) + poolOutstandingValue - _pool.getAvailableToWithdraw(),
            1
        );
        assertEq(queueOS.principalAmount, secondOfferExecution.amount);
        assertApproxEqAbs(queueOS.accruedInterest, interestSecond, 1);
        assertEq(queueOS.sumApr / queueOS.principalAmount, secondOfferExecution.offer.aprBps);
        assertEq(queueOS.lastTs, block.timestamp);

        /// Second
        uint256 shares = _pool.balanceOf(_user) / 2;
        uint256 preSecondDeployBalanceFirstQueue = _asset.balanceOf(address(deployedQueue.contractAddress));
        uint256 expectedTotalShares = _pool.totalSupply() - shares;
        uint256 poolBalancePreDeploy = _asset.balanceOf(address(_pool));
        uint256 expectedLiquidSecondQueue =
            (poolBalancePreDeploy - _pool.getAvailableToWithdraw()).mulDivUp(shares, _pool.totalSupply());

        vm.prank(_user);
        _pool.redeem(shares, _user, _user);
        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(3));
        vm.warp(2 * _pool.getMinTimeBetweenWithdrawalQueues() + 1);
        _pool.deployWithdrawalQueue();

        Pool.DeployedQueue memory deployedQueue2 = _pool.getDeployedQueue(1);

        assertApproxEqAbs(
            _asset.balanceOf(address(_pool)), poolBalancePreDeploy - queueClaimable - expectedLiquidSecondQueue, 1
        );
        assertApproxEqAbs(_asset.balanceOf(deployedQueue2.contractAddress), expectedLiquidSecondQueue, 1);
        assertEq(_asset.balanceOf(deployedQueue.contractAddress), preSecondDeployBalanceFirstQueue + queueClaimable);

        interestSecond = secondOfferExecution.amount.getInterest(
            secondOfferExecution.offer.aprBps.mulDivDown(_BPS - protocolFee.fraction, _BPS), block.timestamp - 1
        );
        uint256 secondRepayment = secondOfferExecution.amount + interestSecond;
        _pool.loanRepayment(
            2, secondOfferExecution.amount, secondOfferExecution.offer.aprBps, 0, protocolFee.fraction, 1
        );
        _asset.mint(address(_pool), secondRepayment);

        Pool.OutstandingValues memory secondQueueOS = _pool.getOutstandingValuesForQueue(1);
        Pool.QueueAccounting memory secondQueueAccounting = _pool.getAccountingValuesForQueue(1);
        uint128 fractionSecond = secondQueueAccounting.thisQueueFraction;
        uint128 previousNetPoolFraction = queueAccounting.netPoolFraction;
        queueAccounting = _pool.getAccountingValuesForQueue(0);

        assertEq(
            secondQueueAccounting.thisQueueFraction,
            shares.mulDivDown(_pool.PRINCIPAL_PRECISION(), expectedTotalShares + shares)
        );
        assertEq(_pool.totalSupply(), expectedTotalShares);
        assertEq(
            queueAccounting.netPoolFraction,
            previousNetPoolFraction
                - uint256(previousNetPoolFraction).mulDivUp(fractionSecond, _pool.PRINCIPAL_PRECISION())
        );
        assertEq(secondQueueAccounting.netPoolFraction, fractionSecond);
        assertEq(secondQueueOS.principalAmount, 0);
        assertEq(secondQueueOS.accruedInterest, 0);
        assertEq(secondQueueOS.sumApr, 0);

        uint256 pending = secondRepayment.mulDivDown(
            _pool.PRINCIPAL_PRECISION() - queueAccounting.netPoolFraction, _pool.PRINCIPAL_PRECISION()
        );
        outstandingValues = _pool.getOutstandingValues();
        Pool.OutstandingValues memory firstOutstandingValues = _pool.getOutstandingValuesForQueue(0);

        assertEq(outstandingValues.principalAmount, 0);
        assertEq(outstandingValues.accruedInterest, 0);
        assertEq(outstandingValues.sumApr, 0);

        assertEq(firstOutstandingValues.principalAmount, 0);
        assertEq(firstOutstandingValues.accruedInterest, 0);
        assertEq(firstOutstandingValues.sumApr, 0);
        assertEq(_pool.getTotalReceived(0), secondRepayment);
        assertEq(_pool.getAvailableToWithdraw(), pending);

        // This one shouldn't change things
        _deposit(_principal);
        _lido.setTotalPooledEther(_lido.getTotalPooledEther().mulDivUp(10050, 10000));
        IMultiSourceLoan.OfferExecution memory thirdOfferExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());
        _pool.validateOffer(abi.encode(thirdOfferExecution), protocolFee.fraction);
        vm.prank(address(_pool));
        _asset.transfer(address(0), thirdOfferExecution.amount);

        assertEq(_pool.getTotalReceived(0), secondRepayment);

        uint256 balanceQueueOne = _asset.balanceOf(deployedQueue.contractAddress);
        uint256 balanceQueueTwo = _asset.balanceOf(deployedQueue2.contractAddress);
        _pool.queueClaimAll();

        uint256 secondRepaymentToFirstQueue =
            secondRepayment.mulDivDown(queueAccounting.thisQueueFraction, _pool.PRINCIPAL_PRECISION());
        uint256 secondRepaymentToSecondQueue =
            (secondRepayment - secondRepaymentToFirstQueue).mulDivDown(fractionSecond, _pool.PRINCIPAL_PRECISION());

        assertEq(balanceQueueOne + secondRepaymentToFirstQueue, _asset.balanceOf(deployedQueue.contractAddress));
        assertEq(balanceQueueTwo + secondRepaymentToSecondQueue, _asset.balanceOf(deployedQueue2.contractAddress));
    }

    function testReallocateOnWithdrawal() public {
        _setupWithdrawal();

        uint256 deposit = 1e5;
        _deposit(deposit);
        uint256 totalAssets = _asset.balanceOf(address(_pool));
        uint256 toBeReallocated =
            totalAssets.mulDivDown(_pool.PRINCIPAL_PRECISION() - _optimalIdleRange.mid, _pool.PRINCIPAL_PRECISION());
        Pool.DeployedQueue memory pendingQueue = _pool.getDeployedQueue(_pool.getPendingQueueIndex());

        uint256 sharesPendingWithdrawal = WithdrawalQueue(pendingQueue.contractAddress).getTotalShares();
        uint256 totalShares = _pool.totalSupply();
        uint256 expectedLiquidTransfer =
            _asset.balanceOf(address(_pool)).mulDivDown(sharesPendingWithdrawal, totalShares);

        _curvePool.setNextDy(toBeReallocated);
        _pool.reallocate();

        _curvePool.setNextDy(deposit / 2 - 1 - _asset.balanceOf(address(_pool)) / 2);
        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(2));
        vm.warp(2 * _pool.getMinTimeBetweenWithdrawalQueues() + 1);
        _pool.deployWithdrawalQueue();

        assertEq(_asset.balanceOf(address(pendingQueue.contractAddress)), expectedLiquidTransfer);
    }

    function testLoanLiquidated() public {
        (, IMultiSourceLoan.OfferExecution memory offerExecution) = _setupWithdrawal();

        vm.mockCall(address(this), abi.encodeWithSignature("getTotalLoansIssued()"), abi.encode(2));
        vm.warp(_pool.getMinTimeBetweenWithdrawalQueues() + 1);
        _pool.deployWithdrawalQueue();

        vm.warp(_pool.getMinTimeBetweenWithdrawalQueues() + 1 days + 1);
        uint256 proceeds = 1e5;
        _pool.loanLiquidation(
            address(this), 1, offerExecution.amount, offerExecution.offer.aprBps, 0, protocolFee.fraction, proceeds, 1
        );
        _asset.mint(address(_pool), proceeds);

        assertEq(_pool.getTotalReceived(0), proceeds);
    }

    function _getPool() private returns (Pool) {
        return new Pool(
            address(new FeeManager(IFeeManager.Fees(0, 0))),
            address(_loanManagerParameterSetter),
            3 days,
            _optimalIdleRange,
            _maxTotalWithdrawalQueues,
            _asset,
            "Pool",
            "POOL",
            6
        );
    }

    function _deposit(uint256 _tokens) private returns (uint256) {
        return _setupUser(_user, _tokens);
    }

    function _getBaseOfferExecution(uint256 _baseRate) private returns (IMultiSourceLoan.OfferExecution memory) {
        IMultiSourceLoan.LoanOffer memory offer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _principal);
        offer.duration = _duration;
        offer.aprBps =
            _baseRate + _poolOfferHandler.getAprPremium(address(collateralCollection), _duration, 0, _principal);
        return IMultiSourceLoan.OfferExecution(offer, _principal, "");
    }

    function _setupWithdrawal() private returns (uint256, IMultiSourceLoan.OfferExecution memory) {
        uint256 shares = _deposit(_principal);

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(_baseAllocator.getBaseApr());
        _pool.validateOffer(abi.encode(offerExecution), protocolFee.fraction);
        vm.prank(address(_pool));
        _asset.transfer(address(0), offerExecution.amount);

        uint256 withdraw = shares / 2;
        vm.prank(_user);
        _pool.redeem(withdraw, _user, _user);

        return (withdraw, offerExecution);
    }

    function _setupUser(address __user, uint256 _tokens) private returns (uint256) {
        vm.startPrank(__user);
        _asset.mint(__user, _tokens);
        _asset.approve(address(_pool), _tokens);
        uint256 shares = _pool.deposit(_tokens, __user);
        vm.stopPrank();
        return shares;
    }

    function _getTotalOutstandingValue(Pool __pool) private view returns (uint256) {
        uint256 undeployedAssets = __pool.asset().balanceOf(address(__pool))
            + IBaseInterestAllocator(__pool.getBaseInterestAllocator()).getAssetsAllocated()
            - __pool.getAvailableToWithdraw();
        return _pool.totalAssets() - undeployedAssets;
    }
}
