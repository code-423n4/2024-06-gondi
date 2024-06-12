// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "../loans/IMultiSourceLoan.sol";

/// @title Interface for  Loan Offer Validators.
/// @author Florida St
/// @notice Verify the given `_offer` is valid for `_tokenId` and `_validatorData`.
interface IOfferValidator {
    /// @notice Validate a loan offer.
    function validateOffer(IMultiSourceLoan.LoanOffer calldata _offer, uint256 _tokenId, bytes calldata _validatorData)
        external
        view;
}
