// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "../Multicall.sol";
import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../../interfaces/pools/IPoolOfferHandler.sol";

/// @title OfferHandler
/// @author Florida St
/// @notice Basic offer handler for a set number of collections (these values can be updated).
///         For any given offer, it'll check that the principal requested is below the max allowed,
///         the apr is at least the minimum one defined, and the max senior repayment is below the max allowed.
///         Aprs are defined by the sum three factors: baseRate, f(utilizationRate), collectionPremium. `f` is
///         the function that will map the utilization rate to an apr premium. We use a linear function here.
contract PoolOfferHandler is Multicall, Owned, IPoolOfferHandler {
    using FixedPointMathLib for uint256;

    /// @notice Terms for a given collection and duration
    struct TermsKey {
        address collection;
        uint256 duration;
        uint256 maxSeniorRepayment;
    }

    struct Terms {
        uint256 principalAmount;
        uint256 aprPremium;
    }

    /// @dev 10000 BPS = 100%
    uint256 private constant _BPS = 10000;
    /// @notice Get the principal amount for each (collection, duration).

    /// @dev Minimum time to add new terms for any given collection/duration/maxSeniorRepayment.
    uint256 public immutable NEW_TERMS_WAITING_TIME;

    /// @notice Get the maximum duration allowed for a loan.
    uint32 public immutable getMaxDuration;

    /// @notice The terms for a given collection, duration and maxSeniorRepayment.
    mapping(
        address collection
            => mapping(
                uint256 duration
                    => mapping(uint256 maxSeniorRepayment => mapping(uint256 principalAmount => uint256 aprPremium))
            )
    ) private _terms;

    /// @notice Get the pending terms keys.
    TermsKey[] public getPendingTermKeys;

    /// @notice Get the pending terms.
    Terms[] public getPendingTerms;

    /// @notice The time when the pending terms were set.
    uint256 public pendingTermsSetTime;

    event PendingTermsSet(TermsKey[] keys, Terms[] terms, uint256 ts);
    event TermsSet(TermsKey[] keys, Terms[] terms);

    error InvalidOfferError();
    error InvalidInputError();
    error TooSoonError();
    error InvalidTermsError();

    constructor(uint32 _maxDuration, uint256 _newTermsWaitingTime) Owned(tx.origin) {
        getMaxDuration = _maxDuration;
        NEW_TERMS_WAITING_TIME = _newTermsWaitingTime;
        pendingTermsSetTime = type(uint256).max;
    }

    /// @notice First step to set new terms.
    /// @param _termKeys The keys for the new terms.
    /// @param __terms The new terms.
    function setTerms(TermsKey[] calldata _termKeys, Terms[] calldata __terms) external onlyOwner {
        uint256 total = _termKeys.length;
        if (total != __terms.length) {
            revert InvalidInputError();
        }
        for (uint256 i = 0; i < total;) {
            if (_termKeys[i].duration > getMaxDuration) {
                revert InvalidTermsError();
            }
            unchecked {
                ++i;
            }
        }
        getPendingTermKeys = _termKeys;
        getPendingTerms = __terms;
        uint256 ts = block.timestamp;
        pendingTermsSetTime = ts;

        emit PendingTermsSet(_termKeys, __terms, ts);
    }

    /// @notice Second step to set new terms. At least `NEW_TERMS_WAITING_TIME` must have passed since the first step.
    function confirmTerms() external {
        if (block.timestamp - pendingTermsSetTime < NEW_TERMS_WAITING_TIME) {
            revert TooSoonError();
        }
        TermsKey[] memory termKeys = getPendingTermKeys;
        Terms[] memory terms = getPendingTerms;
        uint256 total = terms.length;
        for (uint256 i = 0; i < total;) {
            _terms[termKeys[i].collection][termKeys[i].duration][termKeys[i].maxSeniorRepayment][terms[i]
                .principalAmount] = terms[i].aprPremium;
            unchecked {
                ++i;
            }
        }
        getPendingTermKeys = new TermsKey[](0);
        getPendingTerms = new Terms[](0);
        pendingTermsSetTime = type(uint256).max;

        emit TermsSet(termKeys, terms);
    }

    /// @notice Given `_collection`, `_duration`, `_maxSeniorRepayment`, and `_principalAmount` returns the risk (apr) premium.
    /// @param _collection The collection address.
    /// @param _duration The duration of the loan.
    /// @param _maxSeniorRepayment The maximum senior repayment.
    /// @param _principalAmount The principal amount.
    /// @return The risk premium.
    function getAprPremium(
        address _collection,
        uint256 _duration,
        uint256 _maxSeniorRepayment,
        uint256 _principalAmount
    ) external view returns (uint256) {
        return _terms[_collection][_duration][_maxSeniorRepayment][_principalAmount];
    }

    /// @inheritdoc IPoolOfferHandler
    function validateOffer(uint256 _baseRate, bytes calldata _offer)
        external
        view
        override
        returns (uint256, uint256)
    {
        /// @dev bring to memory
        IMultiSourceLoan.OfferExecution memory offerExecution = abi.decode(_offer, (IMultiSourceLoan.OfferExecution));
        if (offerExecution.offer.validators.length != 0) {
            revert InvalidOfferError();
        }
        uint256 aprPremium = _terms[offerExecution.offer.nftCollateralAddress][offerExecution.offer.duration][offerExecution
            .offer
            .maxSeniorRepayment][offerExecution.offer.principalAmount];
        if (offerExecution.offer.aprBps < _baseRate + aprPremium || aprPremium == 0) {
            revert InvalidAprError();
        }
        return (offerExecution.amount, offerExecution.offer.aprBps);
    }
}
