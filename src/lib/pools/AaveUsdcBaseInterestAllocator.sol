// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC20.sol";
import "@solmate/tokens/WETH.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "../../interfaces/external/IAaveRewardsController.sol";
import "../../interfaces/external/IAaveLendingPool.sol";
import "../../interfaces/pools/IBaseInterestAllocator.sol";
import "./Pool.sol";

/// @title AaveUsdcBaseInterestAllocator
/// @author Florida St
/// @notice Base Interest Allocator for USDC Pools using AAVE.
contract AaveUsdcBaseInterestAllocator is IBaseInterestAllocator, Owned {
    using FixedPointMathLib for uint256;

    address public immutable getPool;

    uint256 private constant _RAY = 1e27;
    uint256 private constant _BPS = 10000;
    uint128 private constant _PRINCIPAL_PRECISION = 1e20;
    uint256 private constant _SECONDS_PER_YEAR = 365 days;

    address private immutable _aavePool;
    address private immutable _usdc;
    address private immutable _aToken;

    address public getRewardsController;
    address public getRewardsReceiver;

    event RewardsControllerSet(address controller);
    event RewardsReceiverSet(address receiver);

    error InvalidPoolError();
    error InvalidCallerError();
    error InvalidAprError();

    constructor(
        address _pool,
        address __aavePool,
        address __usdc,
        address __aToken,
        address _rewardsController,
        address _rewardsReceiver
    ) Owned(tx.origin) {
        if (address(Pool(_pool).asset()) != address(__usdc)) {
            revert InvalidPoolError();
        }
        getPool = _pool;
        _aavePool = __aavePool;
        _usdc = __usdc;
        _aToken = __aToken;

        getRewardsController = _rewardsController;
        getRewardsReceiver = _rewardsReceiver;

        ERC20(__usdc).approve(__aavePool, type(uint256).max);
        ERC20(__aToken).approve(__aavePool, type(uint256).max);
    }

    function setRewardsController(address _controller) external onlyOwner {
        getRewardsController = _controller;

        emit RewardsControllerSet(_controller);
    }

    function setRewardsReceiver(address _receiver) external onlyOwner {
        getRewardsReceiver = _receiver;

        emit RewardsReceiverSet(_receiver);
    }

    /// @inheritdoc IBaseInterestAllocator
    function getBaseApr() external view override returns (uint256) {
        return _getBaseApr();
    }

    /// @inheritdoc IBaseInterestAllocator
    function getBaseAprWithUpdate() external view returns (uint256) {
        return _getBaseApr();
    }

    /// @inheritdoc IBaseInterestAllocator
    function getAssetsAllocated() external view returns (uint256) {
        return ERC20(_aToken).balanceOf(address(this));
    }

    /// @inheritdoc IBaseInterestAllocator
    function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool) external {
        address pool = _onlyPool();
        if (_currentIdle > _targetIdle) {
            uint256 delta = _currentIdle - _targetIdle;
            ERC20(_usdc).transferFrom(pool, address(this), delta);
            IAaveLendingPool(_aavePool).deposit(_usdc, delta, address(this), 0);
        } else {
            uint256 delta = _targetIdle - _currentIdle;
            IAaveLendingPool(_aavePool).withdraw(_usdc, delta, address(this));
            ERC20(_usdc).transfer(pool, delta);
        }

        emit Reallocated(_currentIdle, _targetIdle);
    }

    /// @inheritdoc IBaseInterestAllocator
    function transferAll() external {
        uint256 total = ERC20(_aToken).balanceOf(address(this));
        address pool = _onlyPool();
        address usdc = _usdc;

        IAaveLendingPool(_aavePool).withdraw(usdc, total, address(this));

        ERC20(usdc).transfer(pool, total);

        emit AllTransfered(total);
    }

    /// @notice Claim rewards from AAVE.
    function claimRewards() external {
        address[] memory assets = new address[](1);
        assets[0] = _aToken;
        IAaveReewardsController(getRewardsController).claimAllRewards(assets, getRewardsReceiver);
    }

    function _onlyPool() private view returns (address) {
        address pool = getPool;
        if (pool != msg.sender) {
            revert InvalidCallerError();
        }
        return pool;
    }

    function _getBaseApr() private view returns (uint256) {
        (,, uint128 currentLiquidityRate,,,,,,,,,,,,) = IAaveLendingPool(_aavePool).getReserveData(_usdc);
        return currentLiquidityRate * _BPS / _RAY;
    }
}
