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

/// @dev Creating this extra class since I can't make it work in the main test class because of a stack too deep error...
/// INCREDIBLY FRUSTRATING.
contract MultiSourceLoanTestExtra is MultiSourceCommons {
    using FixedPointMathLib for uint256;
    using Hash for IMultiSourceLoan.SignableRepaymentData;
    using Hash for IMultiSourceLoan.ExecutionData;
    using Hash for IMultiSourceLoan.Loan;
    using Interest for IMultiSourceLoan.Loan;
    using Interest for uint256;
    using MessageHashUtils for bytes32;

    function testRepayLoanWithFees() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _emitWithFees();

        vm.warp(loan.startTime + loan.duration - 1);

        /// @dev only one tranche
        IMultiSourceLoan.Tranche memory tranche = loan.tranche[0];
        uint256 interest = tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
        uint256 protocolFee = interest.mulDivUp(_fee, 10000);
        uint256 totalOwed = loan.principalAmount + interest;
        testToken.mint(_borrower, totalOwed);

        uint256 protocolBalanceBefore = testToken.balanceOf(address(_protocol));
        uint256 lenderBalanceBefore = testToken.balanceOf(tranche.lender);
        uint256 borrowerBalanceBefore = testToken.balanceOf(address(_borrower));

        IMultiSourceLoan.LoanRepaymentData memory repaymentData = _sampleRepaymentData(loanId, loan);
        repaymentData.data.callbackData = abi.encode(0);

        vm.prank(_msLoanWithFee.owner());
        _msLoanWithFee.addWhitelistedCallbackContract(_borrower);

        vm.prank(_borrower);
        _msLoanWithFee.repayLoan(repaymentData);

        assertEq(testToken.balanceOf(_borrower), borrowerBalanceBefore - totalOwed);
        assertEq(testToken.balanceOf(tranche.lender), lenderBalanceBefore + totalOwed - protocolFee);
        assertEq(testToken.balanceOf(_protocol), protocolFee + protocolBalanceBefore);
    }

    function testRepayLoan() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        IMultiSourceLoan.RenegotiationOffer memory refiOffer =
            _getSampleRefinancePartial(loanId, new uint256[](1), loan);

        uint256 currentTs = block.timestamp;
        uint256 delta = 1 days;
        vm.warp(currentTs + delta);

        vm.prank(_refinanceLender);
        (uint256 newLoanId, IMultiSourceLoan.Loan memory newLoan) = _msLoan.refinancePartial(refiOffer, loan);

        uint256 delta2 = 15 days;
        vm.warp(block.timestamp + delta2);

        uint256 balanceRefinanceLender = testToken.balanceOf(_refinanceLender);
        uint256 owed = 0;
        for (uint256 i = 0; i < newLoan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = newLoan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + tranche.principalAmount.getInterest(tranche.aprBps, block.timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }

        uint256 borrowerBalance = testToken.balanceOf(_borrower);

        vm.startPrank(_borrower);
        testToken.mint(_borrower, owed);
        testToken.approve(address(_msLoan), owed);
        _msLoan.repayLoan(_sampleRepaymentData(newLoanId, newLoan));
        vm.stopPrank();

        assertEq(collateralCollection.ownerOf(collateralTokenId), _borrower);
        assertEq(testToken.balanceOf(_borrower), borrowerBalance);
        assertEq(testToken.balanceOf(_refinanceLender), owed + balanceRefinanceLender);
    }

    function testRepayMulitpleTranches() public {}

    function testRepayWithCallback() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(_borrower);
        vm.mockCall(
            _borrower,
            abi.encodeWithSignature("afterNFTTransfer(Loan,bytes)"),
            abi.encode(ILoanCallback.afterNFTTransfer.selector)
        );
        vm.mockCall(
            _borrower,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );

        vm.warp(loan.startTime + loan.duration - 1);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(_borrower, owed);

        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), owed);
        _msLoan.repayLoan(_sampleRepaymentData(loanId, loan));
        vm.stopPrank();
    }

    function testRepayWithNotWhitelistedCallback() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.mockCall(
            _borrower,
            abi.encodeWithSignature("afterNFTTransfer(Loan,bytes)"),
            abi.encode(ILoanCallback.afterNFTTransfer.selector)
        );
        vm.mockCall(
            _borrower,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );

        vm.warp(loan.startTime + loan.duration - 1);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(_borrower, owed);

        IMultiSourceLoan.LoanRepaymentData memory repaymentData = _sampleRepaymentData(loanId, loan);
        repaymentData.data.callbackData = abi.encode(0);

        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), owed);
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        _msLoan.repayLoan(repaymentData);
        vm.stopPrank();
    }

    function testRepayWithWrongReturnCallback() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.mockCall(_borrower, abi.encodeWithSelector(ILoanCallback.afterNFTTransfer.selector), abi.encode(0x0));
        vm.mockCall(
            _borrower,
            abi.encodeWithSignature("onERC721Received(address,address,uint256,bytes)"),
            abi.encode(ERC721TokenReceiver.onERC721Received.selector)
        );

        vm.prank(_msLoan.owner());
        _msLoan.addWhitelistedCallbackContract(_borrower);
        vm.warp(loan.startTime + loan.duration - 1);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(_borrower, owed);

        IMultiSourceLoan.LoanRepaymentData memory data = _sampleRepaymentData(loanId, loan);
        data.data.callbackData = abi.encode(0);

        vm.startPrank(_borrower);
        testToken.approve(address(_msLoan), owed);
        vm.expectRevert(abi.encodeWithSignature("InvalidCallbackError()"));
        _msLoan.repayLoan(data);
        vm.stopPrank();
    }

    function testRepayLoanWithSignature() public {
        uint256 privateKey = 100;
        address otherBorrower = vm.addr(privateKey);
        uint256 otherToken = collateralTokenId + 1;
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getLoanOtherBorrower(privateKey, otherToken);

        vm.warp(1000);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(otherBorrower, owed);
        vm.prank(otherBorrower);
        testToken.approve(address(_msLoan), owed);
        IMultiSourceLoan.LoanRepaymentData memory data = _sampleRepaymentData(loanId, loan);
        bytes32 signableHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(data.data.hash());
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, signableHash);
        data.borrowerSignature = abi.encodePacked(r, s, v);
        vm.prank(address(99999)); // just a random address
        _msLoan.repayLoan(data);

        assertEq(otherBorrower, collateralCollection.ownerOf(otherToken));
    }

    function testRepayLoanWithSignatureFail() public {
        uint256 privateKey = 100;
        address otherBorrower = vm.addr(privateKey);
        uint256 otherToken = collateralTokenId + 1;
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getLoanOtherBorrower(privateKey, otherToken);

        vm.warp(1000);
        uint256 owed = loan.getTotalOwed(block.timestamp);
        testToken.mint(otherBorrower, owed);
        vm.prank(otherBorrower);
        testToken.approve(address(_msLoan), owed);
        bytes32 loanHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(loan.hash());
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey + 1, loanHash);
        IMultiSourceLoan.LoanRepaymentData memory data = _sampleRepaymentData(loanId, loan);
        data.borrowerSignature = abi.encodePacked(r, s, v);
        vm.prank(address(99999)); // just a random address
        vm.expectRevert(abi.encodeWithSignature("InvalidSignatureError()"));
        _msLoan.repayLoan(data);
    }

    function testRepayMany() public {
        uint256 anotherTokenId = collateralTokenId + 1;
        collateralCollection.mint(_borrower, anotherTokenId);
        vm.prank(_borrower);
        collateralCollection.approve(address(_msLoan), anotherTokenId);

        bytes[] memory executionData = new bytes[](2);
        for (uint256 i; i < 2;) {
            uint256 tokenId = collateralTokenId + i;
            IMultiSourceLoan.LoanOffer memory offer =
                _getSampleOffer(address(collateralCollection), tokenId, _INITIAL_PRINCIPAL);
            offer.duration = 30 days;
            executionData[i] =
                abi.encodeWithSelector(IMultiSourceLoan.emitLoan.selector, _sampleLoanExecutionData(offer));
            unchecked {
                ++i;
            }
        }

        bytes[] memory output = _msLoan.multicall(executionData);
        uint256[] memory loanIds = new uint256[](executionData.length);
        IMultiSourceLoan.Loan[] memory loans = new IMultiSourceLoan.Loan[](executionData.length);
        for (uint256 i; i < executionData.length;) {
            (loanIds[i], loans[i]) = abi.decode(output[i], (uint256, IMultiSourceLoan.Loan));
            unchecked {
                ++i;
            }
        }

        vm.warp(15 days);
        bytes[] memory repaymentData = new bytes[](loans.length);
        for (uint256 i; i < loans.length;) {
            repaymentData[i] = abi.encodeWithSelector(
                IMultiSourceLoan.repayLoan.selector,
                IMultiSourceLoan.LoanRepaymentData(
                    IMultiSourceLoan.SignableRepaymentData(loanIds[i], "", false), loans[i], ""
                )
            );
            unchecked {
                ++i;
            }
        }
        vm.startPrank(_borrower);
        testToken.mint(_borrower, _INITIAL_PRINCIPAL * 2);
        testToken.approve(address(_msLoan), _INITIAL_PRINCIPAL * 4);
        _msLoan.multicall(repaymentData);
        vm.stopPrank();

        assertEq(collateralCollection.ownerOf(collateralTokenId), _borrower);
        assertEq(collateralCollection.ownerOf(anotherTokenId), _borrower);
    }

    function testOriginationAndRepayWithProtocolFee() public {
        WithProtocolFee.ProtocolFee memory protocolFee =
            WithProtocolFee.ProtocolFee({fraction: 100, recipient: address(9999)});
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
        loanOffer.fee = 1000;
        uint256 lenderBalanceBeforeEmit = testToken.balanceOf(_originalLender);
        uint256 protocolBalanceBeforeEmit = testToken.balanceOf(protocolFee.recipient);
        uint256 protocolFeeFromFee = loanOffer.fee.mulDivUp(protocolFee.fraction, 10000);
        vm.prank(_borrower);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) =
            msLoanWithFee.emitLoan(_sampleLoanExecutionData(loanOffer));

        assertEq(testToken.balanceOf(protocolFee.recipient), protocolBalanceBeforeEmit + protocolFeeFromFee);
        assertEq(
            testToken.balanceOf(_originalLender),
            lenderBalanceBeforeEmit - loanOffer.principalAmount + loanOffer.fee - protocolFeeFromFee
        );

        vm.warp(loan.startTime + loan.duration - 1);

        uint256 interest = loanOffer.principalAmount.getInterest(loanOffer.aprBps, block.timestamp - loan.startTime);
        uint256 expectedProtocolFee = interest.mulDivUp(protocolFee.fraction, 10000);

        uint256 balanceLenderBefore = testToken.balanceOf(_originalLender);
        uint256 balanceBorrowerBefore = testToken.balanceOf(_borrower);
        uint256 balanceProtocolBefore = testToken.balanceOf(protocolFee.recipient);
        vm.startPrank(_borrower);
        testToken.mint(_borrower, loanOffer.principalAmount + interest);
        testToken.approve(address(msLoanWithFee), loanOffer.principalAmount + interest);
        msLoanWithFee.repayLoan(_sampleRepaymentData(loanId, loan));
        vm.stopPrank();

        assertEq(testToken.balanceOf(protocolFee.recipient), balanceProtocolBefore + expectedProtocolFee);
        assertEq(
            testToken.balanceOf(_originalLender),
            balanceLenderBefore + loanOffer.principalAmount + interest - expectedProtocolFee
        );
        assertEq(testToken.balanceOf(_borrower), balanceBorrowerBefore);
    }

    function testLiquidationSingleSource() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.warp(loan.startTime + loan.duration + 1);

        _msLoan.liquidateLoan(loanId, loan);
        assertEq(collateralCollection.ownerOf(collateralTokenId), _originalLender);
    }

    function testSendToLiquidation() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(_maxTranches - 1);
        vm.warp(loan.startTime + loan.duration + 10);
        _msLoan.liquidateLoan(loanId, loan);

        assertEq(collateralCollection.ownerOf(collateralTokenId), liquidationContract);
    }

    function testSendToLiquidationNotExpired() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(_maxTranches - 1);
        uint256 endTime = loan.startTime + loan.duration;
        vm.warp(endTime - 1);
        vm.expectRevert(abi.encodeWithSignature("LoanNotDueError(uint256)", endTime));
        _msLoan.liquidateLoan(loanId, loan);
    }

    function testDelegate() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        address delegate = address(8888);
        vm.prank(_borrower);
        _msLoan.delegate(loanId, loan, delegate, "", true);

        assertTrue(
            _delegationRegistry.checkDelegateForERC721(
                delegate, address(_msLoan), address(collateralCollection), collateralTokenId, ""
            )
        );
    }

    function testRevoke() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        address delegate = address(8888);
        vm.startPrank(_borrower);
        testToken.mint(_borrower, 2 * loan.principalAmount);
        testToken.approve(address(_msLoan), 2 * loan.principalAmount);
        _msLoan.delegate(loanId, loan, delegate, "", true);
        _msLoan.repayLoan(_sampleRepaymentData(loanId, loan));
        vm.stopPrank();

        _msLoan.revokeDelegate(delegate, loan.nftCollateralAddress, loan.nftCollateralTokenId);
        assertFalse(
            _delegationRegistry.checkDelegateForERC721(
                delegate, address(_msLoan), address(collateralCollection), collateralTokenId, ""
            )
        );
    }

    function testRevokeOutstandingError() public {
        (, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        vm.expectRevert(abi.encodeWithSignature("InvalidMethodError()"));
        _msLoan.revokeDelegate(address(8888), loan.nftCollateralAddress, loan.nftCollateralTokenId);
    }

    function testExecuteFlashAction() public {
        address target = address(8888);
        bytes memory data = abi.encode(0);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        vm.expectCall(
            address(_flashActionContract),
            abi.encodeWithSignature(
                "execute(address,uint256,address,bytes)", address(collateralCollection), collateralTokenId, target, data
            )
        );
        vm.prank(_borrower);
        _msLoan.executeFlashAction(loanId, loan, target, data);
    }

    function testMaliciousFlashAction() public {
        address target = address(8888);
        bytes memory data = abi.encode(0);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();
        TestNFTMaliciousFlashAction malicious = new TestNFTMaliciousFlashAction();

        vm.prank(_msLoan.owner());
        _msLoan.setFlashActionContract(address(malicious));

        vm.prank(_borrower);
        vm.expectRevert(abi.encodeWithSignature("NFTNotReturnedError()"));
        _msLoan.executeFlashAction(loanId, loan, target, data);
        vm.prank(_msLoan.owner());
        _msLoan.setFlashActionContract(address(_flashActionContract));
    }

    function testInvalidCallerFlashActionError() public {
        address target = address(8888);
        bytes memory data = abi.encode(0);
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _getInitialLoan();

        vm.prank(address(99999)); // Random address
        vm.expectRevert(abi.encodeWithSignature("InvalidCallerError()"));
        _msLoan.executeFlashAction(loanId, loan, target, data);
    }

    function testSetFlashActionContract() public {
        address newProxyContract = address(8888);
        vm.prank(_msLoan.owner());
        _msLoan.setFlashActionContract(newProxyContract);
        assertEq(_msLoan.getFlashActionContract(), newProxyContract);
    }

    function testAddNewTranche() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(2);

        uint256 originalPrincipal = loan.principalAmount;
        uint256 originalTrancheLength = loan.tranche.length;
        uint256 extraPrincipal = originalPrincipal / 2;
        uint256 newApr = 1000;
        IMultiSourceLoan.RenegotiationOffer memory offer =
            _getSampleRenegotiationNewTranche(loanId, loan, extraPrincipal, newApr);
        testToken.mint(offer.lender, extraPrincipal);
        vm.prank(offer.lender);
        testToken.approve(address(_msLoan), extraPrincipal);

        uint256 newLoanId;
        vm.prank(loan.borrower);
        (newLoanId, loan) = _msLoan.addNewTranche(offer, loan, abi.encode());

        assertEq(loan.principalAmount, originalPrincipal + extraPrincipal);
        assertEq(loan.tranche.length, originalTrancheLength + 1);

        IMultiSourceLoan.Tranche memory newTranche = loan.tranche[loan.tranche.length - 1];
        assertEq(newLoanId, loanId + 1);
        assertEq(newTranche.principalAmount, extraPrincipal);
        assertEq(newTranche.floor, originalPrincipal);
        assertEq(newTranche.lender, offer.lender);
        assertEq(newTranche.aprBps, newApr);
    }

    function testAddNewTrancheWrongTrancheIndexError() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(2);

        uint256 extraPrincipal = 1000;
        uint256 newApr = 1000;
        IMultiSourceLoan.RenegotiationOffer memory offer =
            _getSampleRenegotiationNewTranche(loanId, loan, extraPrincipal, newApr);

        offer.trancheIndex[0] = 0;
        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        vm.prank(loan.borrower);
        _msLoan.addNewTranche(offer, loan, abi.encode());

        offer.trancheIndex = new uint256[](0);
        vm.expectRevert(abi.encodeWithSignature("InvalidRenegotiationOfferError()"));
        vm.prank(loan.borrower);
        _msLoan.addNewTranche(offer, loan, abi.encode());
    }

    function testAddNewTrancheInvalidCaller() public {
        (uint256 loanId, IMultiSourceLoan.Loan memory loan) = _setupMultipleRefi(2);

        uint256 extraPrincipal = 1000;
        uint256 newApr = 1000;
        IMultiSourceLoan.RenegotiationOffer memory offer =
            _getSampleRenegotiationNewTranche(loanId, loan, extraPrincipal, newApr);

        vm.expectRevert(abi.encodeWithSignature("InvalidCallerError()"));
        _msLoan.addNewTranche(offer, loan, abi.encode());
    }

    function _getLoanOtherBorrower(uint256 _privateKey, uint256 _otherToken)
        private
        returns (uint256, IMultiSourceLoan.Loan memory)
    {
        address otherBorrower = vm.addr(_privateKey);

        collateralCollection.mint(otherBorrower, _otherToken);
        vm.prank(otherBorrower);
        collateralCollection.approve(address(_msLoan), _otherToken);
        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), _otherToken, _INITIAL_PRINCIPAL);
        loanOffer.duration = 30 days;
        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);
        lde.borrower = otherBorrower;
        bytes32 executionDataHash = _msLoan.DOMAIN_SEPARATOR().toTypedDataHash(lde.executionData.hash());
        (uint8 vOffer, bytes32 rOffer, bytes32 sOffer) = vm.sign(_privateKey, executionDataHash);
        lde.borrowerOfferSignature = abi.encodePacked(rOffer, sOffer, vOffer);
        return _msLoan.emitLoan(lde);
    }

    function _emitWithFees() private returns (uint256 loanId, IMultiSourceLoan.Loan memory loan) {
        _setupLoanWithFee();

        IMultiSourceLoan.LoanOffer memory loanOffer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _INITIAL_PRINCIPAL);

        IMultiSourceLoan.LoanExecutionData memory lde = _sampleLoanExecutionData(loanOffer);

        vm.prank(_borrower);
        testToken.approve(address(_msLoanWithFee), type(uint256).max);
        vm.prank(_borrower);
        (loanId, loan) = _msLoanWithFee.emitLoan(lde);
    }
}
