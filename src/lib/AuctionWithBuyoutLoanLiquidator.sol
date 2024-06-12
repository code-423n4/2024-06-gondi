// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.21;

import "../interfaces/loans/ILoanManagerRegistry.sol";
import "./loans/LoanManager.sol";
import "./utils/Interest.sol";
import "./AuctionLoanLiquidator.sol";

/// @title Auction With Buyout Loan Liquidator
/// @author Florida St
/// @notice Receives an NFT to be auctioned when a loan defaults. Main lender has the option to buy out other lenders.
contract AuctionWithBuyoutLoanLiquidator is AuctionLoanLiquidator {
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;
    /// @notice Time for main lender to buy

    uint256 private _timeForMainLenderToBuy;

    uint256 public constant MAX_TIME_FOR_MAIN_LENDER_TO_BUY = 4 days;

    ILoanManagerRegistry public immutable getLoanManagerRegistry;

    event AuctionSettledWithBuyout(
        address loanAddress, uint256 loanId, address nftAddress, uint256 tokenId, uint256 largestTrancheIdx
    );

    event TimeForMainLenderToBuyUpdated(uint256 timeForMainLenderToBuy);

    error OptionToBuyExpiredError(uint256 timeLimit);

    error OptionToBuyStilValidError(uint256 timeLimit);

    error NotMainLenderError();

    error InvalidInputError();

    /// @param liquidationDistributor Contract that distributes the proceeds of an auction.
    /// @param currencyManager The address manager for currencies (check whitelisting).
    /// @param collectionManager The address manager for collections (check whitelisting).
    /// @param loanManagerRegistry The address of the LoanManagerRegistry.
    /// @param triggerFee The trigger fee. Given to the originator/settler of an auction. Expressed in bps.
    /// @param maxExtension The maximum extension for an auction.
    /// @param timeForMainLenderToBuy Time for the main lender to buy other lenders out.
    constructor(
        address liquidationDistributor,
        address currencyManager,
        address collectionManager,
        address loanManagerRegistry,
        uint256 triggerFee,
        uint96 maxExtension,
        uint256 timeForMainLenderToBuy
    ) AuctionLoanLiquidator(liquidationDistributor, currencyManager, collectionManager, triggerFee, maxExtension) {
        _timeForMainLenderToBuy = timeForMainLenderToBuy;

        getLoanManagerRegistry = ILoanManagerRegistry(loanManagerRegistry);
    }

    /// @notice Settles an auction with a buyout from the main lender.
    ///         This runs for `_timeForMainLenderToBuy` seconds after the auction starts.
    /// @param _nftAddress The address of the NFT.
    /// @param _tokenId The ID of the NFT.
    /// @param _auction The auction data.
    /// @param _loan The loan data.
    function settleWithBuyout(
        address _nftAddress,
        uint256 _tokenId,
        Auction calldata _auction,
        IMultiSourceLoan.Loan calldata _loan
    ) external nonReentrant {
        address buyer = msg.sender;

        _checkAuction(_nftAddress, _tokenId, _auction);
        uint256 timeLimit = _auction.startTime + _timeForMainLenderToBuy;
        if (timeLimit <= block.timestamp) {
            revert OptionToBuyExpiredError(timeLimit);
        }
        uint256 largestTrancheIdx;
        uint256 largestPrincipal;
        uint256 totalTranches = _loan.tranche.length;
        for (uint256 i = 0; i < totalTranches;) {
            if (_loan.tranche[i].principalAmount > largestPrincipal) {
                largestPrincipal = _loan.tranche[i].principalAmount;
                largestTrancheIdx = i;
            }
            unchecked {
                ++i;
            }
        }
        if (buyer != _loan.tranche[largestTrancheIdx].lender) {
            revert NotMainLenderError();
        }
        ERC20 asset = ERC20(_auction.asset);
        uint256 totalOwed;
        for (uint256 i; i < totalTranches;) {
            if (i != largestTrancheIdx) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                uint256 owed = thisTranche.principalAmount + thisTranche.accruedInterest
                    + thisTranche.principalAmount.getInterest(thisTranche.aprBps, block.timestamp - thisTranche.startTime);
                totalOwed += owed;
                asset.safeTransferFrom(msg.sender, thisTranche.lender, owed);

                if (getLoanManagerRegistry.isLoanManager(thisTranche.lender)) {
                    LoanManager(thisTranche.lender).loanLiquidation(
                        _auction.loanAddress,
                        thisTranche.loanId,
                        thisTranche.principalAmount,
                        thisTranche.aprBps,
                        thisTranche.accruedInterest,
                        _loan.protocolFee,
                        owed,
                        thisTranche.startTime
                    );
                }
            }
            unchecked {
                ++i;
            }
        }
        IMultiSourceLoan(_auction.loanAddress).loanLiquidated(_auction.loanId, _loan);

        asset.safeTransferFrom(buyer, _auction.originator, totalOwed.mulDivDown(_auction.triggerFee, _BPS));

        ERC721(_loan.nftCollateralAddress).transferFrom(address(this), buyer, _tokenId);

        delete _auctions[_nftAddress][_tokenId];

        emit AuctionSettledWithBuyout(_auction.loanAddress, _auction.loanId, _nftAddress, _tokenId, largestTrancheIdx);
    }

    /// @notice Sets the time for the main lender to buy other lenders out.
    /// @param __timeForMainLenderToBuy The time for the main lender to buy other lenders out.
    function setTimeForMainLenderToBuy(uint256 __timeForMainLenderToBuy) external onlyOwner {
        if (__timeForMainLenderToBuy > MAX_TIME_FOR_MAIN_LENDER_TO_BUY) {
            revert InvalidInputError();
        }
        _timeForMainLenderToBuy = __timeForMainLenderToBuy;

        emit TimeForMainLenderToBuyUpdated(__timeForMainLenderToBuy);
    }

    /// @notice Gets the time for the main lender to buy other lenders out.
    function getTimeForMainLenderToBuy() external view returns (uint256) {
        return _timeForMainLenderToBuy;
    }

    function _placeBidChecks(address _nftAddress, uint256 _tokenId, Auction memory _auction, uint256 _bid)
        internal
        view
        override
    {
        super._placeBidChecks(_nftAddress, _tokenId, _auction, _bid);
        uint256 timeLimit = _auction.startTime + _timeForMainLenderToBuy;
        if (timeLimit > block.timestamp) {
            revert OptionToBuyStilValidError(timeLimit);
        }
    }
}
