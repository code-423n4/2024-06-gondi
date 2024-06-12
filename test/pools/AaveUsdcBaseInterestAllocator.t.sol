// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "src/lib/loans/LoanManagerParameterSetter.sol";
import "src/lib/pools/AaveUsdcBaseInterestAllocator.sol";
import "src/lib/pools/FeeManager.sol";
import "src/lib/pools/Pool.sol";
import "test/loans/MultiSourceCommons.sol";
import "test/utils/MockedAave.sol";
import "test/utils/SampleToken.sol";

contract AaveUsdcBaseInterestAllocatorTest is MultiSourceCommons {
    MockedAave private _aavePool;
    Pool private _pool;
    AaveUsdcBaseInterestAllocator private _baseAllocator;
    Pool.OptimalIdleRange private _optimalIdleRange = IPool.OptimalIdleRange(5e19, 75e18, 0);

    address payable private _aToken;
    address private constant _poolOfferHandler = address(1001);
    uint16 private constant _bonusAprAdjustment = 9500;
    uint16 private constant _bonusDepositAdjustment = 10500;
    uint256 private constant _maxTotalWithdrawalQueues = 4;

    address private _rewardsController = address(1002);
    address private _rewardsReceiver = address(1003);

    LoanManagerParameterSetter private _loanManagerParameterSetter =
        new LoanManagerParameterSetter(_poolOfferHandler, 3 days);

    function setUp() public override {
        super.setUp();
        _aavePool = new MockedAave(testToken);
        _pool = _getPool();
        _aToken = payable(address(_aavePool.aToken()));
        _baseAllocator = new AaveUsdcBaseInterestAllocator(
            address(_pool), address(_aavePool), address(testToken), _aToken, _rewardsController, _rewardsReceiver
        );

        ILoanManager.ProposedCaller[] memory proposedCaller = new LoanManager.ProposedCaller[](1);
        proposedCaller[0] = ILoanManager.ProposedCaller(address(this), true);

        vm.startPrank(_pool.owner());
        _loanManagerParameterSetter.setLoanManager(address(_pool));
        _loanManagerParameterSetter.requestAddCallers(proposedCaller);
        _pool.setBaseInterestAllocator(address(_baseAllocator));
        _pool.confirmBaseInterestAllocator();

        vm.warp(_pool.UPDATE_WAITING_TIME() + 1);
        _loanManagerParameterSetter.addCallers(proposedCaller);
        vm.warp(1);
        vm.stopPrank();
    }

    function testSetRewardsController() public {
        address newController = address(1004);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        _baseAllocator.setRewardsController(newController);

        vm.prank(_baseAllocator.owner());
        _baseAllocator.setRewardsController(newController);

        assertEq(_baseAllocator.getRewardsController(), newController);
    }

    function testSetRewardsReceiver() public {
        address newReceiver = address(1005);

        vm.expectRevert("UNAUTHORIZED");
        _baseAllocator.setRewardsReceiver(newReceiver);

        vm.prank(_baseAllocator.owner());
        _baseAllocator.setRewardsReceiver(newReceiver);

        assertEq(_baseAllocator.getRewardsReceiver(), newReceiver);
    }

    function testGetBaseApr() public {
        _aavePool.setAprBps(100);

        assertEq(_baseAllocator.getBaseApr(), 100);
        assertEq(_baseAllocator.getBaseAprWithUpdate(), 100);
    }

    function testGetAssetsAllocated() public {
        uint256 allocated = 1000;
        SampleToken(_aToken).mint(address(_baseAllocator), allocated);

        assertEq(_baseAllocator.getAssetsAllocated(), allocated);
    }

    function testReallocateMoreCurrent() public {
        uint256 idle = 1000;
        testToken.mint(address(_pool), idle);
        uint256 target = 150;

        vm.prank(address(_pool));
        _baseAllocator.reallocate(idle, target, true);

        assertEq(SampleToken(_aToken).balanceOf(address(_baseAllocator)), idle - target);
        assertEq(testToken.balanceOf(address(_pool)), target);
    }

    function testReallocateMoreIdle() public {
        uint256 idle = 150;
        testToken.mint(address(_pool), idle);
        uint256 target = 1000;
        testToken.mint(address(_aavePool), target - idle);
        SampleToken(_aToken).mint(address(_baseAllocator), target - idle);

        vm.prank(address(_pool));
        _baseAllocator.reallocate(idle, target, true);

        assertEq(SampleToken(_aToken).balanceOf(address(_baseAllocator)), 0);
        assertEq(testToken.balanceOf(address(_pool)), target);
    }

    function testTransferAll() public {
        uint256 atBaseRate = 1000;

        testToken.mint(address(_aavePool), atBaseRate);
        SampleToken(_aToken).mint(address(_baseAllocator), atBaseRate);

        vm.prank(address(_pool));
        _baseAllocator.transferAll();

        assertEq(SampleToken(_aToken).balanceOf(address(_baseAllocator)), 0);
        assertEq(SampleToken(testToken).balanceOf(address(_pool)), atBaseRate);
    }

    function _getPool() private returns (Pool) {
        vm.mockCall(_poolOfferHandler, abi.encodeWithSignature("getMaxDuration()"), abi.encode(365 days));
        return new Pool(
            address(new FeeManager(IFeeManager.Fees(50, 500))),
            address(_loanManagerParameterSetter),
            3 days,
            _optimalIdleRange,
            _maxTotalWithdrawalQueues,
            testToken,
            "Pool",
            "POOL",
            6
        );
    }
}
