// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/utils/FixedPointMathLib.sol";

import "src/lib/pools/Oracle.sol";
import "src/lib/pools/OraclePoolOfferHandler.sol";
import "test/loans/MultiSourceCommons.sol";

contract OraclePoolOfferHandlerTest is MultiSourceCommons {
    using FixedPointMathLib for uint256;

    uint64 private _period = 600 days;
    bytes4 private _key = bytes4("11");
    uint128 private _value = 1e18;

    Oracle private _oracle = new Oracle(3 days);
    bytes4 private _floorKey = bytes4("F");
    bytes4 private _historicalFloorKey = bytes4("HF");

    OraclePoolOfferHandler.AprFactors private _aprFactors = OraclePoolOfferHandler.AprFactors(500, 1e29);

    uint32 private _maxDuration = 100 days;
    uint256 private _aprUpdateTolerance = 3 days;
    OraclePoolOfferHandler private _oraclePoolOfferHandler = new OraclePoolOfferHandler(
        _maxDuration, _aprFactors, _aprUpdateTolerance, address(_oracle), _floorKey, _historicalFloorKey, 3 days
    );

    uint128 private _floor = 1e18;
    uint128 private _historicalFloor = 1e17;

    function setUp() public override {
        super.setUp();

        _setOracle();
    }

    function testSetOracle() public {
        vm.warp(100 days);

        address newOracle = address(8888);
        assertEq(_oraclePoolOfferHandler.getProposedOracle(), address(0));
        assertEq(_oraclePoolOfferHandler.getProposedOracleSetTs(), type(uint256).max);

        vm.prank(_oraclePoolOfferHandler.owner());
        _oraclePoolOfferHandler.setOracle(newOracle);

        assertEq(_oraclePoolOfferHandler.getProposedOracle(), newOracle);
        assertEq(_oraclePoolOfferHandler.getOracle(), address(_oracle));
        assertEq(_oraclePoolOfferHandler.getProposedOracleSetTs(), block.timestamp);

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        _oraclePoolOfferHandler.confirmOracle();

        vm.warp(block.timestamp + _oraclePoolOfferHandler.MIN_WAIT_TIME() + 1);
        _oraclePoolOfferHandler.confirmOracle();

        assertEq(_oraclePoolOfferHandler.getOracle(), newOracle);
        assertEq(_oraclePoolOfferHandler.getProposedOracle(), address(0));
        assertEq(_oraclePoolOfferHandler.getProposedOracleSetTs(), type(uint256).max);
    }

    function testSetAprFactors() public {
        vm.warp(100 days);

        OraclePoolOfferHandler.AprFactors memory newAprFactors = OraclePoolOfferHandler.AprFactors(1e25, 1000);

        vm.prank(_oraclePoolOfferHandler.owner());
        _oraclePoolOfferHandler.setAprFactors(newAprFactors);

        (uint128 proposedMinPremium, uint128 proposedUtilizationFactor) =
            _oraclePoolOfferHandler.getProposedAprFactors();
        (uint128 minPremium, uint128 utilizationFactor) = _oraclePoolOfferHandler.getAprFactors();
        assertEq(proposedMinPremium, newAprFactors.minPremium);
        assertEq(proposedUtilizationFactor, newAprFactors.utilizationFactor);
        assertEq(_oraclePoolOfferHandler.getProposedAprFactorsSetTs(), block.timestamp);
        assertEq(minPremium, _aprFactors.minPremium);
        assertEq(utilizationFactor, _aprFactors.utilizationFactor);

        vm.expectRevert(abi.encodeWithSignature("TooSoonError()"));
        _oraclePoolOfferHandler.confirmAprFactors();

        vm.warp(block.timestamp + _oraclePoolOfferHandler.MIN_WAIT_TIME() + 1);
        _oraclePoolOfferHandler.confirmAprFactors();

        (minPremium, utilizationFactor) = _oraclePoolOfferHandler.getAprFactors();
        assertEq(minPremium, newAprFactors.minPremium);
        assertEq(utilizationFactor, newAprFactors.utilizationFactor);
    }

    function testSetCollectionFactors() public {
        uint128 base = uint128(_oraclePoolOfferHandler.PRECISION());
        uint128 floorFactor = 2;
        uint128 historicalFloorFactor = 4;

        _setCollectionFactor(floorFactor, historicalFloorFactor);

        OraclePoolOfferHandler.PrincipalFactors memory factors =
            _oraclePoolOfferHandler.getCollectionFactors(address(collateralCollection), _period);

        assertEq(factors.floor, base / floorFactor);
        assertEq(factors.historicalFloor, base / historicalFloorFactor);
    }

    function testSetAprPremium() public {
        uint256 deployedAssets = 2e18;
        uint256 totalAssets = 4e18;
        _setupPool(deployedAssets, totalAssets);

        _oraclePoolOfferHandler.setAprPremium();

        (uint128 apr, uint128 setTime) = _oraclePoolOfferHandler.getAprPremium();

        assertEq(
            apr,
            _aprFactors.minPremium
                + deployedAssets.mulDivUp(_aprFactors.utilizationFactor, totalAssets * _oraclePoolOfferHandler.PRECISION())
        );
        assertEq(block.timestamp, setTime);
    }

    function testValidateOffer() public {
        uint128 floorFactor = 2;
        uint128 historicalFloorFactor = 4;

        _setCollectionFactor(floorFactor, historicalFloorFactor);

        uint256 deployedAssets = 2e18;
        uint256 totalAssets = 4e18;
        _setupPool(deployedAssets, totalAssets);

        uint256 baseRate = 1000;
        uint256 principal = _historicalFloor / 10;

        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(principal, baseRate);

        _setOracle();

        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferOutdatedFloorError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);

        uint256 baseRate = 100;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(1e3, baseRate);

        vm.startPrank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _floorKey, _floor);
        _oracle.setData(address(collateralCollection), _period, _historicalFloorKey, _historicalFloor);
        vm.stopPrank();

        uint256 ts = block.timestamp
            + offerExecution.offer.duration.mulDivDown(
                _oraclePoolOfferHandler.TOLERANCE_FLOOR(), _oraclePoolOfferHandler.PRECISION()
            ) + 1;
        vm.warp(ts);

        vm.expectRevert(abi.encodeWithSignature("OutdatedValueError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferOutdatedHistoricalFloorError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);

        uint256 baseRate = 100;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(1e3, baseRate);

        vm.prank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _historicalFloorKey, _historicalFloor);

        uint256 ts = block.timestamp
            + offerExecution.offer.duration.mulDivDown(
                _oraclePoolOfferHandler.TOLERANCE_HISTORICAL_FLOOR(), _oraclePoolOfferHandler.PRECISION()
            ) + 1;
        vm.warp(ts);

        vm.prank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _floorKey, _floor);

        vm.expectRevert(abi.encodeWithSignature("OutdatedValueError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferInvalidPrincipalBelowCurrentError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);

        uint256 baseRate = 100;
        uint128 principal = 1e3;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(principal, baseRate);

        vm.startPrank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _historicalFloorKey, _historicalFloor);
        _oracle.setData(address(collateralCollection), _period, _floorKey, principal);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSignature("InvalidPrincipalAmountError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferInvalidPrincipalBelowHistoricalError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);

        uint256 baseRate = 100;
        uint128 principal = 1e3;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(principal, baseRate);

        vm.startPrank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _historicalFloorKey, principal);
        _oracle.setData(address(collateralCollection), _period, _floorKey, _floor);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSignature("InvalidPrincipalAmountError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferInvalidAprError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);
        _setOracle();

        uint256 baseRate = 100;
        uint128 principal = 1e3;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(principal, baseRate);
        offerExecution.offer.aprBps -= 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidAprError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function testValidateOfferInvalidMaxSeniorRepaymentError() public {
        _setCollectionFactor(2, 4);
        _setupPool(2e18, 4e18);
        _setOracle();

        uint256 baseRate = 100;
        uint128 principal = 1e3;
        IMultiSourceLoan.OfferExecution memory offerExecution = _getBaseOfferExecution(principal, baseRate);
        offerExecution.offer.maxSeniorRepayment = 1;

        vm.expectRevert(abi.encodeWithSignature("InvalidMaxSeniorRepaymentError()"));
        _oraclePoolOfferHandler.validateOffer(baseRate, abi.encode(offerExecution));
    }

    function _setupPool(uint256 _deployedAssets, uint256 _totalAssets) private {
        address pool = address(9999);

        vm.mockCall(pool, abi.encodeWithSignature("getUndeployedAssets()"), abi.encode(_totalAssets - _deployedAssets));
        vm.mockCall(pool, abi.encodeWithSignature("totalAssets()"), abi.encode(_totalAssets));

        vm.prank(_oraclePoolOfferHandler.owner());
        _oraclePoolOfferHandler.setPool(pool);
    }

    function _getBaseOfferExecution(uint256 _principal, uint256 _baseRate)
        private
        returns (IMultiSourceLoan.OfferExecution memory)
    {
        IMultiSourceLoan.LoanOffer memory offer =
            _getSampleOffer(address(collateralCollection), collateralTokenId, _principal);
        offer.duration = _period;
        uint128 aprPremium = _oraclePoolOfferHandler.calculateAprPremium();
        offer.aprBps = _baseRate + aprPremium;
        return IMultiSourceLoan.OfferExecution(offer, _principal, "");
    }

    function _setCollectionFactor(uint128 _floorFactor, uint128 _historicalFloorFactor) private {
        OraclePoolOfferHandler.PrincipalFactors[] memory factors = new OraclePoolOfferHandler.PrincipalFactors[](1);
        uint128 base = uint128(_oraclePoolOfferHandler.PRECISION());
        factors[0] = OraclePoolOfferHandler.PrincipalFactors(base / _floorFactor, base / _historicalFloorFactor);

        address[] memory collections = new address[](1);
        collections[0] = address(collateralCollection);

        uint96[] memory periods = new uint96[](1);
        periods[0] = _period;

        bytes[] memory extra = new bytes[](1);
        extra[0] = "";

        vm.prank(_oraclePoolOfferHandler.owner());
        _oraclePoolOfferHandler.setCollectionFactors(collections, periods, extra, factors);

        vm.warp(block.timestamp + _oraclePoolOfferHandler.MIN_WAIT_TIME() + 1);
        _oraclePoolOfferHandler.confirmCollectionFactors(collections, periods, extra, factors);
    }

    function _setOracle() private {
        vm.startPrank(_oracle.owner());
        _oracle.setData(address(collateralCollection), _period, _floorKey, _floor);
        _oracle.setData(address(collateralCollection), _period, _historicalFloorKey, _historicalFloor);
        vm.stopPrank();
    }
}
