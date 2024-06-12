// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@forge-std/Test.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "src/interfaces/loans/IMultiSourceLoan.sol";
import "src/lib/pools/Pool.sol";
import "src/lib/pools/PoolOfferHandler.sol";
import "test/loans/MultiSourceCommons.sol";

contract PoolOfferHandlerTest is MultiSourceCommons {
    using FixedPointMathLib for uint256;

    PoolOfferHandler private _poolOfferHandler;
    uint32 private constant _maxDuration = 30 days;

    uint16 private constant _bps = 10000;
    uint256 private constant _duration = 30 days;
    uint256 private constant _apr = 1000;
    uint256 private constant _principal = 1e18;

    function setUp() public override {
        super.setUp();

        _poolOfferHandler = new PoolOfferHandler(_maxDuration, 3 days);

        PoolOfferHandler.TermsKey[] memory termKeys = new PoolOfferHandler.TermsKey[](1);
        PoolOfferHandler.Terms[] memory terms = new PoolOfferHandler.Terms[](1);
        termKeys[0] = PoolOfferHandler.TermsKey(address(collateralCollection), _duration, 0);
        terms[0] = PoolOfferHandler.Terms(_principal, _apr);
        vm.startPrank(_poolOfferHandler.owner());
        _poolOfferHandler.setTerms(termKeys, terms);
        vm.warp(_poolOfferHandler.NEW_TERMS_WAITING_TIME() + 1);
        _poolOfferHandler.confirmTerms();
        vm.stopPrank();
        vm.warp(1);
    }

    function testSetTerms() public {
        PoolOfferHandler.TermsKey[] memory termKeys = new PoolOfferHandler.TermsKey[](1);
        PoolOfferHandler.Terms[] memory terms = new PoolOfferHandler.Terms[](1);
        termKeys[0] = PoolOfferHandler.TermsKey(address(collateralCollection), _duration, 0);
        terms[0] = PoolOfferHandler.Terms(_principal + 1, _apr + 1);

        vm.expectRevert(bytes("UNAUTHORIZED"));
        _poolOfferHandler.setTerms(termKeys, terms);

        vm.prank(_poolOfferHandler.owner());
        _poolOfferHandler.setTerms(termKeys, terms);

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        _poolOfferHandler.confirmTerms();

        vm.warp(_poolOfferHandler.NEW_TERMS_WAITING_TIME() + 1);
        _poolOfferHandler.confirmTerms();

        uint256 setAprPremium =
            _poolOfferHandler.getAprPremium(address(collateralCollection), _duration, 0, terms[0].principalAmount);
        assertEq(setAprPremium, terms[0].aprPremium);
    }

    function testValidateOfferSuccess() public {
        uint256 baseRate = 1000;

        _poolOfferHandler.validateOffer(baseRate, abi.encode(_getBaseOfferExecution(baseRate)));
    }

    function testValidateOfferInvalidNoPrincipalError() public {
        uint256 baseRate = 1000;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(baseRate);

        offerExecution.offer.principalAmount += 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidAprError()"));
        _poolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferInvalidAprError() public {
        uint256 baseRate = 1000;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(baseRate);

        offerExecution.offer.aprBps -= 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidAprError()"));
        _poolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function _getBaseOfferExecution(uint256 _baseRate) private returns (IMultiSourceLoan.OfferExecution memory) {
        IMultiSourceLoan.LoanOffer memory offer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _principal);
        offer.duration = _duration;
        offer.aprBps =
            _baseRate + _poolOfferHandler.getAprPremium(address(collateralCollection), _duration, 0, _principal);
        return IMultiSourceLoan.OfferExecution(offer, _principal, "");
    }
}
