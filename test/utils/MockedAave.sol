// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "./SampleToken.sol";
import "src/interfaces/external/IAaveLendingPool.sol";

contract MockedAave {
    ERC20 public baseAsset;
    SampleToken public aToken;

    uint128 private constant _RAY = 1e27;
    uint128 private constant _BPS = 10000;
    uint128 private _apr;

    constructor(SampleToken __baseAsset) {
        baseAsset = __baseAsset;
        aToken = new SampleToken();
    }

    function setAprBps(uint128 __apr) external {
        _apr = __apr;
    }

    function deposit(address, uint256 amount, address onBehalfOf, uint16) external {
        baseAsset.transferFrom(onBehalfOf, address(this), amount);
        aToken.mint(onBehalfOf, amount);
    }

    function withdraw(address, uint256 amount, address to) external {
        aToken.transferFrom(to, address(this), amount);
        baseAsset.transfer(to, amount);
    }

    function getReserveData(address)
        external
        view
        returns (
            uint256,
            uint128,
            uint128,
            uint128,
            uint128,
            uint128,
            uint40,
            uint16,
            address,
            address,
            address,
            address,
            uint128,
            uint128,
            uint128
        )
    {
        return (0, 0, _apr * _RAY / _BPS, 0, 0, 0, 0, 0, address(0), address(0), address(0), address(0), 0, 0, 0);
    }
}
