// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../../interfaces/loans/ILoanManager.sol";
import "../../interfaces/pools/IPoolOfferHandler.sol";
import "../InputChecker.sol";
import "../utils/TwoStepOwned.sol";

contract LoanManagerParameterSetter is TwoStepOwned {
    using InputChecker for address;

    error LoanManagerSetError();

    event RequestCallersAdded(ILoanManager.ProposedCaller[] callers);
    event ProposedOfferHandlerSet(address offerHandler);
    event OfferHandlerSet(address offerHandler);

    /// @notice Time to wait before a new offerHandler can be set.
    uint256 public immutable UPDATE_WAITING_TIME;

    /// @notice OfferHandler contract
    address public getOfferHandler;
    /// @notice Proposed offerHandler contract.
    address public getProposedOfferHandler;
    /// @notice Time when the proposed offerHandler was set.
    uint256 public getProposedOfferHandlerSetTime;

    /// @notice Proposed accepted callers
    ILoanManager.ProposedCaller[] public getProposedAcceptedCallers;
    /// @notice Time when the proposed accepted callers were set.
    uint256 public getProposedAcceptedCallersSetTime;

    /// @notice LoanManager contract
    address public getLoanManager;

    constructor(address __offerHandler, uint256 _updateWaitingTime) TwoStepOwned(tx.origin, _updateWaitingTime) {
        __offerHandler.checkNotZero();
        UPDATE_WAITING_TIME = _updateWaitingTime;

        getOfferHandler = __offerHandler;
        getProposedOfferHandlerSetTime = type(uint256).max;
        getProposedAcceptedCallersSetTime = type(uint256).max;
    }

    function setLoanManager(address __loanManager) external onlyOwner {
        if (getLoanManager != address(0)) {
            revert LoanManagerSetError();
        }
        __loanManager.checkNotZero();

        if (ILoanManager(__loanManager).getParameterSetter() != address(this)) {
            revert InvalidInputError();
        }

        getLoanManager = __loanManager;
    }

    /// @notice First step in settting the OfferHandler contract.
    /// @param __offerHandler The new offerHandler address.
    function setOfferHandler(address __offerHandler) external onlyOwner {
        __offerHandler.checkNotZero();

        if (IPoolOfferHandler(__offerHandler).getMaxDuration() > IPoolOfferHandler(getOfferHandler).getMaxDuration()) {
            revert InvalidInputError();
        }

        getProposedOfferHandler = __offerHandler;
        getProposedOfferHandlerSetTime = block.timestamp;

        emit ProposedOfferHandlerSet(__offerHandler);
    }

    /// @notice Confirm the OfferHandler contract.
    /// @param __offerHandler The new OfferHandler address.
    function confirmOfferHandler(address __offerHandler) external onlyOwner {
        if (getProposedOfferHandlerSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (getProposedOfferHandler != __offerHandler) {
            revert InvalidInputError();
        }

        getOfferHandler = __offerHandler;
        getProposedOfferHandler = address(0);
        getProposedOfferHandlerSetTime = type(uint256).max;

        ILoanManager(getLoanManager).updateOfferHandler(__offerHandler);

        emit OfferHandlerSet(__offerHandler);
    }

    /// @notice First step in d a caller to the accepted callers list. Can be a Loan Contract or Liquidator.
    /// @param _callers The callers to add.
    function requestAddCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {
        getProposedAcceptedCallers = _callers;
        getProposedAcceptedCallersSetTime = block.timestamp;

        emit RequestCallersAdded(_callers);
    }

    /// @notice Second step in d a caller to the accepted callers list. Can be a Loan Contract or Liquidator.
    /// @dev Given repayments, we don't allow callers to be removed.
    /// @param _callers The callers to add.
    function addCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {
        if (getProposedAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        ILoanManager.ProposedCaller[] memory proposedCallers = getProposedAcceptedCallers;
        uint256 totalCallers = _callers.length;
        for (uint256 i = 0; i < totalCallers;) {
            ILoanManager.ProposedCaller calldata caller = _callers[i];
            if (
                proposedCallers[i].caller != caller.caller || proposedCallers[i].isLoanContract != caller.isLoanContract
            ) {
                revert InvalidInputError();
            }

            unchecked {
                ++i;
            }
        }
        ILoanManager(getLoanManager).addCallers(_callers);
    }
}
