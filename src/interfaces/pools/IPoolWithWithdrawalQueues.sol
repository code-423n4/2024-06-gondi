// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Interface for a Pool With Withdrawal Queues.
/// @author Florida St
/// @notice Functions for a pool with withdrawal queues (does not include base methods for any given pool. Reference: `IPool.sol`)
interface IPoolWithWithdrawalQueues {
    /// @param contractAddress Address of the deployed queue.
    /// @param deployedTime Time of deployment.
    struct DeployedQueue {
        address contractAddress;
        uint96 deployedTime;
    }

    /// @notice Return the deployed queue at index `_idx`.
    /// @param _idx Index of the deployed queue.
    /// @return DeployedQueue struct.
    function getDeployedQueue(uint256 _idx) external view returns (DeployedQueue memory);

    /// @notice Distribute available capital to all queues.
    function queueClaimAll() external;

    /// @notice Get index for the next queue to be deployed.
    /// @return Index of the next queue to be deployed.
    function getPendingQueueIndex() external view returns (uint256);

    /// @notice Deploys a new withdrawal queue. Checks min time has passed from previous one.
    function deployWithdrawalQueue() external;
}
