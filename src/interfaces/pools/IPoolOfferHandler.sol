// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Pool Offer Handler Interface
/// @author Florida St
/// @notice Interface for any given Pool Offer Handler
interface IPoolOfferHandler {
    error InvalidDurationError();
    error InvalidPrincipalAmountError();
    error InvalidAprError();
    error InvalidMaxSeniorRepaymentError();

    /// @notice Validate an offer
    /// @param _baseRate Base rate
    /// @param _offer Offer data
    /// @return principalAmount Principal amount
    /// @return aprBps APR in basis points
    function validateOffer(uint256 _baseRate, bytes calldata _offer)
        external
        returns (uint256 principalAmount, uint256 aprBps);

    /// @notice Get the maximum duration allowed for any loan.
    function getMaxDuration() external view returns (uint32);
}
