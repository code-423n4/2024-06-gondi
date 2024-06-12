// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@openzeppelin/utils/structs/EnumerableSet.sol";

import "../loans//LoanManagerParameterSetter.sol";
import "../../interfaces/loans/ILoanManager.sol";
import "../../interfaces/pools/IPoolOfferHandler.sol";
import "../InputChecker.sol";
import "../utils/TwoStepOwned.sol";

/// TODO: Documentation
abstract contract LoanManager is ILoanManager, TwoStepOwned {
    using InputChecker for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice Time to wait before a new offerHandler can be set.
    uint256 public immutable UPDATE_WAITING_TIME;

    /// @notice OfferHandler setter
    address public immutable getParameterSetter;

    /// @notice Set of accepted callers.
    EnumerableSet.AddressSet internal _acceptedCallers;
    /// @dev Keep this in a separate variable as well since we need the subset of loan contracts
    /// within acceptedCallers. Alternatively we could save this in a single struct but keep it
    /// this way for simplicity as we can use EnumerableSet.
    mapping(address => bool) internal _isLoanContract;
    /// @notice OfferHandler contract
    address public getOfferHandler;

    event CallersAdded(ProposedCaller[] callers);

    error CallerNotAccepted();
    error InvalidCallerError();

    constructor(address _owner, address __offerHandlerSetter, uint256 _updateWaitingTime)
        TwoStepOwned(_owner, _updateWaitingTime)
    {
        UPDATE_WAITING_TIME = _updateWaitingTime;

        getParameterSetter = __offerHandlerSetter;
        getOfferHandler = LoanManagerParameterSetter(__offerHandlerSetter).getOfferHandler();
    }

    function updateOfferHandler(address _offerHandler) external {
        if (msg.sender != getParameterSetter) {
            revert InvalidCallerError();
        }
        getOfferHandler = _offerHandler;
    }
    /// @notice Second step in d a caller to the accepted callers list. Can be a Loan Contract or Liquidator.
    /// @dev Given repayments, we don't allow callers to be removed.
    /// @param _callers The callers to add.

    function addCallers(ProposedCaller[] calldata _callers) external {
        if (msg.sender != getParameterSetter) {
            revert InvalidCallerError();
        }
        uint256 totalCallers = _callers.length;
        for (uint256 i = 0; i < totalCallers;) {
            ProposedCaller calldata caller = _callers[i];
            _acceptedCallers.add(caller.caller);
            _isLoanContract[caller.caller] = caller.isLoanContract;

            afterCallerAdded(caller.caller);
            unchecked {
                ++i;
            }
        }

        emit CallersAdded(_callers);
    }

    /// @notice Check if a caller is accepted.
    /// @param _caller The caller to check.
    /// @return Whether the caller is accepted.
    function isCallerAccepted(address _caller) external view returns (bool) {
        return _acceptedCallers.contains(_caller);
    }

    /// @inheritdoc ILoanManager
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external virtual;

    /// @inheritdoc ILoanManager
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external virtual;

    /// @inheritdoc ILoanManager
    function loanLiquidation(
        address _loanAddress,
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external virtual;

    /// @notice Perform operations after a caller is added. I.e: ERC20s approvals.
    /// @param _caller The caller that was added.
    function afterCallerAdded(address _caller) internal virtual;
}
