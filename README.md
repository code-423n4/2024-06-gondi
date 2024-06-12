# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---

# Audit setup

## 🐺 C4: Set up repos
- [ ] Create a new private repo named `YYYY-MM-sponsorname` using this repo as a template.
- [ ] Rename this repo to reflect audit date (if applicable)
- [ ] Rename audit H1 below
- [ ] Update pot sizes
  - [ ] Remove the "Bot race findings opt out" section if there's no bot race.
- [ ] Fill in start and end times in audit bullets below
- [ ] Add link to submission form in audit details below
- [ ] Add the information from the scoping form to the "Scoping Details" section at the bottom of this readme.
- [ ] Add matching info to the Code4rena site
- [ ] Add sponsor to this private repo with 'maintain' level access.
- [ ] Send the sponsor contact the url for this repo to follow the instructions below and add contracts here. 
- [ ] Delete this checklist.

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Confirm that this repo is a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

## ⭐️ Sponsor: Repo checklist

- [ ] Modify the [Overview](#overview) section of this `README.md` file. Describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the auditors should keep in mind when reviewing. (Here are two well-constructed examples: [Ajna Protocol](https://github.com/code-423n4/2023-05-ajna) and [Maia DAO Ecosystem](https://github.com/code-423n4/2023-05-maia))
- [ ] Review the Gas award pool amount, if applicable. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] [This checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746) provides some best practices for Code4rena audit repos.

## ⭐️ Sponsor: Final touches
- [ ] Review and confirm the pull request created by the Scout (technical reviewer) who was assigned to your contest. *Note: any files not listed as "in scope" will be considered out of scope for the purposes of judging, even if the file will be part of the deployed contracts.*
- [ ] Check that images and other files used in this README have been uploaded to the repo as a file and then linked in the README using absolute path (e.g. `https://github.com/code-423n4/yourrepo-url/filepath.png`)
- [ ] Ensure that *all* links and image/file paths in this README use absolute paths, not relative paths
- [ ] Check that all README information is in markdown format (HTML does not render on Code4rena.com)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Gondi audit details
- Total Prize Pool: $15000 in USDC
  - HM awards: $12500 in USDC
  - (remove this line if there is no Analysis pool) Analysis awards: XXX XXX USDC (Notion: Analysis pool)
  - QA awards: $500 in USDC
  - (remove this line if there is no Bot race) Bot Race awards: XXX XXX USDC (Notion: Bot Race pool)
 
  - Judge awards: $1500 in USDC
  - Lookout awards: XXX XXX USDC (Notion: Sum of Pre-sort fee + Pre-sort early bonus)
  - Scout awards: $500 in USDC
  - (this line can be removed if there is no mitigation) Mitigation Review: XXX XXX USDC (*Opportunity goes to top 3 backstage wardens based on placement in this audit who RSVP.*)
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-06-gondi/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts June 14, 2024 20:00 UTC
- Ends July 5, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

Please review the following confidentiality requirements carefully, and if anything is unclear, ask questions in the private audit channel in the C4 Discord.

>>DRAG IN CLASSIFIED IMAGE HERE

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-06-gondi/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._
## 🐺 C4: Begin Gist paste here (and delete this line)





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

