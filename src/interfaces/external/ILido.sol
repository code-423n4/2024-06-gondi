// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Lido Interface
/// @author Florida St
/// @notice Subset of methods we called on the Lido contract.
interface ILido {
    /// @notice Total Pooled Ether in Lido
    function getTotalPooledEther() external view returns (uint256);

    /// @notice Total Shares in Lido
    function getTotalShares() external view returns (uint256);

    function submit(address _referral) external payable returns (uint256);
}
