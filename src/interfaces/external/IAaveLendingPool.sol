// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title Aave LendingPool Interface
/// @author Florida St
/// @notice Subset of methods we called on Aave's LendingPool contract.
interface IAaveLendingPool {
    /// @notice Deposits `amount` of an `asset` into the protocol, minting the same `amount` of corresponding aTokens,
    /// and transferring them to the `onBehalfOf` address.
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;

    /// @notice Withdraws amount of the underlying asset, i.e. redeems the underlying token and burns the aTokens.
    function withdraw(address asset, uint256 amount, address to) external;

    /// @notice Returns the state and configuration of the reserve.
    function getReserveData(address asset)
        external
        view
        returns (
            uint256 configuration,
            uint128 liquidityIndex,
            uint128 currentLiquidityRate,
            uint128 variableBorrowIndex,
            uint128 currentVariableBorrowRate,
            uint128 currentStableBorrowRate,
            uint40 lastUpdateTimestamp,
            uint16 id,
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress,
            address interestRateStrategyAddress,
            uint128 accruedToTreasury,
            uint128 unbacked,
            uint128 isolationModeTotalDebt
        );
}
