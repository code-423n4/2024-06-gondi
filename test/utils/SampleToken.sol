// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@solmate/tokens/ERC20.sol";
import "@solmate/utils/SafeTransferLib.sol";

contract SampleToken is ERC20("SAMPLE_TOKEN", "ST", 18) {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}
