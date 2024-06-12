// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "src/lib/AddressManager.sol";
import "src/lib/UserVault.sol";
import "test/utils/SampleCollection.sol";
import "test/utils/SampleOldCollection.sol";
import "test/utils/SampleToken.sol";

contract UserVaultTest is Test {
    UserVault private _userVault;
    AddressManager private _currencyManager;
    AddressManager private _collectionManager;
    AddressManager private _oldCollectionManager;

    SampleToken private _token;
    SampleCollection private _collection;
    SampleOldCollection private _oldCollection;
    uint256 private _tokenId = 1;

    function setUp() public {
        _token = new SampleToken();
        _collection = new SampleCollection();
        _oldCollection = new SampleOldCollection();

        address[] memory nothing;
        _currencyManager = new AddressManager(nothing);
        _collectionManager = new AddressManager(nothing);
        _oldCollectionManager = new AddressManager(nothing);

        vm.prank(_currencyManager.owner());
        _currencyManager.add(address(_token));
        vm.prank(_collectionManager.owner());
        _collectionManager.add(address(_collection));
        vm.prank(_oldCollectionManager.owner());
        _oldCollectionManager.add(address(_oldCollection));

        _userVault =
            new UserVault(address(_currencyManager), address(_collectionManager), address(_oldCollectionManager));

        _collection.mint(address(this), _tokenId);
        _collection.approve(address(_userVault), _tokenId);

        _oldCollection.mint(address(this), _tokenId);
    }

    function testMint() public {
        uint256 vaultId = _userVault.mint();

        assertEq(_userVault.balanceOf(address(this)), 1);
        assertEq(_userVault.ownerOf(vaultId), address(this));
    }

    function testBurn() public {
        uint256 vaultId = _userVault.mint();

        _userVault.burn(vaultId, address(this));

        assertEq(_userVault.balanceOf(address(this)), 0);
    }

    function testBurnNotApproved() public {
        uint256 vaultId = _userVault.mint();

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        vm.prank(address(9999));
        _userVault.burn(vaultId, address(9999));
    }

    function testDepositERC721() public {
        uint256 vaultId = _userVault.mint();

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);

        assertEq(_collection.ownerOf(_tokenId), address(_userVault));
        assertEq(_userVault.ERC721OwnerOf(address(_collection), _tokenId), vaultId);
    }

    function testDepositMultipleNFTs() public {
        uint256 extraERC721 = 2;
        _collection.mint(address(this), extraERC721);
        _collection.approve(address(_userVault), extraERC721);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = _tokenId;
        tokenIds[1] = extraERC721;

        uint256 vaultId = _userVault.mint();
        _userVault.depositERC721s(vaultId, address(_collection), tokenIds);

        for (uint256 i = 0; i < tokenIds.length;) {
            assertEq(_collection.ownerOf(tokenIds[i]), address(_userVault));
            assertEq(_userVault.ERC721OwnerOf(address(_collection), tokenIds[i]), vaultId);
            unchecked {
                ++i;
            }
        }
    }

    function testDepositSingleNotWhitelistedError() public {
        uint256 vaultId = _userVault.mint();

        vm.expectRevert(abi.encodeWithSignature("CollectionNotWhitelistedError()"));
        _userVault.depositERC721(vaultId, address(9999), _tokenId);
    }

    function testDepositManyNotWhitelistedError() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        uint256 vaultId = _userVault.mint();

        vm.expectRevert(abi.encodeWithSignature("CollectionNotWhitelistedError()"));
        _userVault.depositERC721s(vaultId, address(9999), tokenIds);
    }

    function testDepositERC20() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 1000;
        _token.mint(address(this), amount);
        _token.approve(address(_userVault), amount);

        uint256 originalBalance = _token.balanceOf(address(_userVault));
        _userVault.depositERC20(vaultId, address(_token), amount);

        assertEq(_token.balanceOf(address(_userVault)), originalBalance + amount);
        assertEq(_userVault.ERC20BalanceOf(vaultId, address(_token)), amount);
    }

    function testDepositERC20NotWhitelistedError() public {
        uint256 vaultId = _userVault.mint();

        vm.expectRevert(abi.encodeWithSignature("CurrencyNotWhitelistedError()"));
        _userVault.depositERC20(vaultId, address(9999), 100);
    }

    function testDepositERC20WrongMethod() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 100;
        /// @dev separate variable to trigger the expected on the `depositERC20` call
        address ethAddr = _userVault.ETH();
        vm.deal(address(this), amount);
        vm.expectRevert(abi.encodeWithSignature("WrongMethodError()"));
        _userVault.depositERC20(vaultId, ethAddr, amount);
    }

    function testDepositEth() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 100;
        vm.deal(address(this), amount);

        uint256 originalBalance = address(_userVault).balance;
        _userVault.depositEth{value: amount}(vaultId);

        assertEq(_userVault.ERC20BalanceOf(vaultId, _userVault.ETH()), amount);
        assertEq(address(_userVault).balance, originalBalance + amount);
    }

    function testWithdrawERC721() public {
        uint256 vaultId = _userVault.mint();

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);
        _userVault.burn(vaultId, address(this));

        _userVault.withdrawERC721(vaultId, address(_collection), _tokenId);
        assertEq(_collection.ownerOf(_tokenId), address(this));
    }

    function testWithdrawAssetNotOwned() public {
        uint256 vaultId = _userVault.mint();

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);
        _userVault.burn(vaultId, address(this));

        address otherUser = address(9999);
        vm.startPrank(otherUser);
        uint256 otherVaultId = _userVault.mint();
        _userVault.burn(otherVaultId, otherUser);
        vm.expectRevert(abi.encodeWithSignature("AssetNotOwnedError()"));
        _userVault.withdrawERC721(otherVaultId, address(_collection), _tokenId);
        vm.stopPrank();
    }

    function testWithdrawERC721NotReadyForWithdrawalNeverBurnt() public {
        uint256 vaultId = _userVault.mint();

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        _userVault.withdrawERC721(vaultId, address(_collection), _tokenId);
    }

    function testWithdrawERC721NotReadyForWithdrawalWrongRecipient() public {
        uint256 vaultId = _userVault.mint();

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);
        _userVault.burn(vaultId, address(this));

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        vm.prank(address(9999));
        _userVault.withdrawERC721(vaultId, address(_collection), _tokenId);
    }

    function testWithdrawERC20() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 1000;
        _token.mint(address(this), amount);
        _token.approve(address(_userVault), amount);

        _userVault.depositERC20(vaultId, address(_token), amount);
        _userVault.burn(vaultId, address(this));

        _userVault.withdrawERC20(vaultId, address(_token));
    }

    function testWithdrawERC20NotReadyForWithdrawalNeverBurnt() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 1000;
        _token.mint(address(this), amount);
        _token.approve(address(_userVault), amount);

        _userVault.depositERC20(vaultId, address(_token), amount);

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        _userVault.withdrawERC20(vaultId, address(_token));
    }

    function testWithdrawERC20NotReadyForWithdrawalWrongRecipient() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 1000;
        _token.mint(address(this), amount);
        _token.approve(address(_userVault), amount);

        _userVault.depositERC20(vaultId, address(_token), amount);
        _userVault.burn(vaultId, address(this));

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        vm.prank(address(9999));
        _userVault.withdrawERC20(vaultId, address(_token));
    }

    function testWithdrawEth() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 100;
        vm.deal(address(this), amount);
        _userVault.depositEth{value: amount}(vaultId);
        _userVault.burn(vaultId, address(this));

        _userVault.withdrawEth(vaultId);
        assertEq(address(this).balance, amount);
    }

    function testWithdrawEthNeverBurnt() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 100;
        vm.deal(address(this), amount);
        _userVault.depositEth{value: amount}(vaultId);

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        _userVault.withdrawEth(vaultId);
    }

    function testWithdrawEthWrongRecipient() public {
        uint256 vaultId = _userVault.mint();

        uint256 amount = 100;
        vm.deal(address(this), amount);
        _userVault.depositEth{value: amount}(vaultId);
        _userVault.burn(vaultId, address(this));

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        vm.prank(address(9999));
        _userVault.withdrawEth(vaultId);
    }

    function testBurnAndWithdraw() public {
        uint256 vaultId = _userVault.mint();
        uint256 amount = 100;

        vm.deal(address(this), amount);
        _userVault.depositEth{value: amount}(vaultId);

        _token.mint(address(this), amount);
        _token.approve(address(_userVault), amount);
        _userVault.depositERC20(vaultId, address(_token), amount);

        _userVault.depositERC721(vaultId, address(_collection), _tokenId);

        _oldCollection.approve(address(_userVault), _tokenId);
        _userVault.depositOldERC721(vaultId, address(_oldCollection), _tokenId);

        address[] memory collections = new address[](1);
        collections[0] = address(_collection);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;

        address[] memory oldCollections = new address[](1);
        oldCollections[0] = address(_oldCollection);

        address[] memory tokens = new address[](1);
        tokens[0] = address(_token);

        _userVault.burnAndWithdraw(vaultId, collections, tokenIds, oldCollections, tokenIds, tokens);

        assertEq(_collection.ownerOf(_tokenId), address(this));
        assertEq(_oldCollection.ownerOf(_tokenId), address(this));
        assertEq(_token.balanceOf(address(this)), amount);
        assertEq(address(this).balance, amount);
    }

    function testBurnAndWithdrawNotApproved() public {
        uint256 vaultId = _userVault.mint();

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        vm.prank(address(9999));
        _userVault.burnAndWithdraw(
            vaultId, new address[](0), new uint256[](0), new address[](0), new uint256[](0), new address[](0)
        );
    }

    function testDepositVaultNotExists() public {
        uint256 amount = 100;

        vm.deal(address(this), amount);
        vm.expectRevert();
        _userVault.depositEth{value: amount}(1);
    }

    function testDepositOldERC721() public {
        uint256 vaultId = _userVault.mint();

        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        _userVault.depositOldERC721(vaultId, address(_oldCollection), _tokenId);

        _oldCollection.approve(address(_userVault), _tokenId);

        vm.expectRevert(abi.encodeWithSignature("InvalidCallerError()"));
        vm.prank(address(9999));
        _userVault.depositOldERC721(vaultId, address(_oldCollection), _tokenId);

        _userVault.depositOldERC721(vaultId, address(_oldCollection), _tokenId);

        assertEq(_oldCollection.ownerOf(_tokenId), address(_userVault));
        assertEq(_userVault.OldERC721OwnerOf(address(_oldCollection), _tokenId), vaultId);
    }

    function testDepositOldERC721s() public {
        _oldCollection.approve(address(_userVault), _tokenId);
        uint256 extraOldERC721 = 2;
        _oldCollection.mint(address(this), extraOldERC721);
        _oldCollection.approve(address(_userVault), extraOldERC721);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = _tokenId;
        tokenIds[1] = extraOldERC721;

        uint256 vaultId = _userVault.mint();
        _userVault.depositOldERC721s(vaultId, address(_oldCollection), tokenIds);

        for (uint256 i = 0; i < tokenIds.length;) {
            assertEq(_oldCollection.ownerOf(tokenIds[i]), address(_userVault));
            assertEq(_userVault.OldERC721OwnerOf(address(_oldCollection), tokenIds[i]), vaultId);
            unchecked {
                ++i;
            }
        }
    }

    function testWithdrawOldERC721() public {
        uint256 vaultId = _userVault.mint();

        _oldCollection.approve(address(_userVault), _tokenId);
        _userVault.depositOldERC721(vaultId, address(_oldCollection), _tokenId);

        vm.expectRevert(abi.encodeWithSignature("NotApprovedError(uint256)", vaultId));
        _userVault.withdrawOldERC721(vaultId, address(_oldCollection), _tokenId);

        _userVault.burn(vaultId, address(this));

        address otherUser = address(9999);

        vm.startPrank(otherUser);
        uint256 otherVaultId = _userVault.mint();
        _userVault.burn(otherVaultId, otherUser);
        vm.expectRevert(abi.encodeWithSignature("AssetNotOwnedError()"));
        _userVault.withdrawOldERC721(otherVaultId, address(_oldCollection), _tokenId);
        vm.stopPrank();

        _userVault.withdrawOldERC721(vaultId, address(_oldCollection), _tokenId);
        assertEq(_oldCollection.ownerOf(_tokenId), address(this));
    }

    fallback() external payable {}

    receive() external payable {}
}
