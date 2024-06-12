// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Multi Source Loan Interface
/// @author Florida St
/// @notice A multi source loan is one with multiple tranches.
interface ILoanManager {
    struct ProposedCaller {
        address caller;
        bool isLoanContract;
    }

    /// @notice Validate an offer. Can only be called by an accepted caller.
    /// @param _offer The offer to validate.
    /// @param _protocolFee The protocol fee.
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external;

    /// @notice Update the offer handler.
    /// @param _offerHandler The new offer handler.
    function updateOfferHandler(address _offerHandler) external;

    /// @notice Get the offer handler setter.
    /// @dev Had to take this out from the contract because of size issues.
    /// @return The offer handler setter.
    function getParameterSetter() external view returns (address);

    /// @notice Add allowed callers.
    /// @param _callers The callers to add.
    function addCallers(ProposedCaller[] calldata _callers) external;

    /// @notice Called on loan repayment.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _startTime The start time.
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external;

    /// @notice Called on loan liquidation.
    /// @param _loanAddress The address of the loan contract since this might be called by a liquidator.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _received The received amount (from liquidation proceeds)
    /// @param _startTime The start time.
    function loanLiquidation(
        address _loanAddress,
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external;
}
