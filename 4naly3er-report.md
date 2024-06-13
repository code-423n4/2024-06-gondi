# Report

- [Report](#report)
  - [Gas Optimizations](#gas-optimizations)
    - [\[GAS-1\] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)](#gas-1-a--a--b-is-more-gas-effective-than-a--b-for-state-variables-excluding-arrays-and-mappings)
    - [\[GAS-2\] Use assembly to check for `address(0)`](#gas-2-use-assembly-to-check-for-address0)
    - [\[GAS-3\] Using bools for storage incurs overhead](#gas-3-using-bools-for-storage-incurs-overhead)
    - [\[GAS-4\] Cache array length outside of loop](#gas-4-cache-array-length-outside-of-loop)
    - [\[GAS-5\] State variables should be cached in stack variables rather than re-reading them from storage](#gas-5-state-variables-should-be-cached-in-stack-variables-rather-than-re-reading-them-from-storage)
    - [\[GAS-6\] Use calldata instead of memory for function arguments that do not get mutated](#gas-6-use-calldata-instead-of-memory-for-function-arguments-that-do-not-get-mutated)
    - [\[GAS-7\] For Operations that will not overflow, you could use unchecked](#gas-7-for-operations-that-will-not-overflow-you-could-use-unchecked)
    - [\[GAS-8\] Use Custom Errors instead of Revert Strings to save Gas](#gas-8-use-custom-errors-instead-of-revert-strings-to-save-gas)
    - [\[GAS-9\] Avoid contract existence checks by using low level calls](#gas-9-avoid-contract-existence-checks-by-using-low-level-calls)
    - [\[GAS-10\] Stack variable used as a cheaper cache for a state variable is only used once](#gas-10-stack-variable-used-as-a-cheaper-cache-for-a-state-variable-is-only-used-once)
    - [\[GAS-11\] State variables only set in the constructor should be declared `immutable`](#gas-11-state-variables-only-set-in-the-constructor-should-be-declared-immutable)
    - [\[GAS-12\] Functions guaranteed to revert when called by normal users can be marked `payable`](#gas-12-functions-guaranteed-to-revert-when-called-by-normal-users-can-be-marked-payable)
    - [\[GAS-13\] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)](#gas-13-i-costs-less-gas-compared-to-i-or-i--1-same-for---i-vs-i---or-i---1)
    - [\[GAS-14\] Using `private` rather than `public` for constants, saves gas](#gas-14-using-private-rather-than-public-for-constants-saves-gas)
    - [\[GAS-15\] `uint256` to `bool` `mapping`: Utilizing Bitmaps to dramatically save on Gas](#gas-15-uint256-to-bool-mapping-utilizing-bitmaps-to-dramatically-save-on-gas)
    - [\[GAS-16\] Use != 0 instead of \> 0 for unsigned integer comparison](#gas-16-use--0-instead-of--0-for-unsigned-integer-comparison)
    - [\[GAS-17\] `internal` functions not called by the contract should be removed](#gas-17-internal-functions-not-called-by-the-contract-should-be-removed)
    - [\[GAS-18\] WETH address definition can be use directly](#gas-18-weth-address-definition-can-be-use-directly)
  - [Non Critical Issues](#non-critical-issues)
    - [\[NC-1\] Missing checks for `address(0)` when assigning values to address state variables](#nc-1-missing-checks-for-address0-when-assigning-values-to-address-state-variables)
    - [\[NC-2\] Array indices should be referenced via `enum`s rather than via numeric literals](#nc-2-array-indices-should-be-referenced-via-enums-rather-than-via-numeric-literals)
    - [\[NC-3\] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`](#nc-3-use-stringconcat-or-bytesconcat-instead-of-abiencodepacked)
    - [\[NC-4\] `constant`s should be defined rather than using magic numbers](#nc-4-constants-should-be-defined-rather-than-using-magic-numbers)
    - [\[NC-5\] Control structures do not follow the Solidity Style Guide](#nc-5-control-structures-do-not-follow-the-solidity-style-guide)
    - [\[NC-6\] Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function](#nc-6-duplicated-requirerevert-checks-should-be-refactored-to-a-modifier-or-function)
    - [\[NC-7\] Unused `error` definition](#nc-7-unused-error-definition)
    - [\[NC-8\] Event missing indexed field](#nc-8-event-missing-indexed-field)
    - [\[NC-9\] Events that mark critical parameter changes should contain both the old and the new value](#nc-9-events-that-mark-critical-parameter-changes-should-contain-both-the-old-and-the-new-value)
    - [\[NC-10\] Function ordering does not follow the Solidity style guide](#nc-10-function-ordering-does-not-follow-the-solidity-style-guide)
    - [\[NC-11\] Functions should not be longer than 50 lines](#nc-11-functions-should-not-be-longer-than-50-lines)
    - [\[NC-12\] Change int to int256](#nc-12-change-int-to-int256)
    - [\[NC-13\] Change uint to uint256](#nc-13-change-uint-to-uint256)
    - [\[NC-14\] Lack of checks in setters](#nc-14-lack-of-checks-in-setters)
    - [\[NC-15\] Missing Event for critical parameters change](#nc-15-missing-event-for-critical-parameters-change)
    - [\[NC-16\] NatSpec is completely non-existent on functions that should have them](#nc-16-natspec-is-completely-non-existent-on-functions-that-should-have-them)
    - [\[NC-17\] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor](#nc-17-use-a-modifier-instead-of-a-requireif-statement-for-a-special-msgsender-actor)
    - [\[NC-18\] Constant state variables defined more than once](#nc-18-constant-state-variables-defined-more-than-once)
    - [\[NC-19\] Consider using named mappings](#nc-19-consider-using-named-mappings)
    - [\[NC-20\] `address`s shouldn't be hard-coded](#nc-20-addresss-shouldnt-be-hard-coded)
    - [\[NC-21\] Owner can renounce while system is paused](#nc-21-owner-can-renounce-while-system-is-paused)
    - [\[NC-22\] `require()` / `revert()` statements should have descriptive reason strings](#nc-22-requirerevertstatements-should-have-descriptive-reason-strings)
    - [\[NC-23\] Take advantage of Custom Error's return value property](#nc-23-take-advantage-of-custom-errors-return-value-property)
    - [\[NC-24\] Avoid the use of sensitive terms](#nc-24-avoid-the-use-of-sensitive-terms)
    - [\[NC-25\] Contract does not follow the Solidity style guide's suggested layout ordering](#nc-25-contract-does-not-follow-the-solidity-style-guides-suggested-layout-ordering)
    - [\[NC-26\] Use Underscores for Number Literals (add an underscore every 3 digits)](#nc-26-use-underscores-for-number-literals-add-an-underscore-every-3-digits)
    - [\[NC-27\] Internal and private variables and functions names should begin with an underscore](#nc-27-internal-and-private-variables-and-functions-names-should-begin-with-an-underscore)
    - [\[NC-28\] Event is missing `indexed` fields](#nc-28-event-is-missing-indexed-fields)
    - [\[NC-29\] Constants should be defined rather than using magic numbers](#nc-29-constants-should-be-defined-rather-than-using-magic-numbers)
    - [\[NC-30\] `public` functions not called by the contract should be declared `external` instead](#nc-30-public-functions-not-called-by-the-contract-should-be-declared-external-instead)
    - [\[NC-31\] Variables need not be initialized to zero](#nc-31-variables-need-not-be-initialized-to-zero)
  - [Low Issues](#low-issues)
    - [\[L-1\] `approve()`/`safeApprove()` may revert if the current approval is not zero](#l-1-approvesafeapprove-may-revert-if-the-current-approval-is-not-zero)
    - [\[L-2\] Use of `tx.origin` is unsafe in almost every context](#l-2-use-of-txorigin-is-unsafe-in-almost-every-context)
    - [\[L-3\] Some tokens may revert when zero value transfers are made](#l-3-some-tokens-may-revert-when-zero-value-transfers-are-made)
    - [\[L-4\] Missing checks for `address(0)` when assigning values to address state variables](#l-4-missing-checks-for-address0-when-assigning-values-to-address-state-variables)
    - [\[L-5\] `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`](#l-5-abiencodepacked-should-not-be-used-with-dynamic-types-when-passing-the-result-to-a-hash-function-such-as-keccak256)
    - [\[L-6\] Use of `tx.origin` is unsafe in almost every context](#l-6-use-of-txorigin-is-unsafe-in-almost-every-context)
    - [\[L-7\] `decimals()` is not a part of the ERC-20 standard](#l-7-decimals-is-not-a-part-of-the-erc-20-standard)
    - [\[L-8\] Deprecated approve() function](#l-8-deprecated-approve-function)
    - [\[L-9\] Division by zero not prevented](#l-9-division-by-zero-not-prevented)
    - [\[L-10\] `domainSeparator()` isn't protected against replay attacks in case of a future chain split](#l-10-domainseparator-isnt-protected-against-replay-attacks-in-case-of-a-future-chain-split)
    - [\[L-11\] Empty `receive()/payable fallback()` function does not authenticate requests](#l-11-empty-receivepayable-fallback-function-does-not-authenticate-requests)
    - [\[L-12\] External call recipient may consume all transaction gas](#l-12-external-call-recipient-may-consume-all-transaction-gas)
    - [\[L-13\] Signature use at deadlines should be allowed](#l-13-signature-use-at-deadlines-should-be-allowed)
    - [\[L-14\] Prevent accidentally burning tokens](#l-14-prevent-accidentally-burning-tokens)
    - [\[L-15\] NFT ownership doesn't support hard forks](#l-15-nft-ownership-doesnt-support-hard-forks)
    - [\[L-16\] Owner can renounce while system is paused](#l-16-owner-can-renounce-while-system-is-paused)
    - [\[L-17\] Possible rounding issue](#l-17-possible-rounding-issue)
    - [\[L-18\] Loss of precision](#l-18-loss-of-precision)
    - [\[L-19\] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`](#l-19-solidity-version-0820-may-not-work-on-other-chains-due-to-push0)
    - [\[L-20\] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`](#l-20-use-ownable2steptransferownership-instead-of-ownabletransferownership)
    - [\[L-21\] Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting](#l-21-consider-using-openzeppelins-safecast-library-to-prevent-unexpected-overflows-when-downcasting)
    - [\[L-22\] Unsafe ERC20 operation(s)](#l-22-unsafe-erc20-operations)
    - [\[L-23\] Unspecific compiler version pragma](#l-23-unspecific-compiler-version-pragma)
    - [\[L-24\] A year is not always 365 days](#l-24-a-year-is-not-always-365-days)
  - [Medium Issues](#medium-issues)
    - [\[M-1\] Contracts are vulnerable to fee-on-transfer accounting-related issues](#m-1-contracts-are-vulnerable-to-fee-on-transfer-accounting-related-issues)
    - [\[M-2\] Centralization Risk for trusted owners](#m-2-centralization-risk-for-trusted-owners)
      - [Impact](#impact)
    - [\[M-3\] `_safeMint()` should be used rather than `_mint()` wherever possible](#m-3-_safemint-should-be-used-rather-than-_mint-wherever-possible)
    - [\[M-4\] Using `transferFrom` on ERC721 tokens](#m-4-using-transferfrom-on-erc721-tokens)
    - [\[M-5\] Fees can be set to be greater than 100%](#m-5-fees-can-be-set-to-be-greater-than-100)
    - [\[M-6\]  Solmate's SafeTransferLib does not check for token contract's existence](#m-6--solmates-safetransferlib-does-not-check-for-token-contracts-existence)
    - [\[M-7\] Return values of `transfer()`/`transferFrom()` not checked](#m-7-return-values-of-transfertransferfrom-not-checked)
    - [\[M-8\] Unsafe use of `transfer()`/`transferFrom()` with `IERC20`](#m-8-unsafe-use-of-transfertransferfrom-with-ierc20)

## Gas Optimizations

| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 32 |
| [GAS-2](#GAS-2) | Use assembly to check for `address(0)` | 10 |
| [GAS-3](#GAS-3) | Using bools for storage incurs overhead | 7 |
| [GAS-4](#GAS-4) | Cache array length outside of loop | 3 |
| [GAS-5](#GAS-5) | State variables should be cached in stack variables rather than re-reading them from storage | 7 |
| [GAS-6](#GAS-6) | Use calldata instead of memory for function arguments that do not get mutated | 3 |
| [GAS-7](#GAS-7) | For Operations that will not overflow, you could use unchecked | 417 |
| [GAS-8](#GAS-8) | Use Custom Errors instead of Revert Strings to save Gas | 10 |
| [GAS-9](#GAS-9) | Avoid contract existence checks by using low level calls | 13 |
| [GAS-10](#GAS-10) | Stack variable used as a cheaper cache for a state variable is only used once | 2 |
| [GAS-11](#GAS-11) | State variables only set in the constructor should be declared `immutable` | 48 |
| [GAS-12](#GAS-12) | Functions guaranteed to revert when called by normal users can be marked `payable` | 43 |
| [GAS-13](#GAS-13) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 1 |
| [GAS-14](#GAS-14) | Using `private` rather than `public` for constants, saves gas | 17 |
| [GAS-15](#GAS-15) | `uint256` to `bool` `mapping`: Utilizing Bitmaps to dramatically save on Gas | 2 |
| [GAS-16](#GAS-16) | Use != 0 instead of > 0 for unsigned integer comparison | 4 |
| [GAS-17](#GAS-17) | `internal` functions not called by the contract should be removed | 9 |
| [GAS-18](#GAS-18) | WETH address definition can be use directly | 2 |

### <a name="GAS-1"></a>[GAS-1] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)

This saves **16 gas per instance.**

*Instances (32)*:

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

100:                 totalOwed += owed;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

61:             totalPrincipalAndPaidInterestOwed += thisTranche.accruedInterest;

62:             totalPendingInterestOwed += pendingInterest;

63:             owedPerTranche[i] += thisTranche.principalAmount + thisTranche.accruedInterest + pendingInterest;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

219:         _vaultERC20s[ETH][_vaultId] += msg.value;

316:         _vaultERC20s[_token][_vaultId] += _amount;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

309:             totalFeeTax += feeTax;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

283:                 totalRefinanced += tranche.principalAmount;

284:                 totalAnnualInterest += tranche.principalAmount * tranche.aprBps;

285:                 totalProtocolFee += thisProtocolFee;

562:             _remainingNewLender += totalProtocolFee;

594:                 totalAnnualInterest += tranche.principalAmount * tranche.aprBps;

595:                 totalAccruedInterest += accruedInterest;

596:                 totalProtocolFee += thisProtocolFee;

637:             accruedInterest += _tranche.accruedInterest;

918:                     totalProtocolFee += thisProtocolFee;

924:                 totalRepayment += repayment;

1000:                 totalAmount += amount;

1001:                 totalAmountWithMaxInterest += amount + amount.getInterest(offer.aprBps, _duration);

1006:                 totalFee += fee;

1014:                 _used[lender][offer.offerId] += amount;

1072:             _loan.principalAmount += _renegotiationOffer.principalAmount;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/Pool.sol

427:         getCollectedFees += fees;

533:         outstandingValues.accruedInterest += uint128(

539:             outstandingValues.sumApr += uint128(_apr * _principalAmount);

540:             outstandingValues.principalAmount += uint128(_principalAmount);

577:             getTotalReceived[idx] += _received;

706:             _pendingWithdrawal[secondIdx] += pendingForQueue;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

69:             getTotalShares += _shares;

96:             getWithdrawn[_tokenId] += available;

97:             _totalWithdrawn += available;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/Interest.sol

27:             owed += tranche.principalAmount + tranche.accruedInterest

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

### <a name="GAS-2"></a>[GAS-2] Use assembly to check for `address(0)`

*Saves 6 gas per instance*

*Instances (10)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

206:         if (_auctions[_nftAddress][_tokenId] != bytes32(0)) {

275:         if (_auction.highestBidder == address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/InputChecker.sol

11:         if (_address == address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

38:         if (_liquidator == address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

46:         if (getLoanManager != address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

881:             } else if ((totalValidators == 1) && _loanOffer.validators[0].validator == address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

142:         if (getPool != address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

197:         if (proposedAllocator == address(0)) {

316:             if (_deployedQueues[idx].contractAddress == address(0)) {

428:         _loanAddress = _loanAddress != address(0) ? _loanAddress : msg.sender;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="GAS-3"></a>[GAS-3] Using bools for storage incurs overhead

Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (7)*:

```solidity
File: src/lib/AddressManager.sol

29:     mapping(address => bool) private _whitelist;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

16:     mapping(address callbackContract => bool isWhitelisted) internal _isWhitelistedCallbackContract;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

52:     mapping(address user => mapping(uint256 offerId => bool notActive)) public isOfferCancelled;

57:     mapping(address user => mapping(uint256 renegotiationIf => bool notActive)) public isRenegotiationOfferCancelled;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

28:     mapping(address => bool) internal _isLoanContract;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

9:     mapping(address loanManagerAddress => bool active) internal _loanManagers;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/pools/Pool.sol

89:     bool public isActive;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="GAS-4"></a>[GAS-4] Cache array length outside of loop

If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (3)*:

```solidity
File: src/lib/UserVault.sol

273:         for (uint256 i = 0; i < _tokens.length;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

571:         for (uint256 i = 0; i < _loan.tranche.length << 1;) { 

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/utils/Interest.sol

25:         for (uint256 i = 0; i < _loan.tranche.length;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

### <a name="GAS-5"></a>[GAS-5] State variables should be cached in stack variables rather than re-reading them from storage

The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (7)*:

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

97:             IAaveLendingPool(_aavePool).deposit(_usdc, delta, address(this), 0);

100:             IAaveLendingPool(_aavePool).withdraw(_usdc, delta, address(this));

100:             IAaveLendingPool(_aavePool).withdraw(_usdc, delta, address(this));

101:             ERC20(_usdc).transfer(pool, delta);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

359:             IBaseInterestAllocator(getBaseInterestAllocator).getBaseAprWithUpdate(), _offer

369:             IBaseInterestAllocator(getBaseInterestAllocator).reallocate(currentBalance, principalAmount, true);

425:             fees = IFeeManager(getFeeManager).processFees(_received, 0);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="GAS-6"></a>[GAS-6] Use calldata instead of memory for function arguments that do not get mutated

When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop.

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one.

 *Saves 60 gas per instance*

*Instances (3)*:

```solidity
File: src/lib/loans/MultiSourceLoan.sol

238:     function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)

367:         Loan memory _loan,

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

205:     function getPrincipalFactors(address _collection, uint96 _duration, bytes memory _extra)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

### <a name="GAS-7"></a>[GAS-7] For Operations that will not overflow, you could use unchecked

*Instances (417)*:

```solidity
File: src/lib/AddressManager.sol

4: import "@solmate/auth/Owned.sol";

5: import "@solmate/utils/ReentrancyGuard.sol";

7: import "./InputChecker.sol";

38:                 ++i;

95:             ++_lastAdded;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

4: import "@openzeppelin/utils/structs/EnumerableSet.sol";

5: import "@solmate/auth/Owned.sol";

6: import "@solmate/utils/FixedPointMathLib.sol";

7: import "@solmate/utils/ReentrancyGuard.sol";

8: import "@solmate/utils/SafeTransferLib.sol";

9: import "@solmate/tokens/ERC20.sol";

10: import "@solmate/tokens/ERC721.sol";

12: import "../interfaces/ILiquidationDistributor.sol";

13: import "../interfaces/IAuctionLoanLiquidator.sol";

14: import "../interfaces/ILoanLiquidator.sol";

15: import "../interfaces/loans/IMultiSourceLoan.sol";

16: import "./AddressManager.sol";

17: import "./InputChecker.sol";

18: import "./utils/Hash.sol";

241:         uint96 expiration = _auction.startTime + _auction.duration;

242:         uint96 withMargin = _auction.lastBidTime + _MIN_NO_ACTION_MARGIN;

243:         uint96 maxExtension = expiration + getMaxExtension;

280:         uint96 expiration = _auction.startTime + _auction.duration;

281:         uint96 withMargin = _auction.lastBidTime + _MIN_NO_ACTION_MARGIN;

282:         uint96 maxExtension = expiration + getMaxExtension;

293:         uint256 proceeds = highestBid - 2 * triggerFee;

334:         if ((_bid < _auction.minBid) || (_auction.highestBid.mulDivDown(_BPS + MIN_INCREMENT_BPS, _BPS) >= _bid)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

4: import "../interfaces/loans/ILoanManagerRegistry.sol";

5: import "./loans/LoanManager.sol";

6: import "./utils/Interest.sol";

7: import "./AuctionLoanLiquidator.sol";

74:         uint256 timeLimit = _auction.startTime + _timeForMainLenderToBuy;

87:                 ++i;

98:                 uint256 owed = thisTranche.principalAmount + thisTranche.accruedInterest

99:                     + thisTranche.principalAmount.getInterest(thisTranche.aprBps, block.timestamp - thisTranche.startTime);

100:                 totalOwed += owed;

117:                 ++i;

153:         uint256 timeLimit = _auction.startTime + _timeForMainLenderToBuy;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

4: import "@solmate/auth/Owned.sol";

5: import "@solmate/utils/FixedPointMathLib.sol";

6: import "@solmate/utils/ReentrancyGuard.sol";

7: import "@solmate/utils/SafeTransferLib.sol";

8: import "@solmate/tokens/ERC20.sol";

10: import "../interfaces/ILiquidationDistributor.sol";

11: import "../interfaces/loans/IMultiSourceLoan.sol";

12: import "../interfaces/loans/ILoanManagerRegistry.sol";

13: import "./loans/LoanManager.sol";

14: import "./utils/Interest.sol";

55:         uint256 loanEndTime = _loan.startTime + _loan.duration;

60:                 thisTranche.principalAmount.getInterest(thisTranche.aprBps, loanEndTime - thisTranche.startTime);

61:             totalPrincipalAndPaidInterestOwed += thisTranche.accruedInterest;

62:             totalPendingInterestOwed += pendingInterest;

63:             owedPerTranche[i] += thisTranche.principalAmount + thisTranche.accruedInterest + pendingInterest;

65:                 ++i;

68:         if (_proceeds > totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed) {

77:                     totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed,

82:                     ++i;

92:                     ++i;

108:         uint256 excess = _proceeds - _totalOwed;

110:         uint256 owed = _tranche.principalAmount + _tranche.accruedInterest

111:             + _tranche.principalAmount.getInterest(_tranche.aprBps, _loanEndTime - _tranche.startTime);

112:         uint256 total = owed + excess.mulDivDown(owed, _totalOwed);

129:             _proceedsLeft -= _trancheOwed;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

4: import "@solmate/auth/Owned.sol";

5: import "@solmate/tokens/ERC721.sol";

6: import "@solmate/utils/FixedPointMathLib.sol";

7: import "@solmate/utils/ReentrancyGuard.sol";

9: import "../interfaces/ILiquidationHandler.sol";

10: import "../interfaces/loans/IMultiSourceLoan.sol";

11: import "./callbacks/CallbackHandler.sol";

12: import "./InputChecker.sol";

100:         uint256 expirationTime = _loan.startTime + _loan.duration;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/Multicall.sol

4: import "../interfaces/IMulticall.sol";

22:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/Multicall.sol)

```solidity
File: src/lib/UserVault.sol

4: import "@openzeppelin/utils/Strings.sol";

5: import "@solmate/auth/Owned.sol";

6: import "@solmate/tokens/ERC721.sol";

7: import "@solmate/utils/SafeTransferLib.sol";

9: import "../interfaces/IOldERC721.sol";

10: import "../interfaces/IUserVault.sol";

11: import "./AddressManager.sol";

19:     string private constant _BASE_URI = "https://gondi.xyz/user_vaults/";

88:             _vaultId = ++_nextId;

116:                 ++i;

126:                 ++i;

133:                 ++i;

172:                 ++i;

198:                 ++i;

219:         _vaultERC20s[ETH][_vaultId] += msg.value;

240:                 ++i;

261:                 ++i;

276:                 ++i;

316:         _vaultERC20s[_token][_vaultId] += _amount;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

4: import "../utils/TwoStepOwned.sol";

5: import "../InputChecker.sol";

6: import "../utils/WithProtocolFee.sol";

7: import "../../interfaces/callbacks/ILoanCallback.sol";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

4: import "@seaport/seaport-types/src/lib/ConsiderationStructs.sol";

5: import "@solmate/auth/Owned.sol";

6: import "@solmate/tokens/ERC721.sol";

7: import "@solmate/tokens/WETH.sol";

8: import "@solmate/utils/FixedPointMathLib.sol";

9: import "@solmate/utils/SafeTransferLib.sol";

11: import "../../interfaces/external/IReservoir.sol";

12: import "../../interfaces/callbacks/IPurchaseBundler.sol";

13: import "../../interfaces/callbacks/ILoanCallback.sol";

14: import "../../interfaces/external/ICryptoPunksMarket.sol";

15: import "../../interfaces/external/IWrappedPunk.sol";

16: import "../utils/WithProtocolFee.sol";

17: import "../loans/MultiSourceLoan.sol";

18: import "../utils/BytesLib.sol";

19: import "../AddressManager.sol";

20: import "../InputChecker.sol";

109:                 ++i;

139:                 ++i;

159:         uint256 borrowed = _loan.principalAmount - _fee;

285:         if (block.timestamp < _pendingTaxesSetTime + TAX_UPDATE_NOTICE) {

309:             totalFeeTax += feeTax;

310:             ERC20(principalAddress).safeTransferFrom(borrower, tranche.lender, taxCost - feeTax);

312:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

4: import "@openzeppelin/utils/cryptography/MessageHashUtils.sol";

5: import "@openzeppelin/interfaces/IERC1271.sol";

7: import "@solmate/auth/Owned.sol";

8: import "@solmate/tokens/ERC721.sol";

9: import "@solmate/utils/FixedPointMathLib.sol";

11: import "../../interfaces/loans/IBaseLoan.sol";

12: import "../utils/Hash.sol";

13: import "../AddressManager.sol";

14: import "../LiquidationHandler.sol";

197:             return ++getTotalLoansIssued;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

4: import "@openzeppelin/utils/structs/EnumerableSet.sol";

6: import "../loans//LoanManagerParameterSetter.sol";

7: import "../../interfaces/loans/ILoanManager.sol";

8: import "../../interfaces/pools/IPoolOfferHandler.sol";

9: import "../InputChecker.sol";

10: import "../utils/TwoStepOwned.sol";

68:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

4: import "../../interfaces/loans/ILoanManager.sol";

5: import "../../interfaces/pools/IPoolOfferHandler.sol";

6: import "../InputChecker.sol";

7: import "../utils/TwoStepOwned.sol";

76:         if (getProposedOfferHandlerSetTime + UPDATE_WAITING_TIME > block.timestamp) {

105:         if (getProposedAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {

119:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

4: import "@solmate/auth/Owned.sol";

6: import "../../interfaces/loans/ILoanManagerRegistry.sol";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

4: import "@delegate/IDelegateRegistry.sol";

5: import "@openzeppelin/utils/cryptography/ECDSA.sol";

6: import "@solmate/tokens/ERC20.sol";

7: import "@solmate/tokens/ERC721.sol";

8: import "@solmate/utils/FixedPointMathLib.sol";

9: import "@solmate/utils/ReentrancyGuard.sol";

10: import "@solmate/utils/SafeTransferLib.sol";

12: import "../../interfaces/validators/IOfferValidator.sol";

13: import "../../interfaces/INFTFlashAction.sol";

14: import "../../interfaces/loans/ILoanManager.sol";

15: import "../../interfaces/loans/ILoanManagerRegistry.sol";

16: import "../../interfaces/loans/IMultiSourceLoan.sol";

17: import "../utils/Hash.sol";

18: import "../utils/Interest.sol";

19: import "../Multicall.sol";

20: import "./BaseLoan.sol";

173:         uint256 netNewLender = _renegotiationOffer.principalAmount - _renegotiationOffer.fee;

181:             if (_isLoanLocked(_loan.startTime, _loan.startTime + _loan.duration)) {

187:                 _renegotiationOffer.duration + block.timestamp,

188:                 _loan.duration + _loan.startTime,

190:                 totalAnnualInterest / _loan.principalAmount,

197:                     _renegotiationOffer.principalAmount - _loan.principalAmount

224:         _loan.duration = (block.timestamp - _loan.startTime) + _renegotiationOffer.duration;

247:         if (_isLoanLocked(_loan.startTime, _loan.startTime + _loan.duration)) {

278:                 _loan.startTime + _loan.duration,

283:                 totalRefinanced += tranche.principalAmount;

284:                 totalAnnualInterest += tranche.principalAmount * tranche.aprBps;

285:                 totalProtocolFee += thisProtocolFee;

294:                 ++i;

394:             _renegotiationOffer.lender, _loan.borrower, _renegotiationOffer.principalAmount - _renegotiationOffer.fee

562:             _remainingNewLender += totalProtocolFee;

576:                 ++i;

586:                 _loan.startTime + _loan.duration,

594:                 totalAnnualInterest += tranche.principalAmount * tranche.aprBps;

595:                 totalAccruedInterest += accruedInterest;

596:                 totalProtocolFee += thisProtocolFee;

635:                 _tranche.principalAmount.getInterest(_tranche.aprBps, block.timestamp - _tranche.startTime);

637:             accruedInterest += _tranche.accruedInterest;

653:             oldLenderDebt = _tranche.principalAmount + accruedInterest - thisProtocolFee;

657:             asset.safeTransferFrom(_borrower, _tranche.lender, oldLenderDebt - _remainingNewLender);

665:                 _remainingNewLender -= oldLenderDebt;

678:         if (_loan.startTime + _loan.duration <= block.timestamp) {

731:                 && ((_currentAprBps - _targetAprBps).mulDivDown(_PRECISION, _currentAprBps) < __minImprovementApr)

741:             delta = _loanEndTime - _trancheStartTime;

743:         return _trancheStartTime + delta.mulDivUp(_minLockPeriod, _PRECISION);

750:             delta = _loanEndTime - _loanStartTime;

752:         return block.timestamp > _loanEndTime - delta.mulDivUp(_minLockPeriod, _PRECISION);

791:         if (_offerExecution.amount + _totalAmount > offer.principalAmount) {

792:             revert InvalidAmountError(_offerExecution.amount + _totalAmount, offer.principalAmount);

801:         if ((offer.capacity != 0) && (_used[_lender][offer.offerId] + _offerExecution.amount > offer.capacity)) {

888:                     ++i;

896:         return _loanPrincipal / (_MAX_RATIO_TRANCHE_MIN_PRINCIPAL * getMaxTranches);

913:                 tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);

918:                     totalProtocolFee += thisProtocolFee;

921:             uint256 repayment = tranche.principalAmount + tranche.accruedInterest + newInterest - thisProtocolFee;

924:                 totalRepayment += repayment;

937:                 ++i;

1000:                 totalAmount += amount;

1001:                 totalAmountWithMaxInterest += amount + amount.getInterest(offer.aprBps, _duration);

1006:                 totalFee += fee;

1012:             ERC20(offer.principalAddress).safeTransferFrom(lender, _principalReceiver, amount - fee);

1014:                 _used[lender][offer.offerId] += amount;

1021:                 ++i;

1051:         IMultiSourceLoan.Tranche[] memory tranches = new IMultiSourceLoan.Tranche[](newTrancheIndex + 1);

1057:                 ++i;

1072:             _loan.principalAmount += _renegotiationOffer.principalAmount;

1112:                 (_offerPrincipalAmount - _loanPrincipalAmount != 0)

1114:                         (_loanAprBps * _loanPrincipalAmount - _offerAprBps * _offerPrincipalAmount).mulDivDown(

1115:                             _PRECISION, _loanAprBps * _loanPrincipalAmount

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

4: import "@solmate/auth/Owned.sol";

5: import "@solmate/tokens/ERC20.sol";

6: import "@solmate/tokens/WETH.sol";

7: import "@solmate/utils/FixedPointMathLib.sol";

9: import "../../interfaces/external/IAaveRewardsController.sol";

10: import "../../interfaces/external/IAaveLendingPool.sol";

11: import "../../interfaces/pools/IBaseInterestAllocator.sol";

12: import "./Pool.sol";

95:             uint256 delta = _currentIdle - _targetIdle;

99:             uint256 delta = _targetIdle - _currentIdle;

137:         return currentLiquidityRate * _BPS / _RAY;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

4: import {Math} from "@openzeppelin/utils/math/Math.sol";

5: import {ERC20} from "@solmate/tokens/ERC20.sol";

6: import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

7: import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

36:         ERC20(_name, _symbol, _asset.decimals() + _decimalsOffset)

43:                         DEPOSIT/WITHDRAWAL LOGIC

61:         assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

74:         shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

77:             uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

79:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

93:             uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

95:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

148:         return assets.mulDiv(totalSupply + 10 ** decimalsOffset, totalAssets() + 1, rounding);

153:         return shares.mulDiv(totalAssets() + 1, totalSupply + 10 ** decimalsOffset, rounding);

157:                      DEPOSIT/WITHDRAWAL LIMIT LOGIC

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/FeeManager.sol

4: import "@solmate/utils/FixedPointMathLib.sol";

6: import "../utils/TwoStepOwned.sol";

7: import "../../interfaces/pools/IFeeManager.sol";

48:         if (_proposedFeesSetTime + WAIT_TIME > block.timestamp) {

77:             + _interest.mulDivDown(__fees.performanceFee, PRECISION);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

4: import "@solmate/auth/Owned.sol";

5: import "@solmate/tokens/ERC20.sol";

6: import "@solmate/tokens/WETH.sol";

7: import "@solmate/utils/FixedPointMathLib.sol";

9: import "./Pool.sol";

10: import "../../interfaces/external/ICurve.sol";

11: import "../../interfaces/external/ILido.sol";

12: import "../../interfaces/pools/IBaseInterestAllocator.sol";

79:         if (block.timestamp - lidoData.lastTs > getLidoUpdateTolerance) {

82:                 _BPS * _SECONDS_PER_YEAR * (shareRate - lidoData.shareRate) / lidoData.shareRate

83:                     / (block.timestamp - lidoData.lastTs)

95:         if (block.timestamp - lidoData.lastTs > getLidoUpdateTolerance) {

119:             uint256 amount = _currentIdle - _targetIdle;

126:             _exchangeAndSendWeth(pool, _targetIdle - _currentIdle, _force);

142:         return lido.getTotalPooledEther() * 1e27 / lido.getTotalShares();

156:         uint256 received = ICurve(_curvePool).exchange(1, 0, _amount, _amount.mulDivUp(_BPS - slippage, _BPS));

164:             _BPS * _SECONDS_PER_YEAR * (shareRate - _lidoData.shareRate) / _lidoData.shareRate

165:                 / (block.timestamp - _lidoData.lastTs)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

4: import "../../interfaces/pools/IOracle.sol";

5: import "../utils/TwoStepOwned.sol";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

4: import "@solmate/utils/FixedPointMathLib.sol";

5: import "@solady/utils/MerkleProofLib.sol";

7: import "../../interfaces/loans/IMultiSourceLoan.sol";

8: import "../../interfaces/pools/IOracle.sol";

9: import "../../interfaces/pools/IPoolOfferHandler.sol";

10: import "./Pool.sol";

11: import "../utils/TwoStepOwned.sol";

161:         if (block.timestamp - MIN_WAIT_TIME < getProposedOracleSetTs) {

180:         if (block.timestamp - MIN_WAIT_TIME < getProposedAprFactorsSetTs) {

239:                 ++i;

260:         if (block.timestamp - MIN_WAIT_TIME_UPDATE_FACTOR < getProposedCollectionFactorsSetTs) {

281:                 ++i;

299:             (block.timestamp - aprPremium.updatedTs > getAprUpdateTolerance) ? _calculateAprPremium() : aprPremium.value;

309:             block.timestamp - currentFloor.updated > duration.mulDivDown(TOLERANCE_FLOOR, PRECISION)

310:                 || block.timestamp - historicalFloor.updated > duration.mulDivDown(TOLERANCE_HISTORICAL_FLOOR, PRECISION)

333:         if (_baseRate + aprPremiumValue > offerExecution.offer.aprBps) {

394:         uint256 totalOutstanding = totalAssets - pool.getUndeployedAssets();

396:             totalOutstanding.mulDivUp(aprFactors.utilizationFactor, totalAssets * PRECISION) + aprFactors.minPremium

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

4: import "@solmate/utils/FixedPointMathLib.sol";

5: import "@solmate/utils/ReentrancyGuard.sol";

6: import "@solmate/utils/SafeTransferLib.sol";

8: import "../../interfaces/pools/IBaseInterestAllocator.sol";

9: import "../../interfaces/pools/IFeeManager.sol";

10: import "../../interfaces/pools/IPool.sol";

11: import "../../interfaces/pools/IPoolWithWithdrawalQueues.sol";

12: import "../../interfaces/pools/IPoolOfferHandler.sol";

13: import "../loans/LoanManager.sol";

14: import "../utils/Interest.sol";

15: import {ERC4626} from "./ERC4626.sol";

16: import "./WithdrawalQueue.sol";

149:         _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) >> 1;

156:         getMinTimeBetweenWithdrawalQueues = (IPoolOfferHandler(getOfferHandler).getMaxDuration() + _LOAN_BUFFER_TIME)

159:         _deployedQueues = new DeployedQueue[](_maxTotalWithdrawalQueues + 1);

163:         _queueOutstandingValues = new OutstandingValues[](_maxTotalWithdrawalQueues + 1);

164:         _queueAccounting = new QueueAccounting[](_maxTotalWithdrawalQueues + 1);

178:         _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) >> 1;

203:             if (getProposedBaseInterestAllocatorSetTime + UPDATE_WAITING_TIME > block.timestamp) {

215:         if (allocatorChanged && asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees > 0) {

236:         return _getUndeployedAssets() + _getTotalOutstandingValue();

276:         if (block.timestamp - queue.deployedTime < getMinTimeBetweenWithdrawalQueues) {

287:         uint256 lastQueueIndex = (pendingQueueIndex + 1) % totalQueues;

294:             uint128((totalSupplyCached - sharesPendingWithdrawal).mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached));

300:         _queueClaimAll(proRataLiquid + getAvailableToWithdraw, pendingQueueIndex);

309:         uint256 baseIdx = pendingQueueIndex + totalQueues;

314:         for (uint256 i = 1; i < totalQueues - 1;) {

315:             uint256 idx = (baseIdx - i) % totalQueues;

320:             _queueAccounting[idx].netPoolFraction -=

324:                 ++i;

341:             totalSupply -= sharesPendingWithdrawal;

355:         uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees;

357:         uint256 undeployedAssets = currentBalance + baseRateBalance;

378:         uint256 delta = currentBalance > targetIdle ? currentBalance - targetIdle : targetIdle - currentBalance;

398:         uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);

399:         uint256 received = _principalAmount + interestEarned;

401:         getCollectedFees = getCollectedFees + fees;

402:         _loanTermination(msg.sender, _loanId, _principalAmount, netApr, interestEarned, received - fees);

420:         uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);

423:             fees = IFeeManager(getFeeManager).processFees(_principalAmount, _received - _principalAmount);

427:         getCollectedFees += fees;

429:         _loanTermination(_loanAddress, _loanId, _principalAmount, netApr, interestEarned, _received - fees);

439:         shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

441:             uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

444:                 allowance[owner][msg.sender] = allowed - shares;

453:             uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

456:                 allowance[owner][msg.sender] = allowed - shares;

488:         balanceOf[from] -= amount;

499:         uint256 newest = (_pendingQueueIndex + totalQueues - 1) % totalQueues;

500:         for (uint256 i; i < totalQueues - 1;) {

501:             uint256 idx = (newest + totalQueues - i) % totalQueues;

505:                 + _getOutstandingValue(queueOutstandingValues).mulDivDown(

509:                 ++i;

518:         return principal + uint256(__outstandingValues.accruedInterest)

519:             + principal.getInterest(

520:                 uint256(_outstandingApr(__outstandingValues)), block.timestamp - uint256(__outstandingValues.lastTs)

533:         outstandingValues.accruedInterest += uint128(

535:                 uint256(_outstandingApr(outstandingValues)), block.timestamp - uint256(outstandingValues.lastTs)

539:             outstandingValues.sumApr += uint128(_apr * _principalAmount);

540:             outstandingValues.principalAmount += uint128(_principalAmount);

556:         uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;

561:             idx = (pendingIndex + i) % totalQueues;

566:                 ++i;

576:                 _received.mulDivDown(PRINCIPAL_PRECISION - _queueAccounting[idx].netPoolFraction, PRINCIPAL_PRECISION);

577:             getTotalReceived[idx] += _received;

578:             getAvailableToWithdraw = getAvailableToWithdraw + pendingToQueue;

595:         return asset.balanceOf(address(this)) + IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated()

596:             - getAvailableToWithdraw - getCollectedFees;

603:         uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees;

609:         uint256 total = currentBalance + baseRateBalance;

625:         uint256 currentBalance = asset.balanceOf(address(this)) - getCollectedFees;

631:         uint256 finalBalance = currentBalance + baseRateBalance - _withdrawn;

633:         IBaseInterestAllocator(baseInterestAllocator).reallocate(currentBalance, _withdrawn + targetIdle, true);

638:         return _apr.mulDivDown(_BPS - _protocolFee, _BPS);

658:                 ++i;

674:         uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;

690:                 secondIdx = (_idx + i) % totalQueues;

695:                     ++i;

704:             totalReceived -= pendingForQueue;

706:             _pendingWithdrawal[secondIdx] += pendingForQueue;

708:                 ++i;

717:         uint256 totalQueues = (getMaxTotalWithdrawalQueues + 1);

718:         uint256 oldestQueueIdx = (_cachedPendingQueueIndex + 1) % totalQueues;

721:             uint256 idx = (oldestQueueIdx + i) % totalQueues;

724:                 ++i;

732:                     ++i;

742:                 ++i;

752:         return __outstandingValues.sumApr / __outstandingValues.principalAmount;

769:             block.timestamp - uint256(__outstandingValues.lastTs), _SECONDS_PER_YEAR * _BPS

771:         uint256 total = __outstandingValues.accruedInterest + newlyAccrued;

777:             __outstandingValues.accruedInterest = uint128(total - _interestEarned);

779:         __outstandingValues.sumApr -= uint128(_apr * _principalAmount);

780:         __outstandingValues.principalAmount -= uint128(_principalAmount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

4: import "@openzeppelin/utils/Strings.sol";

5: import "@solmate/tokens/ERC20.sol";

6: import "@solmate/tokens/ERC721.sol";

7: import "@solmate/utils/SafeTransferLib.sol";

9: import "../Multicall.sol";

24:     string private constant _BASE_URI = "https://gondi.xyz/withdrawal-queue/";

69:             getTotalShares += _shares;

74:         return getNextTokenId++;

96:             getWithdrawn[_tokenId] += available;

97:             _totalWithdrawn += available;

123:         if (block.timestamp + _time < getUnlockTime[_tokenId]) {

127:         uint256 unlockTime = block.timestamp + _time;

143:         return (getShares[_tokenId] * (_totalWithdrawn + _asset.balanceOf(address(this)))) / getTotalShares

144:             - getWithdrawn[_tokenId];

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/BytesLib.sol

13:         require(_length + 31 >= _length, "slice_overflow");

14:         require(_start + _length >= _start, "slice_overflow");

15:         require(_bytes.length >= _start + _length, "slice_outOfBounds");

73:         require(_start + 20 >= _start, "toAddress_overflow");

74:         require(_bytes.length >= _start + 20, "toAddress_outOfBounds");

85:         require(_start + 3 >= _start, "toUint24_overflow");

86:         require(_bytes.length >= _start + 3, "toUint24_outOfBounds");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/Hash.sol

4: import "../../interfaces/loans/IMultiSourceLoan.sol";

5: import "../../interfaces/loans/IBaseLoan.sol";

6: import "../../interfaces/IAuctionLoanLiquidator.sol";

46:                 ++i;

77:                 ++i;

110:                 ++i;

135:                 ++i;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

```solidity
File: src/lib/utils/Interest.sol

4: import "@solmate/utils/FixedPointMathLib.sol";

5: import "../../interfaces/loans/IMultiSourceLoan.sol";

6: import "../../interfaces/loans/IBaseLoan.sol";

27:             owed += tranche.principalAmount + tranche.accruedInterest

28:                 + _getInterest(tranche.principalAmount, tranche.aprBps, _timestamp - tranche.startTime);

30:                 ++i;

37:         return _amount.mulDivUp(_aprBps * _duration, _PRECISION * _SECONDS_PER_YEAR);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

4: import "@solmate/auth/Owned.sol";

37:         if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

4: import "./TwoStepOwned.sol";

6: import "../InputChecker.sol";

70:         if (block.timestamp < _pendingProtocolFeeSetTime + FEE_UPDATE_NOTICE) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="GAS-8"></a>[GAS-8] Use Custom Errors instead of Revert Strings to save Gas

Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (10)*:

```solidity
File: src/lib/pools/ERC4626.sol

48:         require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

99:         require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/Pool.sol

461:         require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/BytesLib.sol

13:         require(_length + 31 >= _length, "slice_overflow");

14:         require(_start + _length >= _start, "slice_overflow");

15:         require(_bytes.length >= _start + _length, "slice_outOfBounds");

73:         require(_start + 20 >= _start, "toAddress_overflow");

74:         require(_bytes.length >= _start + 20, "toAddress_outOfBounds");

85:         require(_start + 3 >= _start, "toUint24_overflow");

86:         require(_bytes.length >= _start + 3, "toUint24_outOfBounds");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

### <a name="GAS-9"></a>[GAS-9] Avoid contract existence checks by using low level calls

Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (13)*:

```solidity
File: src/lib/Multicall.sol

16:             (success, results[i]) = address(this).delegatecall(data[i]);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/Multicall.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

218:             uint256 balance = asset.balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

1087:             address recovered = typedDataHash.recover(_signature);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

88:         return ERC20(_aToken).balanceOf(address(this));

109:         uint256 total = ERC20(_aToken).balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

111:         return ERC20(_lido).balanceOf(address(this));

134:         uint256 total = ERC20(_lido).balanceOf(address(this));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

215:         if (allocatorChanged && asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees > 0) {

355:         uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees;

595:         return asset.balanceOf(address(this)) + IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated()

603:         uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees;

625:         uint256 currentBalance = asset.balanceOf(address(this)) - getCollectedFees;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

143:         return (getShares[_tokenId] * (_totalWithdrawn + _asset.balanceOf(address(this)))) / getTotalShares

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="GAS-10"></a>[GAS-10] Stack variable used as a cheaper cache for a state variable is only used once

If the variable is only accessed once, it's cheaper to use the state variable directly that one time, and save the **3 gas** the extra stack assignment would spend

*Instances (2)*:

```solidity
File: src/lib/pools/Pool.sol

223:         uint256 fees = getCollectedFees;

555:         uint256 pendingIndex = _pendingQueueIndex;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="GAS-11"></a>[GAS-11] State variables only set in the constructor should be declared `immutable`

Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (48)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

126:         _currencyManager = AddressManager(currencyManager);

127:         _collectionManager = AddressManager(collectionManager);

129:         getMaxExtension = maxExtension;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

56:         getLoanManagerRegistry = ILoanManagerRegistry(loanManagerRegistry);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

34:         getLoanManagerRegistry = ILoanManagerRegistry(_loanManagerRegistry);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

79:         _currencyManager = AddressManager(currencyManager);

80:         _collectionManager = AddressManager(collectionManager);

81:         _oldCollectionManager = AddressManager(oldCollectionManager);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

76:         _marketplaceContractsAddressManager = AddressManager(_marketplaceContracts);

77:         _weth = WETH(_wethAddress);

78:         _punkMarket = ICryptoPunksMarket(_punkMarketAddress);

79:         _wrappedPunk = IWrappedPunk(_wrappedPunkAddress);

82:         _punkProxy = _wrappedPunk.proxyInfo(address(this));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

116:         name = _name;

120:         _currencyManager = AddressManager(currencyManager);

121:         _collectionManager = AddressManager(collectionManager);

123:         INITIAL_CHAIN_ID = block.chainid;

124:         INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

40:         UPDATE_WAITING_TIME = _updateWaitingTime;

42:         getParameterSetter = __offerHandlerSetter;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

38:         UPDATE_WAITING_TIME = _updateWaitingTime;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

115:         getMaxTranches = maxTranches;

116:         getDelegateRegistry = delegateRegistry;

118:         getLoanManagerRegistry = ILoanManagerRegistry(loanManagerRegistry);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

52:         getPool = _pool;

53:         _aavePool = __aavePool;

54:         _usdc = __usdc;

55:         _aToken = __aToken;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

38:         asset = _asset;

39:         decimalsOffset = _decimalsOffset;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

58:         getPool = _pool;

59:         _curvePool = __curvePool;

60:         _weth = __weth;

61:         _lido = __lido;

63:         getLidoUpdateTolerance = _lidoUpdateTolerance;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

133:         getAprUpdateTolerance = _aprUpdateTolerance;

135:         getMaxDuration = _maxDuration;

137:         _oracleFloorKey = __oracleFloorKey;

138:         _oracleHistoricalFloorKey = __oracleHistoricalFloorKey;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

145:         getFeeManager = _feeManager;

154:         getMaxTotalWithdrawalQueues = _maxTotalWithdrawalQueues;

156:         getMinTimeBetweenWithdrawalQueues = (IPoolOfferHandler(getOfferHandler).getMaxDuration() + _LOAN_BUFFER_TIME)

159:         _deployedQueues = new DeployedQueue[](_maxTotalWithdrawalQueues + 1);

163:         _queueOutstandingValues = new OutstandingValues[](_maxTotalWithdrawalQueues + 1);

164:         _queueAccounting = new QueueAccounting[](_maxTotalWithdrawalQueues + 1);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

52:         getPool = msg.sender;

54:         _asset = __asset;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

22:         MIN_WAIT_TIME = _minWaitTime;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="GAS-12"></a>[GAS-12] Functions guaranteed to revert when called by normal users can be marked `payable`

If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (43)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

133:     function addLoanContract(address _loanContract) external onlyOwner {

142:     function removeLoanContract(address _loanContract) external onlyOwner {

156:     function updateLiquidationDistributor(address __liquidationDistributor) external onlyOwner {

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

133:     function setTimeForMainLenderToBuy(uint256 __timeForMainLenderToBuy) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

37:     function setLiquidator(address _liquidator) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

74:     function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {

82:     function updateLiquidationAuctionDuration(uint48 _newDuration) external override onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

398:     function _onlyApproved(uint256 _vaultId) private view {

407:     function _onlyReadyForWithdrawal(uint256 _vaultId) private view {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

29:     function addWhitelistedCallbackContract(address _contract) external onlyOwner {

38:     function removeWhitelistedCallbackContract(address _contract) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

231:     function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {

240:     function finalUpdateMultiSourceLoanAddress(address _newAddress) external onlyOwner {

272:     function updateTaxes(Taxes calldata _newTaxes) external onlyOwner {

284:     function setTaxes() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

135:     function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

45:     function setLoanManager(address __loanManager) external onlyOwner {

60:     function setOfferHandler(address __offerHandler) external onlyOwner {

75:     function confirmOfferHandler(address __offerHandler) external onlyOwner {

94:     function requestAddCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

104:     function addCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

17:     function addLoanManager(address _loanManager) external onlyOwner {

24:     function removeLoanManager(address _loanManager) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

464:     function loanLiquidated(uint256 _loanId, Loan calldata _loan) external override onlyLiquidator {

507:     function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {

543:     function setFlashActionContract(address _newFlashActionContract) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

64:     function setRewardsController(address _controller) external onlyOwner {

70:     function setRewardsReceiver(address _receiver) external onlyOwner {

127:     function _onlyPool() private view returns (address) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

69:     function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {

145:     function _onlyPool() private view returns (address) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

21:     function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

141:     function setPool(address _pool) external onlyOwner {

152:     function setOracle(address _oracle) external onlyOwner {

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

170:     function pausePool() external onlyOwner {

177:     function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {

185:     function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {

222:     function collectFees(address _recipient) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

27:     function requestTransferOwner(address _newOwner) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="GAS-13"></a>[GAS-13] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)

Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (1)*:

```solidity
File: src/lib/pools/WithdrawalQueue.sol

74:         return getNextTokenId++;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="GAS-14"></a>[GAS-14] Using `private` rather than `public` for constants, saves gas

If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (17)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

38:     uint256 public constant MAX_TRIGGER_FEE = 500;

40:     uint256 public constant MIN_INCREMENT_BPS = 500;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

20:     uint256 public constant MAX_TIME_FOR_MAIN_LENDER_TO_BUY = 4 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

21:     uint48 public constant MIN_AUCTION_DURATION = 1 days;

22:     uint48 public constant MAX_AUCTION_DURATION = 7 days;

23:     uint256 public constant MIN_BID_LIQUIDATION = 50;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

22:     address public constant ETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

31:     uint256 public constant TAX_UPDATE_NOTICE = 7 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

37:     bytes public constant VERSION = "3";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/pools/FeeManager.sol

15:     uint256 public constant WAIT_TIME = 30 days;

16:     uint256 public constant PRECISION = 1e20;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

50:     uint256 public constant PRECISION = 1e27;

53:     uint256 public constant TOLERANCE_FLOOR = 2e25;

56:     uint256 public constant TOLERANCE_HISTORICAL_FLOOR = 5e25;

59:     uint256 public constant MIN_WAIT_TIME_UPDATE_FACTOR = 1 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

43:     uint80 public constant PRINCIPAL_PRECISION = 1e20;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

17:     uint256 public constant FEE_UPDATE_NOTICE = 30 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="GAS-15"></a>[GAS-15] `uint256` to `bool` `mapping`: Utilizing Bitmaps to dramatically save on Gas

<https://soliditydeveloper.com/bitmaps>

<https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol>

- [BitMaps.sol#L5-L16](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/BitMaps.sol#L5-L16):

```solidity
/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
```

*Instances (2)*:

```solidity
File: src/lib/loans/BaseLoan.sol

52:     mapping(address user => mapping(uint256 offerId => bool notActive)) public isOfferCancelled;

57:     mapping(address user => mapping(uint256 renegotiationIf => bool notActive)) public isRenegotiationOfferCancelled;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

### <a name="GAS-16"></a>[GAS-16] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (4)*:

```solidity
File: src/lib/loans/MultiSourceLoan.sol

207:             if (netNewLender > 0) {

660:         if (oldLenderDebt > 0) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/ERC4626.sol

2: pragma solidity >=0.8.0;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/Pool.sol

215:         if (allocatorChanged && asset.balanceOf(address(this)) - getAvailableToWithdraw - getCollectedFees > 0) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="GAS-17"></a>[GAS-17] `internal` functions not called by the contract should be removed

If the functions are required by an interface, the contract should inherit from that interface and use the `override` keyword

*Instances (9)*:

```solidity
File: src/lib/InputChecker.sol

10:     function checkNotZero(address _address) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/utils/BytesLib.sol

12:     function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {

72:     function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

84:     function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/Interest.sol

15:     function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {

19:     function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {

23:     function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

15:     function validateTokenIdPackedList(uint256 _tokenId, uint64 _bytesPerTokenId, bytes memory _tokenIdList)

72:     function validateNFTBitVector(uint256 _tokenId, bytes memory _bitVector) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

### <a name="GAS-18"></a>[GAS-18] WETH address definition can be use directly

WETH is a wrap Ether contract with a specific address in the Ethereum network, giving the option to define it may cause false recognition, it is healthier to define it directly.

    Advantages of defining a specific contract directly:
    
    It saves gas,
    Prevents incorrect argument definition,
    Prevents execution on a different chain and re-signature issues,
    WETH Address : 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2

*Instances (2)*:

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

34:     WETH private immutable _weth;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

31:     address payable private immutable _weth;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

## Non Critical Issues

| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Missing checks for `address(0)` when assigning values to address state variables | 28 |
| [NC-2](#NC-2) | Array indices should be referenced via `enum`s rather than via numeric literals | 9 |
| [NC-3](#NC-3) | Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked` | 8 |
| [NC-4](#NC-4) | `constant`s should be defined rather than using magic numbers | 18 |
| [NC-5](#NC-5) | Control structures do not follow the Solidity Style Guide | 26 |
| [NC-6](#NC-6) | Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function | 2 |
| [NC-7](#NC-7) | Unused `error` definition | 2 |
| [NC-8](#NC-8) | Event missing indexed field | 68 |
| [NC-9](#NC-9) | Events that mark critical parameter changes should contain both the old and the new value | 28 |
| [NC-10](#NC-10) | Function ordering does not follow the Solidity style guide | 4 |
| [NC-11](#NC-11) | Functions should not be longer than 50 lines | 238 |
| [NC-12](#NC-12) | Change int to int256 | 1 |
| [NC-13](#NC-13) | Change uint to uint256 | 1 |
| [NC-14](#NC-14) | Lack of checks in setters | 20 |
| [NC-15](#NC-15) | Missing Event for critical parameters change | 4 |
| [NC-16](#NC-16) | NatSpec is completely non-existent on functions that should have them | 10 |
| [NC-17](#NC-17) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 28 |
| [NC-18](#NC-18) | Constant state variables defined more than once | 18 |
| [NC-19](#NC-19) | Consider using named mappings | 4 |
| [NC-20](#NC-20) | `address`s shouldn't be hard-coded | 1 |
| [NC-21](#NC-21) | Owner can renounce while system is paused | 1 |
| [NC-22](#NC-22) | `require()` / `revert()` statements should have descriptive reason strings | 2 |
| [NC-23](#NC-23) | Take advantage of Custom Error's return value property | 123 |
| [NC-24](#NC-24) | Avoid the use of sensitive terms | 57 |
| [NC-25](#NC-25) | Contract does not follow the Solidity style guide's suggested layout ordering | 20 |
| [NC-26](#NC-26) | Use Underscores for Number Literals (add an underscore every 3 digits) | 12 |
| [NC-27](#NC-27) | Internal and private variables and functions names should begin with an underscore | 22 |
| [NC-28](#NC-28) | Event is missing `indexed` fields | 69 |
| [NC-29](#NC-29) | Constants should be defined rather than using magic numbers | 1 |
| [NC-30](#NC-30) | `public` functions not called by the contract should be declared `external` instead | 2 |
| [NC-31](#NC-31) | Variables need not be initialized to zero | 30 |

### <a name="NC-1"></a>[NC-1] Missing checks for `address(0)` when assigning values to address state variables

*Instances (28)*:

```solidity
File: src/lib/LiquidationHandler.sol

58:         _loanLiquidator = __loanLiquidator;

76:         _loanLiquidator = __loanLiquidator;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

234:         _pendingMultiSourceLoanAddress = _newAddress;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

42:         getParameterSetter = __offerHandlerSetter;

50:         getOfferHandler = _offerHandler;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

40:         getOfferHandler = __offerHandler;

55:         getLoanManager = __loanManager;

67:         getProposedOfferHandler = __offerHandler;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

116:         getDelegateRegistry = delegateRegistry;

117:         getFlashActionContract = flashActionContract;

544:         getFlashActionContract = _newFlashActionContract;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

52:         getPool = _pool;

53:         _aavePool = __aavePool;

54:         _usdc = __usdc;

55:         _aToken = __aToken;

57:         getRewardsController = _rewardsController;

58:         getRewardsReceiver = _rewardsReceiver;

65:         getRewardsController = _controller;

71:         getRewardsReceiver = _receiver;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

58:         getPool = _pool;

61:         _lido = __lido;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

131:         getOracle = _oracle;

145:         getPool = _pool;

153:         getProposedOracle = _oracle;

165:         getOracle = proposedOracle;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

145:         getFeeManager = _feeManager;

188:         getProposedBaseInterestAllocator = _newBaseInterestAllocator;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

28:         pendingOwner = _newOwner;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="NC-2"></a>[NC-2] Array indices should be referenced via `enum`s rather than via numeric literals

*Instances (9)*:

```solidity
File: src/lib/LiquidationHandler.sol

106:                 address(this), _loan.tranche[0].lender, _loan.nftCollateralTokenId

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

214:         newTranche[0] = Tranche(

379:         if (_renegotiationOffer.trancheIndex.length != 1 || _renegotiationOffer.trancheIndex[0] != _loan.tranche.length)

455:             _loanId, _loan, _loan.tranche.length == 1 && !getLoanManagerRegistry.isLoanManager(_loan.tranche[0].lender)

830:         LoanOffer calldata one = _executionData.offerExecution[0].offer;

881:             } else if ((totalValidators == 1) && _loanOffer.validators[0].validator == address(0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

123:         assets[0] = _aToken;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

353:         } else if (_validators.length == 1 && _isZeroAddress(_validators[0].validator)) {

355:                 abi.decode(_validators[0].arguments, (PrincipalFactorsValidationData));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

### <a name="NC-3"></a>[NC-3] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`

Solidity version 0.8.4 introduces `bytes.concat()` (vs `abi.encodePacked(<bytes>,<bytes>)`)

Solidity version 0.8.12 introduces `string.concat()` (vs `abi.encodePacked(<str>,<str>), which catches concatenation errors (in the event of a`bytes`data mixed in the concatenation)`)

*Instances (8)*:

```solidity
File: src/lib/pools/Oracle.sol

28:         return bytes32(abi.encodePacked(_collection, _period, _key));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

366:                 bytes32 leaf = keccak256(abi.encodePacked(_collateralTokenId));

368:                 key = _hashKey(_collateralAddress, uint96(_duration), abi.encodePacked(root));

384:         return keccak256(abi.encodePacked(_collection, _duration, _extra));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/utils/Hash.sol

43:             encodedValidators = abi.encodePacked(encodedValidators, _hashValidator(_loanOffer.validators[i]));

74:                 abi.encodePacked(encodedOfferExecution, _hashOfferExecution(_executionData.offerExecution[i]));

108:             trancheHashes = abi.encodePacked(trancheHashes, _hashTranche(_loan.tranche[i]));

133:             encodedIndexes = abi.encodePacked(encodedIndexes, _refinanceOffer.trancheIndex[i]);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

### <a name="NC-4"></a>[NC-4] `constant`s should be defined rather than using magic numbers

Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (18)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

293:         uint256 proceeds = highestBid - 2 * triggerFee;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

27:     uint48 internal _liquidationAuctionDuration = 3 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

40:     uint256 internal _minImprovementApr = 1000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/pools/ERC4626.sol

148:         return assets.mulDiv(totalSupply + 10 ** decimalsOffset, totalAssets() + 1, rounding);

153:         return shares.mulDiv(totalAssets() + 1, totalSupply + 10 ** decimalsOffset, rounding);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

363:             } else if (validationData.code == 2) {

369:             } else if (validationData.code == 3) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/utils/BytesLib.sol

13:         require(_length + 31 >= _length, "slice_overflow");

34:                 let lengthmod := and(_length, 31)

56:                 mstore(0x40, and(add(mc, 31), not(31)))

73:         require(_start + 20 >= _start, "toAddress_overflow");

74:         require(_bytes.length >= _start + 20, "toAddress_outOfBounds");

85:         require(_start + 3 >= _start, "toUint24_overflow");

86:         require(_bytes.length >= _start + 3, "toUint24_outOfBounds");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

19:         if (_bytesPerTokenId == 0 || _bytesPerTokenId > 32) {

29:         uint256 bitMask = ~(type(uint256).max << (_bytesPerTokenId << 3));

74:         if (_tokenId >= _bitVector.length << 3) {

78:         if (!(uint8(_bitVector[_tokenId >> 3]) & (0x80 >> (_tokenId & 7)) != 0)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

### <a name="NC-5"></a>[NC-5] Control structures do not follow the Solidity Style Guide

See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (26)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

107:     error CouldNotModifyValidLoansError();

135:             revert CouldNotModifyValidLoansError();

144:             revert CouldNotModifyValidLoansError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/UserVault.sol

399:         if (

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

60:         if (

78:         if (

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

57:     mapping(address user => mapping(uint256 renegotiationIf => bool notActive)) public isRenegotiationOfferCancelled;

206:                 keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

112:             if (

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

379:         if (_renegotiationOffer.trancheIndex.length != 1 || _renegotiationOffer.trancheIndex[0] != _loan.tranche.length)

577:                 if(onlyNewLenderPass != isNewLender) continue;

688:         if (

729:         if (

1110:         if (

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/ERC4626.sol

79:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

95:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/FeeManager.sol

7: import "../../interfaces/pools/IFeeManager.sol";

51:         if (

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

264:         if (

274:             if (

308:         if (

367:                 MerkleProofLib.verify(proof, root, leaf);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

9: import "../../interfaces/pools/IFeeManager.sol";

400:         uint256 fees = IFeeManager(getFeeManager).processFees(_principalAmount, interestEarned);

423:             fees = IFeeManager(getFeeManager).processFees(_principalAmount, _received - _principalAmount);

425:             fees = IFeeManager(getFeeManager).processFees(_received, 0);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="NC-6"></a>[NC-6] Duplicated `require()`/`revert()` Checks Should Be Refactored To A Modifier Or Function

*Instances (2)*:

```solidity
File: src/lib/utils/BytesLib.sol

13:         require(_length + 31 >= _length, "slice_overflow");

14:         require(_start + _length >= _start, "slice_overflow");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

### <a name="NC-7"></a>[NC-7] Unused `error` definition

Note that there may be cases where an error superficially appears to be used, but this is only because there are multiple definitions of the error in different files. In such cases, the error definition should be moved into a separate file. The instances below are the unused definitions.

*Instances (2)*:

```solidity
File: src/lib/loans/MultiSourceLoan.sol

66:     error InvalidParametersError();

67:     error MismatchError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

### <a name="NC-8"></a>[NC-8] Event missing indexed field

Index event fields make the field more quickly accessible [to off-chain tools](https://ethereum.stackexchange.com/questions/40396/can-somebody-please-explain-the-concept-of-event-indexing) that parse events. This is especially useful when it comes to filtering based on an address. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Where applicable, each `event` should use three `indexed` fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three applicable fields, all of the applicable fields should be indexed.

*Instances (68)*:

```solidity
File: src/lib/AddressManager.sol

15:     event AddressAdded(address address_added);

17:     event AddressRemovedFromWhitelist(address address_removed);

19:     event AddressWhitelisted(address address_whitelisted);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

60:     event LoanContractAdded(address loan);

62:     event LoanContractRemoved(address loan);

64:     event LiquidationDistributorUpdated(address liquidationDistributor);

66:     event LoanLiquidationStarted(address collection, uint256 tokenId, Auction auction);

68:     event BidPlaced(

72:     event AuctionSettled(

83:     event TriggerFeeUpdated(uint256 triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

24:     event AuctionSettledWithBuyout(

28:     event TimeForMainLenderToBuyUpdated(uint256 timeForMainLenderToBuy);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

27:     event LiquidatorSet(address liquidator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

32:     event MinBidLiquidationUpdated(uint256 newMinBid);

34:     event LoanSentToLiquidator(uint256 loanId, address liquidator);

36:     event LoanForeclosed(uint256 loanId);

38:     event LiquidationContractUpdated(address liquidator);

40:     event LiquidationAuctionDurationUpdated(uint256 newDuration);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

42:     event ERC721Deposited(uint256 vaultId, address collection, uint256 tokenId);

44:     event OldERC721Deposited(uint256 vaultId, address collection, uint256 tokenId);

46:     event OldERC721Withdrawn(uint256 vaultId, address collection, uint256 tokenId);

48:     event ERC20Deposited(uint256 vaultId, address token, uint256 amount);

50:     event ERC721Withdrawn(uint256 vaultId, address collection, uint256 tokenId);

52:     event ERC20Withdrawn(uint256 vaultId, address token, uint256 amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

20:     event WhitelistedCallbackContractAdded(address contractAdded);

21:     event WhitelistedCallbackContractRemoved(address contractRemoved);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

47:     event BNPLLoansStarted(uint256[] loanIds);

48:     event SellAndRepayExecuted(uint256[] loanIds);

49:     event MultiSourceLoanPendingUpdate(address newAddress);

50:     event MultiSourceLoanUpdated(address newAddress);

51:     event TaxesPendingUpdate(Taxes newTaxes);

52:     event TaxesUpdated(Taxes taxes);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

67:     event OfferCancelled(address lender, uint256 offerId);

69:     event AllOffersCancelled(address lender, uint256 minOfferId);

71:     event RenegotiationOfferCancelled(address lender, uint256 renegotiationId);

73:     event MinAprImprovementUpdated(uint256 _minimum);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

32:     event CallersAdded(ProposedCaller[] callers);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

14:     event RequestCallersAdded(ILoanManager.ProposedCaller[] callers);

15:     event ProposedOfferHandlerSet(address offerHandler);

16:     event OfferHandlerSet(address offerHandler);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

11:     event LoanManagerAdded(address loanManagerAdded);

12:     event LoanManagerRemoved(address loanManagerRemoved);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

34:     event RewardsControllerSet(address controller);

35:     event RewardsReceiverSet(address receiver);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

22:     event ProposedFeesSet(Fees fees);

23:     event ProposedFeesConfirmed(Fees fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

40:     event MaxSlippageSet(uint256 maxSlippage);

41:     event LidoValuesUpdated(LidoData lidoData);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

109:     event ProposedCollectionFactorsSet(address[] collection, uint96[] duration, PrincipalFactors[] factor);

110:     event CollectionFactorsSet(address[] collection, uint96[] duration, bytes[], PrincipalFactors[] factor);

111:     event AprPremiumSet(uint256 aprPremium);

112:     event ProposedOracleSet(address proposedOracle);

113:     event OracleSet(address oracle);

114:     event ProposedAprFactorsSet(AprFactors aprFactors);

115:     event AprFactorsSet(AprFactors aprFactors);

116:     event PoolSet(address pool);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

115:     event PendingBaseInterestAllocatorSet(address newBaseInterestAllocator);

116:     event BaseInterestAllocatorSet(address newBaseInterestAllocator);

117:     event OptimalIdleRangeSet(OptimalIdleRange optimalIdleRange);

118:     event QueueClaimed(address queue, uint256 amount);

119:     event Reallocated(uint256 delta);

120:     event QueueDeployed(uint256 index, address queueAddress);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

42:     event WithdrawalPositionMinted(uint256 tokenId, address to, uint256 shares);

43:     event Withdrawn(address to, uint256 tokenId, uint256 available);

44:     event WithdrawalLocked(uint256 tokenId, uint256 unlockTime);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

10:     event TransferOwnerRequested(address newOwner);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

26:     event ProtocolFeeUpdated(ProtocolFee fee);

27:     event ProtocolFeePendingUpdate(ProtocolFee fee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-9"></a>[NC-9] Events that mark critical parameter changes should contain both the old and the new value

This should especially be done if the new value is not required to be different from the old value

*Instances (28)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

156:     function updateLiquidationDistributor(address __liquidationDistributor) external onlyOwner {
             __liquidationDistributor.checkNotZero();
     
             _liquidationDistributor = ILiquidationDistributor(__liquidationDistributor);
     
             emit LiquidationDistributorUpdated(__liquidationDistributor);

270:     function settleAuction(Auction calldata _auction, IMultiSourceLoan.Loan calldata _loan) external nonReentrant {
             address collateralAddress = _loan.nftCollateralAddress;
             uint256 tokenId = _loan.nftCollateralTokenId;
             _checkAuction(collateralAddress, tokenId, _auction);
     
             if (_auction.highestBidder == address(0)) {
                 revert NoBidsError();
             }
     
             uint256 currentTime = block.timestamp;
             uint96 expiration = _auction.startTime + _auction.duration;
             uint96 withMargin = _auction.lastBidTime + _MIN_NO_ACTION_MARGIN;
             uint96 maxExtension = expiration + getMaxExtension;
             if ((withMargin > currentTime && currentTime < maxExtension) || (currentTime < expiration)) {
                 uint96 minWithMarginMaxExtension = withMargin > maxExtension ? maxExtension : withMargin;
                 uint96 max = minWithMarginMaxExtension > expiration ? minWithMarginMaxExtension : expiration;
                 revert AuctionNotOverError(max);
             }
     
             ERC721(collateralAddress).transferFrom(address(this), _auction.highestBidder, tokenId);
     
             uint256 highestBid = _auction.highestBid;
             uint256 triggerFee = highestBid.mulDivDown(_auction.triggerFee, _BPS);
             uint256 proceeds = highestBid - 2 * triggerFee;
             ERC20 asset = ERC20(_auction.asset);
     
             asset.safeTransfer(_auction.originator, triggerFee);
             asset.safeTransfer(msg.sender, triggerFee);
             asset.approve(address(_liquidationDistributor), proceeds);
             _liquidationDistributor.distribute(_auction.loanAddress, proceeds, _loan);
             IMultiSourceLoan(_auction.loanAddress).loanLiquidated(_auction.loanId, _loan);
             emit AuctionSettled(

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

65:     function settleWithBuyout(
            address _nftAddress,
            uint256 _tokenId,
            Auction calldata _auction,
            IMultiSourceLoan.Loan calldata _loan
        ) external nonReentrant {
            address buyer = msg.sender;
    
            _checkAuction(_nftAddress, _tokenId, _auction);
            uint256 timeLimit = _auction.startTime + _timeForMainLenderToBuy;
            if (timeLimit <= block.timestamp) {
                revert OptionToBuyExpiredError(timeLimit);
            }
            uint256 largestTrancheIdx;
            uint256 largestPrincipal;
            uint256 totalTranches = _loan.tranche.length;
            for (uint256 i = 0; i < totalTranches;) {
                if (_loan.tranche[i].principalAmount > largestPrincipal) {
                    largestPrincipal = _loan.tranche[i].principalAmount;
                    largestTrancheIdx = i;
                }
                unchecked {
                    ++i;
                }
            }
            if (buyer != _loan.tranche[largestTrancheIdx].lender) {
                revert NotMainLenderError();
            }
            ERC20 asset = ERC20(_auction.asset);
            uint256 totalOwed;
            for (uint256 i; i < totalTranches;) {
                if (i != largestTrancheIdx) {
                    IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                    uint256 owed = thisTranche.principalAmount + thisTranche.accruedInterest
                        + thisTranche.principalAmount.getInterest(thisTranche.aprBps, block.timestamp - thisTranche.startTime);
                    totalOwed += owed;
                    asset.safeTransferFrom(msg.sender, thisTranche.lender, owed);
    
                    if (getLoanManagerRegistry.isLoanManager(thisTranche.lender)) {
                        LoanManager(thisTranche.lender).loanLiquidation(
                            _auction.loanAddress,
                            thisTranche.loanId,
                            thisTranche.principalAmount,
                            thisTranche.aprBps,
                            thisTranche.accruedInterest,
                            _loan.protocolFee,
                            owed,
                            thisTranche.startTime
                        );
                    }
                }
                unchecked {
                    ++i;
                }
            }
            IMultiSourceLoan(_auction.loanAddress).loanLiquidated(_auction.loanId, _loan);
    
            asset.safeTransferFrom(buyer, _auction.originator, totalOwed.mulDivDown(_auction.triggerFee, _BPS));
    
            ERC721(_loan.nftCollateralAddress).transferFrom(address(this), buyer, _tokenId);
    
            delete _auctions[_nftAddress][_tokenId];
    
            emit AuctionSettledWithBuyout(_auction.loanAddress, _auction.loanId, _nftAddress, _tokenId, largestTrancheIdx);

133:     function setTimeForMainLenderToBuy(uint256 __timeForMainLenderToBuy) external onlyOwner {
             if (__timeForMainLenderToBuy > MAX_TIME_FOR_MAIN_LENDER_TO_BUY) {
                 revert InvalidInputError();
             }
             _timeForMainLenderToBuy = __timeForMainLenderToBuy;
     
             emit TimeForMainLenderToBuyUpdated(__timeForMainLenderToBuy);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

37:     function setLiquidator(address _liquidator) external onlyOwner {
            if (_liquidator == address(0)) {
                revert LiquidatorCannotBeUpdatedError();
            }
            getLiquidator = _liquidator;
    
            emit LiquidatorSet(_liquidator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

74:     function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {
            __loanLiquidator.checkNotZero();
            _loanLiquidator = __loanLiquidator;
    
            emit LiquidationContractUpdated(__loanLiquidator);

82:     function updateLiquidationAuctionDuration(uint48 _newDuration) external override onlyOwner {
            if (_newDuration < MIN_AUCTION_DURATION || _newDuration > MAX_AUCTION_DURATION) {
                revert InvalidDurationError();
            }
            _liquidationAuctionDuration = _newDuration;
    
            emit LiquidationAuctionDurationUpdated(_newDuration);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

231:     function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {
             _newAddress.checkNotZero();
     
             _pendingMultiSourceLoanAddress = _newAddress;
     
             emit MultiSourceLoanPendingUpdate(_newAddress);

272:     function updateTaxes(Taxes calldata _newTaxes) external onlyOwner {
             if (_newTaxes.buyTax > _MAX_TAX || (_newTaxes.sellTax > _MAX_TAX)) {
                 revert InvalidTaxesError(_newTaxes);
             }
     
             _pendingTaxes = _newTaxes;
             _pendingTaxesSetTime = block.timestamp;
     
             emit TaxesPendingUpdate(_newTaxes);

284:     function setTaxes() external onlyOwner {
             if (block.timestamp < _pendingTaxesSetTime + TAX_UPDATE_NOTICE) {
                 revert TooEarlyError(_pendingTaxesSetTime);
             }
             Taxes memory taxes = _pendingTaxes;
             _taxes = taxes;
     
             emit TaxesUpdated(taxes);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

135:     function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {
             _minImprovementApr = _newMinimum;
     
             emit MinAprImprovementUpdated(_minImprovementApr);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

60:     function setOfferHandler(address __offerHandler) external onlyOwner {
            __offerHandler.checkNotZero();
    
            if (IPoolOfferHandler(__offerHandler).getMaxDuration() > IPoolOfferHandler(getOfferHandler).getMaxDuration()) {
                revert InvalidInputError();
            }
    
            getProposedOfferHandler = __offerHandler;
            getProposedOfferHandlerSetTime = block.timestamp;
    
            emit ProposedOfferHandlerSet(__offerHandler);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

507:     function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {
             _minLockPeriod = __minLockPeriod;
     
             emit MinLockPeriodUpdated(__minLockPeriod);

543:     function setFlashActionContract(address _newFlashActionContract) external onlyOwner {
             getFlashActionContract = _newFlashActionContract;
     
             emit FlashActionContractUpdated(_newFlashActionContract);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

64:     function setRewardsController(address _controller) external onlyOwner {
            getRewardsController = _controller;
    
            emit RewardsControllerSet(_controller);

70:     function setRewardsReceiver(address _receiver) external onlyOwner {
            getRewardsReceiver = _receiver;
    
            emit RewardsReceiverSet(_receiver);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {
            _proposedFees = __fees;
            _proposedFeesSetTime = block.timestamp;
    
            emit ProposedFeesSet(__fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

69:     function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {
            getMaxSlippage = _maxSlippage;
    
            emit MaxSlippageSet(_maxSlippage);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

21:     function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {
            _data[_getKey(_collection, _period, _key)] = CollectionData(_value, uint128(block.timestamp));
    
            emit DataUpdated(_collection, _period, _key, _value);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

141:     function setPool(address _pool) external onlyOwner {
             if (getPool != address(0)) {
                 revert PoolAlreadySetError();
             }
             getPool = _pool;
     
             emit PoolSet(_pool);

152:     function setOracle(address _oracle) external onlyOwner {
             getProposedOracle = _oracle;
             getProposedOracleSetTs = block.timestamp;
     
             emit ProposedOracleSet(_oracle);

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {
             getProposedAprFactors = _aprFactors;
             getProposedAprFactorsSetTs = block.timestamp;
     
             emit ProposedAprFactorsSet(_aprFactors);

192:     function setAprPremium() external {
             uint128 aprPremium = _calculateAprPremium();
             getAprPremium = AprPremium(aprPremium, uint128(block.timestamp));
     
             emit AprPremiumSet(aprPremium);

226:     function setCollectionFactors(
             address[] calldata _collection,
             uint96[] calldata _duration,
             bytes[] calldata _extra,
             PrincipalFactors[] calldata _factor
         ) external onlyOwner {
             uint256 updates = _collection.length;
             if (updates != _duration.length || updates != _factor.length || updates != _extra.length) {
                 revert InvalidInputLengthError();
             }
             for (uint256 i; i < updates;) {
                 getProposedCollectionFactors[_hashKey(_collection[i], _duration[i], _extra[i])] = _factor[i];
                 unchecked {
                     ++i;
                 }
             }
     
             getProposedCollectionFactorsSetTs = block.timestamp;
             getTotalUpdatesPending = updates;
     
             emit ProposedCollectionFactorsSet(_collection, _duration, _factor);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

177:     function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {
             _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) >> 1;
             getOptimalIdleRange = _optimalIdleRange;
     
             emit OptimalIdleRangeSet(_optimalIdleRange);

185:     function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {
             _newBaseInterestAllocator.checkNotZero();
     
             getProposedBaseInterestAllocator = _newBaseInterestAllocator;
             getProposedBaseInterestAllocatorSetTime = block.timestamp;
     
             emit PendingBaseInterestAllocatorSet(_newBaseInterestAllocator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {
            _newProtocolFee.recipient.checkNotZero();
    
            _pendingProtocolFee = _newProtocolFee;
            _pendingProtocolFeeSetTime = block.timestamp;
    
            emit ProtocolFeePendingUpdate(_pendingProtocolFee);

69:     function setProtocolFee() external virtual {
            if (block.timestamp < _pendingProtocolFeeSetTime + FEE_UPDATE_NOTICE) {
                revert TooSoonError();
            }
            ProtocolFee memory protocolFee = _pendingProtocolFee;
            _protocolFee = protocolFee;
    
            emit ProtocolFeeUpdated(protocolFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-10"></a>[NC-10] Function ordering does not follow the Solidity style guide

According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (4)*:

```solidity
File: src/lib/UserVault.sol

1: 
   Current order:
   external mint
   external burn
   external burnAndWithdraw
   external ERC721OwnerOf
   external OldERC721OwnerOf
   external ERC20BalanceOf
   external depositERC721
   external depositERC721s
   external depositOldERC721
   external depositOldERC721s
   external depositERC20
   external depositEth
   external withdrawERC721
   external withdrawERC721s
   external withdrawOldERC721
   external withdrawOldERC721s
   external withdrawERC20
   external withdrawERC20s
   public tokenURI
   external withdrawEth
   private _depositERC721
   private _depositOldERC721
   private _depositERC20
   private _withdrawERC721
   private _withdrawOldERC721
   private _withdrawERC20
   private _thisBurn
   private _withdrawEth
   private _vaultExists
   private _onlyApproved
   private _onlyReadyForWithdrawal
   
   Suggested order:
   external mint
   external burn
   external burnAndWithdraw
   external ERC721OwnerOf
   external OldERC721OwnerOf
   external ERC20BalanceOf
   external depositERC721
   external depositERC721s
   external depositOldERC721
   external depositOldERC721s
   external depositERC20
   external depositEth
   external withdrawERC721
   external withdrawERC721s
   external withdrawOldERC721
   external withdrawOldERC721s
   external withdrawERC20
   external withdrawERC20s
   external withdrawEth
   public tokenURI
   private _depositERC721
   private _depositOldERC721
   private _depositERC20
   private _withdrawERC721
   private _withdrawOldERC721
   private _withdrawERC20
   private _thisBurn
   private _withdrawEth
   private _vaultExists
   private _onlyApproved
   private _onlyReadyForWithdrawal

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

1: 
   Current order:
   external emitLoan
   external refinanceFull
   external refinancePartial
   external refinanceFromLoanExecutionData
   external addNewTranche
   external repayLoan
   external liquidateLoan
   external loanLiquidated
   external delegate
   external revokeDelegate
   external getMinLockPeriod
   external setMinLockPeriod
   external getLoanHash
   external executeFlashAction
   external setFlashActionContract
   private _processOldTranchesFull
   private _processOldTranche
   private _baseLoanChecks
   private _baseRenegotiationChecks
   private _handleProtocolFeeForFee
   private _checkTrancheStrictly
   private _getUnlockedTime
   private _isLoanLocked
   private _validateOfferExecution
   private _validateExecutionData
   private _getAddressesFromExecutionData
   private _checkWhitelists
   private _checkOffer
   private _checkValidators
   private _getMinTranchePrincipal
   private _hasCallback
   private _processRepayments
   private _processOffersFromExecutionData
   private _addNewTranche
   private _checkSignature
   internal _checkStrictlyBetter
   
   Suggested order:
   external emitLoan
   external refinanceFull
   external refinancePartial
   external refinanceFromLoanExecutionData
   external addNewTranche
   external repayLoan
   external liquidateLoan
   external loanLiquidated
   external delegate
   external revokeDelegate
   external getMinLockPeriod
   external setMinLockPeriod
   external getLoanHash
   external executeFlashAction
   external setFlashActionContract
   internal _checkStrictlyBetter
   private _processOldTranchesFull
   private _processOldTranche
   private _baseLoanChecks
   private _baseRenegotiationChecks
   private _handleProtocolFeeForFee
   private _checkTrancheStrictly
   private _getUnlockedTime
   private _isLoanLocked
   private _validateOfferExecution
   private _validateExecutionData
   private _getAddressesFromExecutionData
   private _checkWhitelists
   private _checkOffer
   private _checkValidators
   private _getMinTranchePrincipal
   private _hasCallback
   private _processRepayments
   private _processOffersFromExecutionData
   private _addNewTranche
   private _checkSignature

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/ERC4626.sol

1: 
   Current order:
   public deposit
   public mint
   public withdraw
   public redeem
   public totalAssets
   public convertToShares
   public convertToAssets
   public previewDeposit
   public previewMint
   public previewWithdraw
   public previewRedeem
   internal _convertToShares
   internal _convertToAssets
   public maxDeposit
   public maxMint
   public maxWithdraw
   public maxRedeem
   internal beforeWithdraw
   internal afterDeposit
   
   Suggested order:
   public deposit
   public mint
   public withdraw
   public redeem
   public totalAssets
   public convertToShares
   public convertToAssets
   public previewDeposit
   public previewMint
   public previewWithdraw
   public previewRedeem
   public maxDeposit
   public maxMint
   public maxWithdraw
   public maxRedeem
   internal _convertToShares
   internal _convertToAssets
   internal beforeWithdraw
   internal afterDeposit

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/Pool.sol

1: 
   Current order:
   external pausePool
   external setOptimalIdleRange
   external setBaseInterestAllocator
   external confirmBaseInterestAllocator
   external collectFees
   internal afterCallerAdded
   public totalAssets
   external getOutstandingValues
   external getDeployedQueue
   external getOutstandingValuesForQueue
   external getPendingQueueIndex
   external getAccountingValuesForQueue
   external deployWithdrawalQueue
   external validateOffer
   external reallocate
   external loanRepayment
   external loanLiquidation
   external getUndeployedAssets
   public withdraw
   public redeem
   public deposit
   public mint
   external queueClaimAll
   internal _burn
   private _getTotalOutstandingValue
   private _getOutstandingValue
   private _getNewLoanAccounting
   private _loanTermination
   private _preDeposit
   private _getUndeployedAssets
   private _reallocate
   private _reallocateOnWithdrawal
   private _netApr
   private _deployQueue
   private _updateLoanLastIds
   private _updatePendingWithdrawalWithQueue
   private _queueClaimAll
   private _outstandingApr
   private _updateOutstandingValuesOnTermination
   private _withdraw
   private _isZeroAddress
   
   Suggested order:
   external pausePool
   external setOptimalIdleRange
   external setBaseInterestAllocator
   external confirmBaseInterestAllocator
   external collectFees
   external getOutstandingValues
   external getDeployedQueue
   external getOutstandingValuesForQueue
   external getPendingQueueIndex
   external getAccountingValuesForQueue
   external deployWithdrawalQueue
   external validateOffer
   external reallocate
   external loanRepayment
   external loanLiquidation
   external getUndeployedAssets
   external queueClaimAll
   public totalAssets
   public withdraw
   public redeem
   public deposit
   public mint
   internal afterCallerAdded
   internal _burn
   private _getTotalOutstandingValue
   private _getOutstandingValue
   private _getNewLoanAccounting
   private _loanTermination
   private _preDeposit
   private _getUndeployedAssets
   private _reallocate
   private _reallocateOnWithdrawal
   private _netApr
   private _deployQueue
   private _updateLoanLastIds
   private _updatePendingWithdrawalWithQueue
   private _queueClaimAll
   private _outstandingApr
   private _updateOutstandingValuesOnTermination
   private _withdraw
   private _isZeroAddress

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="NC-11"></a>[NC-11] Functions should not be longer than 50 lines

Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability

*Instances (238)*:

```solidity
File: src/lib/AddressManager.sol

47:     function add(address _entry) external payable onlyOwner returns (uint16) {

53:     function addToWhitelist(address _entry) external payable onlyOwner {

65:     function removeFromWhitelist(address _entry) external payable onlyOwner {

73:     function addressToIndex(address _address) external view returns (uint16) {

79:     function indexToAddress(uint16 _index) external view returns (address) {

85:     function isWhitelisted(address _entry) external view returns (bool) {

89:     function _add(address _entry) private returns (uint16) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

133:     function addLoanContract(address _loanContract) external onlyOwner {

142:     function removeLoanContract(address _loanContract) external onlyOwner {

151:     function getValidLoanContracts() external view returns (address[] memory) {

156:     function updateLiquidationDistributor(address __liquidationDistributor) external onlyOwner {

165:     function getLiquidationDistributor() external view returns (address) {

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {

175:     function getTriggerFee() external view returns (uint256) {

231:     function placeBid(address _nftAddress, uint256 _tokenId, Auction memory _auction, uint256 _bid)

270:     function settleAuction(Auction calldata _auction, IMultiSourceLoan.Loan calldata _loan) external nonReentrant {

317:     function getAuctionHash(address _nftAddress, uint256 _tokenId) external view returns (bytes32) {

322:     function _checkAuction(address _nftAddress, uint256 _tokenId, Auction memory _auction) internal view {

328:     function _placeBidChecks(address _nftAddress, uint256 _tokenId, Auction memory _auction, uint256 _bid)

339:     function _updateTriggerFee(uint256 triggerFee) private {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

133:     function setTimeForMainLenderToBuy(uint256 __timeForMainLenderToBuy) external onlyOwner {

143:     function getTimeForMainLenderToBuy() external view returns (uint256) {

147:     function _placeBidChecks(address _nftAddress, uint256 _tokenId, Auction memory _auction, uint256 _bid)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/InputChecker.sol

10:     function checkNotZero(address _address) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

37:     function setLiquidator(address _liquidator) external onlyOwner {

47:     function distribute(address _loanAddress, uint256 _proceeds, IMultiSourceLoan.Loan calldata _loan) external {

140:     function _handleLoanManagerCall(address _loanAddress, IMultiSourceLoan.Tranche calldata _tranche, uint256 _sent, uint256 _protocolFee)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

69:     function getLiquidator() external view override returns (address) {

74:     function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {

82:     function updateLiquidationAuctionDuration(uint48 _newDuration) external override onlyOwner {

92:     function getLiquidationAuctionDuration() external view override returns (uint48) {

96:     function _liquidateLoan(uint256 _loanId, IMultiSourceLoan.Loan calldata _loan, bool _canClaim)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/Multicall.sol

10:     function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/Multicall.sol)

```solidity
File: src/lib/UserVault.sol

95:     function burn(uint256 _vaultId, address _assetRecipient) external {

139:     function ERC721OwnerOf(address _collection, uint256 _tokenId) external view returns (uint256) {

143:     function OldERC721OwnerOf(address _collection, uint256 _tokenId) external view returns (uint256) {

147:     function ERC20BalanceOf(uint256 _vaultId, address _token) external view returns (uint256) {

152:     function depositERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external {

163:     function depositERC721s(uint256 _vaultId, address _collection, uint256[] calldata _tokenIds) external {

178:     function depositOldERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external {

188:     function depositOldERC721s(uint256 _vaultId, address _collection, uint256[] calldata _tokenIds) external {

205:     function depositERC20(uint256 _vaultId, address _token, uint256 _amount) external {

216:     function depositEth(uint256 _vaultId) external payable {

225:     function withdrawERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external {

230:     function withdrawERC721s(uint256 _vaultId, address[] calldata _collections, uint256[] calldata _tokenIds)

246:     function withdrawOldERC721(uint256 _vaultId, address _collection, uint256 _tokenId) external {

251:     function withdrawOldERC721s(uint256 _vaultId, address[] calldata _collections, uint256[] calldata _tokenIds)

267:     function withdrawERC20(uint256 _vaultId, address _token) external {

272:     function withdrawERC20s(uint256 _vaultId, address[] calldata _tokens) external {

282:     function tokenURI(uint256 _vaultId) public pure override returns (string memory) {

291:     function _depositERC721(address _depositor, uint256 _vaultId, address _collection, uint256 _tokenId) private {

299:     function _depositOldERC721(address _depositor, uint256 _vaultId, address _collection, uint256 _tokenId) private {

310:     function _depositERC20(address _depositor, uint256 _vaultId, address _token, uint256 _amount) private {

323:     function _withdrawERC721(uint256 _vaultId, address _collection, uint256 _tokenId) private {

336:     function _withdrawOldERC721(uint256 _vaultId, address _collection, uint256 _tokenId) private {

349:     function _withdrawERC20(uint256 _vaultId, address _token) private {

363:     function _thisBurn(uint256 _vaultId, address _assetRecipient) private {

387:     function _vaultExists(uint256 _vaultId) private view {

398:     function _onlyApproved(uint256 _vaultId) private view {

407:     function _onlyReadyForWithdrawal(uint256 _vaultId) private view {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

29:     function addWhitelistedCallbackContract(address _contract) external onlyOwner {

38:     function removeWhitelistedCallbackContract(address _contract) external onlyOwner {

45:     function isWhitelistedCallbackContract(address _contract) external view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

130:     function sell(bytes[] calldata _executionData) external {

146:     function afterPrincipalTransfer(IMultiSourceLoan.Loan calldata _loan, uint256 _fee, bytes calldata _executionData)

184:     function afterNFTTransfer(IMultiSourceLoan.Loan calldata _loan, bytes calldata _executionData)

231:     function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {

240:     function finalUpdateMultiSourceLoanAddress(address _newAddress) external onlyOwner {

252:     function getMultiSourceLoanAddress() external view override returns (address) {

257:     function getTaxes() external view returns (Taxes memory) {

262:     function getPendingTaxes() external view returns (Taxes memory) {

267:     function getPendingTaxesSetTime() external view returns (uint256) {

272:     function updateTaxes(Taxes calldata _newTaxes) external onlyOwner {

294:     function _handleTax(IMultiSourceLoan.Loan memory _loan, uint256 _tax) private {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

128:     function getMinImprovementApr() external view returns (uint256) {

135:     function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {

142:     function getCurrencyManager() external view returns (address) {

147:     function getCollectionManager() external view returns (address) {

160:     function cancelAllOffers(uint256 _minOfferId) external virtual {

172:     function cancelRenegotiationOffer(uint256 _renegotiationId) external virtual {

183:     function getUsedCapacity(address _lender, uint256 _offerId) external view returns (uint256) {

188:     function DOMAIN_SEPARATOR() public view returns (bytes32) {

195:     function _getAndSetNewLoanId() internal returns (uint256) {

203:     function _computeDomainSeparator() private view returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

46:     function updateOfferHandler(address _offerHandler) external {

56:     function addCallers(ProposedCaller[] calldata _callers) external {

78:     function isCallerAccepted(address _caller) external view returns (bool) {

83:     function validateOffer(bytes calldata _offer, uint256 _protocolFee) external virtual;

109:     function afterCallerAdded(address _caller) internal virtual;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

45:     function setLoanManager(address __loanManager) external onlyOwner {

60:     function setOfferHandler(address __offerHandler) external onlyOwner {

75:     function confirmOfferHandler(address __offerHandler) external onlyOwner {

94:     function requestAddCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

104:     function addCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

17:     function addLoanManager(address _loanManager) external onlyOwner {

24:     function removeLoanManager(address _loanManager) external onlyOwner {

31:     function isLoanManager(address _loanManager) external view returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

122:     function emitLoan(LoanExecutionData calldata _loanExecutionData)

238:     function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)

413:     function repayLoan(LoanRepaymentData calldata _repaymentData) external override nonReentrant {

445:     function liquidateLoan(uint256 _loanId, Loan calldata _loan)

464:     function loanLiquidated(uint256 _loanId, Loan calldata _loan) external override onlyLiquidator {

476:     function delegate(uint256 _loanId, Loan calldata loan, address _delegate, bytes32 _rights, bool _value) external {

491:     function revokeDelegate(address _delegate, address _collection, uint256 _tokenId) external {

502:     function getMinLockPeriod() external view returns (uint256) {

507:     function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {

514:     function getLoanHash(uint256 _loanId) external view returns (bytes32) {

519:     function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data)

543:     function setFlashActionContract(address _newFlashActionContract) external onlyOwner {

674:     function _baseLoanChecks(uint256 _loanId, Loan memory _loan) private view {

684:     function _baseRenegotiationChecks(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)

709:     function _handleProtocolFeeForFee(address _principalAddress, address _lender, uint256 _fee, address _feeRecipient)

738:     function _getUnlockedTime(uint256 _trancheStartTime, uint256 _loanEndTime) private view returns (uint256) {

747:     function _isLoanLocked(uint256 _loanStartTime, uint256 _loanEndTime) private view returns (bool) {

809:     function _validateExecutionData(LoanExecutionData calldata _executionData, address _borrower) private view {

825:     function _getAddressesFromExecutionData(ExecutionData calldata _executionData)

837:     function _checkWhitelists(address _principalAddress, address _nftCollateralAddress) private view {

871:     function _checkValidators(LoanOffer calldata _loanOffer, uint256 _tokenId) private view {

895:     function _getMinTranchePrincipal(uint256 _loanPrincipal) private view returns (uint256) {

899:     function _hasCallback(bytes calldata _callbackData) private pure returns (bool) {

903:     function _processRepayments(Loan calldata loan) private returns (uint256, uint256) {

1079:     function _checkSignature(address _signer, bytes32 _hash, bytes calldata _signature) private view {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

64:     function setRewardsController(address _controller) external onlyOwner {

70:     function setRewardsReceiver(address _receiver) external onlyOwner {

77:     function getBaseApr() external view override returns (uint256) {

82:     function getBaseAprWithUpdate() external view returns (uint256) {

87:     function getAssetsAllocated() external view returns (uint256) {

92:     function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool) external {

127:     function _onlyPool() private view returns (address) {

135:     function _getBaseApr() private view returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

46:     function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {

60:     function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {

73:     function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {

91:     function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets) {

114:     function totalAssets() public view virtual returns (uint256);

117:     function convertToShares(uint256 assets) public view virtual returns (uint256) {

122:     function convertToAssets(uint256 shares) public view virtual returns (uint256) {

127:     function previewDeposit(uint256 assets) public view virtual returns (uint256) {

132:     function previewMint(uint256 shares) public view virtual returns (uint256) {

137:     function previewWithdraw(uint256 assets) public view virtual returns (uint256) {

142:     function previewRedeem(uint256 shares) public view virtual returns (uint256) {

147:     function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {

152:     function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {

160:     function maxDeposit(address) public view virtual returns (uint256) {

164:     function maxMint(address) public view virtual returns (uint256) {

168:     function maxWithdraw(address owner) public view virtual returns (uint256) {

172:     function maxRedeem(address owner) public view virtual returns (uint256) {

180:     function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

182:     function afterDeposit(uint256 assets, uint256 shares) internal virtual {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/FeeManager.sol

34:     function getFees() external view returns (Fees memory) {

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {

47:     function confirmFees(Fees calldata __fees) external {

63:     function getProposedFees() external view returns (Fees memory) {

68:     function getProposedFeesSetTime() external view returns (uint256) {

73:     function processFees(uint256 _principal, uint256 _interest) external view returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

69:     function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {

76:     function getBaseApr() external view override returns (uint256) {

93:     function getBaseAprWithUpdate() external returns (uint256) {

110:     function getAssetsAllocated() external view returns (uint256) {

115:     function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool _force) external {

140:     function _currentShareRate() private view returns (uint256) {

145:     function _onlyPool() private view returns (address) {

153:     function _exchangeAndSendWeth(address _pool, uint256 _amount, bool _force) private {

161:     function _updateLidoValues(LidoData memory _lidoData) private {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

16:     function getData(address _collection, uint64 _period, bytes4 _key) external view returns (CollectionData memory) {

21:     function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {

27:     function _getKey(address _collection, uint64 _period, bytes4 _key) private pure returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

141:     function setPool(address _pool) external onlyOwner {

152:     function setOracle(address _oracle) external onlyOwner {

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {

201:     function calculateAprPremium() external view returns (uint128) {

205:     function getPrincipalFactors(address _collection, uint96 _duration, bytes memory _extra)

213:     function getCollectionFactors(address _collection, uint96 _duration)

291:     function validateOffer(uint256 _baseRate, bytes calldata _offer)

383:     function _hashKey(address _collection, uint96 _duration, bytes memory _extra) private pure returns (bytes32) {

388:     function _calculateAprPremium() private view returns (uint128) {

400:     function _isZeroAddress(address _address) private pure returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

177:     function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {

185:     function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {

195:     function confirmBaseInterestAllocator() external {

222:     function collectFees(address _recipient) external onlyOwner {

230:     function afterCallerAdded(address _caller) internal override {

235:     function totalAssets() public view override returns (uint256) {

241:     function getOutstandingValues() external view returns (OutstandingValues memory) {

246:     function getDeployedQueue(uint256 _idx) external view returns (DeployedQueue memory) {

253:     function getOutstandingValuesForQueue(uint256 _idx) external view returns (OutstandingValues memory) {

258:     function getPendingQueueIndex() external view returns (uint256) {

265:     function getAccountingValuesForQueue(uint256 _idx) external view returns (QueueAccounting memory) {

270:     function deployWithdrawalQueue() external nonReentrant {

348:     function validateOffer(bytes calldata _offer, uint256 _protocolFee) external override {

376:     function reallocate() external nonReentrant returns (uint256) {

433:     function getUndeployedAssets() external view returns (uint256) {

438:     function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {

451:     function redeem(uint256 shares, address receiver, address owner) public override returns (uint256 assets) {

467:     function deposit(uint256 assets, address receiver) public override returns (uint256) {

473:     function mint(uint256 shares, address receiver) public override returns (uint256) {

485:     function _burn(address from, uint256 amount) internal override {

496:     function _getTotalOutstandingValue() private view returns (uint256) {

516:     function _getOutstandingValue(OutstandingValues memory __outstandingValues) private view returns (uint256) {

527:     function _getNewLoanAccounting(uint256 _principalAmount, uint256 _apr)

594:     function _getUndeployedAssets() private view returns (uint256) {

601:     function _reallocate() private returns (uint256, uint256) {

623:     function _reallocateOnWithdrawal(uint256 _withdrawn) private {

637:     function _netApr(uint256 _apr, uint256 _protocolFee) private pure returns (uint256) {

642:     function _deployQueue(ERC20 _asset) private returns (DeployedQueue memory) {

715:     function _queueClaimAll(uint256 _totalToBeWithdrawn, uint256 _cachedPendingQueueIndex) private {

748:     function _outstandingApr(OutstandingValues memory __outstandingValues) private pure returns (uint128) {

785:     function _withdraw(address owner, address receiver, uint256 assets, uint256 shares) private {

793:     function _isZeroAddress(address _address) private pure returns (bool) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

61:     function mint(address _to, uint256 _shares) external returns (uint256) {

82:     function withdraw(address _to, uint256 _tokenId) external returns (uint256) {

110:     function getAvailable(uint256 _tokenId) external view returns (uint256) {

117:     function lockWithdrawals(uint256 _tokenId, uint256 _time) external {

134:     function tokenURI(uint256 _id) public pure override returns (string memory) {

141:     function _getAvailable(uint256 _tokenId) private view returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/BytesLib.sol

12:     function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {

72:     function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

84:     function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/Hash.sol

39:     function hash(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (bytes32) {

69:     function hash(IMultiSourceLoan.ExecutionData memory _executionData) internal pure returns (bytes32) {

93:     function hash(IMultiSourceLoan.SignableRepaymentData memory _repaymentData) internal pure returns (bytes32) {

104:     function hash(IMultiSourceLoan.Loan memory _loan) internal pure returns (bytes32) {

129:     function hash(IMultiSourceLoan.RenegotiationOffer memory _refinanceOffer) internal pure returns (bytes32) {

154:     function hash(IAuctionLoanLiquidator.Auction memory _auction) internal pure returns (bytes32) {

173:     function _hashTranche(IMultiSourceLoan.Tranche memory _tranche) private pure returns (bytes32) {

188:     function _hashValidator(IBaseLoan.OfferValidator memory _validator) private pure returns (bytes32) {

192:     function _hashOfferExecution(IMultiSourceLoan.OfferExecution memory _offerExecution)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

```solidity
File: src/lib/utils/Interest.sol

15:     function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {

19:     function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {

23:     function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {

36:     function _getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) private pure returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

27:     function requestTransferOwner(address _newOwner) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

15:     function validateTokenIdPackedList(uint256 _tokenId, uint64 _bytesPerTokenId, bytes memory _tokenIdList)

72:     function validateNFTBitVector(uint256 _tokenId, bytes memory _bitVector) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

43:     function getProtocolFee() external view returns (ProtocolFee memory) {

48:     function getPendingProtocolFee() external view returns (ProtocolFee memory) {

53:     function getPendingProtocolFeeSetTime() external view returns (uint256) {

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-12"></a>[NC-12] Change int to int256

Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (1)*:

```solidity
File: src/lib/pools/ERC4626.sol

61:         assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

### <a name="NC-13"></a>[NC-13] Change uint to uint256

Throughout the code base, some variables are declared as `uint`. To favor explicitness, consider changing all instances of `uint` to `uint256`

*Instances (1)*:

```solidity
File: src/lib/utils/BytesLib.sol

90:             tempUint := mload(add(add(_bytes, 0x3), _start))

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

### <a name="NC-14"></a>[NC-14] Lack of checks in setters

Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (20)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

156:     function updateLiquidationDistributor(address __liquidationDistributor) external onlyOwner {
             __liquidationDistributor.checkNotZero();
     
             _liquidationDistributor = ILiquidationDistributor(__liquidationDistributor);
     
             emit LiquidationDistributorUpdated(__liquidationDistributor);

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {
             _updateTriggerFee(triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

74:     function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {
            __loanLiquidator.checkNotZero();
            _loanLiquidator = __loanLiquidator;
    
            emit LiquidationContractUpdated(__loanLiquidator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

231:     function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {
             _newAddress.checkNotZero();
     
             _pendingMultiSourceLoanAddress = _newAddress;
     
             emit MultiSourceLoanPendingUpdate(_newAddress);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

135:     function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {
             _minImprovementApr = _newMinimum;
     
             emit MinAprImprovementUpdated(_minImprovementApr);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

507:     function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {
             _minLockPeriod = __minLockPeriod;
     
             emit MinLockPeriodUpdated(__minLockPeriod);

543:     function setFlashActionContract(address _newFlashActionContract) external onlyOwner {
             getFlashActionContract = _newFlashActionContract;
     
             emit FlashActionContractUpdated(_newFlashActionContract);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

64:     function setRewardsController(address _controller) external onlyOwner {
            getRewardsController = _controller;
    
            emit RewardsControllerSet(_controller);

70:     function setRewardsReceiver(address _receiver) external onlyOwner {
            getRewardsReceiver = _receiver;
    
            emit RewardsReceiverSet(_receiver);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {
            _proposedFees = __fees;
            _proposedFeesSetTime = block.timestamp;
    
            emit ProposedFeesSet(__fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

69:     function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {
            getMaxSlippage = _maxSlippage;
    
            emit MaxSlippageSet(_maxSlippage);

105:     function updateLidoValues() external {
             _updateLidoValues(getLidoData);

161:     function _updateLidoValues(LidoData memory _lidoData) private {
             uint256 shareRate = _currentShareRate();
             _lidoData.aprBps = uint16(
                 _BPS * _SECONDS_PER_YEAR * (shareRate - _lidoData.shareRate) / _lidoData.shareRate
                     / (block.timestamp - _lidoData.lastTs)
             );
             _lidoData.shareRate = uint144(shareRate);
             _lidoData.lastTs = uint96(block.timestamp);
             getLidoData = _lidoData;
             emit LidoValuesUpdated(_lidoData);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

21:     function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {
            _data[_getKey(_collection, _period, _key)] = CollectionData(_value, uint128(block.timestamp));
    
            emit DataUpdated(_collection, _period, _key, _value);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

152:     function setOracle(address _oracle) external onlyOwner {
             getProposedOracle = _oracle;
             getProposedOracleSetTs = block.timestamp;
     
             emit ProposedOracleSet(_oracle);

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {
             getProposedAprFactors = _aprFactors;
             getProposedAprFactorsSetTs = block.timestamp;
     
             emit ProposedAprFactorsSet(_aprFactors);

192:     function setAprPremium() external {
             uint128 aprPremium = _calculateAprPremium();
             getAprPremium = AprPremium(aprPremium, uint128(block.timestamp));
     
             emit AprPremiumSet(aprPremium);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

177:     function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {
             _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) >> 1;
             getOptimalIdleRange = _optimalIdleRange;
     
             emit OptimalIdleRangeSet(_optimalIdleRange);

185:     function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {
             _newBaseInterestAllocator.checkNotZero();
     
             getProposedBaseInterestAllocator = _newBaseInterestAllocator;
             getProposedBaseInterestAllocatorSetTime = block.timestamp;
     
             emit PendingBaseInterestAllocatorSet(_newBaseInterestAllocator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {
            _newProtocolFee.recipient.checkNotZero();
    
            _pendingProtocolFee = _newProtocolFee;
            _pendingProtocolFeeSetTime = block.timestamp;
    
            emit ProtocolFeePendingUpdate(_pendingProtocolFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-15"></a>[NC-15] Missing Event for critical parameters change

Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (4)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {
             _updateTriggerFee(triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/loans/LoanManager.sol

46:     function updateOfferHandler(address _offerHandler) external {
            if (msg.sender != getParameterSetter) {
                revert InvalidCallerError();
            }
            getOfferHandler = _offerHandler;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

45:     function setLoanManager(address __loanManager) external onlyOwner {
            if (getLoanManager != address(0)) {
                revert LoanManagerSetError();
            }
            __loanManager.checkNotZero();
    
            if (ILoanManager(__loanManager).getParameterSetter() != address(this)) {
                revert InvalidInputError();
            }
    
            getLoanManager = __loanManager;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

105:     function updateLidoValues() external {
             _updateLidoValues(getLidoData);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

### <a name="NC-16"></a>[NC-16] NatSpec is completely non-existent on functions that should have them

Public and external functions that aren't view or pure should have NatSpec comments

*Instances (10)*:

```solidity
File: src/lib/LiquidationDistributor.sol

37:     function setLiquidator(address _liquidator) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/Multicall.sol

10:     function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/Multicall.sol)

```solidity
File: src/lib/loans/LoanManager.sol

46:     function updateOfferHandler(address _offerHandler) external {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

45:     function setLoanManager(address __loanManager) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

64:     function setRewardsController(address _controller) external onlyOwner {

70:     function setRewardsReceiver(address _receiver) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

141:     function setPool(address _pool) external onlyOwner {

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {

179:     function confirmAprFactors() external {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

222:     function collectFees(address _recipient) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="NC-17"></a>[NC-17] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor

If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (28)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

194:         if (!_validLoanContracts.contains(msg.sender)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

48:         if (msg.sender != getLiquidator) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

62:         if (msg.sender != address(_loanLiquidator)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

408:         if (_readyForWithdrawal[_vaultId] != msg.sender) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

88:         if (msg.sender != address(_multiSourceLoan)) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

47:         if (msg.sender != getParameterSetter) {

57:         if (msg.sender != getParameterSetter) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

200:         } else if (msg.sender != _loan.borrower) {

243:         if (msg.sender != _renegotiationOffer.lender) {

320:         if (msg.sender != _loan.borrower) {

370:         if (msg.sender != _loan.borrower) {

417:         if (msg.sender != loan.borrower) {

480:         if (msg.sender != loan.borrower) {

526:         if (msg.sender != _loan.borrower) {

810:         if (msg.sender != _borrower) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

129:         if (pool != msg.sender) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

76:         if (msg.sender != owner) {

79:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

92:         if (msg.sender != owner) {

95:             if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

147:         if (pool != msg.sender) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

352:         if (!_isLoanContract[msg.sender]) {

394:         if (!_isLoanContract[msg.sender]) {

416:         if (!_acceptedCallers.contains(msg.sender)) {

440:         if (msg.sender != owner) {

452:         if (msg.sender != owner) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

62:         if (msg.sender != getPool) {

119:         if (!(msg.sender == owner || isApprovedForAll[owner][msg.sender] || msg.sender == getApproved[_tokenId])) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="NC-18"></a>[NC-18] Constant state variables defined more than once

Rather than redefining state variable constant, consider using a library to store all constants as this will prevent data redundancy

*Instances (18)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

42:     uint256 internal constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

24:     uint256 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

19:     string private constant _BASE_URI = "https://gondi.xyz/user_vaults/";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

29:     uint256 private constant _PRECISION = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

35:     uint256 internal constant _PRECISION = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

23:     uint256 private constant _BPS = 10000;

24:     uint128 private constant _PRINCIPAL_PRECISION = 1e20;

25:     uint256 private constant _SECONDS_PER_YEAR = 365 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

16:     uint256 public constant PRECISION = 1e20;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

27:     uint256 private constant _BPS = 10000;

28:     uint256 private constant _SECONDS_PER_YEAR = 365 days;

29:     uint256 private constant _PRINCIPAL_PRECISION = 1e20;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

50:     uint256 public constant PRECISION = 1e27;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

45:     uint256 private constant _SECONDS_PER_YEAR = 31536000;

48:     uint16 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

24:     string private constant _BASE_URI = "https://gondi.xyz/withdrawal-queue/";

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/Interest.sol

11:     uint256 private constant _PRECISION = 10000;

13:     uint256 private constant _SECONDS_PER_YEAR = 31536000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

### <a name="NC-19"></a>[NC-19] Consider using named mappings

Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (4)*:

```solidity
File: src/lib/AddressManager.sol

25:     mapping(address => uint16) private _directory;

27:     mapping(uint16 => address) private _inverseDirectory;

29:     mapping(address => bool) private _whitelist;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/loans/LoanManager.sol

28:     mapping(address => bool) internal _isLoanContract;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

### <a name="NC-20"></a>[NC-20] `address`s shouldn't be hard-coded

It is often better to declare `address`es as `immutable`, and assign them via constructor arguments. This allows the code to remain the same across deployments on different networks, and avoids recompilation when addresses need to change.

*Instances (1)*:

```solidity
File: src/lib/UserVault.sol

22:     address public constant ETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

### <a name="NC-21"></a>[NC-21] Owner can renounce while system is paused

The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (1)*:

```solidity
File: src/lib/pools/Pool.sol

170:     function pausePool() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="NC-22"></a>[NC-22] `require()` / `revert()` statements should have descriptive reason strings

*Instances (2)*:

```solidity
File: src/lib/callbacks/CallbackHandler.sol

65:             revert ILoanCallback.InvalidCallbackError();

83:             revert ILoanCallback.InvalidCallbackError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

### <a name="NC-23"></a>[NC-23] Take advantage of Custom Error's return value property

An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (123)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

135:             revert CouldNotModifyValidLoansError();

144:             revert CouldNotModifyValidLoansError();

199:             revert CurrencyNotWhitelistedError();

203:             revert CollectionNotWhitelistedError();

207:             revert AuctionAlreadyInProgressError();

276:             revert NoBidsError();

324:             revert InvalidHashAuctionError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

91:             revert NotMainLenderError();

135:             revert InvalidInputError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/InputChecker.sol

12:             revert AddressZeroError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

39:             revert LiquidatorCannotBeUpdatedError();

49:             revert InvalidCallerError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

84:             revert InvalidDurationError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

111:             revert LengthMismatchError();

121:             revert LengthMismatchError();

156:             revert CollectionNotWhitelistedError();

166:             revert CollectionNotWhitelistedError();

182:             revert CollectionNotWhitelistedError();

192:             revert CollectionNotWhitelistedError();

209:             revert WrongMethodError();

234:             revert LengthMismatchError();

255:             revert LengthMismatchError();

301:             revert InvalidCallerError();

312:             revert CurrencyNotWhitelistedError();

327:             revert AssetNotOwnedError();

340:             revert AssetNotOwnedError();

381:             revert WithdrawingETHError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

65:             revert ILoanCallback.InvalidCallbackError();

83:             revert ILoanCallback.InvalidCallbackError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

89:             revert OnlyLoanCallableError();

121:                 revert CouldNotReturnEthError();

154:             revert MarketplaceAddressNotWhitelisted();

157:             revert OnlyWethSupportedError();

165:             revert InvalidCallbackError();

192:             revert MarketplaceAddressNotWhitelisted();

224:             revert InvalidCallbackError();

242:             revert InvalidAddressUpdateError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

48:             revert InvalidCallerError();

58:             revert InvalidCallerError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

47:             revert LoanManagerSetError();

52:             revert InvalidInputError();

64:             revert InvalidInputError();

77:             revert TooSoonError();

80:             revert InvalidInputError();

106:             revert TooSoonError();

115:                 revert InvalidInputError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

169:             revert InvalidRenegotiationOfferError();

182:                 revert LoanLockedError();

201:             revert InvalidCallerError();

244:             revert InvalidCallerError();

248:             revert LoanLockedError();

251:             revert InvalidRenegotiationOfferError();

269:                 revert InvalidRenegotiationOfferError();

299:             revert InvalidRenegotiationOfferError();

321:             revert InvalidCallerError();

336:             revert InvalidAddressesError();

339:             revert InvalidCollateralIdError();

371:             revert InvalidCallerError();

381:             revert InvalidRenegotiationOfferError();

385:             revert TooManyTranchesError();

481:             revert InvalidCallerError();

493:             revert InvalidMethodError();

527:             revert InvalidCallerError();

536:             revert NFTNotReturnedError();

679:             revert LoanExpiredError();

692:             revert InvalidRenegotiationOfferError();

733:             revert InvalidRenegotiationOfferError();

796:             revert InvalidDurationError();

799:             revert ZeroInterestError();

802:             revert MaxCapacityExceededError();

817:             revert TooManyTranchesError();

839:             revert CurrencyNotWhitelistedError();

842:             revert CollectionNotWhitelistedError();

858:             revert InvalidAddressesError();

861:             revert InvalidTrancheError();

875:                 revert InvalidCollateralIdError();

880:                 revert InvalidCollateralIdError();

1025:             revert InvalidTrancheError();

1048:             revert InvalidTrancheError();

1084:                 revert InvalidSignatureError();

1089:                 revert InvalidSignatureError();

1120:             revert NotStrictlyImprovedError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

50:             revert InvalidPoolError();

130:             revert InvalidCallerError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

49:             revert TooSoonError();

54:             revert InvalidFeesError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

56:             revert InvalidPoolError();

87:             revert InvalidAprError();

99:             revert InvalidAprError();

148:             revert InvalidCallerError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

143:             revert PoolAlreadySetError();

162:             revert TooSoonError();

181:             revert TooSoonError();

234:             revert InvalidInputLengthError();

261:             revert TooSoonError();

268:             revert InvalidInputLengthError();

277:                 revert InvalidInputError();

312:             revert OutdatedValueError();

330:             revert InvalidPrincipalAmountError();

334:             revert InvalidAprError();

338:             revert InvalidMaxSeniorRepaymentError();

360:                     revert InvalidInputError();

373:                     revert InvalidInputError();

377:                 revert InvalidInputError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

198:             revert InvalidInputError();

204:                 revert TooSoonError();

277:             revert TooSoonError();

282:             revert NoSharesPendingWithdrawalError();

350:             revert PoolStatusError();

353:             revert CallerNotAccepted();

367:             revert InsufficientAssetsError();

395:             revert CallerNotAccepted();

417:             revert CallerNotAccepted();

588:             revert PoolStatusError();

605:             revert AllocationAlreadyOptimalError();

614:             revert AllocationAlreadyOptimalError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

63:             revert PoolOnlyCallableError();

90:             revert NotApprovedOrOwnerError();

120:             revert NotApprovedOrOwnerError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

38:             revert TooSoonError();

41:             revert InvalidInputError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

24:             revert EmptyTokenIdListError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

71:             revert TooSoonError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-24"></a>[NC-24] Avoid the use of sensitive terms

Use [alternative variants](https://www.zdnet.com/article/mysql-drops-master-slave-and-blacklist-whitelist-terminology/), e.g. allowlist/denylist instead of whitelist/blacklist

*Instances (57)*:

```solidity
File: src/lib/AddressManager.sol

17:     event AddressRemovedFromWhitelist(address address_removed);

19:     event AddressWhitelisted(address address_whitelisted);

29:     mapping(address => bool) private _whitelist;

53:     function addToWhitelist(address _entry) external payable onlyOwner {

57:         _whitelist[_entry] = true;

59:         emit AddressWhitelisted(_entry);

65:     function removeFromWhitelist(address _entry) external payable onlyOwner {

66:         _whitelist[_entry] = false;

68:         emit AddressRemovedFromWhitelist(_entry);

85:     function isWhitelisted(address _entry) external view returns (bool) {

86:         return _whitelist[_entry];

99:         _whitelist[_entry] = true;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

99:     error CurrencyNotWhitelistedError();

101:     error CollectionNotWhitelistedError();

198:         if (!_currencyManager.isWhitelisted(_asset)) {

199:             revert CurrencyNotWhitelistedError();

202:         if (!_collectionManager.isWhitelisted(_nftAddress)) {

203:             revert CollectionNotWhitelistedError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/UserVault.sol

54:     error CurrencyNotWhitelistedError();

56:     error CollectionNotWhitelistedError();

155:         if (!_collectionManager.isWhitelisted(_collection)) {

156:             revert CollectionNotWhitelistedError();

165:         if (!_collectionManager.isWhitelisted(_collection)) {

166:             revert CollectionNotWhitelistedError();

181:         if (!_oldCollectionManager.isWhitelisted(_collection)) {

182:             revert CollectionNotWhitelistedError();

191:         if (!_oldCollectionManager.isWhitelisted(_collection)) {

192:             revert CollectionNotWhitelistedError();

311:         if (!_currencyManager.isWhitelisted(_token)) {

312:             revert CurrencyNotWhitelistedError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

16:     mapping(address callbackContract => bool isWhitelisted) internal _isWhitelistedCallbackContract;

20:     event WhitelistedCallbackContractAdded(address contractAdded);

21:     event WhitelistedCallbackContractRemoved(address contractRemoved);

29:     function addWhitelistedCallbackContract(address _contract) external onlyOwner {

31:         _isWhitelistedCallbackContract[_contract] = true;

33:         emit WhitelistedCallbackContractAdded(_contract);

38:     function removeWhitelistedCallbackContract(address _contract) external onlyOwner {

39:         _isWhitelistedCallbackContract[_contract] = false;

41:         emit WhitelistedCallbackContractRemoved(_contract);

45:     function isWhitelistedCallbackContract(address _contract) external view returns (bool) {

46:         return _isWhitelistedCallbackContract[_contract];

61:             !_isWhitelistedCallbackContract[_callbackAddress]

79:             !_isWhitelistedCallbackContract[_callbackAddress]

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

54:     error MarketplaceAddressNotWhitelisted();

153:         if (!_marketplaceContractsAddressManager.isWhitelisted(executionInfo.module)) {

154:             revert MarketplaceAddressNotWhitelisted();

191:         if (!_marketplaceContractsAddressManager.isWhitelisted(executionInfo.module)) {

192:             revert MarketplaceAddressNotWhitelisted();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

87:     error CurrencyNotWhitelistedError();

89:     error CollectionNotWhitelistedError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

134:         _checkWhitelists(principalAddress, nftCollateralAddress);

333:         _checkWhitelists(principalAddress, nftCollateralAddress);

837:     function _checkWhitelists(address _principalAddress, address _nftCollateralAddress) private view {

838:         if (!_currencyManager.isWhitelisted(_principalAddress)) {

839:             revert CurrencyNotWhitelistedError();

841:         if (!_collectionManager.isWhitelisted(_nftCollateralAddress)) {

842:             revert CollectionNotWhitelistedError();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

### <a name="NC-25"></a>[NC-25] Contract does not follow the Solidity style guide's suggested layout ordering

The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (20)*:

```solidity
File: src/lib/AddressManager.sol

1: 
   Current order:
   UsingForDirective.InputChecker
   EventDefinition.AddressAdded
   EventDefinition.AddressRemovedFromWhitelist
   EventDefinition.AddressWhitelisted
   ErrorDefinition.AddressAlreadyAddedError
   ErrorDefinition.AddressNotAddedError
   VariableDeclaration._directory
   VariableDeclaration._inverseDirectory
   VariableDeclaration._whitelist
   VariableDeclaration._lastAdded
   FunctionDefinition.constructor
   FunctionDefinition.add
   FunctionDefinition.addToWhitelist
   FunctionDefinition.removeFromWhitelist
   FunctionDefinition.addressToIndex
   FunctionDefinition.indexToAddress
   FunctionDefinition.isWhitelisted
   FunctionDefinition._add
   
   Suggested order:
   UsingForDirective.InputChecker
   VariableDeclaration._directory
   VariableDeclaration._inverseDirectory
   VariableDeclaration._whitelist
   VariableDeclaration._lastAdded
   ErrorDefinition.AddressAlreadyAddedError
   ErrorDefinition.AddressNotAddedError
   EventDefinition.AddressAdded
   EventDefinition.AddressRemovedFromWhitelist
   EventDefinition.AddressWhitelisted
   FunctionDefinition.constructor
   FunctionDefinition.add
   FunctionDefinition.addToWhitelist
   FunctionDefinition.removeFromWhitelist
   FunctionDefinition.addressToIndex
   FunctionDefinition.indexToAddress
   FunctionDefinition.isWhitelisted
   FunctionDefinition._add

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

1: 
   Current order:
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Auction
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   VariableDeclaration.MAX_TRIGGER_FEE
   VariableDeclaration.MIN_INCREMENT_BPS
   VariableDeclaration._BPS
   VariableDeclaration._MIN_NO_ACTION_MARGIN
   VariableDeclaration.getMaxExtension
   VariableDeclaration._liquidationDistributor
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   VariableDeclaration._triggerFee
   VariableDeclaration._validLoanContracts
   VariableDeclaration._auctions
   EventDefinition.LoanContractAdded
   EventDefinition.LoanContractRemoved
   EventDefinition.LiquidationDistributorUpdated
   EventDefinition.LoanLiquidationStarted
   EventDefinition.BidPlaced
   EventDefinition.AuctionSettled
   EventDefinition.TriggerFeeUpdated
   ErrorDefinition.InvalidHashAuctionError
   ErrorDefinition.NFTNotOwnedError
   ErrorDefinition.MinBidError
   ErrorDefinition.AuctionOverError
   ErrorDefinition.AuctionNotOverError
   ErrorDefinition.AuctionAlreadyInProgressError
   ErrorDefinition.NoBidsError
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.LoanNotAcceptedError
   ErrorDefinition.InvalidTriggerFee
   ErrorDefinition.CouldNotModifyValidLoansError
   FunctionDefinition.constructor
   FunctionDefinition.addLoanContract
   FunctionDefinition.removeLoanContract
   FunctionDefinition.getValidLoanContracts
   FunctionDefinition.updateLiquidationDistributor
   FunctionDefinition.getLiquidationDistributor
   FunctionDefinition.updateTriggerFee
   FunctionDefinition.getTriggerFee
   FunctionDefinition.liquidateLoan
   FunctionDefinition.placeBid
   FunctionDefinition.settleAuction
   FunctionDefinition.getAuctionHash
   FunctionDefinition._checkAuction
   FunctionDefinition._placeBidChecks
   FunctionDefinition._updateTriggerFee
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Auction
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   VariableDeclaration.MAX_TRIGGER_FEE
   VariableDeclaration.MIN_INCREMENT_BPS
   VariableDeclaration._BPS
   VariableDeclaration._MIN_NO_ACTION_MARGIN
   VariableDeclaration.getMaxExtension
   VariableDeclaration._liquidationDistributor
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   VariableDeclaration._triggerFee
   VariableDeclaration._validLoanContracts
   VariableDeclaration._auctions
   ErrorDefinition.InvalidHashAuctionError
   ErrorDefinition.NFTNotOwnedError
   ErrorDefinition.MinBidError
   ErrorDefinition.AuctionOverError
   ErrorDefinition.AuctionNotOverError
   ErrorDefinition.AuctionAlreadyInProgressError
   ErrorDefinition.NoBidsError
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.LoanNotAcceptedError
   ErrorDefinition.InvalidTriggerFee
   ErrorDefinition.CouldNotModifyValidLoansError
   EventDefinition.LoanContractAdded
   EventDefinition.LoanContractRemoved
   EventDefinition.LiquidationDistributorUpdated
   EventDefinition.LoanLiquidationStarted
   EventDefinition.BidPlaced
   EventDefinition.AuctionSettled
   EventDefinition.TriggerFeeUpdated
   FunctionDefinition.constructor
   FunctionDefinition.addLoanContract
   FunctionDefinition.removeLoanContract
   FunctionDefinition.getValidLoanContracts
   FunctionDefinition.updateLiquidationDistributor
   FunctionDefinition.getLiquidationDistributor
   FunctionDefinition.updateTriggerFee
   FunctionDefinition.getTriggerFee
   FunctionDefinition.liquidateLoan
   FunctionDefinition.placeBid
   FunctionDefinition.settleAuction
   FunctionDefinition.getAuctionHash
   FunctionDefinition._checkAuction
   FunctionDefinition._placeBidChecks
   FunctionDefinition._updateTriggerFee

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.ERC20
   VariableDeclaration._timeForMainLenderToBuy
   VariableDeclaration.MAX_TIME_FOR_MAIN_LENDER_TO_BUY
   VariableDeclaration.getLoanManagerRegistry
   EventDefinition.AuctionSettledWithBuyout
   EventDefinition.TimeForMainLenderToBuyUpdated
   ErrorDefinition.OptionToBuyExpiredError
   ErrorDefinition.OptionToBuyStilValidError
   ErrorDefinition.NotMainLenderError
   ErrorDefinition.InvalidInputError
   FunctionDefinition.constructor
   FunctionDefinition.settleWithBuyout
   FunctionDefinition.setTimeForMainLenderToBuy
   FunctionDefinition.getTimeForMainLenderToBuy
   FunctionDefinition._placeBidChecks
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.ERC20
   VariableDeclaration._timeForMainLenderToBuy
   VariableDeclaration.MAX_TIME_FOR_MAIN_LENDER_TO_BUY
   VariableDeclaration.getLoanManagerRegistry
   ErrorDefinition.OptionToBuyExpiredError
   ErrorDefinition.OptionToBuyStilValidError
   ErrorDefinition.NotMainLenderError
   ErrorDefinition.InvalidInputError
   EventDefinition.AuctionSettledWithBuyout
   EventDefinition.TimeForMainLenderToBuyUpdated
   FunctionDefinition.constructor
   FunctionDefinition.settleWithBuyout
   FunctionDefinition.setTimeForMainLenderToBuy
   FunctionDefinition.getTimeForMainLenderToBuy
   FunctionDefinition._placeBidChecks

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.ERC20
   VariableDeclaration.getLoanManagerRegistry
   VariableDeclaration.getLiquidator
   EventDefinition.LiquidatorSet
   ErrorDefinition.LiquidatorCannotBeUpdatedError
   ErrorDefinition.InvalidCallerError
   FunctionDefinition.constructor
   FunctionDefinition.setLiquidator
   FunctionDefinition.distribute
   FunctionDefinition._handleTrancheExcess
   FunctionDefinition._handleTrancheInsufficient
   FunctionDefinition._handleLoanManagerCall
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.ERC20
   VariableDeclaration.getLoanManagerRegistry
   VariableDeclaration.getLiquidator
   ErrorDefinition.LiquidatorCannotBeUpdatedError
   ErrorDefinition.InvalidCallerError
   EventDefinition.LiquidatorSet
   FunctionDefinition.constructor
   FunctionDefinition.setLiquidator
   FunctionDefinition.distribute
   FunctionDefinition._handleTrancheExcess
   FunctionDefinition._handleTrancheInsufficient
   FunctionDefinition._handleLoanManagerCall

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

1: 
   Current order:
   UsingForDirective.InputChecker
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.MIN_AUCTION_DURATION
   VariableDeclaration.MAX_AUCTION_DURATION
   VariableDeclaration.MIN_BID_LIQUIDATION
   VariableDeclaration._BPS
   VariableDeclaration._liquidationAuctionDuration
   VariableDeclaration._loanLiquidator
   EventDefinition.MinBidLiquidationUpdated
   EventDefinition.LoanSentToLiquidator
   EventDefinition.LoanForeclosed
   EventDefinition.LiquidationContractUpdated
   EventDefinition.LiquidationAuctionDurationUpdated
   ErrorDefinition.LiquidatorOnlyError
   ErrorDefinition.LoanNotDueError
   ErrorDefinition.InvalidDurationError
   FunctionDefinition.constructor
   ModifierDefinition.onlyLiquidator
   FunctionDefinition.getLiquidator
   FunctionDefinition.updateLiquidationContract
   FunctionDefinition.updateLiquidationAuctionDuration
   FunctionDefinition.getLiquidationAuctionDuration
   FunctionDefinition._liquidateLoan
   
   Suggested order:
   UsingForDirective.InputChecker
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.MIN_AUCTION_DURATION
   VariableDeclaration.MAX_AUCTION_DURATION
   VariableDeclaration.MIN_BID_LIQUIDATION
   VariableDeclaration._BPS
   VariableDeclaration._liquidationAuctionDuration
   VariableDeclaration._loanLiquidator
   ErrorDefinition.LiquidatorOnlyError
   ErrorDefinition.LoanNotDueError
   ErrorDefinition.InvalidDurationError
   EventDefinition.MinBidLiquidationUpdated
   EventDefinition.LoanSentToLiquidator
   EventDefinition.LoanForeclosed
   EventDefinition.LiquidationContractUpdated
   EventDefinition.LiquidationAuctionDurationUpdated
   ModifierDefinition.onlyLiquidator
   FunctionDefinition.constructor
   FunctionDefinition.getLiquidator
   FunctionDefinition.updateLiquidationContract
   FunctionDefinition.updateLiquidationAuctionDuration
   FunctionDefinition.getLiquidationAuctionDuration
   FunctionDefinition._liquidateLoan

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

1: 
   Current order:
   UsingForDirective.ERC20
   VariableDeclaration._BASE_URI
   VariableDeclaration._nextId
   VariableDeclaration.ETH
   VariableDeclaration._readyForWithdrawal
   VariableDeclaration._vaultERC721s
   VariableDeclaration._vaultOldERC721s
   VariableDeclaration._vaultERC20s
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   VariableDeclaration._oldCollectionManager
   EventDefinition.ERC721Deposited
   EventDefinition.OldERC721Deposited
   EventDefinition.OldERC721Withdrawn
   EventDefinition.ERC20Deposited
   EventDefinition.ERC721Withdrawn
   EventDefinition.ERC20Withdrawn
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.LengthMismatchError
   ErrorDefinition.NotApprovedError
   ErrorDefinition.WithdrawingETHError
   ErrorDefinition.WrongMethodError
   ErrorDefinition.AssetNotOwnedError
   ErrorDefinition.VaultNotExistsError
   ErrorDefinition.InvalidCallerError
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.burn
   FunctionDefinition.burnAndWithdraw
   FunctionDefinition.ERC721OwnerOf
   FunctionDefinition.OldERC721OwnerOf
   FunctionDefinition.ERC20BalanceOf
   FunctionDefinition.depositERC721
   FunctionDefinition.depositERC721s
   FunctionDefinition.depositOldERC721
   FunctionDefinition.depositOldERC721s
   FunctionDefinition.depositERC20
   FunctionDefinition.depositEth
   FunctionDefinition.withdrawERC721
   FunctionDefinition.withdrawERC721s
   FunctionDefinition.withdrawOldERC721
   FunctionDefinition.withdrawOldERC721s
   FunctionDefinition.withdrawERC20
   FunctionDefinition.withdrawERC20s
   FunctionDefinition.tokenURI
   FunctionDefinition.withdrawEth
   FunctionDefinition._depositERC721
   FunctionDefinition._depositOldERC721
   FunctionDefinition._depositERC20
   FunctionDefinition._withdrawERC721
   FunctionDefinition._withdrawOldERC721
   FunctionDefinition._withdrawERC20
   FunctionDefinition._thisBurn
   FunctionDefinition._withdrawEth
   FunctionDefinition._vaultExists
   FunctionDefinition._onlyApproved
   FunctionDefinition._onlyReadyForWithdrawal
   
   Suggested order:
   UsingForDirective.ERC20
   VariableDeclaration._BASE_URI
   VariableDeclaration._nextId
   VariableDeclaration.ETH
   VariableDeclaration._readyForWithdrawal
   VariableDeclaration._vaultERC721s
   VariableDeclaration._vaultOldERC721s
   VariableDeclaration._vaultERC20s
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   VariableDeclaration._oldCollectionManager
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.LengthMismatchError
   ErrorDefinition.NotApprovedError
   ErrorDefinition.WithdrawingETHError
   ErrorDefinition.WrongMethodError
   ErrorDefinition.AssetNotOwnedError
   ErrorDefinition.VaultNotExistsError
   ErrorDefinition.InvalidCallerError
   EventDefinition.ERC721Deposited
   EventDefinition.OldERC721Deposited
   EventDefinition.OldERC721Withdrawn
   EventDefinition.ERC20Deposited
   EventDefinition.ERC721Withdrawn
   EventDefinition.ERC20Withdrawn
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.burn
   FunctionDefinition.burnAndWithdraw
   FunctionDefinition.ERC721OwnerOf
   FunctionDefinition.OldERC721OwnerOf
   FunctionDefinition.ERC20BalanceOf
   FunctionDefinition.depositERC721
   FunctionDefinition.depositERC721s
   FunctionDefinition.depositOldERC721
   FunctionDefinition.depositOldERC721s
   FunctionDefinition.depositERC20
   FunctionDefinition.depositEth
   FunctionDefinition.withdrawERC721
   FunctionDefinition.withdrawERC721s
   FunctionDefinition.withdrawOldERC721
   FunctionDefinition.withdrawOldERC721s
   FunctionDefinition.withdrawERC20
   FunctionDefinition.withdrawERC20s
   FunctionDefinition.tokenURI
   FunctionDefinition.withdrawEth
   FunctionDefinition._depositERC721
   FunctionDefinition._depositOldERC721
   FunctionDefinition._depositERC20
   FunctionDefinition._withdrawERC721
   FunctionDefinition._withdrawOldERC721
   FunctionDefinition._withdrawERC20
   FunctionDefinition._thisBurn
   FunctionDefinition._withdrawEth
   FunctionDefinition._vaultExists
   FunctionDefinition._onlyApproved
   FunctionDefinition._onlyReadyForWithdrawal

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.BytesLib
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   UsingForDirective.WETH
   VariableDeclaration._PRECISION
   VariableDeclaration._MAX_TAX
   VariableDeclaration.TAX_UPDATE_NOTICE
   VariableDeclaration._marketplaceContractsAddressManager
   VariableDeclaration._weth
   VariableDeclaration._pendingTaxes
   VariableDeclaration._pendingTaxesSetTime
   VariableDeclaration._taxes
   VariableDeclaration._pendingMultiSourceLoanAddress
   VariableDeclaration._multiSourceLoan
   VariableDeclaration._punkMarket
   VariableDeclaration._wrappedPunk
   VariableDeclaration._punkProxy
   EventDefinition.BNPLLoansStarted
   EventDefinition.SellAndRepayExecuted
   EventDefinition.MultiSourceLoanPendingUpdate
   EventDefinition.MultiSourceLoanUpdated
   EventDefinition.TaxesPendingUpdate
   EventDefinition.TaxesUpdated
   ErrorDefinition.MarketplaceAddressNotWhitelisted
   ErrorDefinition.OnlyWethSupportedError
   ErrorDefinition.OnlyLoanCallableError
   ErrorDefinition.InvalidAddressUpdateError
   ErrorDefinition.CouldNotReturnEthError
   ErrorDefinition.InvalidTaxesError
   FunctionDefinition.constructor
   ModifierDefinition.onlyLoanContract
   FunctionDefinition.buy
   FunctionDefinition.sell
   FunctionDefinition.afterPrincipalTransfer
   FunctionDefinition.afterNFTTransfer
   FunctionDefinition.updateMultiSourceLoanAddressFirst
   FunctionDefinition.finalUpdateMultiSourceLoanAddress
   FunctionDefinition.getMultiSourceLoanAddress
   FunctionDefinition.getTaxes
   FunctionDefinition.getPendingTaxes
   FunctionDefinition.getPendingTaxesSetTime
   FunctionDefinition.updateTaxes
   FunctionDefinition.setTaxes
   FunctionDefinition._handleTax
   FunctionDefinition.fallback
   FunctionDefinition.receive
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.BytesLib
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   UsingForDirective.WETH
   VariableDeclaration._PRECISION
   VariableDeclaration._MAX_TAX
   VariableDeclaration.TAX_UPDATE_NOTICE
   VariableDeclaration._marketplaceContractsAddressManager
   VariableDeclaration._weth
   VariableDeclaration._pendingTaxes
   VariableDeclaration._pendingTaxesSetTime
   VariableDeclaration._taxes
   VariableDeclaration._pendingMultiSourceLoanAddress
   VariableDeclaration._multiSourceLoan
   VariableDeclaration._punkMarket
   VariableDeclaration._wrappedPunk
   VariableDeclaration._punkProxy
   ErrorDefinition.MarketplaceAddressNotWhitelisted
   ErrorDefinition.OnlyWethSupportedError
   ErrorDefinition.OnlyLoanCallableError
   ErrorDefinition.InvalidAddressUpdateError
   ErrorDefinition.CouldNotReturnEthError
   ErrorDefinition.InvalidTaxesError
   EventDefinition.BNPLLoansStarted
   EventDefinition.SellAndRepayExecuted
   EventDefinition.MultiSourceLoanPendingUpdate
   EventDefinition.MultiSourceLoanUpdated
   EventDefinition.TaxesPendingUpdate
   EventDefinition.TaxesUpdated
   ModifierDefinition.onlyLoanContract
   FunctionDefinition.constructor
   FunctionDefinition.buy
   FunctionDefinition.sell
   FunctionDefinition.afterPrincipalTransfer
   FunctionDefinition.afterNFTTransfer
   FunctionDefinition.updateMultiSourceLoanAddressFirst
   FunctionDefinition.finalUpdateMultiSourceLoanAddress
   FunctionDefinition.getMultiSourceLoanAddress
   FunctionDefinition.getTaxes
   FunctionDefinition.getPendingTaxes
   FunctionDefinition.getPendingTaxesSetTime
   FunctionDefinition.updateTaxes
   FunctionDefinition.setTaxes
   FunctionDefinition._handleTax
   FunctionDefinition.fallback
   FunctionDefinition.receive

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.InputChecker
   UsingForDirective.MessageHashUtils
   VariableDeclaration.INITIAL_CHAIN_ID
   VariableDeclaration.INITIAL_DOMAIN_SEPARATOR
   VariableDeclaration.MAGICVALUE_1271
   VariableDeclaration._PRECISION
   VariableDeclaration.VERSION
   VariableDeclaration._minImprovementApr
   VariableDeclaration.name
   VariableDeclaration.getTotalLoansIssued
   VariableDeclaration._used
   VariableDeclaration.isOfferCancelled
   VariableDeclaration.minOfferId
   VariableDeclaration.isRenegotiationOfferCancelled
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   EventDefinition.OfferCancelled
   EventDefinition.AllOffersCancelled
   EventDefinition.RenegotiationOfferCancelled
   EventDefinition.MinAprImprovementUpdated
   ErrorDefinition.CancelledOrExecutedOfferError
   ErrorDefinition.ExpiredOfferError
   ErrorDefinition.LowOfferIdError
   ErrorDefinition.LowRenegotiationOfferIdError
   ErrorDefinition.ZeroInterestError
   ErrorDefinition.InvalidSignatureError
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.MaxCapacityExceededError
   ErrorDefinition.InvalidLoanError
   ErrorDefinition.NotStrictlyImprovedError
   ErrorDefinition.InvalidAmountError
   FunctionDefinition.constructor
   FunctionDefinition.getMinImprovementApr
   FunctionDefinition.updateMinImprovementApr
   FunctionDefinition.getCurrencyManager
   FunctionDefinition.getCollectionManager
   FunctionDefinition.cancelOffer
   FunctionDefinition.cancelAllOffers
   FunctionDefinition.cancelRenegotiationOffer
   FunctionDefinition.getUsedCapacity
   FunctionDefinition.DOMAIN_SEPARATOR
   FunctionDefinition._getAndSetNewLoanId
   FunctionDefinition._computeDomainSeparator
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   UsingForDirective.InputChecker
   UsingForDirective.MessageHashUtils
   VariableDeclaration.INITIAL_CHAIN_ID
   VariableDeclaration.INITIAL_DOMAIN_SEPARATOR
   VariableDeclaration.MAGICVALUE_1271
   VariableDeclaration._PRECISION
   VariableDeclaration.VERSION
   VariableDeclaration._minImprovementApr
   VariableDeclaration.name
   VariableDeclaration.getTotalLoansIssued
   VariableDeclaration._used
   VariableDeclaration.isOfferCancelled
   VariableDeclaration.minOfferId
   VariableDeclaration.isRenegotiationOfferCancelled
   VariableDeclaration._currencyManager
   VariableDeclaration._collectionManager
   ErrorDefinition.CancelledOrExecutedOfferError
   ErrorDefinition.ExpiredOfferError
   ErrorDefinition.LowOfferIdError
   ErrorDefinition.LowRenegotiationOfferIdError
   ErrorDefinition.ZeroInterestError
   ErrorDefinition.InvalidSignatureError
   ErrorDefinition.CurrencyNotWhitelistedError
   ErrorDefinition.CollectionNotWhitelistedError
   ErrorDefinition.MaxCapacityExceededError
   ErrorDefinition.InvalidLoanError
   ErrorDefinition.NotStrictlyImprovedError
   ErrorDefinition.InvalidAmountError
   EventDefinition.OfferCancelled
   EventDefinition.AllOffersCancelled
   EventDefinition.RenegotiationOfferCancelled
   EventDefinition.MinAprImprovementUpdated
   FunctionDefinition.constructor
   FunctionDefinition.getMinImprovementApr
   FunctionDefinition.updateMinImprovementApr
   FunctionDefinition.getCurrencyManager
   FunctionDefinition.getCollectionManager
   FunctionDefinition.cancelOffer
   FunctionDefinition.cancelAllOffers
   FunctionDefinition.cancelRenegotiationOffer
   FunctionDefinition.getUsedCapacity
   FunctionDefinition.DOMAIN_SEPARATOR
   FunctionDefinition._getAndSetNewLoanId
   FunctionDefinition._computeDomainSeparator

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

1: 
   Current order:
   UsingForDirective.InputChecker
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.UPDATE_WAITING_TIME
   VariableDeclaration.getParameterSetter
   VariableDeclaration._acceptedCallers
   VariableDeclaration._isLoanContract
   VariableDeclaration.getOfferHandler
   EventDefinition.CallersAdded
   ErrorDefinition.CallerNotAccepted
   ErrorDefinition.InvalidCallerError
   FunctionDefinition.constructor
   FunctionDefinition.updateOfferHandler
   FunctionDefinition.addCallers
   FunctionDefinition.isCallerAccepted
   FunctionDefinition.validateOffer
   FunctionDefinition.loanRepayment
   FunctionDefinition.loanLiquidation
   FunctionDefinition.afterCallerAdded
   
   Suggested order:
   UsingForDirective.InputChecker
   UsingForDirective.EnumerableSet.AddressSet
   VariableDeclaration.UPDATE_WAITING_TIME
   VariableDeclaration.getParameterSetter
   VariableDeclaration._acceptedCallers
   VariableDeclaration._isLoanContract
   VariableDeclaration.getOfferHandler
   ErrorDefinition.CallerNotAccepted
   ErrorDefinition.InvalidCallerError
   EventDefinition.CallersAdded
   FunctionDefinition.constructor
   FunctionDefinition.updateOfferHandler
   FunctionDefinition.addCallers
   FunctionDefinition.isCallerAccepted
   FunctionDefinition.validateOffer
   FunctionDefinition.loanRepayment
   FunctionDefinition.loanLiquidation
   FunctionDefinition.afterCallerAdded

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

1: 
   Current order:
   UsingForDirective.InputChecker
   ErrorDefinition.LoanManagerSetError
   EventDefinition.RequestCallersAdded
   EventDefinition.ProposedOfferHandlerSet
   EventDefinition.OfferHandlerSet
   VariableDeclaration.UPDATE_WAITING_TIME
   VariableDeclaration.getOfferHandler
   VariableDeclaration.getProposedOfferHandler
   VariableDeclaration.getProposedOfferHandlerSetTime
   VariableDeclaration.getProposedAcceptedCallers
   VariableDeclaration.getProposedAcceptedCallersSetTime
   VariableDeclaration.getLoanManager
   FunctionDefinition.constructor
   FunctionDefinition.setLoanManager
   FunctionDefinition.setOfferHandler
   FunctionDefinition.confirmOfferHandler
   FunctionDefinition.requestAddCallers
   FunctionDefinition.addCallers
   
   Suggested order:
   UsingForDirective.InputChecker
   VariableDeclaration.UPDATE_WAITING_TIME
   VariableDeclaration.getOfferHandler
   VariableDeclaration.getProposedOfferHandler
   VariableDeclaration.getProposedOfferHandlerSetTime
   VariableDeclaration.getProposedAcceptedCallers
   VariableDeclaration.getProposedAcceptedCallersSetTime
   VariableDeclaration.getLoanManager
   ErrorDefinition.LoanManagerSetError
   EventDefinition.RequestCallersAdded
   EventDefinition.ProposedOfferHandlerSet
   EventDefinition.OfferHandlerSet
   FunctionDefinition.constructor
   FunctionDefinition.setLoanManager
   FunctionDefinition.setOfferHandler
   FunctionDefinition.confirmOfferHandler
   FunctionDefinition.requestAddCallers
   FunctionDefinition.addCallers

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.getPool
   VariableDeclaration._RAY
   VariableDeclaration._BPS
   VariableDeclaration._PRINCIPAL_PRECISION
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._aavePool
   VariableDeclaration._usdc
   VariableDeclaration._aToken
   VariableDeclaration.getRewardsController
   VariableDeclaration.getRewardsReceiver
   EventDefinition.RewardsControllerSet
   EventDefinition.RewardsReceiverSet
   ErrorDefinition.InvalidPoolError
   ErrorDefinition.InvalidCallerError
   ErrorDefinition.InvalidAprError
   FunctionDefinition.constructor
   FunctionDefinition.setRewardsController
   FunctionDefinition.setRewardsReceiver
   FunctionDefinition.getBaseApr
   FunctionDefinition.getBaseAprWithUpdate
   FunctionDefinition.getAssetsAllocated
   FunctionDefinition.reallocate
   FunctionDefinition.transferAll
   FunctionDefinition.claimRewards
   FunctionDefinition._onlyPool
   FunctionDefinition._getBaseApr
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.getPool
   VariableDeclaration._RAY
   VariableDeclaration._BPS
   VariableDeclaration._PRINCIPAL_PRECISION
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._aavePool
   VariableDeclaration._usdc
   VariableDeclaration._aToken
   VariableDeclaration.getRewardsController
   VariableDeclaration.getRewardsReceiver
   ErrorDefinition.InvalidPoolError
   ErrorDefinition.InvalidCallerError
   ErrorDefinition.InvalidAprError
   EventDefinition.RewardsControllerSet
   EventDefinition.RewardsReceiverSet
   FunctionDefinition.constructor
   FunctionDefinition.setRewardsController
   FunctionDefinition.setRewardsReceiver
   FunctionDefinition.getBaseApr
   FunctionDefinition.getBaseAprWithUpdate
   FunctionDefinition.getAssetsAllocated
   FunctionDefinition.reallocate
   FunctionDefinition.transferAll
   FunctionDefinition.claimRewards
   FunctionDefinition._onlyPool
   FunctionDefinition._getBaseApr

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

1: 
   Current order:
   UsingForDirective.Math
   UsingForDirective.ERC20
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.decimalsOffset
   EventDefinition.Deposit
   EventDefinition.Withdraw
   VariableDeclaration.asset
   FunctionDefinition.constructor
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.totalAssets
   FunctionDefinition.convertToShares
   FunctionDefinition.convertToAssets
   FunctionDefinition.previewDeposit
   FunctionDefinition.previewMint
   FunctionDefinition.previewWithdraw
   FunctionDefinition.previewRedeem
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.maxDeposit
   FunctionDefinition.maxMint
   FunctionDefinition.maxWithdraw
   FunctionDefinition.maxRedeem
   FunctionDefinition.beforeWithdraw
   FunctionDefinition.afterDeposit
   
   Suggested order:
   UsingForDirective.Math
   UsingForDirective.ERC20
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.decimalsOffset
   VariableDeclaration.asset
   EventDefinition.Deposit
   EventDefinition.Withdraw
   FunctionDefinition.constructor
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.totalAssets
   FunctionDefinition.convertToShares
   FunctionDefinition.convertToAssets
   FunctionDefinition.previewDeposit
   FunctionDefinition.previewMint
   FunctionDefinition.previewWithdraw
   FunctionDefinition.previewRedeem
   FunctionDefinition._convertToShares
   FunctionDefinition._convertToAssets
   FunctionDefinition.maxDeposit
   FunctionDefinition.maxMint
   FunctionDefinition.maxWithdraw
   FunctionDefinition.maxRedeem
   FunctionDefinition.beforeWithdraw
   FunctionDefinition.afterDeposit

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/FeeManager.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.WAIT_TIME
   VariableDeclaration.PRECISION
   VariableDeclaration._fees
   VariableDeclaration._proposedFees
   VariableDeclaration._proposedFeesSetTime
   EventDefinition.ProposedFeesSet
   EventDefinition.ProposedFeesConfirmed
   ErrorDefinition.InvalidFeesError
   FunctionDefinition.constructor
   FunctionDefinition.getFees
   FunctionDefinition.setProposedFees
   FunctionDefinition.confirmFees
   FunctionDefinition.getProposedFees
   FunctionDefinition.getProposedFeesSetTime
   FunctionDefinition.processFees
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.WAIT_TIME
   VariableDeclaration.PRECISION
   VariableDeclaration._fees
   VariableDeclaration._proposedFees
   VariableDeclaration._proposedFeesSetTime
   ErrorDefinition.InvalidFeesError
   EventDefinition.ProposedFeesSet
   EventDefinition.ProposedFeesConfirmed
   FunctionDefinition.constructor
   FunctionDefinition.getFees
   FunctionDefinition.setProposedFees
   FunctionDefinition.confirmFees
   FunctionDefinition.getProposedFees
   FunctionDefinition.getProposedFeesSetTime
   FunctionDefinition.processFees

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   StructDefinition.LidoData
   VariableDeclaration._BPS
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._PRINCIPAL_PRECISION
   VariableDeclaration._curvePool
   VariableDeclaration._weth
   VariableDeclaration._lido
   VariableDeclaration.getPool
   VariableDeclaration.getLidoUpdateTolerance
   VariableDeclaration.getMaxSlippage
   VariableDeclaration.getLidoData
   EventDefinition.MaxSlippageSet
   EventDefinition.LidoValuesUpdated
   ErrorDefinition.InvalidPoolError
   ErrorDefinition.InvalidCallerError
   ErrorDefinition.InvalidAprError
   FunctionDefinition.constructor
   FunctionDefinition.setMaxSlippage
   FunctionDefinition.getBaseApr
   FunctionDefinition.getBaseAprWithUpdate
   FunctionDefinition.updateLidoValues
   FunctionDefinition.getAssetsAllocated
   FunctionDefinition.reallocate
   FunctionDefinition.transferAll
   FunctionDefinition._currentShareRate
   FunctionDefinition._onlyPool
   FunctionDefinition._exchangeAndSendWeth
   FunctionDefinition._updateLidoValues
   FunctionDefinition.receive
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration._BPS
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._PRINCIPAL_PRECISION
   VariableDeclaration._curvePool
   VariableDeclaration._weth
   VariableDeclaration._lido
   VariableDeclaration.getPool
   VariableDeclaration.getLidoUpdateTolerance
   VariableDeclaration.getMaxSlippage
   VariableDeclaration.getLidoData
   StructDefinition.LidoData
   ErrorDefinition.InvalidPoolError
   ErrorDefinition.InvalidCallerError
   ErrorDefinition.InvalidAprError
   EventDefinition.MaxSlippageSet
   EventDefinition.LidoValuesUpdated
   FunctionDefinition.constructor
   FunctionDefinition.setMaxSlippage
   FunctionDefinition.getBaseApr
   FunctionDefinition.getBaseAprWithUpdate
   FunctionDefinition.updateLidoValues
   FunctionDefinition.getAssetsAllocated
   FunctionDefinition.reallocate
   FunctionDefinition.transferAll
   FunctionDefinition._currentShareRate
   FunctionDefinition._onlyPool
   FunctionDefinition._exchangeAndSendWeth
   FunctionDefinition._updateLidoValues
   FunctionDefinition.receive

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

1: 
   Current order:
   FunctionDefinition.constructor
   VariableDeclaration._data
   FunctionDefinition.getData
   FunctionDefinition.setData
   FunctionDefinition._getKey
   
   Suggested order:
   VariableDeclaration._data
   FunctionDefinition.constructor
   FunctionDefinition.getData
   FunctionDefinition.setData
   FunctionDefinition._getKey

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

1: 
   Current order:
   UsingForDirective.FixedPointMathLib
   StructDefinition.PrincipalFactorsValidationData
   StructDefinition.AprPremium
   StructDefinition.PrincipalFactors
   StructDefinition.AprFactors
   StructDefinition.MappingKey
   VariableDeclaration.PRECISION
   VariableDeclaration.TOLERANCE_FLOOR
   VariableDeclaration.TOLERANCE_HISTORICAL_FLOOR
   VariableDeclaration.MIN_WAIT_TIME_UPDATE_FACTOR
   VariableDeclaration.getMaxDuration
   VariableDeclaration.getAprUpdateTolerance
   VariableDeclaration.getOracle
   VariableDeclaration.getProposedOracle
   VariableDeclaration.getProposedOracleSetTs
   VariableDeclaration.getAprPremium
   VariableDeclaration.getAprFactors
   VariableDeclaration.getProposedAprFactors
   VariableDeclaration.getTotalUpdatesPending
   VariableDeclaration.getProposedAprFactorsSetTs
   VariableDeclaration._oracleFloorKey
   VariableDeclaration._oracleHistoricalFloorKey
   VariableDeclaration.getProposedCollectionFactors
   VariableDeclaration._principalFactors
   VariableDeclaration.getProposedCollectionFactorsSetTs
   VariableDeclaration.getPool
   EventDefinition.ProposedCollectionFactorsSet
   EventDefinition.CollectionFactorsSet
   EventDefinition.AprPremiumSet
   EventDefinition.ProposedOracleSet
   EventDefinition.OracleSet
   EventDefinition.ProposedAprFactorsSet
   EventDefinition.AprFactorsSet
   EventDefinition.PoolSet
   ErrorDefinition.InvalidInputLengthError
   ErrorDefinition.OutdatedValueError
   ErrorDefinition.PoolAlreadySetError
   FunctionDefinition.constructor
   FunctionDefinition.setPool
   FunctionDefinition.setOracle
   FunctionDefinition.confirmOracle
   FunctionDefinition.setAprFactors
   FunctionDefinition.confirmAprFactors
   FunctionDefinition.setAprPremium
   FunctionDefinition.calculateAprPremium
   FunctionDefinition.getPrincipalFactors
   FunctionDefinition.getCollectionFactors
   FunctionDefinition.setCollectionFactors
   FunctionDefinition.confirmCollectionFactors
   FunctionDefinition.validateOffer
   FunctionDefinition._getFactors
   FunctionDefinition._hashKey
   FunctionDefinition._calculateAprPremium
   FunctionDefinition._isZeroAddress
   
   Suggested order:
   UsingForDirective.FixedPointMathLib
   VariableDeclaration.PRECISION
   VariableDeclaration.TOLERANCE_FLOOR
   VariableDeclaration.TOLERANCE_HISTORICAL_FLOOR
   VariableDeclaration.MIN_WAIT_TIME_UPDATE_FACTOR
   VariableDeclaration.getMaxDuration
   VariableDeclaration.getAprUpdateTolerance
   VariableDeclaration.getOracle
   VariableDeclaration.getProposedOracle
   VariableDeclaration.getProposedOracleSetTs
   VariableDeclaration.getAprPremium
   VariableDeclaration.getAprFactors
   VariableDeclaration.getProposedAprFactors
   VariableDeclaration.getTotalUpdatesPending
   VariableDeclaration.getProposedAprFactorsSetTs
   VariableDeclaration._oracleFloorKey
   VariableDeclaration._oracleHistoricalFloorKey
   VariableDeclaration.getProposedCollectionFactors
   VariableDeclaration._principalFactors
   VariableDeclaration.getProposedCollectionFactorsSetTs
   VariableDeclaration.getPool
   StructDefinition.PrincipalFactorsValidationData
   StructDefinition.AprPremium
   StructDefinition.PrincipalFactors
   StructDefinition.AprFactors
   StructDefinition.MappingKey
   ErrorDefinition.InvalidInputLengthError
   ErrorDefinition.OutdatedValueError
   ErrorDefinition.PoolAlreadySetError
   EventDefinition.ProposedCollectionFactorsSet
   EventDefinition.CollectionFactorsSet
   EventDefinition.AprPremiumSet
   EventDefinition.ProposedOracleSet
   EventDefinition.OracleSet
   EventDefinition.ProposedAprFactorsSet
   EventDefinition.AprFactorsSet
   EventDefinition.PoolSet
   FunctionDefinition.constructor
   FunctionDefinition.setPool
   FunctionDefinition.setOracle
   FunctionDefinition.confirmOracle
   FunctionDefinition.setAprFactors
   FunctionDefinition.confirmAprFactors
   FunctionDefinition.setAprPremium
   FunctionDefinition.calculateAprPremium
   FunctionDefinition.getPrincipalFactors
   FunctionDefinition.getCollectionFactors
   FunctionDefinition.setCollectionFactors
   FunctionDefinition.confirmCollectionFactors
   FunctionDefinition.validateOffer
   FunctionDefinition._getFactors
   FunctionDefinition._hashKey
   FunctionDefinition._calculateAprPremium
   FunctionDefinition._isZeroAddress

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

1: 
   Current order:
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.FixedPointMathLib
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   VariableDeclaration.PRINCIPAL_PRECISION
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._BPS
   VariableDeclaration.getCollectedFees
   StructDefinition.OutstandingValues
   StructDefinition.QueueAccounting
   VariableDeclaration._LOAN_BUFFER_TIME
   VariableDeclaration.getFeeManager
   VariableDeclaration.getMaxTotalWithdrawalQueues
   VariableDeclaration.getMinTimeBetweenWithdrawalQueues
   VariableDeclaration.getProposedBaseInterestAllocator
   VariableDeclaration.getBaseInterestAllocator
   VariableDeclaration.getProposedBaseInterestAllocatorSetTime
   VariableDeclaration.isActive
   VariableDeclaration.getOptimalIdleRange
   VariableDeclaration.getLastLoanId
   VariableDeclaration.getTotalReceived
   VariableDeclaration.getAvailableToWithdraw
   VariableDeclaration._deployedQueues
   VariableDeclaration._outstandingValues
   VariableDeclaration._pendingQueueIndex
   VariableDeclaration._queueOutstandingValues
   VariableDeclaration._queueAccounting
   ErrorDefinition.PoolStatusError
   ErrorDefinition.InsufficientAssetsError
   ErrorDefinition.AllocationAlreadyOptimalError
   ErrorDefinition.NoSharesPendingWithdrawalError
   EventDefinition.PendingBaseInterestAllocatorSet
   EventDefinition.BaseInterestAllocatorSet
   EventDefinition.OptimalIdleRangeSet
   EventDefinition.QueueClaimed
   EventDefinition.Reallocated
   EventDefinition.QueueDeployed
   FunctionDefinition.constructor
   FunctionDefinition.pausePool
   FunctionDefinition.setOptimalIdleRange
   FunctionDefinition.setBaseInterestAllocator
   FunctionDefinition.confirmBaseInterestAllocator
   FunctionDefinition.collectFees
   FunctionDefinition.afterCallerAdded
   FunctionDefinition.totalAssets
   FunctionDefinition.getOutstandingValues
   FunctionDefinition.getDeployedQueue
   FunctionDefinition.getOutstandingValuesForQueue
   FunctionDefinition.getPendingQueueIndex
   FunctionDefinition.getAccountingValuesForQueue
   FunctionDefinition.deployWithdrawalQueue
   FunctionDefinition.validateOffer
   FunctionDefinition.reallocate
   FunctionDefinition.loanRepayment
   FunctionDefinition.loanLiquidation
   FunctionDefinition.getUndeployedAssets
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.queueClaimAll
   FunctionDefinition._burn
   FunctionDefinition._getTotalOutstandingValue
   FunctionDefinition._getOutstandingValue
   FunctionDefinition._getNewLoanAccounting
   FunctionDefinition._loanTermination
   FunctionDefinition._preDeposit
   FunctionDefinition._getUndeployedAssets
   FunctionDefinition._reallocate
   FunctionDefinition._reallocateOnWithdrawal
   FunctionDefinition._netApr
   FunctionDefinition._deployQueue
   FunctionDefinition._updateLoanLastIds
   FunctionDefinition._updatePendingWithdrawalWithQueue
   FunctionDefinition._queueClaimAll
   FunctionDefinition._outstandingApr
   FunctionDefinition._updateOutstandingValuesOnTermination
   FunctionDefinition._withdraw
   FunctionDefinition._isZeroAddress
   
   Suggested order:
   UsingForDirective.EnumerableSet.AddressSet
   UsingForDirective.FixedPointMathLib
   UsingForDirective.FixedPointMathLib
   UsingForDirective.Interest
   UsingForDirective.InputChecker
   UsingForDirective.ERC20
   VariableDeclaration.PRINCIPAL_PRECISION
   VariableDeclaration._SECONDS_PER_YEAR
   VariableDeclaration._BPS
   VariableDeclaration.getCollectedFees
   VariableDeclaration._LOAN_BUFFER_TIME
   VariableDeclaration.getFeeManager
   VariableDeclaration.getMaxTotalWithdrawalQueues
   VariableDeclaration.getMinTimeBetweenWithdrawalQueues
   VariableDeclaration.getProposedBaseInterestAllocator
   VariableDeclaration.getBaseInterestAllocator
   VariableDeclaration.getProposedBaseInterestAllocatorSetTime
   VariableDeclaration.isActive
   VariableDeclaration.getOptimalIdleRange
   VariableDeclaration.getLastLoanId
   VariableDeclaration.getTotalReceived
   VariableDeclaration.getAvailableToWithdraw
   VariableDeclaration._deployedQueues
   VariableDeclaration._outstandingValues
   VariableDeclaration._pendingQueueIndex
   VariableDeclaration._queueOutstandingValues
   VariableDeclaration._queueAccounting
   StructDefinition.OutstandingValues
   StructDefinition.QueueAccounting
   ErrorDefinition.PoolStatusError
   ErrorDefinition.InsufficientAssetsError
   ErrorDefinition.AllocationAlreadyOptimalError
   ErrorDefinition.NoSharesPendingWithdrawalError
   EventDefinition.PendingBaseInterestAllocatorSet
   EventDefinition.BaseInterestAllocatorSet
   EventDefinition.OptimalIdleRangeSet
   EventDefinition.QueueClaimed
   EventDefinition.Reallocated
   EventDefinition.QueueDeployed
   FunctionDefinition.constructor
   FunctionDefinition.pausePool
   FunctionDefinition.setOptimalIdleRange
   FunctionDefinition.setBaseInterestAllocator
   FunctionDefinition.confirmBaseInterestAllocator
   FunctionDefinition.collectFees
   FunctionDefinition.afterCallerAdded
   FunctionDefinition.totalAssets
   FunctionDefinition.getOutstandingValues
   FunctionDefinition.getDeployedQueue
   FunctionDefinition.getOutstandingValuesForQueue
   FunctionDefinition.getPendingQueueIndex
   FunctionDefinition.getAccountingValuesForQueue
   FunctionDefinition.deployWithdrawalQueue
   FunctionDefinition.validateOffer
   FunctionDefinition.reallocate
   FunctionDefinition.loanRepayment
   FunctionDefinition.loanLiquidation
   FunctionDefinition.getUndeployedAssets
   FunctionDefinition.withdraw
   FunctionDefinition.redeem
   FunctionDefinition.deposit
   FunctionDefinition.mint
   FunctionDefinition.queueClaimAll
   FunctionDefinition._burn
   FunctionDefinition._getTotalOutstandingValue
   FunctionDefinition._getOutstandingValue
   FunctionDefinition._getNewLoanAccounting
   FunctionDefinition._loanTermination
   FunctionDefinition._preDeposit
   FunctionDefinition._getUndeployedAssets
   FunctionDefinition._reallocate
   FunctionDefinition._reallocateOnWithdrawal
   FunctionDefinition._netApr
   FunctionDefinition._deployQueue
   FunctionDefinition._updateLoanLastIds
   FunctionDefinition._updatePendingWithdrawalWithQueue
   FunctionDefinition._queueClaimAll
   FunctionDefinition._outstandingApr
   FunctionDefinition._updateOutstandingValuesOnTermination
   FunctionDefinition._withdraw
   FunctionDefinition._isZeroAddress

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

1: 
   Current order:
   UsingForDirective.ERC20
   VariableDeclaration._NAME
   VariableDeclaration._SYMBOL
   VariableDeclaration._BASE_URI
   VariableDeclaration.getPool
   VariableDeclaration.getTotalShares
   VariableDeclaration.getNextTokenId
   VariableDeclaration.getShares
   VariableDeclaration.getWithdrawn
   VariableDeclaration.getUnlockTime
   VariableDeclaration._asset
   VariableDeclaration._totalWithdrawn
   EventDefinition.WithdrawalPositionMinted
   EventDefinition.Withdrawn
   EventDefinition.WithdrawalLocked
   ErrorDefinition.PoolOnlyCallableError
   ErrorDefinition.NotApprovedOrOwnerError
   ErrorDefinition.WithdrawalsLockedError
   ErrorDefinition.CanOnlyExtendWithdrawalError
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.getAvailable
   FunctionDefinition.lockWithdrawals
   FunctionDefinition.tokenURI
   FunctionDefinition._getAvailable
   
   Suggested order:
   UsingForDirective.ERC20
   VariableDeclaration._NAME
   VariableDeclaration._SYMBOL
   VariableDeclaration._BASE_URI
   VariableDeclaration.getPool
   VariableDeclaration.getTotalShares
   VariableDeclaration.getNextTokenId
   VariableDeclaration.getShares
   VariableDeclaration.getWithdrawn
   VariableDeclaration.getUnlockTime
   VariableDeclaration._asset
   VariableDeclaration._totalWithdrawn
   ErrorDefinition.PoolOnlyCallableError
   ErrorDefinition.NotApprovedOrOwnerError
   ErrorDefinition.WithdrawalsLockedError
   ErrorDefinition.CanOnlyExtendWithdrawalError
   EventDefinition.WithdrawalPositionMinted
   EventDefinition.Withdrawn
   EventDefinition.WithdrawalLocked
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.withdraw
   FunctionDefinition.getAvailable
   FunctionDefinition.lockWithdrawals
   FunctionDefinition.tokenURI
   FunctionDefinition._getAvailable

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

1: 
   Current order:
   EventDefinition.TransferOwnerRequested
   ErrorDefinition.TooSoonError
   ErrorDefinition.InvalidInputError
   VariableDeclaration.MIN_WAIT_TIME
   VariableDeclaration.pendingOwner
   VariableDeclaration.pendingOwnerTime
   FunctionDefinition.constructor
   FunctionDefinition.requestTransferOwner
   FunctionDefinition.transferOwnership
   
   Suggested order:
   VariableDeclaration.MIN_WAIT_TIME
   VariableDeclaration.pendingOwner
   VariableDeclaration.pendingOwnerTime
   ErrorDefinition.TooSoonError
   ErrorDefinition.InvalidInputError
   EventDefinition.TransferOwnerRequested
   FunctionDefinition.constructor
   FunctionDefinition.requestTransferOwner
   FunctionDefinition.transferOwnership

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

1: 
   Current order:
   UsingForDirective.InputChecker
   StructDefinition.ProtocolFee
   VariableDeclaration.FEE_UPDATE_NOTICE
   VariableDeclaration._protocolFee
   VariableDeclaration._pendingProtocolFee
   VariableDeclaration._pendingProtocolFeeSetTime
   EventDefinition.ProtocolFeeUpdated
   EventDefinition.ProtocolFeePendingUpdate
   ErrorDefinition.TooEarlyError
   FunctionDefinition.constructor
   FunctionDefinition.getProtocolFee
   FunctionDefinition.getPendingProtocolFee
   FunctionDefinition.getPendingProtocolFeeSetTime
   FunctionDefinition.updateProtocolFee
   FunctionDefinition.setProtocolFee
   
   Suggested order:
   UsingForDirective.InputChecker
   VariableDeclaration.FEE_UPDATE_NOTICE
   VariableDeclaration._protocolFee
   VariableDeclaration._pendingProtocolFee
   VariableDeclaration._pendingProtocolFeeSetTime
   StructDefinition.ProtocolFee
   ErrorDefinition.TooEarlyError
   EventDefinition.ProtocolFeeUpdated
   EventDefinition.ProtocolFeePendingUpdate
   FunctionDefinition.constructor
   FunctionDefinition.getProtocolFee
   FunctionDefinition.getPendingProtocolFee
   FunctionDefinition.getPendingProtocolFeeSetTime
   FunctionDefinition.updateProtocolFee
   FunctionDefinition.setProtocolFee

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-26"></a>[NC-26] Use Underscores for Number Literals (add an underscore every 3 digits)

*Instances (12)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

42:     uint256 internal constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

24:     uint256 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

29:     uint256 private constant _PRECISION = 10000;

30:     uint256 private constant _MAX_TAX = 5000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

35:     uint256 internal constant _PRECISION = 10000;

40:     uint256 internal _minImprovementApr = 1000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

23:     uint256 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

27:     uint256 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

45:     uint256 private constant _SECONDS_PER_YEAR = 31536000;

48:     uint16 private constant _BPS = 10000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/Interest.sol

11:     uint256 private constant _PRECISION = 10000;

13:     uint256 private constant _SECONDS_PER_YEAR = 31536000;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

### <a name="NC-27"></a>[NC-27] Internal and private variables and functions names should begin with an underscore

According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (22)*:

```solidity
File: src/lib/InputChecker.sol

10:     function checkNotZero(address _address) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

54:     function handleAfterPrincipalTransferCallback(

73:     function handleAfterNFTTransferCallback(

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

109:     function afterCallerAdded(address _caller) internal virtual;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/pools/ERC4626.sol

180:     function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

182:     function afterDeposit(uint256 assets, uint256 shares) internal virtual {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

98:     mapping(bytes32 key => PrincipalFactors factors) getProposedCollectionFactors;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

230:     function afterCallerAdded(address _caller) internal override {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/BytesLib.sol

12:     function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {

72:     function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

84:     function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/Hash.sol

39:     function hash(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (bytes32) {

69:     function hash(IMultiSourceLoan.ExecutionData memory _executionData) internal pure returns (bytes32) {

93:     function hash(IMultiSourceLoan.SignableRepaymentData memory _repaymentData) internal pure returns (bytes32) {

104:     function hash(IMultiSourceLoan.Loan memory _loan) internal pure returns (bytes32) {

129:     function hash(IMultiSourceLoan.RenegotiationOffer memory _refinanceOffer) internal pure returns (bytes32) {

154:     function hash(IAuctionLoanLiquidator.Auction memory _auction) internal pure returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

```solidity
File: src/lib/utils/Interest.sol

15:     function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {

19:     function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {

23:     function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

15:     function validateTokenIdPackedList(uint256 _tokenId, uint64 _bytesPerTokenId, bytes memory _tokenIdList)

72:     function validateNFTBitVector(uint256 _tokenId, bytes memory _bitVector) internal pure {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

### <a name="NC-28"></a>[NC-28] Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (69)*:

```solidity
File: src/lib/AddressManager.sol

15:     event AddressAdded(address address_added);

17:     event AddressRemovedFromWhitelist(address address_removed);

19:     event AddressWhitelisted(address address_whitelisted);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

60:     event LoanContractAdded(address loan);

62:     event LoanContractRemoved(address loan);

64:     event LiquidationDistributorUpdated(address liquidationDistributor);

66:     event LoanLiquidationStarted(address collection, uint256 tokenId, Auction auction);

68:     event BidPlaced(

72:     event AuctionSettled(

83:     event TriggerFeeUpdated(uint256 triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

24:     event AuctionSettledWithBuyout(

28:     event TimeForMainLenderToBuyUpdated(uint256 timeForMainLenderToBuy);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

27:     event LiquidatorSet(address liquidator);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

32:     event MinBidLiquidationUpdated(uint256 newMinBid);

34:     event LoanSentToLiquidator(uint256 loanId, address liquidator);

36:     event LoanForeclosed(uint256 loanId);

38:     event LiquidationContractUpdated(address liquidator);

40:     event LiquidationAuctionDurationUpdated(uint256 newDuration);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

42:     event ERC721Deposited(uint256 vaultId, address collection, uint256 tokenId);

44:     event OldERC721Deposited(uint256 vaultId, address collection, uint256 tokenId);

46:     event OldERC721Withdrawn(uint256 vaultId, address collection, uint256 tokenId);

48:     event ERC20Deposited(uint256 vaultId, address token, uint256 amount);

50:     event ERC721Withdrawn(uint256 vaultId, address collection, uint256 tokenId);

52:     event ERC20Withdrawn(uint256 vaultId, address token, uint256 amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

20:     event WhitelistedCallbackContractAdded(address contractAdded);

21:     event WhitelistedCallbackContractRemoved(address contractRemoved);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

47:     event BNPLLoansStarted(uint256[] loanIds);

48:     event SellAndRepayExecuted(uint256[] loanIds);

49:     event MultiSourceLoanPendingUpdate(address newAddress);

50:     event MultiSourceLoanUpdated(address newAddress);

51:     event TaxesPendingUpdate(Taxes newTaxes);

52:     event TaxesUpdated(Taxes taxes);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

67:     event OfferCancelled(address lender, uint256 offerId);

69:     event AllOffersCancelled(address lender, uint256 minOfferId);

71:     event RenegotiationOfferCancelled(address lender, uint256 renegotiationId);

73:     event MinAprImprovementUpdated(uint256 _minimum);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

32:     event CallersAdded(ProposedCaller[] callers);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

14:     event RequestCallersAdded(ILoanManager.ProposedCaller[] callers);

15:     event ProposedOfferHandlerSet(address offerHandler);

16:     event OfferHandlerSet(address offerHandler);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

11:     event LoanManagerAdded(address loanManagerAdded);

12:     event LoanManagerRemoved(address loanManagerRemoved);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

34:     event RewardsControllerSet(address controller);

35:     event RewardsReceiverSet(address receiver);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

23:     event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/FeeManager.sol

22:     event ProposedFeesSet(Fees fees);

23:     event ProposedFeesConfirmed(Fees fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

40:     event MaxSlippageSet(uint256 maxSlippage);

41:     event LidoValuesUpdated(LidoData lidoData);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

109:     event ProposedCollectionFactorsSet(address[] collection, uint96[] duration, PrincipalFactors[] factor);

110:     event CollectionFactorsSet(address[] collection, uint96[] duration, bytes[], PrincipalFactors[] factor);

111:     event AprPremiumSet(uint256 aprPremium);

112:     event ProposedOracleSet(address proposedOracle);

113:     event OracleSet(address oracle);

114:     event ProposedAprFactorsSet(AprFactors aprFactors);

115:     event AprFactorsSet(AprFactors aprFactors);

116:     event PoolSet(address pool);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

115:     event PendingBaseInterestAllocatorSet(address newBaseInterestAllocator);

116:     event BaseInterestAllocatorSet(address newBaseInterestAllocator);

117:     event OptimalIdleRangeSet(OptimalIdleRange optimalIdleRange);

118:     event QueueClaimed(address queue, uint256 amount);

119:     event Reallocated(uint256 delta);

120:     event QueueDeployed(uint256 index, address queueAddress);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

42:     event WithdrawalPositionMinted(uint256 tokenId, address to, uint256 shares);

43:     event Withdrawn(address to, uint256 tokenId, uint256 available);

44:     event WithdrawalLocked(uint256 tokenId, uint256 unlockTime);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

10:     event TransferOwnerRequested(address newOwner);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

26:     event ProtocolFeeUpdated(ProtocolFee fee);

27:     event ProtocolFeePendingUpdate(ProtocolFee fee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="NC-29"></a>[NC-29] Constants should be defined rather than using magic numbers

*Instances (1)*:

```solidity
File: src/lib/utils/BytesLib.sol

56:                 mstore(0x40, and(add(mc, 31), not(31)))

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

### <a name="NC-30"></a>[NC-30] `public` functions not called by the contract should be declared `external` instead

*Instances (2)*:

```solidity
File: src/lib/loans/BaseLoan.sol

188:     function DOMAIN_SEPARATOR() public view returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

35:     function transferOwnership() public {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="NC-31"></a>[NC-31] Variables need not be initialized to zero

The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (30)*:

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

81:         for (uint256 i = 0; i < totalTranches;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

53:         uint256 totalPendingInterestOwed = 0;

57:         for (uint256 i = 0; i < totalTranches;) {

69:             for (uint256 i = 0; i < totalTranches;) {

86:             for (uint256 i = 0; i < totalTranches;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/Multicall.sol

14:         for (uint256 i = 0; i < totalCalls;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/Multicall.sol)

```solidity
File: src/lib/UserVault.sol

20:     uint256 private _nextId = 0;

113:         for (uint256 i = 0; i < totalCollections;) {

123:         for (uint256 i = 0; i < totalOldCollections;) {

130:         for (uint256 i = 0; i < totalTokens;) {

169:         for (uint256 i = 0; i < totalTokens;) {

195:         for (uint256 i = 0; i < totalTokens;) {

237:         for (uint256 i = 0; i < totalCollections;) {

258:         for (uint256 i = 0; i < totalCollections;) {

273:         for (uint256 i = 0; i < _tokens.length;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

134:         for (uint256 i = 0; i < total;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

61:         for (uint256 i = 0; i < totalCallers;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

110:         for (uint256 i = 0; i < totalCallers;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

571:         for (uint256 i = 0; i < _loan.tranche.length << 1;) { 

884:             for (uint256 i = 0; i < totalValidators;) {

905:         uint256 totalRepayment = 0;

906:         uint256 totalProtocolFee = 0;

914:             uint256 thisProtocolFee = 0;

979:         for (uint256 i = 0; i < totalOffers;) {

1054:         for (uint256 i = 0; i < newTrancheIndex;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/utils/Hash.sol

42:         for (uint256 i = 0; i < totalValidators;) {

72:         for (uint256 i = 0; i < totalOfferExecution;) {

132:         for (uint256 i = 0; i < totalIndexes;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

```solidity
File: src/lib/utils/Interest.sol

24:         uint256 owed = 0;

25:         for (uint256 i = 0; i < _loan.tranche.length;) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

## Low Issues

| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | `approve()`/`safeApprove()` may revert if the current approval is not zero | 9 |
| [L-2](#L-2) | Use of `tx.origin` is unsafe in almost every context | 14 |
| [L-3](#L-3) | Some tokens may revert when zero value transfers are made | 32 |
| [L-4](#L-4) | Missing checks for `address(0)` when assigning values to address state variables | 28 |
| [L-5](#L-5) | `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()` | 5 |
| [L-6](#L-6) | Use of `tx.origin` is unsafe in almost every context | 14 |
| [L-7](#L-7) | `decimals()` is not a part of the ERC-20 standard | 1 |
| [L-8](#L-8) | Deprecated approve() function | 5 |
| [L-9](#L-9) | Division by zero not prevented | 8 |
| [L-10](#L-10) | `domainSeparator()` isn't protected against replay attacks in case of a future chain split  | 6 |
| [L-11](#L-11) | Empty `receive()/payable fallback()` function does not authenticate requests | 3 |
| [L-12](#L-12) | External call recipient may consume all transaction gas | 16 |
| [L-13](#L-13) | Signature use at deadlines should be allowed | 11 |
| [L-14](#L-14) | Prevent accidentally burning tokens | 8 |
| [L-15](#L-15) | NFT ownership doesn't support hard forks | 2 |
| [L-16](#L-16) | Owner can renounce while system is paused | 1 |
| [L-17](#L-17) | Possible rounding issue | 2 |
| [L-18](#L-18) | Loss of precision | 4 |
| [L-19](#L-19) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 21 |
| [L-20](#L-20) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 1 |
| [L-21](#L-21) | Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting | 17 |
| [L-22](#L-22) | Unsafe ERC20 operation(s) | 28 |
| [L-23](#L-23) | Unspecific compiler version pragma | 1 |
| [L-24](#L-24) | A year is not always 365 days | 2 |

### <a name="L-1"></a>[L-1] `approve()`/`safeApprove()` may revert if the current approval is not zero

- Some tokens (like the *very popular* USDT) do not work when changing the allowance from an existing non-zero allowance value (it will revert if the current approval is not zero to protect against front-running changes of approvals). These tokens must first be approved for zero and then the actual allowance can be approved.
- Furthermore, OZ's implementation of safeApprove would throw an error if an approve is attempted from a non-zero value (`"SafeERC20: approve from non-zero to non-zero allowance"`)

Set the allowance to zero immediately before each of the existing allowance calls

*Instances (9)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

298:         asset.approve(address(_liquidationDistributor), proceeds);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

215:             collection.approve(executionInfo.module, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

60:         ERC20(__usdc).approve(__aavePool, type(uint256).max);

61:         ERC20(__aToken).approve(__aavePool, type(uint256).max);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

64:         ERC20(__lido).approve(__curvePool, type(uint256).max);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

166:         _asset.approve(address(_feeManager), type(uint256).max);

207:             asset.approve(cachedAllocator, 0);

209:         asset.approve(proposedAllocator, type(uint256).max);

231:         asset.approve(_caller, type(uint256).max);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-2"></a>[L-2] Use of `tx.origin` is unsafe in almost every context

According to [Vitalik Buterin](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof), contracts should *not* `assume that tx.origin will continue to be usable or meaningful`. An example of this is [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074#allowing-txorigin-as-signer-1) which explicitly mentions the intention to change its semantics when it's used with new op codes. There have also been calls to [remove](https://github.com/ethereum/solidity/issues/683) `tx.origin`, and there are [security issues](solidity.readthedocs.io/en/v0.4.24/security-considerations.html#tx-origin) associated with using it for authorization. For these reasons, it's best to completely avoid the feature.

*Instances (14)*:

```solidity
File: src/lib/AddressManager.sol

33:     constructor(address[] memory _original) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

120:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

33:     constructor(address _loanManagerRegistry) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

77:         Owned(tx.origin)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

71:     ) WithProtocolFee(tx.origin, _minWaitTime, __protocolFee) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

36:     constructor(address __offerHandler, uint256 _updateWaitingTime) TwoStepOwned(tx.origin, _updateWaitingTime) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

14:     constructor() Owned(tx.origin) {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

108:             tx.origin,

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

48:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

27:     constructor(Fees memory __fees) TwoStepOwned(tx.origin, WAIT_TIME) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

54:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

11:     constructor(uint256 _minWaitTime) TwoStepOwned(tx.origin, _minWaitTime) {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

130:     ) TwoStepOwned(tx.origin, _minWaitTime) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

143:         LoanManager(tx.origin, _offerHandlerSetter, _waitingTimeBetweenUpdates)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-3"></a>[L-3] Some tokens may revert when zero value transfers are made

Example: <https://github.com/d-xo/weird-erc20#revert-on-zero-value-transfers>.

In spite of the fact that EIP-20 [states](https://github.com/ethereum/EIPs/blob/46b9b698815abbfa628cd1097311deee77dd45c5/EIPS/eip-20.md?plain=1#L116) that zero-valued transfers must be accepted, some tokens, such as LEND will revert if this is attempted, which may cause transactions that involve other tokens (such as batch operations) to fully revert. Consider skipping the transfer if the amount is zero, which will also save gas.

*Instances (32)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

253:             token.safeTransfer(_auction.highestBidder, currentHighestBid);

257:         token.safeTransferFrom(newBidder, address(this), _bid);

296:         asset.safeTransfer(_auction.originator, triggerFee);

297:         asset.safeTransfer(msg.sender, triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

101:                 asset.safeTransferFrom(msg.sender, thisTranche.lender, owed);

122:         asset.safeTransferFrom(buyer, _auction.originator, totalOwed.mulDivDown(_auction.triggerFee, _BPS));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

114:         ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, total);

128:             ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _trancheOwed);

133:                 ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _proceedsLeft);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

314:         ERC20(_token).safeTransferFrom(_depositor, address(this), _amount);

358:         ERC20(_token).safeTransfer(msg.sender, amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

221:             asset.safeTransfer(_loan.borrower, balance);

310:             ERC20(principalAddress).safeTransferFrom(borrower, tranche.lender, taxCost - feeTax);

316:             ERC20(principalAddress).safeTransferFrom(borrower, protocolFee.recipient, totalFeeTax);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

194:                 ERC20(_loan.principalAddress).safeTransferFrom(

208:                 ERC20(_loan.principalAddress).safeTransferFrom(_renegotiationOffer.lender, _loan.borrower, netNewLender);

393:         ERC20(_loan.principalAddress).safeTransferFrom(

398:             ERC20(_loan.principalAddress).safeTransferFrom(

657:             asset.safeTransferFrom(_borrower, _tranche.lender, oldLenderDebt - _remainingNewLender);

662:                 asset.safeTransferFrom(_lender, _tranche.lender, oldLenderDebt);

713:             ERC20(_principalAddress).safeTransferFrom(_lender, _feeRecipient, _fee);

922:             asset.safeTransferFrom(loan.borrower, tranche.lender, repayment);

942:             asset.safeTransferFrom(loan.borrower, _protocolFee.recipient, totalProtocolFee);

1012:             ERC20(offer.principalAddress).safeTransferFrom(lender, _principalReceiver, amount - fee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

96:             ERC20(_usdc).transferFrom(pool, address(this), delta);

101:             ERC20(_usdc).transfer(pool, delta);

115:         ERC20(usdc).transfer(pool, total);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

51:         asset.safeTransferFrom(msg.sender, address(this), assets);

64:         asset.safeTransferFrom(msg.sender, address(this), assets);

88:         asset.safeTransfer(receiver, assets);

107:         asset.safeTransfer(receiver, assets);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

100:         _asset.safeTransfer(_to, available);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="L-4"></a>[L-4] Missing checks for `address(0)` when assigning values to address state variables

*Instances (28)*:

```solidity
File: src/lib/LiquidationHandler.sol

58:         _loanLiquidator = __loanLiquidator;

76:         _loanLiquidator = __loanLiquidator;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

234:         _pendingMultiSourceLoanAddress = _newAddress;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

42:         getParameterSetter = __offerHandlerSetter;

50:         getOfferHandler = _offerHandler;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

40:         getOfferHandler = __offerHandler;

55:         getLoanManager = __loanManager;

67:         getProposedOfferHandler = __offerHandler;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

116:         getDelegateRegistry = delegateRegistry;

117:         getFlashActionContract = flashActionContract;

544:         getFlashActionContract = _newFlashActionContract;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

52:         getPool = _pool;

53:         _aavePool = __aavePool;

54:         _usdc = __usdc;

55:         _aToken = __aToken;

57:         getRewardsController = _rewardsController;

58:         getRewardsReceiver = _rewardsReceiver;

65:         getRewardsController = _controller;

71:         getRewardsReceiver = _receiver;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

58:         getPool = _pool;

61:         _lido = __lido;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

131:         getOracle = _oracle;

145:         getPool = _pool;

153:         getProposedOracle = _oracle;

165:         getOracle = proposedOracle;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

145:         getFeeManager = _feeManager;

188:         getProposedBaseInterestAllocator = _newBaseInterestAllocator;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

28:         pendingOwner = _newOwner;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="L-5"></a>[L-5] `abi.encodePacked()` should not be used with dynamic types when passing the result to a hash function such as `keccak256()`

Use `abi.encode()` instead which will pad items to 32 bytes, which will [prevent hash collisions](https://docs.soliditylang.org/en/v0.8.13/abi-spec.html#non-standard-packed-mode) (e.g. `abi.encodePacked(0x123,0x456)` => `0x123456` => `abi.encodePacked(0x1,0x23456)`, but `abi.encode(0x123,0x456)` => `0x0...1230...456`). "Unless there is a compelling reason, `abi.encode` should be preferred". If there is only one argument to `abi.encodePacked()` it can often be cast to `bytes()` or `bytes32()` [instead](https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity#answer-82739).
If all arguments are strings and or bytes, `bytes.concat()` should be used instead

*Instances (5)*:

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

384:         return keccak256(abi.encodePacked(_collection, _duration, _extra));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/utils/Hash.sol

43:             encodedValidators = abi.encodePacked(encodedValidators, _hashValidator(_loanOffer.validators[i]));

74:                 abi.encodePacked(encodedOfferExecution, _hashOfferExecution(_executionData.offerExecution[i]));

108:             trancheHashes = abi.encodePacked(trancheHashes, _hashTranche(_loan.tranche[i]));

133:             encodedIndexes = abi.encodePacked(encodedIndexes, _refinanceOffer.trancheIndex[i]);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

### <a name="L-6"></a>[L-6] Use of `tx.origin` is unsafe in almost every context

According to [Vitalik Buterin](https://ethereum.stackexchange.com/questions/196/how-do-i-make-my-dapp-serenity-proof), contracts should *not* `assume that tx.origin will continue to be usable or meaningful`. An example of this is [EIP-3074](https://eips.ethereum.org/EIPS/eip-3074#allowing-txorigin-as-signer-1) which explicitly mentions the intention to change its semantics when it's used with new op codes. There have also been calls to [remove](https://github.com/ethereum/solidity/issues/683) `tx.origin`, and there are [security issues](solidity.readthedocs.io/en/v0.4.24/security-considerations.html#tx-origin) associated with using it for authorization. For these reasons, it's best to completely avoid the feature.

*Instances (14)*:

```solidity
File: src/lib/AddressManager.sol

33:     constructor(address[] memory _original) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

120:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

33:     constructor(address _loanManagerRegistry) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

77:         Owned(tx.origin)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

71:     ) WithProtocolFee(tx.origin, _minWaitTime, __protocolFee) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

36:     constructor(address __offerHandler, uint256 _updateWaitingTime) TwoStepOwned(tx.origin, _updateWaitingTime) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

14:     constructor() Owned(tx.origin) {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

108:             tx.origin,

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

48:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

27:     constructor(Fees memory __fees) TwoStepOwned(tx.origin, WAIT_TIME) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

54:     ) Owned(tx.origin) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

11:     constructor(uint256 _minWaitTime) TwoStepOwned(tx.origin, _minWaitTime) {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

130:     ) TwoStepOwned(tx.origin, _minWaitTime) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

143:         LoanManager(tx.origin, _offerHandlerSetter, _waitingTimeBetweenUpdates)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-7"></a>[L-7] `decimals()` is not a part of the ERC-20 standard

The `decimals()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (1)*:

```solidity
File: src/lib/pools/ERC4626.sol

36:         ERC20(_name, _symbol, _asset.decimals() + _decimalsOffset)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

### <a name="L-8"></a>[L-8] Deprecated approve() function

Due to the inheritance of ERC20's approve function, there's a vulnerability to the ERC20 approve and double spend front running attack. Briefly, an authorized spender could spend both allowances by front running an allowance-changing transaction. Consider implementing OpenZeppelin's `.safeApprove()` function to help mitigate this.

*Instances (5)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

298:         asset.approve(address(_liquidationDistributor), proceeds);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

215:             collection.approve(executionInfo.module, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/pools/Pool.sol

207:             asset.approve(cachedAllocator, 0);

209:         asset.approve(proposedAllocator, type(uint256).max);

231:         asset.approve(_caller, type(uint256).max);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-9"></a>[L-9] Division by zero not prevented

The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (8)*:

```solidity
File: src/lib/loans/MultiSourceLoan.sol

190:                 totalAnnualInterest / _loan.principalAmount,

896:         return _loanPrincipal / (_MAX_RATIO_TRANCHE_MIN_PRINCIPAL * getMaxTranches);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

137:         return currentLiquidityRate * _BPS / _RAY;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

82:                 _BPS * _SECONDS_PER_YEAR * (shareRate - lidoData.shareRate) / lidoData.shareRate

142:         return lido.getTotalPooledEther() * 1e27 / lido.getTotalShares();

164:             _BPS * _SECONDS_PER_YEAR * (shareRate - _lidoData.shareRate) / _lidoData.shareRate

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

752:         return __outstandingValues.sumApr / __outstandingValues.principalAmount;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

143:         return (getShares[_tokenId] * (_totalWithdrawn + _asset.balanceOf(address(this)))) / getTotalShares

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="L-10"></a>[L-10] `domainSeparator()` isn't protected against replay attacks in case of a future chain split

Severity: Low.
Description: See <https://eips.ethereum.org/EIPS/eip-2612#security-considerations>.
Remediation: Consider using the [implementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol#L77-L90) from OpenZeppelin, which recalculates the domain separator if the current `block.chainid` is not the cached chain ID.
Past occurrences of this issue:

- [Reality Cards Contest](https://github.com/code-423n4/2021-06-realitycards-findings/issues/166)
- [Swivel Contest](https://github.com/code-423n4/2021-09-swivel-findings/issues/98)
- [Malt Finance Contest](https://github.com/code-423n4/2021-11-malt-findings/issues/349)

*Instances (6)*:

```solidity
File: src/lib/loans/BaseLoan.sol

30:     bytes32 public immutable INITIAL_DOMAIN_SEPARATOR;

124:         INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();

188:     function DOMAIN_SEPARATOR() public view returns (bytes32) {

189:         return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : _computeDomainSeparator();

203:     function _computeDomainSeparator() private view returns (bytes32) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

1080:         bytes32 typedDataHash = DOMAIN_SEPARATOR().toTypedDataHash(_hash);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

### <a name="L-11"></a>[L-11] Empty `receive()/payable fallback()` function does not authenticate requests

If the intention is for the Ether to be used, the function should call another function, otherwise it should revert (e.g. require(msg.sender == address(weth))). Having no access control on the function means that someone may send Ether to the contract, and have no way to get anything back out, which is a loss of funds. If the concern is having to spend a small amount of gas to check the sender against an immutable address, the code should at least have a function to rescue unused Ether.

*Instances (3)*:

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

320:     fallback() external payable {}

322:     receive() external payable {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

173:     receive() external payable {}

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

### <a name="L-12"></a>[L-12] External call recipient may consume all transaction gas

There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (16)*:

```solidity
File: src/lib/UserVault.sol

379:         (bool sent,) = payable(msg.sender).call{value: amount}("");

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

119:             (bool success,) = payable(msg.sender).call{value: remainingBalance}("");

163:         (bool success,) = executionInfo.module.call{value: executionInfo.value}(executionInfo.data);

203:             (success,) = executionInfo.module.call(executionInfo.data);

211:             (success,) = executionInfo.module.call(executionInfo.data);

216:             (success,) = executionInfo.module.call(executionInfo.data);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManager.sol

63:             _acceptedCallers.add(caller.caller);

64:             _isLoanContract[caller.caller] = caller.isLoanContract;

66:             afterCallerAdded(caller.caller);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

113:                 proposedCallers[i].caller != caller.caller || proposedCallers[i].isLoanContract != caller.isLoanContract

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

147:         if (_hasCallback(executionData.callbackData)) {

148:             handleAfterPrincipalTransferCallback(loan, msg.sender, executionData.callbackData, totalFee);

432:         if (_hasCallback(_repaymentData.data.callbackData)) {

433:             handleAfterNFTTransferCallback(loan, msg.sender, _repaymentData.data.callbackData);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/utils/Hash.sol

88:                 keccak256(_executionData.callbackData)

98:                 keccak256(_repaymentData.callbackData),

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

### <a name="L-13"></a>[L-13] Signature use at deadlines should be allowed

According to [EIP-2612](https://github.com/ethereum/EIPs/blob/71dc97318013bf2ac572ab63fab530ac9ef419ca/EIPS/eip-2612.md?plain=1#L58), signatures used on exactly the deadline timestamp are supposed to be allowed. While the signature may or may not be used for the exact EIP-2612 use case (transfer approvals), for consistency's sake, all deadlines should follow this semantic. If the timestamp is an expiration rather than a deadline, consider whether it makes more sense to include the expiration timestamp as a valid timestamp, as is done for deadlines.

*Instances (11)*:

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

75:         if (timeLimit <= block.timestamp) {

154:         if (timeLimit > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

101:         if (expirationTime > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

76:         if (getProposedOfferHandlerSetTime + UPDATE_WAITING_TIME > block.timestamp) {

105:         if (getProposedAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

630:         if (unlockTime > block.timestamp) {

678:         if (_loan.startTime + _loan.duration <= block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/FeeManager.sol

48:         if (_proposedFeesSetTime + WAIT_TIME > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/Pool.sol

203:             if (getProposedBaseInterestAllocatorSetTime + UPDATE_WAITING_TIME > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

84:         if (unlockTime > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

37:         if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="L-14"></a>[L-14] Prevent accidentally burning tokens

Minting and burning tokens to address(0) prevention

*Instances (8)*:

```solidity
File: src/lib/UserVault.sol

90:         _mint(msg.sender, _vaultId);

366:         _burn(_vaultId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/pools/ERC4626.sol

53:         _mint(receiver, shares);

66:         _mint(receiver, shares);

84:         _burn(owner, shares);

103:         _burn(owner, shares);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/Pool.sol

786:         _burn(owner, shares);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

66:         _mint(_to, nextTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="L-15"></a>[L-15] NFT ownership doesn't support hard forks

To ensure clarity regarding the ownership of the NFT on a specific chain, it is recommended to add `require(block.chainid == 1, "Invalid Chain")` or the desired chain ID in the functions below.

Alternatively, consider including the chain ID in the URI itself. By doing so, any confusion regarding the chain responsible for owning the NFT will be eliminated.

*Instances (2)*:

```solidity
File: src/lib/UserVault.sol

282:     function tokenURI(uint256 _vaultId) public pure override returns (string memory) {
             return string.concat(_BASE_URI, Strings.toString(_vaultId));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

134:     function tokenURI(uint256 _id) public pure override returns (string memory) {
             return string.concat(_BASE_URI, Strings.toString(_id));

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="L-16"></a>[L-16] Owner can renounce while system is paused

The contract owner or single user with a role is not prevented from renouncing the role/ownership while the contract is paused, which would cause any user assets stored in the protocol, to be locked indefinitely.

*Instances (1)*:

```solidity
File: src/lib/pools/Pool.sol

170:     function pausePool() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-17"></a>[L-17] Possible rounding issue

Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator. Also, there is indication of multiplication and division without the use of parenthesis which could result in issues.

*Instances (2)*:

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

142:         return lido.getTotalPooledEther() * 1e27 / lido.getTotalShares();

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

143:         return (getShares[_tokenId] * (_totalWithdrawn + _asset.balanceOf(address(this)))) / getTotalShares

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="L-18"></a>[L-18] Loss of precision

Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*Instances (4)*:

```solidity
File: src/lib/loans/MultiSourceLoan.sol

896:         return _loanPrincipal / (_MAX_RATIO_TRANCHE_MIN_PRINCIPAL * getMaxTranches);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

137:         return currentLiquidityRate * _BPS / _RAY;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

83:                     / (block.timestamp - lidoData.lastTs)

165:                 / (block.timestamp - _lidoData.lastTs)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

### <a name="L-19"></a>[L-19] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`

The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (21)*:

```solidity
File: src/lib/AddressManager.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/InputChecker.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/InputChecker.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

```solidity
File: src/lib/utils/BytesLib.sol

9: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/BytesLib.sol)

```solidity
File: src/lib/utils/Hash.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Hash.sol)

```solidity
File: src/lib/utils/Interest.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/Interest.sol)

```solidity
File: src/lib/utils/ValidatorHelpers.sol

2: pragma solidity ^0.8.21;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/ValidatorHelpers.sol)

### <a name="L-20"></a>[L-20] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`

Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (1)*:

```solidity
File: src/lib/utils/TwoStepOwned.sol

35:     function transferOwnership() public {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

### <a name="L-21"></a>[L-21] Consider using OpenZeppelin's SafeCast library to prevent unexpected overflows when downcasting

Downcasting from `uint256`/`int256` in Solidity does not revert on overflow. This can result in undesired exploitation or bugs, since developers usually assume that overflows raise errors. [OpenZeppelin's SafeCast library](https://docs.openzeppelin.com/contracts/3.x/api/utils#SafeCast) restores this intuition by reverting the transaction when such an operation overflows. Using this library eliminates an entire class of bugs, so it's recommended to use it always. Some exceptions are acceptable like with the classic `uint256(uint160(address(variable)))`

*Instances (17)*:

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

62:         getLidoData = LidoData(uint96(block.timestamp), uint144(_currentShareRate()), uint16(_currentBaseAprBps));

167:         _lidoData.shareRate = uint144(shareRate);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

304:             oracle.getData(offerExecution.offer.nftCollateralAddress, uint64(duration), _oracleFloorKey);

306:             oracle.getData(offerExecution.offer.nftCollateralAddress, uint64(duration), _oracleHistoricalFloorKey);

352:             key = _hashKey(_collateralAddress, uint96(_duration), "");

362:                 key = _hashKey(_collateralAddress, uint96(_duration), validationData.data);

368:                 key = _hashKey(_collateralAddress, uint96(_duration), abi.encodePacked(root));

375:                 key = _hashKey(_collateralAddress, uint96(_duration), validationData.data);

395:         return uint128(

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

294:             uint128((totalSupplyCached - sharesPendingWithdrawal).mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached));

296:             uint128(sharesPendingWithdrawal.mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached)), poolFraction

321:                 uint128(thisQueueAccounting.netPoolFraction.mulDivDown(sharesPendingWithdrawal, totalSupplyCached));

539:             outstandingValues.sumApr += uint128(_apr * _principalAmount);

540:             outstandingValues.principalAmount += uint128(_principalAmount);

777:             __outstandingValues.accruedInterest = uint128(total - _interestEarned);

779:         __outstandingValues.sumApr -= uint128(_apr * _principalAmount);

780:         __outstandingValues.principalAmount -= uint128(_principalAmount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-22"></a>[L-22] Unsafe ERC20 operation(s)

*Instances (28)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

289:         ERC721(collateralAddress).transferFrom(address(this), _auction.highestBidder, tokenId);

298:         asset.approve(address(_liquidationDistributor), proceeds);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

124:         ERC721(_loan.nftCollateralAddress).transferFrom(address(this), buyer, _tokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

105:             ERC721(_loan.nftCollateralAddress).transferFrom(

113:             ERC721(_loan.nftCollateralAddress).transferFrom(address(this), liquidator, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

292:         ERC721(_collection).transferFrom(_depositor, address(this), _tokenId);

329:         ERC721(_collection).transferFrom(address(this), msg.sender, _tokenId);

342:         IOldERC721(_collection).transfer(msg.sender, _tokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

172:             _wrappedPunk.transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);

174:             ERC721(_loan.nftCollateralAddress).transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);

199:             _wrappedPunk.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);

214:             collection.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);

215:             collection.approve(executionInfo.module, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

151:         ERC721(nftCollateralAddress).transferFrom(borrower, address(this), executionData.tokenId);

430:         ERC721(loan.nftCollateralAddress).transferFrom(address(this), loan.borrower, loan.nftCollateralTokenId);

530:         ERC721(_loan.nftCollateralAddress).transferFrom(address(this), flashActionContract, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

60:         ERC20(__usdc).approve(__aavePool, type(uint256).max);

61:         ERC20(__aToken).approve(__aavePool, type(uint256).max);

96:             ERC20(_usdc).transferFrom(pool, address(this), delta);

101:             ERC20(_usdc).transfer(pool, delta);

115:         ERC20(usdc).transfer(pool, total);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

64:         ERC20(__lido).approve(__curvePool, type(uint256).max);

120:             weth.transferFrom(getPool, address(this), amount);

158:         weth.transfer(_pool, received);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Pool.sol

166:         _asset.approve(address(_feeManager), type(uint256).max);

207:             asset.approve(cachedAllocator, 0);

209:         asset.approve(proposedAllocator, type(uint256).max);

231:         asset.approve(_caller, type(uint256).max);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

### <a name="L-23"></a>[L-23] Unspecific compiler version pragma

*Instances (1)*:

```solidity
File: src/lib/pools/ERC4626.sol

2: pragma solidity >=0.8.0;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

### <a name="L-24"></a>[L-24] A year is not always 365 days

On leap years, the number of days is 366, so calculations during those years will return the wrong value

*Instances (2)*:

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

25:     uint256 private constant _SECONDS_PER_YEAR = 365 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

28:     uint256 private constant _SECONDS_PER_YEAR = 365 days;

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

## Medium Issues

| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Contracts are vulnerable to fee-on-transfer accounting-related issues | 5 |
| [M-2](#M-2) | Centralization Risk for trusted owners | 70 |
| [M-3](#M-3) | `_safeMint()` should be used rather than `_mint()` wherever possible | 2 |
| [M-4](#M-4) | Using `transferFrom` on ERC721 tokens | 12 |
| [M-5](#M-5) | Fees can be set to be greater than 100%. | 4 |
| [M-6](#M-6) |  Solmate's SafeTransferLib does not check for token contract's existence | 31 |
| [M-7](#M-7) | Return values of `transfer()`/`transferFrom()` not checked | 3 |
| [M-8](#M-8) | Unsafe use of `transfer()`/`transferFrom()` with `IERC20` | 3 |

### <a name="M-1"></a>[M-1] Contracts are vulnerable to fee-on-transfer accounting-related issues

Consistently check account balance before and after transfers for Fee-On-Transfer discrepancies. As arbitrary ERC20 tokens can be used, the amount here should be calculated every time to take into consideration a possible fee-on-transfer or deflation.
Also, it's a good practice for the future of the solution.

Use the balance before and after the transfer to calculate the received amount instead of assuming that it would be equal to the amount passed as a parameter. Or explicitly document that such tokens shouldn't be used and won't be supported

*Instances (5)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

257:         token.safeTransferFrom(newBidder, address(this), _bid);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/UserVault.sol

314:         ERC20(_token).safeTransferFrom(_depositor, address(this), _amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

96:             ERC20(_usdc).transferFrom(pool, address(this), delta);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/ERC4626.sol

51:         asset.safeTransferFrom(msg.sender, address(this), assets);

64:         asset.safeTransferFrom(msg.sender, address(this), assets);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

### <a name="M-2"></a>[M-2] Centralization Risk for trusted owners

#### Impact

Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (70)*:

```solidity
File: src/lib/AddressManager.sol

12: contract AddressManager is Owned, ReentrancyGuard {

33:     constructor(address[] memory _original) Owned(tx.origin) {

47:     function add(address _entry) external payable onlyOwner returns (uint16) {

53:     function addToWhitelist(address _entry) external payable onlyOwner {

65:     function removeFromWhitelist(address _entry) external payable onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AddressManager.sol)

```solidity
File: src/lib/AuctionLoanLiquidator.sol

28:     Owned,

120:     ) Owned(tx.origin) {

133:     function addLoanContract(address _loanContract) external onlyOwner {

142:     function removeLoanContract(address _loanContract) external onlyOwner {

156:     function updateLiquidationDistributor(address __liquidationDistributor) external onlyOwner {

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

133:     function setTimeForMainLenderToBuy(uint256 __timeForMainLenderToBuy) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

19: contract LiquidationDistributor is ILiquidationDistributor, Owned, ReentrancyGuard {

33:     constructor(address _loanManagerRegistry) Owned(tx.origin) {

37:     function setLiquidator(address _liquidator) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/LiquidationHandler.sol

74:     function updateLiquidationContract(address __loanLiquidator) external override onlyOwner {

82:     function updateLiquidationAuctionDuration(uint48 _newDuration) external override onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

16: contract UserVault is ERC721, ERC721TokenReceiver, IUserVault, Owned {

77:         Owned(tx.origin)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/CallbackHandler.sol

29:     function addWhitelistedCallbackContract(address _contract) external onlyOwner {

38:     function removeWhitelistedCallbackContract(address _contract) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/CallbackHandler.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

231:     function updateMultiSourceLoanAddressFirst(address _newAddress) external onlyOwner {

240:     function finalUpdateMultiSourceLoanAddress(address _newAddress) external onlyOwner {

272:     function updateTaxes(Taxes calldata _newTaxes) external onlyOwner {

284:     function setTaxes() external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/BaseLoan.sol

135:     function updateMinImprovementApr(uint256 _newMinimum) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/BaseLoan.sol)

```solidity
File: src/lib/loans/LoanManager.sol

13: abstract contract LoanManager is ILoanManager, TwoStepOwned {

38:         TwoStepOwned(_owner, _updateWaitingTime)

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManager.sol)

```solidity
File: src/lib/loans/LoanManagerParameterSetter.sol

9: contract LoanManagerParameterSetter is TwoStepOwned {

36:     constructor(address __offerHandler, uint256 _updateWaitingTime) TwoStepOwned(tx.origin, _updateWaitingTime) {

45:     function setLoanManager(address __loanManager) external onlyOwner {

60:     function setOfferHandler(address __offerHandler) external onlyOwner {

75:     function confirmOfferHandler(address __offerHandler) external onlyOwner {

94:     function requestAddCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

104:     function addCallers(ILoanManager.ProposedCaller[] calldata _callers) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerParameterSetter.sol)

```solidity
File: src/lib/loans/LoanManagerRegistry.sol

8: contract LoanManagerRegistry is ILoanManagerRegistry, Owned {

14:     constructor() Owned(tx.origin) {}

17:     function addLoanManager(address _loanManager) external onlyOwner {

24:     function removeLoanManager(address _loanManager) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/LoanManagerRegistry.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

507:     function setMinLockPeriod(uint256 __minLockPeriod) external onlyOwner {

543:     function setFlashActionContract(address _newFlashActionContract) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

17: contract AaveUsdcBaseInterestAllocator is IBaseInterestAllocator, Owned {

48:     ) Owned(tx.origin) {

64:     function setRewardsController(address _controller) external onlyOwner {

70:     function setRewardsReceiver(address _receiver) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

12: contract FeeManager is IFeeManager, TwoStepOwned {

27:     constructor(Fees memory __fees) TwoStepOwned(tx.origin, WAIT_TIME) {

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/LidoEthBaseInterestAllocator.sol

17: contract LidoEthBaseInterestAllocator is IBaseInterestAllocator, Owned {

54:     ) Owned(tx.origin) {

69:     function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/LidoEthBaseInterestAllocator.sol)

```solidity
File: src/lib/pools/Oracle.sol

10: contract Oracle is IOracle, TwoStepOwned {

11:     constructor(uint256 _minWaitTime) TwoStepOwned(tx.origin, _minWaitTime) {}

21:     function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Oracle.sol)

```solidity
File: src/lib/pools/OraclePoolOfferHandler.sol

16: contract OraclePoolOfferHandler is IPoolOfferHandler, TwoStepOwned {

130:     ) TwoStepOwned(tx.origin, _minWaitTime) {

141:     function setPool(address _pool) external onlyOwner {

152:     function setOracle(address _oracle) external onlyOwner {

172:     function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {

231:     ) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/OraclePoolOfferHandler.sol)

```solidity
File: src/lib/pools/Pool.sol

170:     function pausePool() external onlyOwner {

177:     function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {

185:     function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {

222:     function collectFees(address _recipient) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/TwoStepOwned.sol

9: abstract contract TwoStepOwned is Owned {

20:     constructor(address _owner, uint256 _minWaitTime) Owned(_owner) {

27:     function requestTransferOwner(address _newOwner) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/TwoStepOwned.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

8: abstract contract WithProtocolFee is TwoStepOwned {

36:         TwoStepOwned(_owner, _minWaitTime)

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="M-3"></a>[M-3] `_safeMint()` should be used rather than `_mint()` wherever possible

`_mint()` is [discouraged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L271) in favor of `_safeMint()` which ensures that the recipient is either an EOA or implements `IERC721Receiver`. Both open [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4d8d2ed9798cc3383912a23b5e8d5cb602f7d4b/contracts/token/ERC721/ERC721.sol#L238-L250) and [solmate](https://github.com/Rari-Capital/solmate/blob/4eaf6b68202e36f67cab379768ac6be304c8ebde/src/tokens/ERC721.sol#L180) have versions of this function so that NFTs aren't lost if they're minted to contracts that cannot transfer them back out.

Be careful however to respect the CEI pattern or add a re-entrancy guard as `_safeMint` adds a callback-check (`_checkOnERC721Received`) and a malicious `onERC721Received` could be exploited if not careful.

Reading material:

- <https://blocksecteam.medium.com/when-safemint-becomes-unsafe-lessons-from-the-hypebears-security-incident-2965209bda2a>
- <https://samczsun.com/the-dangers-of-surprising-code/>
- <https://github.com/KadenZipfel/smart-contract-attack-vectors/blob/master/vulnerabilities/unprotected-callback.md>

*Instances (2)*:

```solidity
File: src/lib/UserVault.sol

90:         _mint(msg.sender, _vaultId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

66:         _mint(_to, nextTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="M-4"></a>[M-4] Using `transferFrom` on ERC721 tokens

The `transferFrom` function is used instead of `safeTransferFrom` and [it's discouraged by OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/109778c17c7020618ea4e035efb9f0f9b82d43ca/contracts/token/ERC721/IERC721.sol#L84). If the arbitrary address is a contract and is not aware of the incoming ERC721 token, the sent token could be locked.

*Instances (12)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

289:         ERC721(collateralAddress).transferFrom(address(this), _auction.highestBidder, tokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/AuctionWithBuyoutLoanLiquidator.sol

124:         ERC721(_loan.nftCollateralAddress).transferFrom(address(this), buyer, _tokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionWithBuyoutLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationHandler.sol

113:             ERC721(_loan.nftCollateralAddress).transferFrom(address(this), liquidator, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationHandler.sol)

```solidity
File: src/lib/UserVault.sol

292:         ERC721(_collection).transferFrom(_depositor, address(this), _tokenId);

329:         ERC721(_collection).transferFrom(address(this), msg.sender, _tokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

172:             _wrappedPunk.transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);

174:             ERC721(_loan.nftCollateralAddress).transferFrom(address(this), _loan.borrower, _loan.nftCollateralTokenId);

199:             _wrappedPunk.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);

214:             collection.transferFrom(_loan.borrower, address(this), _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

151:         ERC721(nftCollateralAddress).transferFrom(borrower, address(this), executionData.tokenId);

430:         ERC721(loan.nftCollateralAddress).transferFrom(address(this), loan.borrower, loan.nftCollateralTokenId);

530:         ERC721(_loan.nftCollateralAddress).transferFrom(address(this), flashActionContract, _loan.nftCollateralTokenId);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

### <a name="M-5"></a>[M-5] Fees can be set to be greater than 100%

There should be an upper limit to reasonable fees.
A malicious owner can keep the fee rate at zero, but if a large value transfer enters the mempool, the owner can jack the rate up to the maximum and sandwich attack a user.

*Instances (4)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

170:     function updateTriggerFee(uint256 triggerFee) external onlyOwner {
             _updateTriggerFee(triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/pools/FeeManager.sol

39:     function setProposedFees(Fees calldata __fees) external onlyOwner {
            _proposedFees = __fees;
            _proposedFeesSetTime = block.timestamp;
    
            emit ProposedFeesSet(__fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/FeeManager.sol)

```solidity
File: src/lib/pools/Pool.sol

222:     function collectFees(address _recipient) external onlyOwner {
             uint256 fees = getCollectedFees;
             getCollectedFees = 0;
     
             asset.safeTransfer(_recipient, fees);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/utils/WithProtocolFee.sol

59:     function updateProtocolFee(ProtocolFee calldata _newProtocolFee) external onlyOwner {
            _newProtocolFee.recipient.checkNotZero();
    
            _pendingProtocolFee = _newProtocolFee;
            _pendingProtocolFeeSetTime = block.timestamp;
    
            emit ProtocolFeePendingUpdate(_pendingProtocolFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/utils/WithProtocolFee.sol)

### <a name="M-6"></a>[M-6]  Solmate's SafeTransferLib does not check for token contract's existence

There is a subtle difference between the implementation of solmate’s SafeTransferLib and OZ’s SafeERC20: OZ’s SafeERC20 checks if the token is a contract or not, solmate’s SafeTransferLib does not.
<https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol#L9>
`@dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller`

*Instances (31)*:

```solidity
File: src/lib/AuctionLoanLiquidator.sol

253:             token.safeTransfer(_auction.highestBidder, currentHighestBid);

257:         token.safeTransferFrom(newBidder, address(this), _bid);

296:         asset.safeTransfer(_auction.originator, triggerFee);

297:         asset.safeTransfer(msg.sender, triggerFee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/AuctionLoanLiquidator.sol)

```solidity
File: src/lib/LiquidationDistributor.sol

114:         ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, total);

128:             ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _trancheOwed);

133:                 ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _proceedsLeft);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/LiquidationDistributor.sol)

```solidity
File: src/lib/UserVault.sol

314:         ERC20(_token).safeTransferFrom(_depositor, address(this), _amount);

358:         ERC20(_token).safeTransfer(msg.sender, amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/UserVault.sol)

```solidity
File: src/lib/callbacks/PurchaseBundler.sol

209:             _weth.safeTransfer(_loan.borrower, balance);

221:             asset.safeTransfer(_loan.borrower, balance);

310:             ERC20(principalAddress).safeTransferFrom(borrower, tranche.lender, taxCost - feeTax);

316:             ERC20(principalAddress).safeTransferFrom(borrower, protocolFee.recipient, totalFeeTax);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/callbacks/PurchaseBundler.sol)

```solidity
File: src/lib/loans/MultiSourceLoan.sol

194:                 ERC20(_loan.principalAddress).safeTransferFrom(

208:                 ERC20(_loan.principalAddress).safeTransferFrom(_renegotiationOffer.lender, _loan.borrower, netNewLender);

393:         ERC20(_loan.principalAddress).safeTransferFrom(

398:             ERC20(_loan.principalAddress).safeTransferFrom(

657:             asset.safeTransferFrom(_borrower, _tranche.lender, oldLenderDebt - _remainingNewLender);

662:                 asset.safeTransferFrom(_lender, _tranche.lender, oldLenderDebt);

713:             ERC20(_principalAddress).safeTransferFrom(_lender, _feeRecipient, _fee);

922:             asset.safeTransferFrom(loan.borrower, tranche.lender, repayment);

942:             asset.safeTransferFrom(loan.borrower, _protocolFee.recipient, totalProtocolFee);

1012:             ERC20(offer.principalAddress).safeTransferFrom(lender, _principalReceiver, amount - fee);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/loans/MultiSourceLoan.sol)

```solidity
File: src/lib/pools/ERC4626.sol

51:         asset.safeTransferFrom(msg.sender, address(this), assets);

64:         asset.safeTransferFrom(msg.sender, address(this), assets);

88:         asset.safeTransfer(receiver, assets);

107:         asset.safeTransfer(receiver, assets);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/ERC4626.sol)

```solidity
File: src/lib/pools/Pool.sol

226:         asset.safeTransfer(_recipient, fees);

302:         asset.safeTransfer(queue.contractAddress, proRataLiquid);

739:             asset.safeTransfer(queueAddr, amount);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/Pool.sol)

```solidity
File: src/lib/pools/WithdrawalQueue.sol

100:         _asset.safeTransfer(_to, available);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/WithdrawalQueue.sol)

### <a name="M-7"></a>[M-7] Return values of `transfer()`/`transferFrom()` not checked

Not all `IERC20` implementations `revert()` when there's a failure in `transfer()`/`transferFrom()`. The function signature has a `boolean` return value and they indicate errors that way instead. By not checking the return value, operations that should have marked as failed, may potentially go through without actually making a payment

*Instances (3)*:

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

96:             ERC20(_usdc).transferFrom(pool, address(this), delta);

101:             ERC20(_usdc).transfer(pool, delta);

115:         ERC20(usdc).transfer(pool, total);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)

### <a name="M-8"></a>[M-8] Unsafe use of `transfer()`/`transferFrom()` with `IERC20`

Some tokens do not implement the ERC20 standard properly but are still accepted by most code that accepts ERC20 tokens.  For example Tether (USDT)'s `transfer()` and `transferFrom()` functions on L1 do not return booleans as the specification requires, and instead have no return value. When these sorts of tokens are cast to `IERC20`, their [function signatures](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca) do not match and therefore the calls made, revert (see [this](https://gist.github.com/IllIllI000/2b00a32e8f0559e8f386ea4f1800abc5) link for a test case). Use OpenZeppelin's `SafeERC20`'s `safeTransfer()`/`safeTransferFrom()` instead

*Instances (3)*:

```solidity
File: src/lib/pools/AaveUsdcBaseInterestAllocator.sol

96:             ERC20(_usdc).transferFrom(pool, address(this), delta);

101:             ERC20(_usdc).transfer(pool, delta);

115:         ERC20(usdc).transfer(pool, total);

```

[Link to code](https://github.com/code-423n4/2024-06-gondi/blob/main/src/lib/pools/AaveUsdcBaseInterestAllocator.sol)
