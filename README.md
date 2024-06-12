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


_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._


If the owner of the pool or poolunderwriter are compromised, then pools could be drained by setting underwriting terms agains worthless NFTs.
The security of those wallets is in a separate layer (multi-sig / governor contract) and should not be considered.

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

# Overview

[ ⭐️ SPONSORS: add info here ]

## Links

- **Previous audits:**  
  - ✅ SCOUTS: If there are multiple report links, please format them in a list.
- **Documentation:** https://app.gitbook.com/invite/4HJV0LcOOnJ7AVJ77p8e/KW6r5CM24fuLQn0gSSXQ
- **Website:** https://www.gondi.xyz/
- **X/Twitter:** https://twitter.com/gondixyz
- **Discord:** https://discord.com/invite/gondi

---

# Scope

[ ✅ SCOUTS: add scoping and technical details here ]

### Files in scope
- ✅ This should be completed using the `metrics.md` file
- ✅ Last row of the table should be Total: SLOC
- ✅ SCOUTS: Have the sponsor review and and confirm in text the details in the section titled "Scoping Q amp; A"

*For sponsors that don't use the scoping tool: list all files in scope in the table below (along with hyperlinks) -- and feel free to add notes to emphasize areas of focus.*

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/sample.sol](https://github.com/code-423n4/repo-name/blob/contracts/folder/sample.sol) | 123 | This contract does XYZ | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |

### Files out of scope
✅ SCOUTS: List files/directories out of scope

## Scoping Q &amp; A

### General questions
### Are there any ERC20's in scope?: Yes

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".

Specific tokens (please specify)
USDC / WETH

### Are there any ERC777's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



### Are there any ERC721's in scope?: Yes

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".

Any but whitelisted.

### Are there any ERC1155's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



✅ SCOUTS: Once done populating the table below, please remove all the Q/A data above.

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       🖊️             |
| Test coverage                           | ✅ SCOUTS: Please populate this after running the test coverage command                          |
| ERC721 used  by the protocol            |            🖊️              |
| ERC777 used by the protocol             |           🖊️                |
| ERC1155 used by the protocol            |              🖊️            |
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

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist
--

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| src/Token.sol                           | ERC20, ERC721                |
| src/NFT.sol                             | ERC721                       |


# Additional context

## Main invariants

- While a loan is outstanding, MultiSourceLoan must own the collateral.

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Attack ideas (where to focus for bugs)
Security of collateral in MultiSourceLoan.
Pool accounting and potential exploits.

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## All trusted roles in the protocol

Owner of Pool (this will be a Governor contract) will update the poolunderwriter/base rate strategy.

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Owner                          | Has superpowers                |
| Administrator                             | Can change fees                       |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

--

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Running tests

1. `curl -L https://foundry.paradigm.xyz | bash`
3. `forge install transmissions11/solmate`
3. `forge install OpenZeppelin`
4. `forge test`

✅ SCOUTS: Please format the response above 👆 using the template below👇

```bash
git clone https://github.com/code-423n4/2023-08-arbitrum
git submodule update --init --recursive
cd governance
foundryup
make install
make build
make sc-election-test
```
To run code coverage
```bash
make coverage
```
To run gas benchmarks
```bash
make gas
```

✅ SCOUTS: Add a screenshot of your terminal showing the gas report
✅ SCOUTS: Add a screenshot of your terminal showing the test coverage

## Miscellaneous
Employees of Gondi and employees' family members are ineligible to participate in this audit.





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

