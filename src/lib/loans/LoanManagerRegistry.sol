// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";

import "../../interfaces/loans/ILoanManagerRegistry.sol";

contract LoanManagerRegistry is ILoanManagerRegistry, Owned {
    mapping(address loanManagerAddress => bool active) internal _loanManagers;

    event LoanManagerAdded(address loanManagerAdded);
    event LoanManagerRemoved(address loanManagerRemoved);

    constructor() Owned(tx.origin) {}

    /// @inheritdoc ILoanManagerRegistry
    function addLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = true;

        emit LoanManagerAdded(_loanManager);
    }

    /// @inheritdoc ILoanManagerRegistry
    function removeLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = false;

        emit LoanManagerRemoved(_loanManager);
    }

    /// @inheritdoc ILoanManagerRegistry
    function isLoanManager(address _loanManager) external view returns (bool) {
        return _loanManagers[_loanManager];
    }
}
