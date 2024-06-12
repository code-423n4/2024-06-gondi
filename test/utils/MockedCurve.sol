// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@forge-std/console.sol";

import "test/utils/SampleToken.sol";

contract MockedCurve {
    uint256 public nextDy;

    SampleToken public token;

    constructor(SampleToken _token) {
        token = _token;
    }

    function setNextDy(uint256 _nextDy) external {
        nextDy = _nextDy;
    }

    function exchange(uint128 i, uint128, uint256, uint256 _min_dy) external payable returns (uint256) {
        if (nextDy < _min_dy) {
            revert("ERROR");
        }
        if (i == 0) {
            token.mint(msg.sender, nextDy);
        } else {
            token.transferFrom(msg.sender, address(this), nextDy);
            (bool suc,) = msg.sender.call{value: nextDy}("");
            if (!suc) {
                revert("ETH_SENDING_ERROR");
            }
        }
        return nextDy;
    }
}
