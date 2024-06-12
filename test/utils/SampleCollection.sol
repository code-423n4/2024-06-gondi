// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@solmate/tokens/ERC721.sol";

contract SampleCollection is ERC721("SAMPLE_COLLECTION", "SC") {
    uint256 public lastId;

    constructor() {}

    function mintNext(address to) external {
        _mint(to, lastId);
        lastId++;
    }

    function mint(address to, uint256 id) external {
        _mint(to, id);
        if (id > lastId) {
            lastId = id + 1;
        } else {
            lastId++;
        }
    }

    function tokenURI(uint256 id) public pure override returns (string memory) {
        return string(abi.encodePacked("", id));
    }
}
