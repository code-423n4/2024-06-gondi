// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "src/lib/pools/WithdrawalQueue.sol";
import "test/utils/SampleToken.sol";

contract WithdrawalQueueTest is Test {
    SampleToken private _asset = new SampleToken();

    function testDeploy() public {
        WithdrawalQueue queue = new WithdrawalQueue(_asset);
        assertEq(queue.getPool(), address(this));
    }

    function testMint() public {
        WithdrawalQueue queue = new WithdrawalQueue(_asset);

        address user = address(9999);
        uint256 shares = 1e5;
        uint256 tokenId = queue.mint(user, shares);

        assertEq(queue.getTotalShares(), shares);
        assertEq(queue.getShares(tokenId), shares);
        assertEq(queue.getNextTokenId() - 1, tokenId);
    }

    function testMintNotPool() public {
        WithdrawalQueue queue = new WithdrawalQueue(_asset);

        vm.prank(address(9999));
        vm.expectRevert(abi.encodeWithSignature("PoolOnlyCallableError()"));
        queue.mint(address(this), 1);
    }

    function testGetWithdrawablePerShare() public {
        WithdrawalQueue queue = new WithdrawalQueue(_asset);

        uint256 minted = 1e18;
        uint256 shares = 1e5;
        address user = address(9999);
        uint256 tokenId = queue.mint(user, shares);

        assertEq(queue.getAvailable(tokenId), 0);
        assertEq(queue.getWithdrawn(tokenId), 0);

        _asset.mint(address(queue), minted);

        assertEq(queue.getAvailable(tokenId), minted);

        vm.expectRevert(abi.encodeWithSignature("NotApprovedOrOwnerError()"));
        queue.withdraw(address(this), tokenId);

        vm.prank(user);
        uint256 withdrawn = queue.withdraw(user, tokenId);

        assertEq(_asset.balanceOf(user), withdrawn);
        assertEq(queue.getAvailable(tokenId), 0);

        vm.prank(user);
        withdrawn = queue.withdraw(user, tokenId);
        assertEq(withdrawn, 0);
    }

    function testLockWithdrawal() public {
        WithdrawalQueue queue = new WithdrawalQueue(_asset);

        address user = address(9999);
        uint256 shares = 1e5;
        uint256 tokenId = queue.mint(user, shares);

        uint256 lockedTime = 10;
        vm.expectRevert(abi.encodeWithSignature("NotApprovedOrOwnerError()"));
        queue.lockWithdrawals(tokenId, lockedTime);

        vm.prank(user);
        queue.lockWithdrawals(tokenId, lockedTime);

        assertEq(queue.getUnlockTime(tokenId), block.timestamp + lockedTime);

        uint256 minted = 1000;
        _asset.mint(address(queue), minted);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSignature(
                "CanOnlyExtendWithdrawalError(uint256,uint256)", tokenId, block.timestamp + lockedTime
            )
        );
        queue.lockWithdrawals(tokenId, lockedTime - 1);

        vm.expectRevert(
            abi.encodeWithSignature("WithdrawalsLockedError(uint256,uint256)", tokenId, block.timestamp + lockedTime)
        );
        queue.withdraw(user, tokenId);
    }
}
