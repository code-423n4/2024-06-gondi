// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

interface IOracle {
    struct CollectionData {
        uint128 value;
        uint128 updated;
    }

    /// @notice Set the value for a given stat (_key) for a given collection over some period.
    /// @param _collection The collection to set the data for
    /// @param _period The period to set the data for
    /// @param _key The key to set the data for
    /// @param _value The value to set
    function setData(address _collection, uint64 _period, bytes4 _key, uint128 _value) external;

    /// @notice Get data for a given collection over some period
    /// @param _collection The collection to get the data for
    /// @param _period The period to get the data for
    /// @param _key The key to get the data for
    /// @return CollectionData The data and time it was updated
    function getData(address _collection, uint64 _period, bytes4 _key) external view returns (CollectionData memory);

    event DataUpdated(address collection, uint64 period, bytes4 key, uint128 value);
}
