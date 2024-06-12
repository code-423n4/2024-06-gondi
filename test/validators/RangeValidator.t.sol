// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";

import "src/lib/validators/RangeValidator.sol";

contract RangeValidatorTest is Test {
    RangeValidator private immutable _validator = new RangeValidator();

    function testValidateOffer() public view {
        bytes memory validatorData = abi.encode(1, 5);
        IMultiSourceLoan.LoanOffer memory offer = _getSampleOffer();

        _validator.validateOffer(offer, 3, validatorData);
    }

    function testValidateOfferOutOfRange() public {
        bytes memory validatorData = abi.encode(1, 5);
        IMultiSourceLoan.LoanOffer memory offer = _getSampleOffer();

        vm.expectRevert(abi.encodeWithSignature("TokenIdOutOfRangeError(uint256,uint256)", 1, 5));
        _validator.validateOffer(offer, 6, validatorData);

        vm.expectRevert(abi.encodeWithSignature("TokenIdOutOfRangeError(uint256,uint256)", 1, 5));
        _validator.validateOffer(offer, 0, validatorData);
    }

    function _getSampleOffer() private pure returns (IMultiSourceLoan.LoanOffer memory) {
        return IMultiSourceLoan.LoanOffer(
            0, address(0), 0, 0, address(0), 3, address(0), 0, 0, 0, 0, 0, new IBaseLoan.OfferValidator[](0)
        );
    }
}
