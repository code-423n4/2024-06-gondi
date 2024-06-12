// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../../interfaces/validators/IOfferValidator.sol";
import "../utils/ValidatorHelpers.sol";

contract NftBitVectorValidator is IOfferValidator {
    using ValidatorHelpers for uint256;

    function validateOffer(IMultiSourceLoan.LoanOffer calldata, uint256 _tokenId, bytes calldata _validatorData)
        external
        pure
    {
        _tokenId.validateNFTBitVector(_validatorData);
    }
}
