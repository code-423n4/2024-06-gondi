// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/tokens/ERC721.sol";
import "src/interfaces/INFTFlashAction.sol";

/// @title Test NFT Flash Action
/// @author Florida St
/// @notice Only used for testing purposes.
contract TestNFTFlashAction is INFTFlashAction, ERC721TokenReceiver {
    function execute(address _collection, uint256 _tokenId, address, bytes calldata) external {
        ERC721 collection = ERC721(_collection);
        if (collection.ownerOf(_tokenId) != address(this)) {
            revert InvalidOwnerError();
        }
        collection.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

/// @title Malisicous Flash Action
/// @author Florida St
/// @notice Only used for testing purposes.
contract TestNFTMaliciousFlashAction is INFTFlashAction, ERC721TokenReceiver {
    /// @dev Does not return nft
    function execute(address, uint256, address, bytes calldata) external {}

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
