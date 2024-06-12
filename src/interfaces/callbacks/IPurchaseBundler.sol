// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.20;

import "../loans/IMultiSourceLoan.sol";
import "../../interfaces/external/IReservoir.sol";

interface IPurchaseBundler {
    struct ExecutionInfo {
        IReservoir.ExecutionInfo reservoirExecutionInfo;
        bool contractMustBeOwner;
    }

    struct Taxes {
        uint128 buyTax;
        uint128 sellTax;
    }

    /// @notice Buy a number of NFTs using loans to cover part of the price (i.e. BNPL).
    /// @dev Buy calls emit loan -> Before trying to transfer the NFT but after transfering the principal
    /// @dev Encoded: emitLoan(IMultiSourceLoan.LoanExecutionData)[]
    /// @param _executionData The data needed to execute the loan + buy the NFT.
    function buy(bytes[] calldata _executionData)
        external
        payable
        returns (uint256[] memory, IMultiSourceLoan.Loan[] memory);

    /// @notice Sell the collateral behind a number of loans (potentially 1) and use proceeds to pay back the loans.
    /// @dev Encoded: repayLoan(IMultiSourceLoan.LoanRepaymentData)[]
    /// @param _executionData The data needed to execute the loan repayment + sell the NFT.
    function sell(bytes[] calldata _executionData) external;

    /// @notice First step to update the MultiSourceLoan address.
    /// @param _newAddress The new address of the MultiSourceLoan.
    function updateMultiSourceLoanAddressFirst(address _newAddress) external;

    /// @notice Second step to update the MultiSourceLoan address.
    /// @param _newAddress The new address of the MultiSourceLoan. Must match address from first update.
    function finalUpdateMultiSourceLoanAddress(address _newAddress) external;

    /// @notice Returns the address of the MultiSourceLoan.
    function getMultiSourceLoanAddress() external view returns (address);

    /// @return _taxes The current taxes.
    function getTaxes() external returns (Taxes memory);

    /// @return _pendingTaxes The pending taxes.
    function getPendingTaxes() external returns (Taxes memory);

    /// @return _pendingTaxesSetTime The time when the pending taxes were set.
    function getPendingTaxesSetTime() external returns (uint256);

    /// @notice Kicks off the process to update the taxes.
    /// @param _newTaxes New taxes.
    function updateTaxes(Taxes calldata _newTaxes) external;

    /// @notice Set the taxes if enough notice has been given.
    function setTaxes() external;
}
