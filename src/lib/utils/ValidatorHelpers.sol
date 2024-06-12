// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

/// TODO: Give credit

library ValidatorHelpers {
    error InvalidBytesPerTokenIdError(uint64 _bytesPerTokenId);

    error TokenIdNotFoundError(uint256 _tokenId);

    error BitVectorLengthExceededError(uint256 _tokenId);

    error EmptyTokenIdListError();

    function validateTokenIdPackedList(uint256 _tokenId, uint64 _bytesPerTokenId, bytes memory _tokenIdList)
        internal
        pure
    {
        if (_bytesPerTokenId == 0 || _bytesPerTokenId > 32) {
            revert InvalidBytesPerTokenIdError(_bytesPerTokenId);
        }

        if (_tokenIdList.length == 0) {
            revert EmptyTokenIdListError();
        }
        // Masks the lower `bytesPerTokenId` bytes of a word
        // So if `bytesPerTokenId` == 1, then bitmask = 0xff
        //    if `bytesPerTokenId` == 2, then bitmask = 0xffff, etc.
        uint256 bitMask = ~(type(uint256).max << (_bytesPerTokenId << 3));
        assembly {
            // Binary search for given token id

            let left := 1
            // right = number of tokenIds in the list
            let right := div(mload(_tokenIdList), _bytesPerTokenId)

            // while(left < right)
            for {} lt(left, right) {} {
                // mid = (left + right) / 2
                let mid := shr(1, add(left, right))
                // more or less equivalent to:
                // value = list[index]
                let offset := add(_tokenIdList, mul(mid, _bytesPerTokenId))
                let value := and(mload(offset), bitMask)
                // if (value < tokenId) {
                //     left = mid + 1;
                //     continue;
                // }
                if lt(value, _tokenId) {
                    left := add(mid, 1)
                    continue
                }
                // if (value > tokenId) {
                //     right = mid;
                //     continue;
                // }
                if gt(value, _tokenId) {
                    right := mid
                    continue
                }
                // if (value == tokenId) { return; }
                stop()
            }
            // At this point left == right; check if list[left] == tokenId
            let offset := add(_tokenIdList, mul(left, _bytesPerTokenId))
            let value := and(mload(offset), bitMask)
            if eq(value, _tokenId) { stop() }
        }
        revert TokenIdNotFoundError(_tokenId);
    }

    function validateNFTBitVector(uint256 _tokenId, bytes memory _bitVector) internal pure {
        // tokenId < propertyData.length * 8
        if (_tokenId >= _bitVector.length << 3) {
            revert BitVectorLengthExceededError(_tokenId);
        }
        // Bit corresponding to tokenId must be set
        if (!(uint8(_bitVector[_tokenId >> 3]) & (0x80 >> (_tokenId & 7)) != 0)) {
            revert TokenIdNotFoundError(_tokenId);
        }
    }
}
