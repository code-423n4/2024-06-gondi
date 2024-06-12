// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "src/interfaces/IOldERC721.sol";

import "../utils/SampleCollection.sol";

contract SampleOldCollection is IOldERC721, SampleCollection {
    constructor() {}

    function transfer(address _to, uint256 _tokenId) external {
        transferFrom(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) external {
        transferFrom(_ownerOf[_tokenId], msg.sender, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public override(ERC721, IOldERC721) {
        ERC721.approve(_to, _tokenId);
    }

    function balanceOf(address _owner) public view override(ERC721, IOldERC721) returns (uint256) {
        return ERC721.balanceOf(_owner);
    }

    function ownerOf(uint256 _tokenId) public view override(ERC721, IOldERC721) returns (address) {
        return ERC721.ownerOf(_tokenId);
    }
}
