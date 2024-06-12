// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/pools/FeeManager.sol";

contract FeeManagerTest is Test {
    using FixedPointMathLib for uint256;

    FeeManager private _feeManager;
    IFeeManager.Fees private _fees = IFeeManager.Fees(1e18, 1e19);

    function setUp() public {
        _feeManager = new FeeManager(_fees);
    }

    function testGetFees() public {
        FeeManager.Fees memory fees = _feeManager.getFees();
        assertEq(_fees.managementFee, fees.managementFee);
        assertEq(_fees.performanceFee, fees.performanceFee);
    }

    function testSetFees() public {
        IFeeManager.Fees memory newFees = IFeeManager.Fees(2e18, 2e19);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        _feeManager.setProposedFees(newFees);

        vm.prank(_feeManager.owner());
        _feeManager.setProposedFees(newFees);

        IFeeManager.Fees memory proposedFees = _feeManager.getProposedFees();

        assertEq(proposedFees.managementFee, newFees.managementFee);
        assertEq(proposedFees.performanceFee, newFees.performanceFee);
        assertEq(_feeManager.getProposedFeesSetTime(), block.timestamp);
        assertEq(_feeManager.getFees().managementFee, _fees.managementFee);
        assertEq(_feeManager.getFees().performanceFee, _fees.performanceFee);

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        _feeManager.confirmFees(newFees);

        vm.warp(_feeManager.WAIT_TIME() + 1);
        vm.expectRevert(abi.encodeWithSignature("InvalidFeesError()"));
        _feeManager.confirmFees(_fees);

        _feeManager.confirmFees(newFees);
        assertEq(_feeManager.getFees().managementFee, newFees.managementFee);
        assertEq(_feeManager.getFees().performanceFee, newFees.performanceFee);
        assertEq(_feeManager.getProposedFeesSetTime(), type(uint256).max);
    }

    function testProcessFees(uint256 _principal, uint256 _interest) public {
        uint256 principal = 1e5;
        uint256 interest = 1e6;
        uint256 totalFees = principal.mulDivDown(_fees.managementFee, _feeManager.PRECISION())
            + interest.mulDivDown(_fees.performanceFee, _feeManager.PRECISION());

        assertEq(_feeManager.processFees(principal, interest), totalFees);
    }
}
