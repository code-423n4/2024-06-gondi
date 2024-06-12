// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "src/lib/loans/LoanManagerParameterSetter.sol";
import "src/lib/pools/FeeManager.sol";
import "src/lib/pools/LidoEthBaseInterestAllocator.sol";
import "src/lib/pools/PoolOfferHandler.sol";
import "src/lib/pools/Pool.sol";
import "test/loans/MultiSourceCommons.sol";
import "test/utils/SampleToken.sol";

contract LidoEthBaseInterestAllocatorTest is MultiSourceCommons {
    address private constant _poolOfferHandler = address(1001);
    uint16 private constant _bonusAprAdjustment = 9500;
    uint16 private constant _bonusDepositAdjustment = 10500;
    uint256 private constant _maxTotalWithdrawalQueues = 4;

    LoanManagerParameterSetter private _loanManagerParameterSetter =
        new LoanManagerParameterSetter(_poolOfferHandler, 3 days);

    LidoEthBaseInterestAllocator private _baseAllocator;

    Pool.OptimalIdleRange private _optimalIdleRange = IPool.OptimalIdleRange(5e19, 75e18, 0);

    SampleToken private _asset = new SampleToken();
    Pool private _pool;

    function setUp() public override {
        super.setUp();

        _pool = _getPool();
        _baseAllocator = new LidoEthBaseInterestAllocator(
            address(_pool), payable(address(_curvePool)), payable(address(testToken)), address(_lido), 1000, 1 days
        );

        ILoanManager.ProposedCaller[] memory proposedCaller = new ILoanManager.ProposedCaller[](1);
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

        vm.deal(address(testToken), 1e19);
        vm.deal(address(_curvePool), 1e19);
    }

    function testSetMaxSlippage() public {
        uint256 slippage = 1e4;
        vm.prank(_baseAllocator.owner());
        _baseAllocator.setMaxSlippage(slippage);

        assertEq(_baseAllocator.getMaxSlippage(), slippage);
    }

    function testGetBaseApr() public {
        assertEq(_baseAllocator.getBaseApr(), 1000);
    }

    function testBaseAprWithUpdateNotExpired() public {
        assertEq(_baseAllocator.getBaseAprWithUpdate(), 1000);
    }

    function testBaseAprWithUpdateExpired() public {
        (uint96 lastTs, uint144 shareRate,) = _baseAllocator.getLidoData();

        vm.warp(uint256(lastTs) + _baseAllocator.getLidoUpdateTolerance() + 1);
        uint256 newTotalShares = _lido.getTotalShares() * 2;
        uint256 newTotalPooledEther = _lido.getTotalPooledEther() * 201 / 100;

        _lido.setTotalShares(newTotalShares);
        _lido.setTotalPooledEther(newTotalPooledEther);

        uint256 newShareRate = newTotalPooledEther * 1e27 / newTotalShares;
        uint256 newAprBps =
            uint16(10000 * 365 days * (newShareRate - shareRate) / shareRate / (block.timestamp - lastTs));

        assertEq(_baseAllocator.getBaseAprWithUpdate(), newAprBps);
    }

    function testGetAssetsAllocated() public {
        uint256 balance = 1000;
        _lido.mint(address(_baseAllocator), balance);
        assertEq(_baseAllocator.getAssetsAllocated(), _lido.balanceOf(address(_baseAllocator)));
    }

    function testReallocateNotPool() public {
        vm.expectRevert(abi.encodeWithSignature("InvalidCallerError()"));
        _baseAllocator.reallocate(0, 0, false);
    }

    function testReallocateMoreIdle() public {
        uint256 poolMint = 1000;
        uint256 target = 500;

        _curvePool.setNextDy(target);
        testToken.mint(address(_pool), poolMint);

        uint256 currentBalance = testToken.balanceOf(address(_pool));
        vm.prank(_baseAllocator.getPool());
        _baseAllocator.reallocate(poolMint, target, false);

        assertEq(testToken.balanceOf(address(_pool)), currentBalance + target - poolMint);
    }

    function testReallocateLessIdle() public {
        uint256 poolMint = 500;
        uint256 target = 1000;

        _curvePool.setNextDy(target - poolMint);
        _lido.mint(address(_baseAllocator), poolMint);

        uint256 currentBalance = testToken.balanceOf(address(_pool));
        vm.prank(_baseAllocator.getPool());
        _baseAllocator.reallocate(poolMint, target, false);

        assertEq(testToken.balanceOf(address(_pool)), currentBalance + target - poolMint);
    }

    function testTransferAll() public {
        uint256 newMint = 1000;
        _lido.mint(address(_baseAllocator), newMint);
        _curvePool.setNextDy(newMint);

        uint256 poolBalance = testToken.balanceOf(address(_pool));

        vm.prank(_baseAllocator.getPool());
        _baseAllocator.transferAll();

        assertEq(_lido.balanceOf(address(_baseAllocator)), 0);
        assertEq(testToken.balanceOf(address(_pool)), poolBalance + newMint);
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
