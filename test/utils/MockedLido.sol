// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "./SampleToken.sol";

contract MockedLido is SampleToken {
    uint256 public getTotalPooledEther;
    uint256 public getTotalShares;

    function setTotalPooledEther(uint256 _totalPooledEther) external {
        getTotalPooledEther = _totalPooledEther;
    }

    function setTotalShares(uint256 _totalShares) external {
        getTotalShares = _totalShares;
    }

    function submit(address) external payable returns (uint256) {
        deposit();
        return msg.value;
    }
}
