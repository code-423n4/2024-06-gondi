# Gondi audit details

- Total Prize Pool: $15,000 in USDC
  - HM awards: $12,500 in USDC
  - QA awards: $500 in USDC
  - Judge awards: $1,500 in USDC
  - Scout awards: $500 in USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-06-gondi-invitational/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts June 14, 2024 20:00 UTC
- Ends July 5, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-06-gondi/blob/main/4naly3er-report.md).

*Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards.*

If the owner of the Pool or PoolUnderwriter are compromised, then pools could be drained by setting underwriting terms against worthless NFTs.
The security of those wallets is in a separate layer (multi-sig / governor contract) and should not be considered.

# Overview

Gondi is a decentralized non-custodial NFT lending protocol that offers the most flexible and capital efficient primitive.
Gondi loans allows borrowers to access liquidity and obtain the best marginal rate when available as well as allow lenders to earn yield on their capital with the flexibility of entering and exiting their position any moment without affecting borrowers' loans. Gondi V3 loan offers are submitted from both protocol pools as well as peers market participants creating deep liquidity as well as precise risk pricing.

## Links

- **Previous audits:**  
  - N/A
- **Documentation:** <https://app.gitbook.com/invite/4HJV0LcOOnJ7AVJ77p8e/KW6r5CM24fuLQn0gSSXQ>
- **Website:** <https://www.gondi.xyz/>
- **X/Twitter:** <https://twitter.com/gondixyz>
- **Discord:** <https://discord.com/invite/gondi>

---

# Scope

