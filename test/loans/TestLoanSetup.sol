// SPDX-License-Identifier:19 AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";

import "@solmate/utils/FixedPointMathLib.sol";
import "@openzeppelin/utils/cryptography/ECDSA.sol";
import "src/interfaces/loans/IBaseLoan.sol";
import "src/lib/AddressManager.sol";
import "src/lib/loans/BaseLoan.sol";
import "src/lib/utils/Hash.sol";
import "src/lib/utils/Interest.sol";
import "src/lib/utils/WithProtocolFee.sol";
import "test/utils/SampleCollection.sol";
import "test/utils/SampleToken.sol";

abstract contract TestLoanSetup is Test {
    using ECDSA for bytes32;
    using FixedPointMathLib for uint96;
    using Hash for IMultiSourceLoan.LoanOffer;
    using Interest for IMultiSourceLoan.LoanOffer;

    uint96 internal constant BPS = 10000;

    uint256 internal constant TRIGGER_FEE = 100;

    address internal constant liquidationContract = address(50);
    WithProtocolFee.ProtocolFee internal protocolFee = WithProtocolFee.ProtocolFee(address(60), 0);

    /// @notice Sample borrower
    address internal constant userA = address(1000);
    /// @notice Sample lender
    address internal constant userB = address(2000);
    /// @notice Sample reneg / second lender
    address internal constant userC = address(3000);

    SampleToken internal immutable testToken = new SampleToken();
    SampleCollection internal immutable collateralCollection = new SampleCollection();
    uint256 internal constant collateralTokenId = 1;

    AddressManager internal currencyManager;
    AddressManager internal collectionManager;

    mapping(address => uint256) internal _offerId;

    function baseSetup() internal {
        address[] memory currencyArr = new address[](1);
        currencyArr[0] = address(testToken);
        currencyManager = new AddressManager(currencyArr);
        address[] memory collectionArr = new address[](1);
        collectionArr[0] = address(collateralCollection);
        collectionManager = new AddressManager(collectionArr);

        uint256 tokenAmount = 1e10;
        collateralCollection.mint(userA, collateralTokenId);
        testToken.mint(userB, tokenAmount);
        testToken.mint(userC, tokenAmount);

        vm.mockCall(
            liquidationContract,
            abi.encodeWithSignature("liquidateLoan(uint256,address,uint256,address,uint96,uint256,address)"),
            abi.encode("0x0")
        );
        vm.mockCall(
            liquidationContract,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );
        // It has code.length == 1...
        vm.mockCall(
            userA,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );
        vm.etch(userA, "0xGarbage");
        vm.mockCall(userA, abi.encodeWithSignature("isValidSignature(bytes32,bytes)"), abi.encode(bytes4(0x1626ba7e)));

        vm.mockCall(
            userB,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );
        vm.etch(userB, "0xGarbage");
        vm.mockCall(userB, abi.encodeWithSignature("isValidSignature(bytes32,bytes)"), abi.encode(bytes4(0x1626ba7e)));

        vm.mockCall(
            userC,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );
        vm.mockCall(userC, abi.encodeWithSignature("isValidSignature(bytes32,bytes)"), abi.encode(bytes4(0x1626ba7e)));
    }

    function loanSetUp(address _loan) internal {
        vm.prank(userB);
        testToken.approve(_loan, type(uint256).max);

        vm.prank(userC);
        testToken.approve(_loan, type(uint256).max);

        vm.prank(userA);
        collateralCollection.approve(_loan, collateralTokenId);
    }

    function _getSampleOffer(address _collection, uint256 _tokenId, uint256 amount)
        internal
        returns (IMultiSourceLoan.LoanOffer memory)
    {
        _offerId[userB]++;
        return IMultiSourceLoan.LoanOffer(
            _offerId[userB],
            userB,
            0,
            0,
            _collection,
            _tokenId,
            address(testToken),
            amount,
            5000,
            10 days,
            30 days,
            0,
            new IBaseLoan.OfferValidator[](0)
        );
    }

    function _addUser(address _thisUser, uint256 _mint, address _loan) internal {
        testToken.mint(_thisUser, _mint);
        vm.etch(_thisUser, "0xGarbage");
        vm.mockCall(
            _thisUser, abi.encodeWithSignature("isValidSignature(bytes32,bytes)"), abi.encode(bytes4(0x1626ba7e))
        );
        vm.prank(_thisUser);
        testToken.approve(_loan, type(uint256).max);
    }
}
