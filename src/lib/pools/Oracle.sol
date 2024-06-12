// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../../interfaces/pools/IOracle.sol";
import "../utils/TwoStepOwned.sol";

/// @title Oracle
/// @author Florida St
/// @notice Simple oracle implementation
contract Oracle is IOracle, TwoStepOwned {
    constructor(uint256 _minWaitTime) TwoStepOwned(tx.origin, _minWaitTime) {}

    mapping(bytes32 key => CollectionData data) private _data;

    /// @inheritdoc IOracle
    function getData(address _collection, uint64 _period, bytes4 _key) external view returns (CollectionData memory) {
        return _data[_getKey(_collection, _period, _key)];
    }

    /// @inheritdoc IOracle
    function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external onlyOwner {
        _data[_getKey(_collection, _period, _key)] = CollectionData(_value, uint128(block.timestamp));

        emit DataUpdated(_collection, _period, _key, _value);
    }

    function _getKey(address _collection, uint64 _period, bytes4 _key) private pure returns (bytes32) {
        return bytes32(abi.encodePacked(_collection, _period, _key));
    }
}
