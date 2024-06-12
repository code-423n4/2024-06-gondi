// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.21;

interface IAaveReewardsController {
    ///@notice See https://docs.aave.com/developers/periphery-contracts/rewardscontroller
    function claimAllRewards(address[] calldata _assets, address _to) external;
}
