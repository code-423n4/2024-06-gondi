// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@openzeppelin/utils/Strings.sol";
import "@solmate/tokens/ERC20.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "../Multicall.sol";

/// @title WithdrawalQueue
/// @author Florida St
/// @notice Pools use WithdrawalQueues to manage the withdrawal of funds from them. Each
///         withdrawal request is represented by an NFT (it can be traded, borrowed against, etc).
///         Each NFT has some number of shares backing it (`getShares`) and some amount that
///         has already been claimed (`getWithdrawn`).
///         We allow NFTs to be locked for some time (`getUnlockTime`) which cannot be reduced,
///         so listing for potential loans/or getting offers from potential buyers is feasible.
contract WithdrawalQueue is ERC721, Multicall {
    using SafeTransferLib for ERC20;

    string private constant _NAME = "GPoolWithdrawalQueue";
    string private constant _SYMBOL = "WQ";
    string private constant _BASE_URI = "https://gondi.xyz/withdrawal-queue/";

    /// @notice The pool associated with.
    address public immutable getPool;
    /// @notice Total amount of shares withdrawn.
    uint256 public getTotalShares;
    /// @notice The next tokenId to be minted.
    uint256 public getNextTokenId;

    mapping(uint256 tokenId => uint256 shares) public getShares;
    mapping(uint256 tokenId => uint256 withdrawn) public getWithdrawn;
    mapping(uint256 tokenId => uint256 unlockTime) public getUnlockTime;

    /// @dev Asset backing the pool.
    ERC20 private immutable _asset;
    /// @dev Total amount withdrawn across all positions.
    uint256 private _totalWithdrawn;

    event WithdrawalPositionMinted(uint256 tokenId, address to, uint256 shares);
    event Withdrawn(address to, uint256 tokenId, uint256 available);
    event WithdrawalLocked(uint256 tokenId, uint256 unlockTime);

    error PoolOnlyCallableError();
    error NotApprovedOrOwnerError();
    error WithdrawalsLockedError(uint256 tokenId, uint256 unlockTime);
    error CanOnlyExtendWithdrawalError(uint256 tokenId, uint256 unlockTime);

    constructor(ERC20 __asset) ERC721(_NAME, _SYMBOL) {
        getPool = msg.sender;

        _asset = __asset;
    }

    /// @notice Mint a new withdrawal position. Can only be called by the pool.
    /// @param _to The address to mint the position to.
    /// @param _shares The amount of shares backing the position.
    /// @return The tokenId of the minted position.
    function mint(address _to, uint256 _shares) external returns (uint256) {
        if (msg.sender != getPool) {
            revert PoolOnlyCallableError();
        }
        uint256 nextTokenId = getNextTokenId;
        _mint(_to, nextTokenId);
        getShares[nextTokenId] = _shares;
        unchecked {
            getTotalShares += _shares;
        }

        emit WithdrawalPositionMinted(nextTokenId, _to, _shares);

        return getNextTokenId++;
    }

    /// @notice Withdraw funds from a position (will check if it's locked) and it's
    ///         the right caller.
    /// @param _to The address to withdraw the funds to.
    /// @param _tokenId The tokenId of the position to withdraw from.
    /// @return The amount withdrawn.
    function withdraw(address _to, uint256 _tokenId) external returns (uint256) {
        uint256 unlockTime = getUnlockTime[_tokenId];
        if (unlockTime > block.timestamp) {
            revert WithdrawalsLockedError(_tokenId, unlockTime);
        }
        address caller = msg.sender;
        address owner = _ownerOf[_tokenId];
        if (!(caller == owner || isApprovedForAll[owner][caller] || caller == getApproved[_tokenId])) {
            revert NotApprovedOrOwnerError();
        }

        uint256 available = _getAvailable(_tokenId);

        unchecked {
            getWithdrawn[_tokenId] += available;
            _totalWithdrawn += available;
        }

        _asset.safeTransfer(_to, available);

        emit Withdrawn(_to, _tokenId, available);

        return available;
    }

    /// @notice Get the available amount to withdraw from a position.
    /// @param _tokenId The tokenId of the position to check.
    /// @return The amount available to withdraw.
    function getAvailable(uint256 _tokenId) external view returns (uint256) {
        return _getAvailable(_tokenId);
    }

    /// @notice Lock withdrawals for a position.
    /// @param _tokenId The tokenId of the position to lock.
    /// @param _time The time to lock the position for.
    function lockWithdrawals(uint256 _tokenId, uint256 _time) external {
        address owner = _ownerOf[_tokenId];
        if (!(msg.sender == owner || isApprovedForAll[owner][msg.sender] || msg.sender == getApproved[_tokenId])) {
            revert NotApprovedOrOwnerError();
        }

        if (block.timestamp + _time < getUnlockTime[_tokenId]) {
            revert CanOnlyExtendWithdrawalError(_tokenId, getUnlockTime[_tokenId]);
        }

        uint256 unlockTime = block.timestamp + _time;
        getUnlockTime[_tokenId] = unlockTime;

        emit WithdrawalLocked(_tokenId, unlockTime);
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 _id) public pure override returns (string memory) {
        return string.concat(_BASE_URI, Strings.toString(_id));
    }

    /// @notice Get the available amount to withdraw from a position (totalAmount - totalWithdrawn)
    /// @param _tokenId The tokenId of the position to check.
    /// @return The amount available to withdraw.
    function _getAvailable(uint256 _tokenId) private view returns (uint256) {
        /// shares * withdrawablePerShare / totalShares - withdrawn
        return (getShares[_tokenId] * (_totalWithdrawn + _asset.balanceOf(address(this)))) / getTotalShares
            - getWithdrawn[_tokenId];
    }
}
