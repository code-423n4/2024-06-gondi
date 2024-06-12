// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/AuctionWithBuyoutLoanLiquidator.sol";
import "src/lib/LiquidationDistributor.sol";
import "src/lib/utils/Interest.sol";
import "src/interfaces/loans/IMultiSourceLoan.sol";
import "test/loans/MultiSourceCommons.sol";
import "test/utils/SampleCollection.sol";
import "test/utils/SampleToken.sol";

contract AuctionWithBuyoutLoanLiquidatorTest is MultiSourceCommons {
    using FixedPointMathLib for uint256;
    using Interest for uint256;

    address private constant distributor = address(60);
    address private constant originator = address(70);
    address private constant settler = address(80);
    address private constant loanManagerRegistry = address(90);

    AuctionWithBuyoutLoanLiquidator liquidator;

    function setUp() public override {
        super.setUp();

        liquidator = new AuctionWithBuyoutLoanLiquidator(
            distributor, address(currencyManager), address(collectionManager), loanManagerRegistry, 0, 3 days, 1 days
        );
        vm.prank(liquidator.owner());
        liquidator.addLoanContract(address(_msLoan));

        vm.mockCall(address(_msLoan), abi.encodeWithSignature("loanLiquidated(uint256,uint256)"), abi.encode());

        vm.etch(distributor, "0xGarbage");
        vm.mockCall(distributor, abi.encodeWithSelector(LiquidationDistributor.distribute.selector), abi.encode());

        vm.mockCall(
            loanManagerRegistry, abi.encodeWithSelector(ILoanManagerRegistry.isLoanManager.selector), abi.encode(false)
        );

        vm.prank(_msLoan.owner());
        _msLoan.updateLiquidationContract(address(liquidator));
    }

    function testSettleWithBuyout() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(3);

        vm.warp(loan.duration + 1 days);
        vm.prank(address(_msLoan));
        bytes memory encodedAuction = _msLoan.liquidateLoan(loanId, loan);
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        uint256[] memory balances = new uint256[](loan.tranche.length);
        uint256 largestIndex;
        for (uint256 i; i < loan.tranche.length;) {
            if (loan.tranche[i].principalAmount > loan.tranche[largestIndex].principalAmount) {
                largestIndex = i;
            }
            balances[i] = testToken.balanceOf(loan.tranche[i].lender);
            unchecked {
                ++i;
            }
        }

        uint256[] memory owed = new uint256[](loan.tranche.length);
        uint256 endTime = block.timestamp;
        uint256 totalOwed;
        for (uint256 i; i < loan.tranche.length;) {
            if (i != largestIndex) {
                uint256 principalAmount = loan.tranche[i].principalAmount;
                uint256 thisOwed = principalAmount + loan.tranche[i].accruedInterest
                    + principalAmount.getInterest(loan.tranche[i].aprBps, endTime - loan.tranche[i].startTime);
                owed[i] = thisOwed;
                totalOwed += thisOwed;
            }
            unchecked {
                ++i;
            }
        }

        uint256 triggerFee = totalOwed.mulDivDown(auction.triggerFee, BPS);
        address largestLender = loan.tranche[largestIndex].lender;
        vm.startPrank(largestLender);
        testToken.mint(largestLender, totalOwed + triggerFee);
        testToken.approve(address(liquidator), totalOwed);
        liquidator.settleWithBuyout(address(collateralCollection), collateralTokenId, auction, loan);
        vm.stopPrank();

        assertEq(testToken.balanceOf(auction.originator), triggerFee);
        assertEq(loan.tranche[largestIndex].lender, collateralCollection.ownerOf(collateralTokenId));
        for (uint256 i; i < loan.tranche.length;) {
            uint256 balance = testToken.balanceOf(loan.tranche[i].lender);
            if (i != largestIndex) {
                assertEq(balance, balances[i] + owed[i]);
            } else {
                /// we don't subtract since we minted the total owed to the largest lender
                assertEq(balance, balances[i]);
            }
            unchecked {
                ++i;
            }
        }
    }

    function testSettleWithBuyoutExpiredError() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(3);

        vm.warp(loan.duration + 1 days);
        vm.prank(address(_msLoan));
        bytes memory encodedAuction = _msLoan.liquidateLoan(loanId, loan);
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        vm.warp(block.timestamp + 2 days);
        /// @dev largest lender at index = 0
        address largestLender = loan.tranche[0].lender;
        vm.startPrank(largestLender);
        testToken.mint(largestLender, 1e18);
        testToken.approve(address(liquidator), 1e28);
        vm.expectRevert(
            abi.encodeWithSignature(
                "OptionToBuyExpiredError(uint256)", auction.startTime + liquidator.getTimeForMainLenderToBuy()
            )
        );
        liquidator.settleWithBuyout(address(collateralCollection), collateralTokenId, auction, loan);
        vm.stopPrank();
    }

    function testSettleWithBuyoutNotMainLenderError() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(3);

        vm.warp(loan.duration + 1 days);
        vm.prank(address(_msLoan));
        bytes memory encodedAuction = _msLoan.liquidateLoan(loanId, loan);
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        /// @dev largest lender at index = 0
        address largestLender = loan.tranche[0].lender;
        vm.startPrank(largestLender);
        testToken.mint(largestLender, 1e18);
        testToken.approve(address(liquidator), 1e28);
        vm.stopPrank();
        vm.prank(loan.tranche[1].lender);
        vm.expectRevert(abi.encodeWithSignature("NotMainLenderError()"));
        liquidator.settleWithBuyout(address(collateralCollection), collateralTokenId, auction, loan);
    }

    function testPlaceBidTooEarly() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(3);

        vm.warp(loan.duration + 1 days);
        vm.prank(address(_msLoan));
        bytes memory encodedAuction = _msLoan.liquidateLoan(loanId, loan);
        IAuctionLoanLiquidator.Auction memory auction = abi.decode(encodedAuction, (IAuctionLoanLiquidator.Auction));

        /// @dev largest lender at index = 0
        address largestLender = loan.tranche[0].lender;
        vm.startPrank(largestLender);
        testToken.mint(largestLender, 1e18);
        testToken.approve(address(liquidator), 1e28);
        vm.stopPrank();
        vm.expectRevert(
            abi.encodeWithSignature(
                "OptionToBuyStilValidError(uint256)", auction.startTime + liquidator.getTimeForMainLenderToBuy()
            )
        );
        liquidator.placeBid(address(collateralCollection), collateralTokenId, auction, loan.principalAmount / 2);
    }

    function testSetTimeForMainLenderToBuy() public {
        assertEq(liquidator.getTimeForMainLenderToBuy(), 1 days);

        vm.prank(address(11111));
        vm.expectRevert(bytes("UNAUTHORIZED"));
        liquidator.setTimeForMainLenderToBuy(2 days);

        uint256 invalidInput = liquidator.MAX_TIME_FOR_MAIN_LENDER_TO_BUY() + 1;
        vm.prank(liquidator.owner());
        vm.expectRevert(abi.encodeWithSignature("InvalidInputError()"));
        liquidator.setTimeForMainLenderToBuy(invalidInput);

        vm.prank(liquidator.owner());
        liquidator.setTimeForMainLenderToBuy(invalidInput - 1);
        assertEq(liquidator.getTimeForMainLenderToBuy(), invalidInput - 1);
    }
}
