// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/AuctionLoanLiquidator.sol";
import "src/lib/LiquidationDistributor.sol";
import "src/interfaces/loans/IMultiSourceLoan.sol";
import "test/utils/SampleCollection.sol";
import "test/utils/SampleToken.sol";

contract AuctionLoanLiquidatorTest is Test {
    using FixedPointMathLib for uint256;

    uint256 private constant minBid = 5;

    address private constant loanContract = address(30);
    address private constant whitelistedCurrencies = address(40);
    address private constant whitelistedCollections = address(50);
    address private constant distributor = address(60);

    address private constant originator = address(70);
    address private constant settler = address(80);

    SampleCollection private immutable collection = new SampleCollection();
    SampleToken private immutable token = new SampleToken();
    uint256 private constant loanId = 1;
    uint256 private constant tokenId = 1;

    AuctionLoanLiquidator liquidator;

    function setUp() public {
        liquidator =
            new AuctionLoanLiquidator(distributor, whitelistedCurrencies, whitelistedCollections, 0, 120 minutes);
        vm.prank(liquidator.owner());
        liquidator.addLoanContract(loanContract);

        vm.mockCall(whitelistedCurrencies, abi.encodeWithSignature("isWhitelisted(address)"), abi.encode(true));

        vm.mockCall(whitelistedCollections, abi.encodeWithSignature("isWhitelisted(address)"), abi.encode(true));

        vm.etch(loanContract, "0xGarbage");
        vm.mockCall(loanContract, abi.encodeWithSignature("loanLiquidated(uint256,uint256)"), abi.encode());

        vm.etch(distributor, "0xGarbage");
        vm.mockCall(distributor, abi.encodeWithSelector(LiquidationDistributor.distribute.selector), abi.encode());
    }

    function testLiquidateLoanSuccess() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );

        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        assertEq(auction.loanAddress, loanContract);
        assertEq(auction.loanId, loanId);
        assertEq(auction.duration, 10);
        assertEq(collection.ownerOf(tokenId), address(liquidator));
    }

    function testGetAndSetDistributor() public {
        assertEq(liquidator.getLiquidationDistributor(), distributor);

        address newDistributor = address(9999);
        vm.prank(liquidator.owner());
        liquidator.updateLiquidationDistributor(newDistributor);

        assertEq(liquidator.getLiquidationDistributor(), newDistributor);

        vm.prank(address(8888));
        vm.expectRevert(bytes("UNAUTHORIZED"));
        liquidator.updateLiquidationDistributor(address(8888));
    }

    function testLiquidateLoanNotOwner() public {
        collection.mint(address(this), tokenId);

        vm.prank(loanContract);
        vm.expectRevert(abi.encodeWithSignature("NFTNotOwnedError(address)", address(this)));
        liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
    }

    function testZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressZeroError()"));
        new AuctionLoanLiquidator(address(0), whitelistedCurrencies, whitelistedCollections, 0, 120 minutes);

        vm.expectRevert(abi.encodeWithSignature("AddressZeroError()"));
        new AuctionLoanLiquidator(distributor, address(0), whitelistedCollections, 0, 120 minutes);

        vm.expectRevert(abi.encodeWithSignature("AddressZeroError()"));
        new AuctionLoanLiquidator(distributor, whitelistedCurrencies, address(0), 0, 120 minutes);
    }

    function testLiquidateLoanNotAccepted() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(liquidator.owner());
        liquidator.removeLoanContract(loanContract);
        vm.expectRevert(abi.encodeWithSignature("LoanNotAcceptedError(address)", loanContract));
        vm.prank(loanContract);
        liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        vm.prank(liquidator.owner());
        liquidator.addLoanContract(loanContract);
    }

    function testDoubleLiquidate() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        vm.expectRevert(abi.encodeWithSignature("AuctionAlreadyInProgressError()"));
        vm.prank(loanContract);
        liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
    }

    function testPlaceFirstBidSuccess() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);

        assertEq(token.balanceOf(address(liquidator)), 10);
        assertEq(token.balanceOf(address(this)), 90);
        assertEq(auction.highestBid, 10);
        assertEq(auction.highestBidder, address(this));
    }

    function testPlaceFirstBidMinBidError() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        vm.expectRevert(abi.encodeWithSignature("MinBidError(uint256)", minBid - 1));
        liquidator.placeBid(address(collection), tokenId, auction, minBid - 1);
    }

    function testPlaceFirstBidNoAuction() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        vm.expectRevert(abi.encodeWithSignature("InvalidHashAuctionError()"));
        liquidator.placeBid(address(collection), tokenId + 1, auction, 10);
    }

    function testPlaceSecondBidSuccess() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);

        address userA = address(100);
        token.mint(userA, 100);
        vm.startPrank(userA);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 20);
        vm.stopPrank();

        assertEq(auction.highestBid, 20);
        assertEq(auction.highestBidder, userA);
        assertEq(token.balanceOf(address(liquidator)), 20);
        assertEq(token.balanceOf(address(this)), 100);
        assertEq(token.balanceOf(userA), 80);
    }

    function testPlaceSecondBidMinBidFail() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);

        address userA = address(100);
        token.mint(userA, 100);
        vm.startPrank(userA);
        token.approve(address(liquidator), 100);
        vm.expectRevert(abi.encodeWithSignature("MinBidError(uint256)", 10));
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);
        vm.stopPrank();
    }

    function testPlaceBidAuctionOver() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        address otherBidder = address(101);
        token.mint(otherBidder, 100);
        vm.startPrank(otherBidder);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        vm.warp(block.timestamp + 15 minutes);
        vm.expectRevert(
            abi.encodeWithSignature("AuctionOverError(uint96)", 601) // Ten minutes + 1 second
        );
        liquidator.placeBid(address(collection), tokenId, auction, 50);
    }

    function testSecondBidWithinMinMargin() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        address otherBidder = address(101);
        token.mint(otherBidder, 100);
        vm.startPrank(otherBidder);
        token.approve(address(liquidator), 100);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 5);

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        vm.warp(block.timestamp + 5 minutes);
        auction = liquidator.placeBid(address(collection), tokenId, auction, 10);
        vm.stopPrank();

        assertEq(auction.highestBid, 10);
    }

    function testBidsWithinMinMarginMaxExtension() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        address otherBidder = address(101);
        token.mint(otherBidder, 1e18);

        vm.startPrank(otherBidder);
        token.approve(address(liquidator), 1e18);
        uint256 ts = block.timestamp;
        uint256 bid = 10;
        uint256 maxExtension = liquidator.getMaxExtension();
        uint256 maxTs = auction.startTime + auction.duration + maxExtension;
        while (ts < maxTs) {
            auction = liquidator.placeBid(address(collection), tokenId, auction, bid);
            ts += 10 minutes - 1;
            vm.warp(ts);
            bid = bid.mulDivUp(110, 100);
        }
        vm.expectRevert(abi.encodeWithSignature("AuctionOverError(uint96)", maxTs));
        liquidator.placeBid(address(collection), tokenId, auction, bid);
        vm.stopPrank();
    }

    function testPlaceBidAuctionOverNoBids() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        token.mint(address(this), 100);
        token.approve(address(liquidator), 100);
        vm.warp(block.timestamp + 15);
        liquidator.placeBid(address(collection), tokenId, auction, 10);
        assertEq(token.balanceOf(address(liquidator)), 10);
    }

    function testSettleSuccess() public {
        uint256 originalBalanceLoanContract = token.balanceOf(loanContract);
        address userA = address(100);
        uint256 mint = 1e5;
        uint256 bid = 1e3;
        IAuctionLoanLiquidator.Auction memory auction = _setupAuctionAndBid(userA, mint, bid, 1 days);

        uint256 expectedTriggerFee = bid.mulDivDown(liquidator.getTriggerFee(), 10000);

        vm.warp(block.timestamp + auction.duration + 1);
        vm.prank(settler);
        liquidator.settleAuction(auction, _getSampleLoan());

        assertEq(token.balanceOf(userA), mint - bid);
        assertEq(token.balanceOf(originator), expectedTriggerFee);
        assertEq(token.balanceOf(settler), expectedTriggerFee);
        assertEq(token.allowance(address(liquidator), distributor), bid - 2 * expectedTriggerFee);
        assertEq(token.balanceOf(address(liquidator)), originalBalanceLoanContract + bid - 2 * expectedTriggerFee);
        assertEq(collection.ownerOf(tokenId), userA);
    }

    function testSettleNotOverErrorNoMargin() public {
        IAuctionLoanLiquidator.Auction memory auction = _setupAuctionAndBid(address(9999), 1e5, 1e3, 5);
        vm.prank(settler);
        vm.expectRevert(abi.encodeWithSignature("AuctionNotOverError(uint96)", auction.lastBidTime + 10 minutes));

        liquidator.settleAuction(auction, _getSampleLoan());
    }

    function testSettleNotOverErrorBeforeExpiration() public {
        uint96 duration = 1 days;
        IAuctionLoanLiquidator.Auction memory auction = _setupAuctionAndBid(address(9999), 1e5, 1e3, duration);

        vm.warp(block.timestamp + duration - 1);
        vm.prank(settler);
        vm.expectRevert(abi.encodeWithSignature("AuctionNotOverError(uint96)", auction.startTime + auction.duration));
        liquidator.settleAuction(auction, _getSampleLoan());
    }

    function testSettleNoBidsError() public {
        collection.mint(address(liquidator), tokenId);

        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), uint96(10), minBid, address(this)
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        vm.warp(block.timestamp + auction.duration + 1);
        vm.expectRevert(abi.encodeWithSignature("NoBidsError()"));
        liquidator.settleAuction(auction, _getSampleLoan());
    }

    function _setupAuctionAndBid(address _user, uint256 _mint, uint256 _bid, uint96 _duration)
        private
        returns (IAuctionLoanLiquidator.Auction memory)
    {
        collection.mint(address(liquidator), tokenId);
        vm.prank(loanContract);
        bytes memory encodedAuction = liquidator.liquidateLoan(
            loanId, address(collection), tokenId, address(token), _duration, minBid, originator
        );
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        vm.startPrank(_user);
        token.mint(_user, _mint);
        token.approve(address(liquidator), _mint);
        auction = liquidator.placeBid(address(collection), tokenId, auction, _bid);
        vm.stopPrank();
        return auction;
    }

    function _getSampleLoan() private view returns (IMultiSourceLoan.Loan memory) {
        IMultiSourceLoan.Tranche[] memory tranche;

        return IMultiSourceLoan.Loan(
            address(100), tokenId, address(collection), address(token), 1e5, block.timestamp, 30 days, tranche, 0
        );
    }
}
