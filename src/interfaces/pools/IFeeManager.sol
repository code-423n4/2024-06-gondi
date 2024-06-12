// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title IFeeManager
/// @author Florida St
/// @notice Interface for Pool's Fee Manager
interface IFeeManager {
    /// Fees expresed in PRECISION
    struct Fees {
        uint256 managementFee;
        uint256 performanceFee;
    }

    function PRECISION() external view returns (uint256);

    /// @return Fees
    function getFees() external view returns (Fees memory);

    /// @return Get pending fees
    function getProposedFees() external view returns (Fees memory);

    /// @notice Set pending fee.
    /// @param _fee The fee.
    function setProposedFees(Fees calldata _fee) external;

    /// @notice Set the fee manager's fee.
    /// @param _fees The fee.
    function confirmFees(Fees calldata _fees) external;

    /// @notice Get the time when the pending fee was set.
    function getProposedFeesSetTime() external view returns (uint256);

    /// @notice Process fees on repayment.
    /// @param _principal The principal amount.
    /// @param _interest The interest amount.
    /// @return Total fees charged.
    function processFees(uint256 _principal, uint256 _interest) external returns (uint256);
}
