// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

/// @title IOldERC721
/// @notice Interface for the old ERC721 standard.
interface IOldERC721 {
    function balanceOf(address _owner) external view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) external view returns (address _owner);

    function transfer(address _to, uint256 _tokenId) external;

    function approve(address _to, uint256 _tokenId) external;

    function takeOwnership(uint256 _tokenId) external;
}
