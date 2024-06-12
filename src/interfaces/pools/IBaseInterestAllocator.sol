// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Interface for a Base Interest Allocator.
/// @author Florida St
/// @notice Pools have a base interest allocator for idle capital.
interface IBaseInterestAllocator {
    /// @notice Emitted on reallocation
    /// @param currentIdle The amount of assets that are currently available.
    /// @param targetIdle The amount of assets that should be available.
    event Reallocated(uint256 currentIdle, uint256 targetIdle);

    /// @notice Emitted when all assets are transferred.
    /// @param total The total amount of assets transferred.
    event AllTransfered(uint256 total);

    /// @return The base APR for the pool.
    function getBaseApr() external view returns (uint256);

    /// @return The base APR for the pool with potential update.
    function getBaseAprWithUpdate() external returns (uint256);

    /// @return The assets that are currently at the base rate.
    function getAssetsAllocated() external view returns (uint256);

    /// @notice Reallocate assets ot have `_targetIdle` assets available.
    /// @param _currentIdle The amount of assets that are currently available.
    /// @param _targetIdle The amount of assets that should be available.
    /// @param _force If true, reallocate regardless of cost.
    function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool _force) external;

    /// @notice Call when the pool is being closed to transfer all assets to the pool.
    function transferAll() external;
}
