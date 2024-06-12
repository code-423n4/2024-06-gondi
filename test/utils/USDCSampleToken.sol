// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@solmate/tokens/ERC20.sol";

contract USDCSampleToken is ERC20("USDC_SAMPLE_TOKEN", "USDC_ST", 18) {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
