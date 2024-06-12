// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC20.sol";
import "@solmate/tokens/WETH.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "./Pool.sol";
import "../../interfaces/external/ICurve.sol";
import "../../interfaces/external/ILido.sol";
import "../../interfaces/pools/IBaseInterestAllocator.sol";

/// @title LidoEthBaseInterestAllocator
/// @author Florida St
/// @notice Base Interest Allocator for ETH Pools using stETH.
contract LidoEthBaseInterestAllocator is IBaseInterestAllocator, Owned {
    using FixedPointMathLib for uint256;

    /// @dev APR in Bps
    struct LidoData {
        uint96 lastTs;
        uint144 shareRate;
        uint16 aprBps;
    }

    uint256 private constant _BPS = 10000;
    uint256 private constant _SECONDS_PER_YEAR = 365 days;
    uint256 private constant _PRINCIPAL_PRECISION = 1e20;
    address payable private immutable _curvePool;
    address payable private immutable _weth;
    address private immutable _lido;

    address public immutable getPool;
    uint96 public immutable getLidoUpdateTolerance;

    uint256 public getMaxSlippage;
    LidoData public getLidoData;

    event MaxSlippageSet(uint256 maxSlippage);
    event LidoValuesUpdated(LidoData lidoData);

    error InvalidPoolError();
    error InvalidCallerError();
    error InvalidAprError();

    constructor(
        address _pool,
        address payable __curvePool,
        address payable __weth,
        address __lido,
        uint256 _currentBaseAprBps,
        uint96 _lidoUpdateTolerance
    ) Owned(tx.origin) {
        if (address(Pool(_pool).asset()) != address(__weth)) {
            revert InvalidPoolError();
        }
        getPool = _pool;
        _curvePool = __curvePool;
        _weth = __weth;
        _lido = __lido;
        getLidoData = LidoData(uint96(block.timestamp), uint144(_currentShareRate()), uint16(_currentBaseAprBps));
        getLidoUpdateTolerance = _lidoUpdateTolerance;
        ERC20(__lido).approve(__curvePool, type(uint256).max);
    }

    /// @notice Set max slippage allow for reallocations.
    /// @param _maxSlippage The max slippage allowed.
    function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {
        getMaxSlippage = _maxSlippage;

        emit MaxSlippageSet(_maxSlippage);
    }

    /// @inheritdoc IBaseInterestAllocator
    function getBaseApr() external view override returns (uint256) {
        LidoData memory lidoData = getLidoData;
        uint256 aprBps = getLidoData.aprBps;
        if (block.timestamp - lidoData.lastTs > getLidoUpdateTolerance) {
            uint256 shareRate = _currentShareRate();
            aprBps = uint16(
                _BPS * _SECONDS_PER_YEAR * (shareRate - lidoData.shareRate) / lidoData.shareRate
                    / (block.timestamp - lidoData.lastTs)
            );
        }
        if (aprBps == 0) {
            revert InvalidAprError();
        }
        return aprBps;
    }

    /// @inheritdoc IBaseInterestAllocator
    function getBaseAprWithUpdate() external returns (uint256) {
        LidoData memory lidoData = getLidoData;
        if (block.timestamp - lidoData.lastTs > getLidoUpdateTolerance) {
            _updateLidoValues(lidoData);
        }
        if (lidoData.aprBps == 0) {
            revert InvalidAprError();
        }
        return lidoData.aprBps;
    }

    /// @notice Triggger update.
    function updateLidoValues() external {
        _updateLidoValues(getLidoData);
    }

    /// @inheritdoc IBaseInterestAllocator
    function getAssetsAllocated() external view returns (uint256) {
        return ERC20(_lido).balanceOf(address(this));
    }

    /// @inheritdoc IBaseInterestAllocator
    function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool _force) external {
        address pool = _onlyPool();
        if (_currentIdle > _targetIdle) {
            WETH weth = WETH(_weth);
            uint256 amount = _currentIdle - _targetIdle;
            weth.transferFrom(getPool, address(this), amount);
            weth.withdraw(amount);
            /// @dev 0 = ETH, 1 = STETH
            /// Look into deposit directly.
            ILido(_lido).submit{value: amount}(address(0));
        } else {
            _exchangeAndSendWeth(pool, _targetIdle - _currentIdle, _force);
        }

        emit Reallocated(_currentIdle, _targetIdle);
    }

    /// @dev Convert all stETH to ETH and send it to the pool.
    function transferAll() external {
        uint256 total = ERC20(_lido).balanceOf(address(this));
        _exchangeAndSendWeth(_onlyPool(), total, true);

        emit AllTransfered(total);
    }

    function _currentShareRate() private view returns (uint256) {
        ILido lido = ILido(_lido);
        return lido.getTotalPooledEther() * 1e27 / lido.getTotalShares();
    }

    function _onlyPool() private view returns (address) {
        address pool = getPool;
        if (pool != msg.sender) {
            revert InvalidCallerError();
        }
        return pool;
    }

    function _exchangeAndSendWeth(address _pool, uint256 _amount, bool _force) private {
        uint256 slippage = _force ? _BPS : getMaxSlippage;
        WETH weth = WETH(_weth);
        uint256 received = ICurve(_curvePool).exchange(1, 0, _amount, _amount.mulDivUp(_BPS - slippage, _BPS));
        weth.deposit{value: received}();
        weth.transfer(_pool, received);
    }

    function _updateLidoValues(LidoData memory _lidoData) private {
        uint256 shareRate = _currentShareRate();
        _lidoData.aprBps = uint16(
            _BPS * _SECONDS_PER_YEAR * (shareRate - _lidoData.shareRate) / _lidoData.shareRate
                / (block.timestamp - _lidoData.lastTs)
        );
        _lidoData.shareRate = uint144(shareRate);
        _lidoData.lastTs = uint96(block.timestamp);
        getLidoData = _lidoData;
        emit LidoValuesUpdated(_lidoData);
    }

    receive() external payable {}
}
