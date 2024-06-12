// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../../interfaces/loans/IBaseLoan.sol";
import "../../interfaces/IAuctionLoanLiquidator.sol";

library Hash {
    // keccak256("OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _VALIDATOR_HASH = 0x4def3e04bd42194484d5f8a5b268ec0df03b9d9d0402606fe3100023c5d79ac4;

    // keccak256("LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _LOAN_OFFER_HASH = 0xa87df46e2d2684eb0bbc7abfb05483167cdccac6d7302078a9eaad540c119958;

    // keccak256("OfferExecution(LoanOffer offer,uint256 amount,bytes lenderOfferSignature)LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _OFFER_EXECUTION_HASH = 0x00c14ad24a24ef957b8af9ebdfbc5d353bba0d3b20bbd97fb243c9f5fb361282;

    /// keccak256("ExecutionData(OfferExecution[] offerExecution,uint256 tokenId,uint256 duration,uint256 expirationTime,address principalReceiver,bytes callbackData)OfferExecution(LoanOffer offer,uint256 amount,bytes lenderOfferSignature)LoanOffer(uint256 offerId,address lender,uint256 fee,uint256 capacity,address nftCollateralAddress,uint256 nftCollateralTokenId,address principalAddress,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration,uint256 maxSeniorRepayment,OfferValidator[] validators)OfferValidator(address validator,bytes arguments)")
    bytes32 private constant _EXECUTION_DATA_HASH = 0xa5cb06a0c5f03000a6afa6b0d5080d0f863338257beb253058bc2c184ad7d4e1;

    /// keccak256("SignableRepaymentData(uint256 loanId,bytes callbackData,bool shouldDelegate)")
    bytes32 private constant _SIGNABLE_REPAYMENT_DATA_HASH =
        0x41277b3c1cbe08ea7bbdd10a13f24dc956f3936bf46526f904c73697d9958e0c;

    // keccak256("Loan(address borrower,uint256 nftCollateralTokenId,address nftCollateralAddress,address principalAddress,uint256 principalAmount,uint256 startTime,uint256 duration,Tranche[] tranche,uint256 protocolFee)Tranche(uint256 floor,uint256 principalAmount,Source[] source)Source(uint256 loanId,address lender,uint256 principalAmount,uint256 accruedInterest,uint256 startTime,uint256 aprBps)")
    bytes32 private constant _MULTI_SOURCE_LOAN_HASH =
        0x47dba7e6940f0063b21c2ef8f7b0beaf1a2f4c2f84144c36b274ceec12e99b57;

    /// keccak256("Tranche(uint256 loanId,uint256 floor,uint256 principalAmount,address lender,uint256 accruedInterest,uint256 startTime,uint256 aprBps)")
    bytes32 private constant _TRANCHE_HASH = 0x6ac594952a72f2e6b24efaf9744b05c23b1b92ce25aa97d18a4338f484c41b95;

    /// keccak256("RenegotiationOffer(uint256 renegotiationId,uint256 loanId,address lender,uint256 fee,uint256[] trancheIndex,uint256 principalAmount,uint256 aprBps,uint256 expirationTime,uint256 duration)")
    bytes32 private constant _MULTI_RENEGOTIATION_OFFER_HASH =
        0x986a160abc209a64a5b0786817ff0aa7a5f5737a4ee6a95197f86290598cd03d;

    /// keccak256("Auction(address loanAddress,uint256 loanId,uint256 highestBid,uint256 triggerFee,uint256 minBid,address highestBidder,uint96 duration,address asset,uint96 startTime,address originator,uint96 lastBidTime)")
    bytes32 private constant _AUCTION_HASH = 0x091bb2c766793330514b24dc458b085f596716d69fcb631d53788558ff148646;

    function hash(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (bytes32) {
        bytes memory encodedValidators;
        uint256 totalValidators = _loanOffer.validators.length;
        for (uint256 i = 0; i < totalValidators;) {
            encodedValidators = abi.encodePacked(encodedValidators, _hashValidator(_loanOffer.validators[i]));

            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _LOAN_OFFER_HASH,
                _loanOffer.offerId,
                _loanOffer.lender,
                _loanOffer.fee,
                _loanOffer.capacity,
                _loanOffer.nftCollateralAddress,
                _loanOffer.nftCollateralTokenId,
                _loanOffer.principalAddress,
                _loanOffer.principalAmount,
                _loanOffer.aprBps,
                _loanOffer.expirationTime,
                _loanOffer.duration,
                _loanOffer.maxSeniorRepayment,
                keccak256(encodedValidators)
            )
        );
    }

    function hash(IMultiSourceLoan.ExecutionData memory _executionData) internal pure returns (bytes32) {
        bytes memory encodedOfferExecution;
        uint256 totalOfferExecution = _executionData.offerExecution.length;
        for (uint256 i = 0; i < totalOfferExecution;) {
            encodedOfferExecution =
                abi.encodePacked(encodedOfferExecution, _hashOfferExecution(_executionData.offerExecution[i]));

            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _EXECUTION_DATA_HASH,
                keccak256(encodedOfferExecution),
                _executionData.tokenId,
                _executionData.duration,
                _executionData.expirationTime,
                _executionData.principalReceiver,
                keccak256(_executionData.callbackData)
            )
        );
    }

    function hash(IMultiSourceLoan.SignableRepaymentData memory _repaymentData) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _SIGNABLE_REPAYMENT_DATA_HASH,
                _repaymentData.loanId,
                keccak256(_repaymentData.callbackData),
                _repaymentData.shouldDelegate
            )
        );
    }

    function hash(IMultiSourceLoan.Loan memory _loan) internal pure returns (bytes32) {
        bytes memory trancheHashes;
        uint256 totalTranches = _loan.tranche.length;
        for (uint256 i; i < totalTranches;) {
            trancheHashes = abi.encodePacked(trancheHashes, _hashTranche(_loan.tranche[i]));
            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _MULTI_SOURCE_LOAN_HASH,
                _loan.borrower,
                _loan.nftCollateralTokenId,
                _loan.nftCollateralAddress,
                _loan.principalAddress,
                _loan.principalAmount,
                _loan.startTime,
                _loan.duration,
                keccak256(trancheHashes),
                _loan.protocolFee
            )
        );
    }

    function hash(IMultiSourceLoan.RenegotiationOffer memory _refinanceOffer) internal pure returns (bytes32) {
        bytes memory encodedIndexes;
        uint256 totalIndexes = _refinanceOffer.trancheIndex.length;
        for (uint256 i = 0; i < totalIndexes;) {
            encodedIndexes = abi.encodePacked(encodedIndexes, _refinanceOffer.trancheIndex[i]);
            unchecked {
                ++i;
            }
        }
        return keccak256(
            abi.encode(
                _MULTI_RENEGOTIATION_OFFER_HASH,
                _refinanceOffer.renegotiationId,
                _refinanceOffer.loanId,
                _refinanceOffer.lender,
                _refinanceOffer.fee,
                keccak256(encodedIndexes),
                _refinanceOffer.principalAmount,
                _refinanceOffer.aprBps,
                _refinanceOffer.expirationTime,
                _refinanceOffer.duration
            )
        );
    }

    function hash(IAuctionLoanLiquidator.Auction memory _auction) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _AUCTION_HASH,
                _auction.loanAddress,
                _auction.loanId,
                _auction.highestBid,
                _auction.triggerFee,
                _auction.minBid,
                _auction.highestBidder,
                _auction.duration,
                _auction.asset,
                _auction.startTime,
                _auction.originator,
                _auction.lastBidTime
            )
        );
    }

    function _hashTranche(IMultiSourceLoan.Tranche memory _tranche) private pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _TRANCHE_HASH,
                _tranche.loanId,
                _tranche.floor,
                _tranche.principalAmount,
                _tranche.lender,
                _tranche.accruedInterest,
                _tranche.startTime,
                _tranche.aprBps
            )
        );
    }

    function _hashValidator(IBaseLoan.OfferValidator memory _validator) private pure returns (bytes32) {
        return keccak256(abi.encode(_VALIDATOR_HASH, _validator.validator, keccak256(_validator.arguments)));
    }

    function _hashOfferExecution(IMultiSourceLoan.OfferExecution memory _offerExecution)
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                _OFFER_EXECUTION_HASH,
                hash(_offerExecution.offer),
                _offerExecution.amount,
                keccak256(_offerExecution.lenderOfferSignature)
            )
        );
    }
}
