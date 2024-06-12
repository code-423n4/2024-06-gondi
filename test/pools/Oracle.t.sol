// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "src/lib/pools/Oracle.sol";

contract OracleTest is Test {
    address private _collection = address(11111);
    uint64 private _period = 600 days;
    bytes4 private _key = bytes4("11");
    uint128 private _value = 1e18;

    Oracle private _oracle = new Oracle(3 days);

    function testSetData() public {
        vm.prank(_oracle.owner());
        _oracle.setData(_collection, _period, _key, _value);

        Oracle.CollectionData memory data = _oracle.getData(_collection, _period, _key);

        assertEq(data.value, _value);
    }

    function testSetDataUnauthorized() public {
        vm.expectRevert(bytes("UNAUTHORIZED"));
        _oracle.setData(_collection, _period, _key, _value);
    }
}
