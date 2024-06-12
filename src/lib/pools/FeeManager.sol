// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/utils/FixedPointMathLib.sol";

import "../utils/TwoStepOwned.sol";
import "../../interfaces/pools/IFeeManager.sol";

/// @title FeeManager
/// @author Florida St
/// @notice Pool's Fee Manager
contract FeeManager is IFeeManager, TwoStepOwned {
    using FixedPointMathLib for uint256;

    uint256 public constant WAIT_TIME = 30 days;
    uint256 public constant PRECISION = 1e20;

    Fees private _fees;
    Fees private _proposedFees;
    uint256 private _proposedFeesSetTime;

    event ProposedFeesSet(Fees fees);
    event ProposedFeesConfirmed(Fees fees);

    error InvalidFeesError();

    constructor(Fees memory __fees) TwoStepOwned(tx.origin, WAIT_TIME) {
        _fees = __fees;

        _proposedFeesSetTime = type(uint256).max;
    }

    /// @inheritdoc IFeeManager
    function getFees() external view returns (Fees memory) {
        return _fees;
    }

    /// @inheritdoc IFeeManager
    function setProposedFees(Fees calldata __fees) external onlyOwner {
        _proposedFees = __fees;
        _proposedFeesSetTime = block.timestamp;

        emit ProposedFeesSet(__fees);
    }

    /// @inheritdoc IFeeManager
    function confirmFees(Fees calldata __fees) external {
        if (_proposedFeesSetTime + WAIT_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (
            _proposedFees.managementFee != __fees.managementFee || _proposedFees.performanceFee != __fees.performanceFee
        ) {
            revert InvalidFeesError();
        }
        _fees = __fees;
        _proposedFeesSetTime = type(uint256).max;

        emit ProposedFeesConfirmed(__fees);
    }

    /// @inheritdoc IFeeManager
    function getProposedFees() external view returns (Fees memory) {
        return _proposedFees;
    }

    /// @inheritdoc IFeeManager
    function getProposedFeesSetTime() external view returns (uint256) {
        return _proposedFeesSetTime;
    }

    /// @inheritdoc IFeeManager
    function processFees(uint256 _principal, uint256 _interest) external view returns (uint256) {
        /// @dev cached
        Fees memory __fees = _fees;
        return _principal.mulDivDown(__fees.managementFee, PRECISION)
            + _interest.mulDivDown(__fees.performanceFee, PRECISION);
    }
}
