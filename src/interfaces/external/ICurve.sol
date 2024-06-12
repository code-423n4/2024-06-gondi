// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.21;

/// @title Curve Interface
/// @author Florida St
/// @notice Subset of methods we called on the Curve Pool contract.
interface ICurve {
    function exchange(uint128 _i, uint128 _j, uint256 _dx, uint256 _min_dy) external payable returns (uint256);
}