*See [scope.txt](https://github.com/code-423n4/2024-06-gondi/blob/main/scope.txt)*

### Files in scope

| File   | Logic Contracts | Interfaces | SLOC  | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/lib/AddressManager.sol | 1| **** | 62 | |@solmate/auth/Owned.sol<br>@solmate/utils/ReentrancyGuard.sol|
| /src/lib/AuctionLoanLiquidator.sol | 1| **** | 249 | |@openzeppelin/utils/structs/EnumerableSet.sol<br>@solmate/auth/Owned.sol<br>@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/ReentrancyGuard.sol<br>@solmate/utils/SafeTransferLib.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/tokens/ERC721.sol|
| /src/lib/AuctionWithBuyoutLoanLiquidator.sol | 1| **** | 113 | ||
| /src/lib/InputChecker.sol | 1| **** | 9 | ||
| /src/lib/LiquidationDistributor.sol | 1| **** | 136 | |@solmate/auth/Owned.sol<br>@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/ReentrancyGuard.sol<br>@solmate/utils/SafeTransferLib.sol<br>@solmate/tokens/ERC20.sol|
| /src/lib/LiquidationHandler.sol | 1| **** | 86 | |@solmate/auth/Owned.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/ReentrancyGuard.sol|
| /src/lib/Multicall.sol | 1| **** | 18 | ||
| /src/lib/UserVault.sol | 1| **** | 295 | |@openzeppelin/utils/Strings.sol<br>@solmate/auth/Owned.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/utils/SafeTransferLib.sol|
| /src/lib/callbacks/CallbackHandler.sol | 1| **** | 54 | ||
| /src/lib/callbacks/PurchaseBundler.sol | 1| **** | 250 | |@seaport/seaport-types/src/lib/ConsiderationStructs.sol<br>@solmate/auth/Owned.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/tokens/WETH.sol<br>@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/SafeTransferLib.sol|
| /src/lib/loans/BaseLoan.sol | 1| **** | 116 | |@openzeppelin/utils/cryptography/MessageHashUtils.sol<br>@openzeppelin/interfaces/IERC1271.sol<br>@solmate/auth/Owned.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/utils/FixedPointMathLib.sol|
| /src/lib/loans/LoanManager.sol | 1| **** | 71 | |@openzeppelin/utils/structs/EnumerableSet.sol|
| /src/lib/loans/LoanManagerParameterSetter.sol | 1| **** | 82 | ||
| /src/lib/loans/LoanManagerRegistry.sol | 1| **** | 20 | |@solmate/auth/Owned.sol|
| /src/lib/loans/MultiSourceLoan.sol | 1| **** | 856 | |@delegate/IDelegateRegistry.sol<br>@openzeppelin/utils/cryptography/ECDSA.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/ReentrancyGuard.sol<br>@solmate/utils/SafeTransferLib.sol|
| /src/lib/pools/AaveUsdcBaseInterestAllocator.sol | 1| **** | 101 | |@solmate/auth/Owned.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/tokens/WETH.sol<br>@solmate/utils/FixedPointMathLib.sol|
| /src/lib/pools/ERC4626.sol | 1| **** | 97 | |@openzeppelin/utils/math/Math.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/utils/SafeTransferLib.sol<br>@solmate/utils/FixedPointMathLib.sol|
| /src/lib/pools/FeeManager.sol | 1| **** | 51 | |@solmate/utils/FixedPointMathLib.sol|
| /src/lib/pools/LidoEthBaseInterestAllocator.sol | 1| **** | 134 | |@solmate/auth/Owned.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/tokens/WETH.sol<br>@solmate/utils/FixedPointMathLib.sol|
| /src/lib/pools/Oracle.sol | 1| **** | 17 | ||
| /src/lib/pools/OraclePoolOfferHandler.sol | 1| **** | 290 | |@solmate/utils/FixedPointMathLib.sol<br>@solady/utils/MerkleProofLib.sol|
| /src/lib/pools/Pool.sol | 1| **** | 543 | |@solmate/utils/FixedPointMathLib.sol<br>@solmate/utils/ReentrancyGuard.sol<br>@solmate/utils/SafeTransferLib.sol|
| /src/lib/pools/WithdrawalQueue.sol | 1| **** | 85 | |@openzeppelin/utils/Strings.sol<br>@solmate/tokens/ERC20.sol<br>@solmate/tokens/ERC721.sol<br>@solmate/utils/SafeTransferLib.sol|
| /src/lib/utils/BytesLib.sol | 1| **** | 50 | ||
| /src/lib/utils/Hash.sol | 1| **** | 175 | ||
| /src/lib/utils/Interest.sol | 1| **** | 30 | |@solmate/utils/FixedPointMathLib.sol|
| /src/lib/utils/TwoStepOwned.sol | 1| **** | 32 | |@solmate/auth/Owned.sol|
| /src/lib/utils/ValidatorHelpers.sol | 1| **** | 49 | ||
| /src/lib/utils/WithProtocolFee.sol | 1| **** | 46 | ||
| **Totals** | **29** | **** | **4117** | | |

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2024-06-gondi/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./src/interfaces/IAuctionLoanLiquidator.sol |
| ./src/interfaces/ILiquidationDistributor.sol |
| ./src/interfaces/ILiquidationHandler.sol |
| ./src/interfaces/ILoanLiquidator.sol |
| ./src/interfaces/IMulticall.sol |
| ./src/interfaces/INFTFlashAction.sol |
| ./src/interfaces/IOldERC721.sol |
| ./src/interfaces/IUserVault.sol |
| ./src/interfaces/callbacks/ILoanCallback.sol |
| ./src/interfaces/callbacks/IPurchaseBundler.sol |
| ./src/interfaces/external/IAaveLendingPool.sol |
| ./src/interfaces/external/IAaveRewardsController.sol |
| ./src/interfaces/external/ICryptoPunksMarket.sol |
| ./src/interfaces/external/ICurve.sol |
| ./src/interfaces/external/ILido.sol |
| ./src/interfaces/external/IReservoir.sol |
| ./src/interfaces/external/IWrappedPunk.sol |
| ./src/interfaces/loans/IBaseLoan.sol |
| ./src/interfaces/loans/ILoanManager.sol |
| ./src/interfaces/loans/ILoanManagerRegistry.sol |
| ./src/interfaces/loans/IMultiSourceLoan.sol |
| ./src/interfaces/pools/IBaseInterestAllocator.sol |
| ./src/interfaces/pools/IFeeManager.sol |
| ./src/interfaces/pools/IOracle.sol |
| ./src/interfaces/pools/IPool.sol |
| ./src/interfaces/pools/IPoolOfferHandler.sol |
| ./src/interfaces/pools/IPoolWithWithdrawalQueues.sol |
| ./src/interfaces/validators/IOfferValidator.sol |
| ./src/lib/pools/PoolOfferHandler.sol |
| ./src/lib/validators/NftBitVectorValidator.sol |
| ./src/lib/validators/NftPackedListValidator.sol |
| ./src/lib/validators/RangeValidator.sol |
| ./test/AddressManager.t.sol |
| ./test/AuctionLoanLiquidator.t.sol |
| ./test/AuctionWithBuyoutLoanLiquidator.t.sol |
| ./test/LiquidationDistributor.t.sol |
| ./test/MultiSourceGas.t.sol |
| ./test/TestNFTFlashAction.sol |
| ./test/UserVault.t.sol |
| ./test/callbacks/PurchaseBundler.t.sol |
| ./test/loans/MultiSourceCommons.sol |
| ./test/loans/MultiSourceLoan.t.sol |
| ./test/loans/MultiSourceLoanTestExtra.t.sol |
| ./test/loans/TestLoanSetup.sol |
| ./test/pools/AaveUsdcBaseInterestAllocator.t.sol |
| ./test/pools/FeeManager.t.sol |
| ./test/pools/LidoEthBaseInterestAllocator.t.sol |
| ./test/pools/Oracle.t.sol |
| ./test/pools/OraclePoolOfferHandler.t.sol |
| ./test/pools/Pool.t.sol |
| ./test/pools/PoolOfferHandler.t.sol |
| ./test/pools/WithdrawalQueue.t.sol |
| ./test/utils/MockedAave.sol |
| ./test/utils/MockedCurve.sol |
| ./test/utils/MockedLido.sol |
| ./test/utils/SampleCollection.sol |
| ./test/utils/SampleMarketplace.sol |
| ./test/utils/SampleOldCollection.sol |
| ./test/utils/SampleToken.sol |
| ./test/utils/USDCSampleToken.sol |
| ./test/validators/NftBitVectorValidator.t.sol |
| ./test/validators/NftPackedListValidator.t.sol |
| ./test/validators/RangeValidator.t.sol |
| Totals: 63 |

## Scoping Q &amp; A

### General questions

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       USDC / WETH             |
| Test coverage                           | 85%                          |
| ERC721 used  by the protocol            |            Any but whitelisted.              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |             None           |
| Chains the protocol will be deployed on | Ethereum |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   No  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  No  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | No    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   No  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | No    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | No    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | No    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | No    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | No    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | No    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | No    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | No    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  Yes   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | Yes    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   No  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | No    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | No    |

### External integrations (e.g., Uniswap) behavior in scope

| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |

### EIP compliance checklist

--

# Additional context

## Main invariants

- While a loan is outstanding, MultiSourceLoan must own the collateral.

## Attack ideas (where to focus for bugs)

- Security of collateral in MultiSourceLoan.
- Pool accounting and potential exploits.

## All trusted roles in the protocol

| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Owner of Pool (this will be a Governor contract)                          | Will update the PoolUnderwriter/base rate strategy               |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts

--

## Running tests

```bash
git clone --recurse https://github.com/code-423n4/2024-06-gondi.git
cd 2024-06-gondi
forge test
forge coverage --ir-minimum
```

Screenshot showing the test coverage:

![](https://github.com/code-423n4/2024-06-gondi/assets/47150934/1180d315-4eff-46d2-bcea-a02f3d86ba10)

## Slither

*See [slither.txt](https://github.com/code-423n4/2024-06-gondi/blob/main/slither.txt)*

Run with `slither .`

## Miscellaneous

Employees of Gondi and employees' family members are ineligible to participate in this audit.
