// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";

import "src/lib/validators/NftBitVectorValidator.sol";

contract NftBitVectorValidatorTest is Test {
    NftBitVectorValidator private immutable validator = new NftBitVectorValidator();

    function testValidateOffer() public view {
        uint256 collateralTokenId = 3;
        bytes memory validatorData = abi.encode(1 << 252);

        validator.validateOffer(_getSampleOffer(), collateralTokenId, validatorData);
    }

    function testValidateOfferNoToken() public {
        uint256 collateralTokenId = 3;
        bytes memory validatorData = abi.encode(1 << 251);

        vm.expectRevert(abi.encodeWithSignature("TokenIdNotFoundError(uint256)", collateralTokenId));
        validator.validateOffer(_getSampleOffer(), collateralTokenId, validatorData);
    }

    function _getSampleOffer() private pure returns (IMultiSourceLoan.LoanOffer memory) {
        return IMultiSourceLoan.LoanOffer(
            0, address(0), 0, 0, address(0), 3, address(0), 0, 0, 0, 0, 0, new IBaseLoan.OfferValidator[](0)
        );
    }
}
