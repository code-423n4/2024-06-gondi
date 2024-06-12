// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// TODO: Give credit

import "../../interfaces/validators/IOfferValidator.sol";
import "../utils/ValidatorHelpers.sol";

contract NftPackedListValidator is IOfferValidator {
    using ValidatorHelpers for uint256;

    function validateOffer(IMultiSourceLoan.LoanOffer calldata, uint256 _tokenId, bytes calldata _validatorData)
        external
        pure
    {
        (uint64 bytesPerTokenId, bytes memory tokenIdList) = abi.decode(_validatorData, (uint64, bytes));
        _tokenId.validateTokenIdPackedList(bytesPerTokenId, tokenIdList);
    }
}
