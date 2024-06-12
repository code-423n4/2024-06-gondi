// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "@solmate/utils/FixedPointMathLib.sol";
import "@solady/utils/MerkleProofLib.sol";

import "../../interfaces/loans/IMultiSourceLoan.sol";
import "../../interfaces/pools/IOracle.sol";
import "../../interfaces/pools/IPoolOfferHandler.sol";
import "./Pool.sol";
import "../utils/TwoStepOwned.sol";

/// @title OraclePoolOfferHandler
/// @author Florida St
/// @notice Handles the validation of offers for the using an oracle
contract OraclePoolOfferHandler is IPoolOfferHandler, TwoStepOwned {
    using FixedPointMathLib for uint256;

    /// @notice Extra data required for more complex validations. Trait-offers / ArtBlocks / Individual.
    /// @param code The validation code. 1 = Range, 2 = MerkleRoot, 3 = Individual
    /// @dev Even though (3) could reduce to (2), it saves us calculating hashes.
    struct PrincipalFactorsValidationData {
        uint8 code;
        bytes data;
    }

    struct AprPremium {
        uint128 value;
        uint128 updatedTs;
    }

    /// @notice Expressed in `PRECISION`
    struct PrincipalFactors {
        uint128 floor;
        uint128 historicalFloor;
    }

    /// @notice UtilizationFactor Expressed in `PRECISION`. minPremium in BPS
    struct AprFactors {
        uint128 minPremium;
        uint128 utilizationFactor;
    }

    struct MappingKey {
        address collection;
        uint96 period;
    }

    /// @notice Used for division
    uint256 public constant PRECISION = 1e27;

    /// @notice Expressed as PRECISION  (1/50)
    uint256 public constant TOLERANCE_FLOOR = 2e25;

    /// @notice Expressed as PRECISION  (1/20)
    uint256 public constant TOLERANCE_HISTORICAL_FLOOR = 5e25;

    /// @notice Min wait time to update collection factors
    uint256 public constant MIN_WAIT_TIME_UPDATE_FACTOR = 1 days;

    /// @notice Get the maximum duration allowed for a loan
    uint32 public immutable getMaxDuration;

    /// @notice Tolerance for apr to be updated
    uint256 public immutable getAprUpdateTolerance;

    /// @notice The oracle address
    address public getOracle;

    /// @notice The proposed oracle address (2-step change)
    address public getProposedOracle;

    /// @notice The timestamp when the proposed oracle was set
    uint256 public getProposedOracleSetTs;

    /// @notice Apr premium / set time;
    AprPremium public getAprPremium;

    /// @notice The APR factors
    AprFactors public getAprFactors;

    /// @notice Proposed Apr Factors
    AprFactors public getProposedAprFactors;

    /// @notice Total updates pending
    uint256 public getTotalUpdatesPending;

    /// @notice The timestamp when the proposed apr factors were set.
    uint256 public getProposedAprFactorsSetTs;

    /// @notice The key for the oracle floor
    bytes4 private immutable _oracleFloorKey;

    /// @notice The key for the oracle historical floor
    bytes4 private immutable _oracleHistoricalFloorKey;

    /// @notice key = hash(MappingKey)
    mapping(bytes32 key => PrincipalFactors factors) getProposedCollectionFactors;

    /// @notice key = hash(MappingKey)
    mapping(bytes32 key => PrincipalFactors factors) _principalFactors;

    /// @notice The timestamp when the proposed collection factors were set.
    uint256 public getProposedCollectionFactorsSetTs;

    /// @notice Pool this handler manages
    address public getPool;

    event ProposedCollectionFactorsSet(address[] collection, uint96[] duration, PrincipalFactors[] factor);
    event CollectionFactorsSet(address[] collection, uint96[] duration, bytes[], PrincipalFactors[] factor);
    event AprPremiumSet(uint256 aprPremium);
    event ProposedOracleSet(address proposedOracle);
    event OracleSet(address oracle);
    event ProposedAprFactorsSet(AprFactors aprFactors);
    event AprFactorsSet(AprFactors aprFactors);
    event PoolSet(address pool);

    error InvalidInputLengthError();
    error OutdatedValueError();
    error PoolAlreadySetError();

    constructor(
        uint32 _maxDuration,
        AprFactors memory _aprFactors,
        uint256 _aprUpdateTolerance,
        address _oracle,
        bytes4 __oracleFloorKey,
        bytes4 __oracleHistoricalFloorKey,
        uint256 _minWaitTime
    ) TwoStepOwned(tx.origin, _minWaitTime) {
        getOracle = _oracle;
        getAprFactors = _aprFactors;
        getAprUpdateTolerance = _aprUpdateTolerance;
        getProposedOracleSetTs = type(uint256).max;
        getMaxDuration = _maxDuration;
        getAprPremium = AprPremium(type(uint128).max, 0);
        _oracleFloorKey = __oracleFloorKey;
        _oracleHistoricalFloorKey = __oracleHistoricalFloorKey;
    }

    function setPool(address _pool) external onlyOwner {
        if (getPool != address(0)) {
            revert PoolAlreadySetError();
        }
        getPool = _pool;

        emit PoolSet(_pool);
    }

    /// @notice First step in changing the oracle address
    /// @param _oracle The new oracle address
    function setOracle(address _oracle) external onlyOwner {
        getProposedOracle = _oracle;
        getProposedOracleSetTs = block.timestamp;

        emit ProposedOracleSet(_oracle);
    }

    /// @notice Second step in changing the oracle address
    function confirmOracle() external {
        if (block.timestamp - MIN_WAIT_TIME < getProposedOracleSetTs) {
            revert TooSoonError();
        }
        address proposedOracle = getProposedOracle;
        getOracle = proposedOracle;
        getProposedOracle = address(0);
        getProposedOracleSetTs = type(uint256).max;

        emit OracleSet(proposedOracle);
    }

    function setAprFactors(AprFactors calldata _aprFactors) external onlyOwner {
        getProposedAprFactors = _aprFactors;
        getProposedAprFactorsSetTs = block.timestamp;

        emit ProposedAprFactorsSet(_aprFactors);
    }

    function confirmAprFactors() external {
        if (block.timestamp - MIN_WAIT_TIME < getProposedAprFactorsSetTs) {
            revert TooSoonError();
        }

        AprFactors memory proposedAprFactors = getProposedAprFactors;
        getAprFactors = proposedAprFactors;
        getProposedAprFactorsSetTs = type(uint256).max;

        emit AprFactorsSet(proposedAprFactors);
    }

    /// @notice Set the APR premium
    function setAprPremium() external {
        uint128 aprPremium = _calculateAprPremium();
        getAprPremium = AprPremium(aprPremium, uint128(block.timestamp));

        emit AprPremiumSet(aprPremium);
    }

    /// @notice Get the APR premium with current values
    /// @dev Not necessarily the same as the one set
    function calculateAprPremium() external view returns (uint128) {
        return _calculateAprPremium();
    }

    function getPrincipalFactors(address _collection, uint96 _duration, bytes memory _extra)
        external
        view
        returns (PrincipalFactors memory)
    {
        return _principalFactors[_hashKey(_collection, _duration, _extra)];
    }

    function getCollectionFactors(address _collection, uint96 _duration)
        external
        view
        returns (PrincipalFactors memory)
    {
        return _principalFactors[_hashKey(_collection, _duration, "")];
    }

    /// @notice First step in setting the collection factors for a given duration
    /// @param _collection The collection addresses
    /// @param _duration The durations
    /// @param _extra The extra data. Potentially empty.
    /// @param _factor The factors
    function setCollectionFactors(
        address[] calldata _collection,
        uint96[] calldata _duration,
        bytes[] calldata _extra,
        PrincipalFactors[] calldata _factor
    ) external onlyOwner {
        uint256 updates = _collection.length;
        if (updates != _duration.length || updates != _factor.length || updates != _extra.length) {
            revert InvalidInputLengthError();
        }
        for (uint256 i; i < updates;) {
            getProposedCollectionFactors[_hashKey(_collection[i], _duration[i], _extra[i])] = _factor[i];
            unchecked {
                ++i;
            }
        }

        getProposedCollectionFactorsSetTs = block.timestamp;
        getTotalUpdatesPending = updates;

        emit ProposedCollectionFactorsSet(_collection, _duration, _factor);
    }

    /// @notice Second step in setting the collection factors for a given duration
    /// @param _collection The collection addresses
    /// @param _duration The durations
    /// @param _extra The extra data. Potentially empty.
    /// @param _factor The factors
    function confirmCollectionFactors(
        address[] calldata _collection,
        uint96[] calldata _duration,
        bytes[] calldata _extra,
        PrincipalFactors[] calldata _factor
    ) external {
        if (block.timestamp - MIN_WAIT_TIME_UPDATE_FACTOR < getProposedCollectionFactorsSetTs) {
            revert TooSoonError();
        }
        uint256 updates = _collection.length;
        if (
            getTotalUpdatesPending != updates || updates != _duration.length || updates != _factor.length
                || updates != _extra.length
        ) {
            revert InvalidInputLengthError();
        }

        for (uint256 i; i < updates;) {
            bytes32 key = _hashKey(_collection[i], _duration[i], _extra[i]);
            PrincipalFactors memory proposedFactor = getProposedCollectionFactors[key];
            if (
                proposedFactor.floor != _factor[i].floor || proposedFactor.historicalFloor != _factor[i].historicalFloor
            ) {
                revert InvalidInputError();
            }
            _principalFactors[key] = proposedFactor;
            unchecked {
                ++i;
            }
        }
        getProposedCollectionFactorsSetTs = type(uint256).max;
        getTotalUpdatesPending = 0;

        emit CollectionFactorsSet(_collection, _duration, _extra, _factor);
    }

    /// @inheritdoc IPoolOfferHandler
    function validateOffer(uint256 _baseRate, bytes calldata _offer)
        external
        view
        override
        returns (uint256, uint256)
    {
        AprPremium memory aprPremium = getAprPremium;
        uint256 aprPremiumValue =
            (block.timestamp - aprPremium.updatedTs > getAprUpdateTolerance) ? _calculateAprPremium() : aprPremium.value;
        IMultiSourceLoan.OfferExecution memory offerExecution = abi.decode(_offer, (IMultiSourceLoan.OfferExecution));
        uint256 duration = offerExecution.offer.duration;
        IOracle oracle = IOracle(getOracle);
        IOracle.CollectionData memory currentFloor =
            oracle.getData(offerExecution.offer.nftCollateralAddress, uint64(duration), _oracleFloorKey);
        IOracle.CollectionData memory historicalFloor =
            oracle.getData(offerExecution.offer.nftCollateralAddress, uint64(duration), _oracleHistoricalFloorKey);

        if (
            block.timestamp - currentFloor.updated > duration.mulDivDown(TOLERANCE_FLOOR, PRECISION)
                || block.timestamp - historicalFloor.updated > duration.mulDivDown(TOLERANCE_HISTORICAL_FLOOR, PRECISION)
        ) {
            revert OutdatedValueError();
        }

        PrincipalFactors memory factors = _getFactors(
            offerExecution.offer.nftCollateralAddress,
            offerExecution.offer.nftCollateralTokenId,
            duration,
            offerExecution.offer.validators
        );

        uint128 maxPrincipalFromCurrentFloor = uint128(uint256(currentFloor.value).mulDivDown(factors.floor, PRECISION));
        uint128 maxPrincipalFromHistoricalFloor =
            uint128(uint256(historicalFloor.value).mulDivDown(factors.historicalFloor, PRECISION));
        uint256 maxPrincipal = maxPrincipalFromCurrentFloor > maxPrincipalFromHistoricalFloor
            ? maxPrincipalFromHistoricalFloor
            : maxPrincipalFromCurrentFloor;

        if (offerExecution.amount > maxPrincipal) {
            revert InvalidPrincipalAmountError();
        }

        if (_baseRate + aprPremiumValue > offerExecution.offer.aprBps) {
            revert InvalidAprError();
        }

        if (offerExecution.offer.maxSeniorRepayment != 0) {
            revert InvalidMaxSeniorRepaymentError();
        }

        return (offerExecution.amount, offerExecution.offer.aprBps);
    }

    function _getFactors(
        address _collateralAddress,
        uint256 _collateralTokenId,
        uint256 _duration,
        IBaseLoan.OfferValidator[] memory _validators
    ) private view returns (PrincipalFactors memory) {
        bytes32 key;
        if (_validators.length == 0) {
            key = _hashKey(_collateralAddress, uint96(_duration), "");
        } else if (_validators.length == 1 && _isZeroAddress(_validators[0].validator)) {
            PrincipalFactorsValidationData memory validationData =
                abi.decode(_validators[0].arguments, (PrincipalFactorsValidationData));
            if (validationData.code == 1) {
                // Range
                (uint256 min, uint256 max) = abi.decode(validationData.data, (uint256, uint256));
                if (_collateralTokenId < min && _collateralTokenId > max) {
                    revert InvalidInputError();
                }
                key = _hashKey(_collateralAddress, uint96(_duration), validationData.data);
            } else if (validationData.code == 2) {
                // MerkleRoot
                (bytes32[] memory proof, bytes32 root) = abi.decode(validationData.data, (bytes32[], bytes32));
                bytes32 leaf = keccak256(abi.encodePacked(_collateralTokenId));
                MerkleProofLib.verify(proof, root, leaf);
                key = _hashKey(_collateralAddress, uint96(_duration), abi.encodePacked(root));
            } else if (validationData.code == 3) {
                // Individual
                uint256 tokenId = abi.decode(validationData.data, (uint256));
                if (_collateralTokenId != tokenId) {
                    revert InvalidInputError();
                }
                key = _hashKey(_collateralAddress, uint96(_duration), validationData.data);
            } else {
                revert InvalidInputError();
            }
        }
        return _principalFactors[key];
    }

    function _hashKey(address _collection, uint96 _duration, bytes memory _extra) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_collection, _duration, _extra));
    }

    /// @notice Calculate the APR premium
    function _calculateAprPremium() private view returns (uint128) {
        /// @dev cached
        Pool pool = Pool(getPool);

        AprFactors memory aprFactors = getAprFactors;
        uint256 totalAssets = pool.totalAssets();
        uint256 totalOutstanding = totalAssets - pool.getUndeployedAssets();
        return uint128(
            totalOutstanding.mulDivUp(aprFactors.utilizationFactor, totalAssets * PRECISION) + aprFactors.minPremium
        );
    }

    function _isZeroAddress(address _address) private pure returns (bool) {
        bool isZero;
        assembly {
            isZero := iszero(_address)
        }
        return isZero;
    }
}
