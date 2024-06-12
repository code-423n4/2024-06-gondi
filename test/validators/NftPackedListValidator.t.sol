// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";

import "src/interfaces/validators/IOfferValidator.sol";
import "src/lib/validators/NftPackedListValidator.sol";

contract NftPackedListValidatorTest is Test {
    NftPackedListValidator private immutable validator = new NftPackedListValidator();

    function testValidateOffer() public view {
        uint64 bytesPerTokenId = 1;
        uint256 collateralTokenId = 3;
        bytes memory validatorData = abi.encode(bytesPerTokenId, abi.encode(3));

        validator.validateOffer(_getSampleOffer(), collateralTokenId, validatorData);
    }

    function testValidateOfferNoToken() public {
        uint64 bytesPerTokenId = 1;
        uint256 collateralTokenId = 3;
        bytes memory validatorData = abi.encode(bytesPerTokenId, abi.encode(1));

        vm.expectRevert(abi.encodeWithSignature("TokenIdNotFoundError(uint256)", collateralTokenId));
        validator.validateOffer(_getSampleOffer(), collateralTokenId, validatorData);
    }

    function _getSampleOffer() private pure returns (IMultiSourceLoan.LoanOffer memory) {
        return IMultiSourceLoan.LoanOffer(
            0, address(0), 0, 0, address(0), 3, address(0), 0, 0, 0, 0, 0, new IBaseLoan.OfferValidator[](0)
        );
    }
}
