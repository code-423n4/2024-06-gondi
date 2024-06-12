// SPDX-License-Identifier:19 AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "src/lib/AddressManager.sol";

contract AddressManagerTest is Test {
    address[] private _whitelist;

    function setUp() public {
        _whitelist = new address[](1);
        _whitelist[0] = address(1);
    }

    function testConstructor() public {
        AddressManager manager = new AddressManager(_whitelist);

        assertEq(manager.addressToIndex(_whitelist[0]), 1);
        assertEq(manager.indexToAddress(1), _whitelist[0]);
        assertTrue(manager.isWhitelisted(_whitelist[0]));
    }

    function testAddAndCheckentry() public {
        AddressManager manager = new AddressManager(_whitelist);

        address entry = address(2);

        vm.prank(manager.owner());
        uint16 index = manager.add(entry);

        assertTrue(manager.isWhitelisted(entry));
        assertEq(manager.addressToIndex(entry), index);
        assertEq(manager.indexToAddress(index), entry);
    }

    function testRemoveFromWhitelist() public {
        AddressManager manager = new AddressManager(_whitelist);

        vm.prank(manager.owner());
        manager.removeFromWhitelist(_whitelist[0]);

        assertEq(manager.addressToIndex(_whitelist[0]), 1);
        assertEq(manager.indexToAddress(1), _whitelist[0]);
        assertFalse(manager.isWhitelisted(_whitelist[0]));
    }
}
