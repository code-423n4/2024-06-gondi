// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.21;

import "@openzeppelin/utils/cryptography/ECDSA.sol";
import "@openzeppelin/utils/cryptography/MessageHashUtils.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/interfaces/external/IReservoir.sol";
import "src/interfaces/callbacks/ILoanCallback.sol";
import "src/lib/loans/MultiSourceLoan.sol";
import "src/lib/utils/Hash.sol";
import "src/lib/utils/Interest.sol";
import "test/loans/MultiSourceCommons.sol";
import "test/loans/TestLoanSetup.sol";

contract MultiSourceLoanTest is MultiSourceCommons {
    using FixedPointMathLib for uint256;
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    using Interest for uint256;
    using Interest for IMultiSourceLoan.Loan;
    using Hash for IMultiSourceLoan.LoanOffer;
    using Hash for IMultiSourceLoan.ExecutionData;
    using Hash for IMultiSourceLoan.Loan;
    using Hash for IMultiSourceLoan.RenegotiationOffer;
    using Hash for IMultiSourceLoan.SignableRepaymentData;

    function testSetMinLockPeriod() public {
        MultiSourceLoan testMsLoan = _getOtherMsLoan();
        uint256 otherPeriod = 100;
        vm.prank(testMsLoan.owner());
        testMsLoan.setMinLockPeriod(otherPeriod);
        assertEq(testMsLoan.getMinLockPeriod(), otherPeriod);

        address otherAddress = address(8888);
        vm.prank(otherAddress);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        testMsLoan.setMinLockPeriod(otherPeriod);
    }

    function testUpdateImprovementMinimum() public {
        MultiSourceLoan testMsLoan = _getOtherMsLoan();
        uint256 newMin = 100;
        vm.prank(testMsLoan.owner());
        testMsLoan.updateMinImprovementApr(newMin);

        assertEq(testMsLoan.getMinImprovementApr(), newMin);

        address otherAddress = address(8888);
        vm.prank(otherAddress);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        testMsLoan.updateMinImprovementApr(newMin);
    }

    function testUpdateProtocolFee() public {
        MultiSourceLoan testMsLoan = _getOtherMsLoan();
        WithProtocolFee.ProtocolFee memory newFee = WithProtocolFee.ProtocolFee(address(111), 1);

        vm.prank(testMsLoan.owner());
        testMsLoan.updateProtocolFee(newFee);
        assertEq(testMsLoan.getPendingProtocolFee().recipient, newFee.recipient);
        assertEq(testMsLoan.getPendingProtocolFee().fraction, newFee.fraction);
        assertEq(testMsLoan.getPendingProtocolFeeSetTime(), block.timestamp);

        address owner = testMsLoan.owner();
        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        vm.prank(owner);
        testMsLoan.setProtocolFee();

        vm.warp(testMsLoan.FEE_UPDATE_NOTICE() + 1);
        vm.prank(testMsLoan.owner());
        testMsLoan.setProtocolFee();

        MultiSourceLoan.ProtocolFee memory protocolFee = testMsLoan.getProtocolFee();
        assertEq(protocolFee.fraction, newFee.fraction);
        assertEq(protocolFee.recipient, newFee.recipient);

        assertEq(testMsLoan.getProtocolFee().fraction, newFee.fraction);
        assertEq(testMsLoan.getProtocolFee().recipient, newFee.recipient);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        testMsLoan.updateProtocolFee(newFee);
    }

    function testTransferOwnership() public {
        address otherUser = address(111111);

        vm.startPrank(otherUser);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        _msLoan.requestTransferOwner(otherUser);
        vm.stopPrank();

        vm.prank(_msLoan.owner());
        _msLoan.requestTransferOwner(otherUser);

        assertEq(_msLoan.pendingOwner(), otherUser);

        vm.prank(_msLoan.owner());
        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        _msLoan.transferOwnership();

        vm.warp(_msLoan.MIN_WAIT_TIME() + 1);

        vm.prank(_msLoan.owner());
        vm.expectRevert(abi.encodeWithSignature("InvalidInputError()"));
        _msLoan.transferOwnership();

        vm.prank(otherUser);
        _msLoan.transferOwnership();

        assertEq(_msLoan.owner(), otherUser);
    }

    function testEmitLoanSuccess() public {
        (, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        assertEq(collateralCollection.ownerOf(collateralTokenId), address(_msLoan));
        assertEq(testToken.balanceOf(_borrower), loan.principalAmount);
        assertEq(loan.tranche.length, 1);
        IMultiSourceLoan.Tranche memory tranche = loan.tranche[0];
        assertEq(tranche.lender, address(_originalLender));
        assertEq(tranche.principalAmount, _INITIAL_PRINCIPAL);
    }

    function testEmitLoanPrincipalReceiverNotBorrowerSuccess() public {
        address _receiver;
        (, IMultiSourceLoan.Loan memory loan) = _getInitialLoanWithPrincipalReceiver(_receiver);

        assertEq(testToken.balanceOf(_receiver), loan.principalAmount);
        assertEq(testToken.balanceOf(_borrower), 0);
    }

    function testEmitLoanSuccessWithLenderSignature() public {
        uint256 privateKey = 100;
        address otherLender = vm.addr(privateKey);

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        testToken.mint(otherLender, loanOffer.principalAmount);
        vm.prank(otherLender);
        testToken.approve(address(_msLoan), loanOffer.principalAmount);
        loanOffer.lender = otherLender;
        bytes32 offerHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(loanOffer.hash());
        (uint8 vOffer, bytes32 rOffer, bytes32 sOffer) = vm.sign(privateKey, offerHash);
        loanOffer.duration = 30 days;
        IMultiSourceLoan.ExecutionData memory executionData = _sampleExecutionData(loanOffer, _borrower);
        executionData.offerExecution[0].lenderOfferSignature = abi.encodePacked(rOffer, sOffer, vOffer);

        (, IMultiSourceLoan.Loan memory loan) =
            _msLoan.emitLoan(IMultiSourceLoan.LoanExecutionData(executionData, _borrower, ""));

        IMultiSourceLoan.Tranche memory tranche = loan.tranche[0];
        assertEq(testToken.balanceOf(loan.borrower), loan.principalAmount);
        assertEq(tranche.lender, address(otherLender));
        assertEq(tranche.principalAmount, _INITIAL_PRINCIPAL);
    }

    function testEmitLoanInvalidDurationError() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        uint256 amount = loanOffer.principalAmount / 2;
        loanOffer.fee = 10;
        loanOffer.duration = 30 days;

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.duration = loanOffer.duration + 1;
        lde.executionData.offerExecution[0].amount = amount;

        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("InvalidDurationError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitLoanInvalidBorrowerSignature() public {
        uint256 privateKey = 100;
        address otherBorrower = vm.addr(privateKey);
        uint256 otherToken = collateralTokenId + 1;

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), otherToken, _INITIAL_PRINCIPAL);

        collateralCollection.mint(otherBorrower, otherToken);
        vm.prank(otherBorrower);
        collateralCollection.approve(address(_msLoan), otherToken);
        loanOffer.nftCollateralTokenId = otherToken;

        loanOffer.duration = 30 days;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.tokenId = otherToken;
        lde.borrower = otherBorrower;
        bytes32 executionDataHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(lde.executionData.hash());
        (uint8 vOffer, bytes32 rOffer, bytes32 sOffer) = vm.sign(privateKey + 1, executionDataHash);
        lde.borrowerOfferSignature = abi.encodePacked(rOffer, sOffer, vOffer);

        vm.expectRevert(abi.encodeWithSignature("InvalidSignatureError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitLoanInvalidLenderSignature() public {
        uint256 privateKey = 100;
        address otherLender = vm.addr(privateKey);

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        testToken.mint(otherLender, loanOffer.principalAmount);
        vm.prank(otherLender);
        testToken.approve(address(_msLoan), loanOffer.principalAmount);
        loanOffer.lender = otherLender;

        bytes32 offerHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(loanOffer.hash());
        (uint8 vOffer, bytes32 rOffer, bytes32 sOffer) = vm.sign(privateKey + 1, offerHash);
        loanOffer.duration = 30 days;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.offerExecution[0].lenderOfferSignature = abi.encodePacked(rOffer, sOffer, vOffer);

        vm.expectRevert(abi.encodeWithSignature("InvalidSignatureError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitLoanPartialFillSuccess() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        uint256 amount = loanOffer.principalAmount / 2;
        loanOffer.fee = 10;
        loanOffer.duration = 30 days;

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.offerExecution[0].amount = amount;

        vm.prank(_borrower);
        (, IMultiSourceLoan.Loan memory loan) = _msLoan.emitLoan(lde);

        assertEq(collateralCollection.ownerOf(collateralTokenId), address(_msLoan));
        assertEq(testToken.balanceOf(_borrower), (loanOffer.principalAmount - loanOffer.fee) / 2);
        assertEq(loan.principalAmount, amount);
        assertEq(loan.principalAmount, amount);
    }

    function testEmitManyLoanSuccess() public {
        uint256 totalOffers = 2;
        bytes[] memory encodedData = new bytes[](totalOffers);
        IMultiSourceLoan.LoanExecutionData[] memory lde = new IMultiSourceLoan.LoanExecutionData[](totalOffers);
        lde[0].executionData.tokenId = collateralTokenId;
        lde[1].executionData.tokenId = _setupSecondNft();

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < totalOffers;) {
            IMultiSourceLoan.ExecutionData memory executionData = lde[i].executionData;
            executionData.offerExecution = new IMultiSourceLoan.OfferExecution[](1);
            executionData.offerExecution[0].offer =
                _getSampleOffer(address(collateralCollection), executionData.tokenId, _INITIAL_PRINCIPAL / 2);
            executionData.offerExecution[0].amount = executionData.offerExecution[0].offer.principalAmount / 2;
            executionData.callbackData = "";
            totalAmount += executionData.offerExecution[0].amount;
            executionData.expirationTime = executionData.offerExecution[0].offer.expirationTime;
            lde[i].borrower = _borrower;
            executionData.principalReceiver = _borrower;
            executionData.offerExecution[0].lenderOfferSignature = abi.encode(0);
            lde[i].borrowerOfferSignature = abi.encode(0);
            encodedData[i] = abi.encodeWithSelector(IMultiSourceLoan.emitLoan.selector, lde[i]);
            unchecked {
                ++i;
            }
        }

        vm.prank(_borrower);
        _msLoan.multicall(encodedData);
        assertEq(totalAmount, testToken.balanceOf(_borrower));
    }

    function testEmitWithLenderOfferExpired() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.warp(loanOffer.expirationTime + 1);
        lde.executionData.expirationTime += 2;
        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("ExpiredOfferError(uint256)", loanOffer.expirationTime));

        _msLoan.emitLoan(lde);
    }

    function testEmitWithBorrowerOfferExpired() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        vm.warp(loanOffer.expirationTime - 1);
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.expirationTime -= 2;
        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("ExpiredOfferError(uint256)", loanOffer.expirationTime - 2));
        _msLoan.emitLoan(lde);
    }

    function testEmitLoanPartialFillFail() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        uint256 amount = loanOffer.principalAmount * 2;
        lde.executionData.offerExecution[0].amount = amount;
        vm.prank(_borrower);
        vm.expectRevert(
            abi.encodeWithSignature("InvalidAmountError(uint256,uint256)", amount, loanOffer.principalAmount)
        );
        _msLoan.emitLoan(lde);
    }

    function testEmitWithCallback() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.duration = 30 days;

        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(_borrower);
        vm.mockCall(
            _borrower,
            abi.encodeWithSelector(ILoanCallback.afterPrincipalTransfer.selector),
            abi.encode(ILoanCallback.afterPrincipalTransfer.selector)
        );

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.callbackData = abi.encode(0);
        vm.expectCall(_borrower, abi.encodeWithSelector(ILoanCallback.afterPrincipalTransfer.selector));
        vm.prank(_borrower);
        _msLoan.emitLoan(lde);
    }

    function testEmitZeroTokenId() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        uint256 tokenId = 0;
        loanOffer.nftCollateralTokenId = tokenId;
        collateralCollection.mint(userA, tokenId);

        vm.startPrank(_borrower);
        collateralCollection.approve(address(_msLoan), tokenId);
        _msLoan.emitLoan(_sampleLoanExecutionData(loanOffer));
        vm.stopPrank();

        assertEq(collateralCollection.ownerOf(tokenId), address(_msLoan));
    }

    function testEmitZeroTokenIdInvalid() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        uint256 tokenId = 0;
        loanOffer.nftCollateralTokenId = tokenId;
        collateralCollection.mint(userA, tokenId);

        vm.startPrank(_borrower);
        collateralCollection.approve(address(_msLoan), tokenId);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.tokenId = 1;
        vm.expectRevert(abi.encodeWithSignature("InvalidCollateralIdError()"));
        _msLoan.emitLoan(lde);
        vm.stopPrank();
    }

    function testEmitCollection() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, 100);
        IBaseLoan.OfferValidator[] memory validators = new IBaseLoan.OfferValidator[](1);
        validators[0] = IBaseLoan.OfferValidator(address(0), abi.encode(0));
        loanOffer.validators = validators;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        loanOffer.nftCollateralTokenId = 0;
        vm.prank(userA);
        (, IMultiSourceLoan.Loan memory loan) = _msLoan.emitLoan(lde);

        assertEq(collateralCollection.ownerOf(collateralTokenId), address(_msLoan));
        assertEq(testToken.balanceOf(_borrower), loanOffer.principalAmount);
        assertEq(loan.tranche[0].lender, _originalLender);
    }

    function testEmitNotWhitelistedCallback() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.duration = 30 days;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.callbackData = abi.encode(0);
        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitNotWhitelistedInvalidSelector() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.duration = 30 days;

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.callbackData = abi.encode(0);

        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(_borrower);
        vm.mockCall(_borrower, abi.encodeWithSelector(ILoanCallback.afterPrincipalTransfer.selector), abi.encode(0x0));

        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitWithExecutedOffer() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.expirationTime = block.timestamp + 15 days;
        loanOffer.duration = 30 days;

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.startPrank(_borrower);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _msLoan.emitLoan(lde);
        vm.warp(1 days);
        uint256 owed = loanOffer.principalAmount + loanOffer.principalAmount.getInterest(loanOffer.aprBps, 1 days);
        testToken.mint(_borrower, owed);
        testToken.approve(address(_msLoan), owed);
        _msLoan.repayLoan(_sampleRepaymentData(loanId, loan));
        vm.expectRevert(
            abi.encodeWithSignature(
                "CancelledOrExecutedOfferError(address,uint256)", loanOffer.lender, loanOffer.offerId
            )
        );
        _msLoan.emitLoan(lde);
        vm.stopPrank();
    }

    function testEmitWithCancelledOffer() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.expirationTime = block.timestamp + 15 days;
        loanOffer.duration = 30 days;

        vm.prank(loanOffer.lender);
        _msLoan.cancelOffer(loanOffer.offerId);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.startPrank(_borrower);
        vm.expectRevert(
            abi.encodeWithSignature(
                "CancelledOrExecutedOfferError(address,uint256)", loanOffer.lender, loanOffer.offerId
            )
        );
        _msLoan.emitLoan(lde);
        vm.stopPrank();
    }

    function testEmitWithCancelledMinOffer() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.expirationTime = block.timestamp + 15 days;
        loanOffer.duration = 30 days;

        vm.prank(loanOffer.lender);
        _msLoan.cancelAllOffers(loanOffer.offerId);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.startPrank(_borrower);
        vm.expectRevert(
            abi.encodeWithSignature(
                "CancelledOrExecutedOfferError(address,uint256)", loanOffer.lender, loanOffer.offerId
            )
        );
        _msLoan.emitLoan(lde);
        vm.stopPrank();
    }

    function testEmitWithOverCapacity() public {
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, 100);
        loanOffer.capacity = loanOffer.principalAmount + 1;
        loanOffer.nftCollateralTokenId = 0;
        IBaseLoan.OfferValidator[] memory validators = new IBaseLoan.OfferValidator[](1);
        validators[0] = IBaseLoan.OfferValidator(address(0), abi.encode(0));
        loanOffer.validators = validators;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.executionData.tokenId = collateralTokenId;
        vm.startPrank(_borrower);
        _msLoan.emitLoan(lde);

        uint256 newTokenId = collateralTokenId + 1;
        collateralCollection.mint(_borrower, newTokenId);
        collateralCollection.approve(address(_msLoan), newTokenId);

        vm.expectRevert(abi.encodeWithSignature("MaxCapacityExceededError()"));
        _msLoan.emitLoan(lde);
        vm.stopPrank();
    }

    function _getManyOffersLDE() private returns (IMultiSourceLoan.LoanExecutionData memory) {
        IMultiSourceLoan.LoanOffer memory firstOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        IMultiSourceLoan.LoanOffer memory secondOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        secondOffer.maxSeniorRepayment = firstOffer.principalAmount * 2;
        secondOffer.principalAmount *= 2;
        IMultiSourceLoan.OfferExecution[] memory offerExecutions = new IMultiSourceLoan.OfferExecution[](2);
        offerExecutions[0] = IMultiSourceLoan.OfferExecution(firstOffer, firstOffer.principalAmount, abi.encode(0));
        offerExecutions[1] = IMultiSourceLoan.OfferExecution(secondOffer, firstOffer.principalAmount, abi.encode(0));

        IMultiSourceLoan.ExecutionData memory executionData = IMultiSourceLoan.ExecutionData(
            offerExecutions, collateralTokenId, firstOffer.duration, firstOffer.expirationTime, _borrower, ""
        );
        return IMultiSourceLoan.LoanExecutionData(executionData, _borrower, "");
    }

    function testEmitManyOffers() public {
        (, IMultiSourceLoan.Loan memory loan) = _msLoan.emitLoan(_getManyOffersLDE());

        assertEq(loan.tranche.length, 2);
        assertEq(loan.principalAmount, _INITIAL_PRINCIPAL * 2);
        for (uint256 i; i < loan.tranche.length;) {
            assertEq(loan.tranche[i].principalAmount, _INITIAL_PRINCIPAL);
            unchecked {
                ++i;
            }
        }
    }

    function testEmitManyOffersInvalidPrincipal() public {
        IMultiSourceLoan.LoanExecutionData memory lde = _getManyOffersLDE();
        lde.executionData.offerExecution[1].offer.maxSeniorRepayment = _INITIAL_PRINCIPAL - 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidTrancheError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitManyOffersInvalidApr() public {
        IMultiSourceLoan.LoanExecutionData memory lde = _getManyOffersLDE();
        IMultiSourceLoan.LoanOffer memory firstOffer = lde.executionData.offerExecution[0].offer;
        lde.executionData.offerExecution[1].offer.maxSeniorRepayment = firstOffer.principalAmount
            + firstOffer.principalAmount.getInterest(firstOffer.aprBps, block.timestamp - 1) - 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidTrancheError()"));
        _msLoan.emitLoan(lde);
    }

    function testEmitManyOffersInvalidAddress() public {
        IMultiSourceLoan.LoanExecutionData memory lde = _getManyOffersLDE();
        lde.executionData.offerExecution[1].offer.principalAddress = address(9999999);

        vm.expectRevert(abi.encodeWithSignature("InvalidAddressesError()"));
        _msLoan.emitLoan(lde);

        lde = _getManyOffersLDE();
        lde.executionData.offerExecution[1].offer.nftCollateralAddress = address(9999999);
        vm.expectRevert(abi.encodeWithSignature("InvalidAddressesError()"));
        _msLoan.emitLoan(lde);
    }

    function testPartialRefinanceLockedTrancheEnd() public {
        MultiSourceLoan withLock = _setupMultiSourceLoanWithLock();
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = withLock.emitLoan(lde);

        uint256[] memory trancheIdx = new uint256[](1);
        trancheIdx[0] = loan.tranche.length - 1;
        IMultiSourceLoan.RenegotiationOffer memory refiOffer = _getSampleRefinancePartial(loanId, trancheIdx, loan);

        vm.warp(block.timestamp + loan.duration - 1);
        vm.prank(_refinanceLender);

        vm.expectRevert(abi.encodeWithSignature("LoanLockedError()"));
        withLock.refinancePartial(refiOffer, loan);
    }

    function testPartialRefinanceLockedTranche() public {
        MultiSourceLoan withLock = _setupMultiSourceLoanWithLock();
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = withLock.emitLoan(lde);

        uint256[] memory trancheIdx = new uint256[](1);
        trancheIdx[0] = loan.tranche.length - 1;
        IMultiSourceLoan.RenegotiationOffer memory refiOffer = _getSampleRefinancePartial(loanId, trancheIdx, loan);

        uint256 endLockupPeriod = _getEndLockup(loan, withLock.getMinLockPeriod());
        vm.warp(endLockupPeriod - 1);
        vm.prank(_refinanceLender);

        vm.expectRevert(abi.encodeWithSignature("TrancheCannotBeRefinancedError(uint256)", endLockupPeriod));
        withLock.refinancePartial(refiOffer, loan);

        vm.warp(endLockupPeriod + 1);
        vm.prank(_refinanceLender);
        (loanId, loan) = withLock.refinancePartial(refiOffer, loan);

        uint256 secondLockup = _getEndLockup(loan, withLock.getMinLockPeriod());
        IMultiSourceLoan.RenegotiationOffer memory refiFullOffer = IMultiSourceLoan.RenegotiationOffer(
            1, // renegotiationId
            loanId,
            _refinanceLender,
            0, // fee
            new uint256[](1), // trancheIndex
            loan.tranche[0].principalAmount,
            loan.tranche[0].aprBps.mulDivDown(9000, 10000), // 10% less
            secondLockup + 2,
            loan.duration
        );

        vm.warp(secondLockup - 1);
        vm.prank(_refinanceLender);
        vm.expectRevert(abi.encodeWithSignature("TrancheCannotBeRefinancedError(uint256)", secondLockup));
        withLock.refinanceFull(refiFullOffer, loan, abi.encode(""));

        vm.warp(secondLockup + 1);
        uint256 owed = 0;
        for (uint256 i = 0; i < loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        vm.startPrank(_refinanceLender);
        testToken.approve(address(withLock), owed);
        (, loan) = withLock.refinanceFull(refiFullOffer, loan, abi.encode(""));
        vm.stopPrank();

        assertEq(loan.tranche.length, 1);
    }

    function testRefinanceFullStrict() public {
        uint256 refinanceLenderBalance = testToken.balanceOf(_refinanceLender);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        vm.prank(_refinanceLender);
        (loanId, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));

        assertEq(loan.tranche.length, 1);
        assertEq(testToken.balanceOf(_refinanceLender), refinanceLenderBalance);
    }

    function testRefinanceFullWrongTrancheIndexError() public {
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        refiOffer.trancheIndex = new uint256[](1);

        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        vm.prank(_refinanceLender);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullStrictLocked() public {
        vm.prank(_msLoan.owner());
        _msLoan.setMinLockPeriod(500);

        (uint256 loanId, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        vm.warp(loan.startTime + loan.duration - 1);
        refiOffer.expirationTime = block.timestamp + 1;
        vm.startPrank(_refinanceLender);
        testToken.mint(_refinanceLender, 2 * loan.principalAmount);
        testToken.approve(address(_msLoan), 2 * loan.principalAmount);
        vm.expectRevert(abi.encodeWithSignature("LoanLockedError()"));
        (loanId, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();
    }

    function testRefinanceFullStrictInvalidSender() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        vm.expectRevert(abi.encodeWithSignature("InvalidCallerError()"));
        (loanId, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullFailApr() public {
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        refiOffer.aprBps = loan.tranche[0].aprBps;
        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        vm.prank(_refinanceLender);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullInvalidPrincipal() public {
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        refiOffer.principalAmount = _PRINCIPAL_DELTA;

        /// @dev Underflow
        vm.expectRevert();
        vm.prank(_refinanceLender);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullInvalidDuration() public {
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        refiOffer.duration = loan.startTime + loan.duration - block.timestamp - 1;

        /// @dev Underflow
        vm.expectRevert();
        vm.prank(_refinanceLender);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullBorrowerMorePrincipal() public {
        uint256 originalBalanceRefinanceLender = testToken.balanceOf(_refinanceLender);
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        uint256 extraPrincipal = refiOffer.principalAmount;
        refiOffer.principalAmount += extraPrincipal;
        testToken.mint(_refinanceLender, extraPrincipal);
        vm.prank(refiOffer.lender);
        testToken.approve(address(_msLoan), type(uint256).max);

        uint256 totalLenders = loan.tranche.length;
        uint256 interestToBePaid = loan.getTotalOwed(block.timestamp) - loan.principalAmount;
        uint256[] memory interestByLender = new uint256[](totalLenders);
        address[] memory interestLenders = new address[](totalLenders);
        uint256[] memory currentLenderBalance = new uint256[](totalLenders);
        for (uint256 i = 0; i < interestByLender.length;) {
            IMultiSourceLoan.Tranche memory tranche = loan.tranche[i];
            interestByLender[i] = tranche.principalAmount.getInterest(
                tranche.aprBps, block.timestamp - tranche.startTime
            ) + tranche.accruedInterest + tranche.principalAmount;
            interestLenders[i] = tranche.lender;
            currentLenderBalance[i] = testToken.balanceOf(tranche.lender);
            unchecked {
                ++i;
            }
        }

        uint256 originalBalanceBorrower = testToken.balanceOf(_borrower);
        vm.startPrank(_borrower);
        (, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();

        assertEq(testToken.balanceOf(_refinanceLender), originalBalanceRefinanceLender + interestToBePaid);
        assertEq(testToken.balanceOf(_borrower), originalBalanceBorrower + extraPrincipal - interestToBePaid);
        assertEq(1, loan.tranche.length);
        assertEq(0, loan.tranche[0].accruedInterest);

        for (uint256 i = 0; i < interestLenders.length;) {
            assertEq(testToken.balanceOf(interestLenders[i]), currentLenderBalance[i] + interestByLender[i]);
            unchecked {
                ++i;
            }
        }
    }

    function testRefinanceFullBorrowerEqualPrincipal() public {
        uint256 originalBalanceRefinanceLender = testToken.balanceOf(_refinanceLender);
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        uint256 interestToBePaid = loan.getTotalOwed(block.timestamp) - loan.principalAmount;

        uint256 originalBalanceBorrower = testToken.balanceOf(_borrower);
        testToken.mint(_borrower, interestToBePaid);
        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), interestToBePaid);
        (, loan) = _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();

        assertEq(testToken.balanceOf(_refinanceLender), originalBalanceRefinanceLender + interestToBePaid);
        assertEq(testToken.balanceOf(_borrower), originalBalanceBorrower);
        assertEq(1, loan.tranche.length);
        assertEq(0, loan.tranche[0].accruedInterest);
    }

    function testRefinanceFullBorrowerLessPrincipal() public {
        uint256 originalBalanceRefinanceLender = testToken.balanceOf(_refinanceLender);
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        uint256 lowerPrincipal = _PRINCIPAL_DELTA;
        refiOffer.principalAmount -= lowerPrincipal;
        uint256 originalBalanceBorrower = testToken.balanceOf(_borrower);

        uint256 interestToBePaid = loan.getTotalOwed(block.timestamp) - loan.principalAmount;

        testToken.mint(_borrower, interestToBePaid);
        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), lowerPrincipal + interestToBePaid);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();

        assertEq(
            testToken.balanceOf(_refinanceLender), originalBalanceRefinanceLender + lowerPrincipal + interestToBePaid
        );
        assertEq(testToken.balanceOf(_borrower), originalBalanceBorrower - lowerPrincipal);
    }

    function testRefinanceFullBorrowerSameLenderNoAllowance() public {
        // We check that the lender doesn't need allowance if the borrower already owes him more than the principal
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        IMultiSourceLoan.RenegotiationOffer memory refiOffer = _getSampleRefinanceFull(loanId, loan);
        address maker = loan.tranche[0].lender;
        refiOffer.lender = maker;
        vm.startPrank(maker);
        testToken.approve(address(_msLoan), 0);
        vm.startPrank(_borrower);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();
    }
    function testRefinanceFullBorrowerSameLenderPartialNoAllowance() public {
        // We check that the lender doesn't need allowance if the borrower already owes him more than the principal
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) = _setupRefinanceFull();
        IMultiSourceLoan.Tranche memory tranche = loan.tranche[loan.tranche.length-1];
        address maker = tranche.lender;
        refiOffer.lender = maker;
        refiOffer.principalAmount = tranche.principalAmount + tranche.accruedInterest + tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
        uint256 borrowerContribution = loan.getTotalOwed(block.timestamp) - refiOffer.principalAmount;
        vm.startPrank(maker);
        testToken.approve(address(_msLoan), 0);
        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), borrowerContribution);
        vm.startPrank(_borrower);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();
    }

    function testRefinanceFullBorrowerLockOk() public {
        vm.prank(_msLoan.owner());
        _msLoan.setMinLockPeriod(500);

        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        vm.warp(loan.startTime + loan.duration - 1);
        refiOffer.expirationTime = block.timestamp + 1;
        uint256 interestToBePaid = loan.getTotalOwed(block.timestamp) - loan.principalAmount;

        testToken.mint(_refinanceLender, loan.principalAmount + interestToBePaid);
        vm.prank(_refinanceLender);
        testToken.approve(address(_msLoan), loan.principalAmount + interestToBePaid);

        testToken.mint(_borrower, interestToBePaid);
        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), interestToBePaid);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();
    }

    function testRefinanceWithFee() public {
        WithProtocolFee.ProtocolFee memory protocolFee =
            WithProtocolFee.ProtocolFee({fraction: _fee, recipient: _protocol});
        MultiSourceLoan msLoanWithFee = new MultiSourceLoan(
            liquidationContract,
            protocolFee,
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            _minLockPeriod,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );
        loanSetUp(address(msLoanWithFee));

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.prank(_borrower);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = msLoanWithFee.emitLoan(lde);

        uint256 fee = 1000;
        uint256[] memory targetPrincipal = new uint256[](1);
        targetPrincipal[0] = 0;
        IMultiSourceLoan.RenegotiationOffer memory refiOffer = IMultiSourceLoan.RenegotiationOffer(
            1, // renegotiationId
            loanId,
            _refinanceLender,
            fee, // fee
            new uint256[](loan.tranche.length), // trancheIndex
            loan.principalAmount, // principalAmount
            loan.tranche[0].aprBps.mulDivDown(9000, 10000), // 10% less
            block.timestamp + 200,
            loan.duration
        );

        vm.warp(100);
        uint256 balanceLenderBefore = testToken.balanceOf(_originalLender);
        uint256 balanceRefinancerBefore = testToken.balanceOf(_refinanceLender);
        uint256 balanceBorrowerBefore = testToken.balanceOf(_borrower);
        uint256 balanceProtocolBefore = testToken.balanceOf(protocolFee.recipient);
        uint256 expectedInterestPaid =
            loan.principalAmount.getInterest(loanOffer.aprBps, block.timestamp - loan.tranche[0].startTime);
        uint256 protocolFeePaidFromFee = fee.mulDivUp(protocolFee.fraction, 10000);
        uint256 protocolFeePaidFromInterest = expectedInterestPaid.mulDivUp(protocolFee.fraction, 10000);

        uint256 interestPaid = loan.getTotalOwed(block.timestamp) - loan.principalAmount;
        testToken.mint(_borrower, interestPaid);
        vm.startPrank(_borrower);
        testToken.approve(address(msLoanWithFee), fee + interestPaid);
        msLoanWithFee.refinanceFull(refiOffer, loan, abi.encode(0));
        vm.stopPrank();

        assertEq(
            testToken.balanceOf(protocolFee.recipient),
            balanceProtocolBefore + protocolFeePaidFromFee + protocolFeePaidFromInterest
        );
        assertEq(testToken.balanceOf(_borrower), balanceBorrowerBefore - fee);
        assertEq(
            testToken.balanceOf(_refinanceLender),
            balanceRefinancerBefore - expectedInterestPaid - loan.principalAmount + fee - protocolFeePaidFromFee
                + interestPaid
        );
        assertEq(
            testToken.balanceOf(_originalLender),
            balanceLenderBefore + loan.principalAmount + expectedInterestPaid - protocolFeePaidFromInterest
        );
    }

    function testRefinanceCancelledOne() public {
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();
        vm.prank(refiOffer.lender);
        _msLoan.cancelRenegotiationOffer(refiOffer.renegotiationId);

        vm.expectRevert(
            abi.encodeWithSignature(
                "CancelledOrExecutedOfferError(address,uint256)", refiOffer.lender, refiOffer.renegotiationId
            )
        );
        vm.prank(_borrower);
        _msLoan.refinanceFull(refiOffer, loan, abi.encode(0));
    }

    function testRefinanceFullInvalidSignature() public {
        /// Pkey = 100  generates signer = 0xd9A284367b6D3e25A91c91b5A430AF2593886EB9
        uint256 pkey = 100;
        address signer = 0xd9A284367b6D3e25A91c91b5A430AF2593886EB9;
        testToken.mint(signer, _INITIAL_PRINCIPAL * 4);
        vm.prank(signer);
        testToken.approve(address(_msLoan), _INITIAL_PRINCIPAL * 2);
        (, IMultiSourceLoan.Loan memory loan, IMultiSourceLoan.RenegotiationOffer memory refiOffer) =
            _setupRefinanceFull();

        refiOffer.lender = signer;

        testToken.mint(loan.borrower, loan.principalAmount * 2);
        vm.prank(loan.borrower);
        testToken.approve(address(_msLoan), loan.principalAmount * 2);

        testToken.mint(refiOffer.lender, loan.principalAmount * 2);
        vm.prank(refiOffer.lender);
        testToken.approve(address(_msLoan), loan.principalAmount * 2);

        bytes32 offerHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(refiOffer.hash());
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pkey, offerHash);
        r = bytes32("0");

        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("InvalidSignatureError()"));
        _msLoan.refinanceFull(refiOffer, loan, abi.encodePacked(r, s, v));
    }

    function testRefinancePartialNoExtra() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        uint256 originalLenderOriginalBalance = testToken.balanceOf(_originalLender);
        uint256 newLenderOriginalBalance = testToken.balanceOf(_refinanceLender);

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        uint256 currentTs = block.timestamp;
        uint256 delta = 1 days;
        vm.warp(currentTs + delta);

        IMultiSourceLoan.Tranche memory tranche = loan.tranche[0];
        uint256 expectedInterest = tranche.principalAmount.getInterest(tranche.aprBps, delta);

        uint256 transferred = tranche.principalAmount + expectedInterest;
        vm.prank(_refinanceLender);
        (, IMultiSourceLoan.Loan memory newLoan) = _msLoan.refinancePartial(refiOffer, loan);

        assertEq(newLoan.tranche.length, 1);
        IMultiSourceLoan.Tranche memory newTranche = newLoan.tranche[0];
        assertEq(newTranche.lender, _refinanceLender);
        assertEq(collateralCollection.ownerOf(collateralTokenId), address(_msLoan));
        assertEq(testToken.balanceOf(_borrower), newTranche.principalAmount);
        assertEq(testToken.balanceOf(_originalLender), originalLenderOriginalBalance + transferred);
        assertEq(testToken.balanceOf(_refinanceLender), newLenderOriginalBalance - transferred);
        assertEq(newTranche.accruedInterest, expectedInterest);
    }

    function testRefinanceFromLoanExecutionData() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.warp(1 days);

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        loanOffer.duration = 90 days;
        loanOffer.principalAmount *= 2;
        IMultiSourceLoan.LoanExecutionData memory led =
            IMultiSourceLoan.LoanExecutionData(_sampleExecutionData(loanOffer, loan.borrower), address(0), "");
        led.executionData.offerExecution[0].amount = loanOffer.principalAmount;

        testToken.mint(loanOffer.lender, loanOffer.principalAmount * 2);
        vm.prank(loanOffer.lender);
        testToken.approve(address(_msLoan), loanOffer.principalAmount * 2);

        vm.startPrank(_borrower);
        testToken.mint(_borrower, loanOffer.principalAmount);
        testToken.approve(address(_msLoan), loanOffer.principalAmount);
        (uint256 newLoanId, IMultiSourceLoan.Loan memory newLoan) =
            _msLoan.refinanceFromLoanExecutionData(loanId, loan, led);
        vm.stopPrank();

        assertEq(newLoan.duration, loanOffer.duration);
        assertEq(loanId + 1, newLoanId);
        assertEq(_msLoan.getLoanHash(loanId), bytes32(0));
        assertEq(_msLoan.getLoanHash(newLoanId), newLoan.hash());
    }

    function testFailExtraNotLast() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(2);

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        _msLoan.refinancePartial(refiOffer, loan);
    }

    function testRefinanceManySourcesOneLoan() public {
        WithProtocolFee.ProtocolFee memory protocolFee =
            WithProtocolFee.ProtocolFee({fraction: _fee, recipient: _protocol});
        MultiSourceLoan msLoanWithFee = new MultiSourceLoan(
            liquidationContract,
            protocolFee,
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            _minLockPeriod,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );
        loanSetUp(address(msLoanWithFee));

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        vm.prank(_borrower);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = msLoanWithFee.emitLoan(lde);

        uint256 newRefis = _maxTranches - 1;
        uint256 principalAmount = loan.tranche[0].principalAmount;

        uint256 baseAddress = 4000;
        for (uint256 i = 0; i < newRefis;) {
            vm.warp(block.timestamp + 1 days);
            uint256[] memory trancheIdx = new uint256[](1);
            trancheIdx[0] = loan.tranche.length - 1;
            IMultiSourceLoan.RenegotiationOffer memory refiOffer = _getSampleRefinancePartial(loanId, trancheIdx, loan);
            address thisUser = address(uint160(baseAddress + i));
            _addUser(thisUser, principalAmount * 20, address(msLoanWithFee));

            refiOffer.lender = thisUser;
            vm.startPrank(thisUser);
            IMultiSourceLoan.Tranche memory refinancedTranche = loan.tranche[0];
            uint256 expectedPaidPendingInterest = refinancedTranche.principalAmount.getInterest(
                refinancedTranche.aprBps, block.timestamp - refinancedTranche.startTime
            );
            uint256 expectedToBePaid =
                refiOffer.principalAmount + expectedPaidPendingInterest + refinancedTranche.accruedInterest;
            uint256 expectedProtocolFee = expectedPaidPendingInterest.mulDivUp(protocolFee.fraction, 10000);
            uint256 currentProtocolAccountBalance = testToken.balanceOf(protocolFee.recipient);
            uint256 currentBalance = testToken.balanceOf(thisUser);
            (loanId, loan) = msLoanWithFee.refinancePartial(refiOffer, loan);
            uint256 postBalance = testToken.balanceOf(thisUser);
            uint256 postProtocolAccountBalance = testToken.balanceOf(protocolFee.recipient);
            uint256 total = 0;
            for (uint256 j = 0; j < loan.tranche.length;) {
                total += loan.tranche[j].principalAmount;
                unchecked {
                    ++j;
                }
            }
            assertEq(loan.principalAmount, total);
            assertEq(currentBalance - postBalance, expectedToBePaid);
            assertEq(postProtocolAccountBalance - currentProtocolAccountBalance, expectedProtocolFee);
            assertEq(loan.tranche[0].accruedInterest, expectedPaidPendingInterest + refinancedTranche.accruedInterest);
            vm.stopPrank();
            unchecked {
                ++i;
            }
        }
    }

    function testRefinancePartialFailInvalidLoan() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        loan.tranche[0].principalAmount += 1;
        vm.prank(_refinanceLender);
        vm.expectRevert(abi.encodeWithSignature("InvalidLoanError(uint256)", loanId));
        _msLoan.refinancePartial(refiOffer, loan);
    }

    function testRefinancePartialExpiredOffer() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        vm.warp(block.timestamp + refiOffer.expirationTime + 1);
        vm.prank(_refinanceLender);
        vm.expectRevert(abi.encodeWithSignature("ExpiredOfferError(uint256)", refiOffer.expirationTime));
        _msLoan.refinancePartial(refiOffer, loan);
    }

    function testRefinanceInvalidHash() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);
        refiOffer.trancheIndex = new uint256[](10);

        vm.prank(_refinanceLender);
        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        _msLoan.refinancePartial(refiOffer, loan);
    }

    function testRefinancePartialFailNotStrictlyBetter() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        uint256 originalDuration = loan.duration;
        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        /// @dev should be ignore
        refiOffer.duration = 100 days;
        refiOffer.fee = 5e18;

        vm.prank(_refinanceLender);
        _msLoan.refinancePartial(refiOffer, loan);

        assertEq(loan.duration, originalDuration);
    }

    function testRefinancePartialFailInvalidApr() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        refiOffer.aprBps = loan.tranche[0].aprBps;
        vm.prank(_refinanceLender);
        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        _msLoan.refinancePartial(refiOffer, loan);
    }

    function _setupSecondNft() private returns (uint256) {
        uint256 tokenId = collateralTokenId + 1;
        collateralCollection.mint(_borrower, tokenId);
        vm.prank(_borrower);
        collateralCollection.approve(address(_msLoan), tokenId);
        return tokenId;
    }

    function _getOtherMsLoan() private returns (MultiSourceLoan) {
        return new MultiSourceLoan(
            liquidationContract,
            protocolFee,
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            _minLockPeriod,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );
    }

    function _setupMultiSourceLoanWithLock() private returns (MultiSourceLoan) {
        MultiSourceLoan msl = new MultiSourceLoan(
            liquidationContract,
            protocolFee,
            address(currencyManager),
            address(collectionManager),
            _maxTranches,
            300,
            address(_delegationRegistry),
            address(_loanManagerRegistry),
            address(_flashActionContract),
            3 days
        );
        vm.prank(_borrower);
        collateralCollection.approve(address(msl), collateralTokenId);
        vm.prank(_originalLender);
        testToken.approve(address(msl), _INITIAL_PRINCIPAL);
        vm.prank(_refinanceLender);
        testToken.approve(address(msl), 2 * _INITIAL_PRINCIPAL);
        return msl;
    }

    function _getEndLockup(IMultiSourceLoan.Loan memory _loan, uint256 _lockupBps) private pure returns (uint256) {
        uint256 startTime = _loan.tranche[0].startTime;
        return startTime + (_loan.startTime + _loan.duration - startTime).mulDivUp(_lockupBps, 10000);
    }
}
