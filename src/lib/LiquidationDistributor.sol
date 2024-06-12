// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/ReentrancyGuard.sol";
import "@solmate/utils/SafeTransferLib.sol";
import "@solmate/tokens/ERC20.sol";

import "../interfaces/ILiquidationDistributor.sol";
import "../interfaces/loans/IMultiSourceLoan.sol";
import "../interfaces/loans/ILoanManagerRegistry.sol";
import "./loans/LoanManager.sol";
import "./utils/Interest.sol";

/// @title Liquidation Distributor
/// @author Florida St
/// @notice Receives proceeds from a liquidation and distributes them based on tranches.
contract LiquidationDistributor is ILiquidationDistributor, Owned, ReentrancyGuard {
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;

    ILoanManagerRegistry public immutable getLoanManagerRegistry;
    address public getLiquidator;

    event LiquidatorSet(address liquidator);

    error LiquidatorCannotBeUpdatedError();
    error InvalidCallerError();

    /// @param _loanManagerRegistry The address of the LoanManagerRegistry
    constructor(address _loanManagerRegistry) Owned(tx.origin) {
        getLoanManagerRegistry = ILoanManagerRegistry(_loanManagerRegistry);
    }

    function setLiquidator(address _liquidator) external onlyOwner {
        if (_liquidator == address(0)) {
            revert LiquidatorCannotBeUpdatedError();
        }
        getLiquidator = _liquidator;

        emit LiquidatorSet(_liquidator);
    }

    /// @inheritdoc ILiquidationDistributor
    function distribute(address _loanAddress, uint256 _proceeds, IMultiSourceLoan.Loan calldata _loan) external {
        if (msg.sender != getLiquidator) {
            revert InvalidCallerError();
        }
        uint256[] memory owedPerTranche = new uint256[](_loan.tranche.length);
        uint256 totalPrincipalAndPaidInterestOwed = _loan.principalAmount;
        uint256 totalPendingInterestOwed = 0;
        uint256 totalTranches = _loan.tranche.length;
        uint256 loanEndTime = _loan.startTime + _loan.duration;
        uint256 protocolFee = _loan.protocolFee;
        for (uint256 i = 0; i < totalTranches;) {
            IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
            uint256 pendingInterest =
                thisTranche.principalAmount.getInterest(thisTranche.aprBps, loanEndTime - thisTranche.startTime);
            totalPrincipalAndPaidInterestOwed += thisTranche.accruedInterest;
            totalPendingInterestOwed += pendingInterest;
            owedPerTranche[i] += thisTranche.principalAmount + thisTranche.accruedInterest + pendingInterest;
            unchecked {
                ++i;
            }
        }
        if (_proceeds > totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed) {
            for (uint256 i = 0; i < totalTranches;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _handleTrancheExcess(
                    _loanAddress,
                    _loan.principalAddress,
                    thisTranche,
                    msg.sender,
                    _proceeds,
                    totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed,
                    loanEndTime,
                    protocolFee
                );
                unchecked {
                    ++i;
                }
            }
        } else {
            for (uint256 i = 0; i < totalTranches;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _proceeds = _handleTrancheInsufficient(
                    _loanAddress, _loan.principalAddress, thisTranche, msg.sender, _proceeds, owedPerTranche[i], protocolFee
                );
                unchecked {
                    ++i;
                }
            }
        }
    }

    function _handleTrancheExcess(
        address _loanAddress,
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceeds,
        uint256 _totalOwed,
        uint256 _loanEndTime,
        uint256 _protocolFee
    ) private {
        uint256 excess = _proceeds - _totalOwed;
        /// Total = principal + accruedInterest +  pendingInterest + pro-rata remainder
        uint256 owed = _tranche.principalAmount + _tranche.accruedInterest
            + _tranche.principalAmount.getInterest(_tranche.aprBps, _loanEndTime - _tranche.startTime);
        uint256 total = owed + excess.mulDivDown(owed, _totalOwed);
        _handleLoanManagerCall(_loanAddress, _tranche, total, _protocolFee);
        ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, total);
    }

    function _handleTrancheInsufficient(
        address _loanAddress,
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceedsLeft,
        uint256 _trancheOwed,
        uint256 _protocolFee
    ) private returns (uint256) {
        if (_proceedsLeft > _trancheOwed) {
            _handleLoanManagerCall(_loanAddress, _tranche, _trancheOwed, _protocolFee);
            ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _trancheOwed);
            _proceedsLeft -= _trancheOwed;
        } else {
            _handleLoanManagerCall(_loanAddress, _tranche, _proceedsLeft, _protocolFee);
            if (_proceedsLeft != 0) {
                ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _proceedsLeft);
            }
            _proceedsLeft = 0;
        }
        return _proceedsLeft;
    }

    function _handleLoanManagerCall(address _loanAddress, IMultiSourceLoan.Tranche calldata _tranche, uint256 _sent, uint256 _protocolFee)
        private
    {
        if (getLoanManagerRegistry.isLoanManager(_tranche.lender)) {
            LoanManager(_tranche.lender).loanLiquidation(
                _loanAddress,
                _tranche.loanId,
                _tranche.principalAmount,
                _tranche.aprBps,
                _tranche.accruedInterest,
                _protocolFee,
                _sent,
                _tranche.startTime
            );
        }
    }
}
