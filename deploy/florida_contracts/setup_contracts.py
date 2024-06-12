from florida_contracts.contracts import (
    AuctionLoanLiquidator,
    LiquidationDistributor,
    Leverage,
    MultiSourceLoan,
    UserVault,
)
from florida_contracts.utils import send_local


def setup_distributor(rpc_url: str, key: str, deployed: dict[str, str]):
    send_local(
        key,
        rpc_url,
        deployed[AuctionLoanLiquidator.name_str],
        "updateLiquidationDistributor(address)",
        [deployed[LiquidationDistributor.name_str]],
    )


def setup_liquidator(rpc_url: str, key: str, deployed: dict[str, str]):
    send_local(
        key,
        rpc_url,
        deployed[AuctionLoanLiquidator.name_str],
        "addLoanContract(address)",
        [deployed[MultiSourceLoan.name_str]],
    )


def setup_whitelisted_callback(
    rpc_url: str, key: str, deployed: dict[str, str], buy_tax: int, sell_tax: int
):
    send_local(
        key,
        rpc_url,
        deployed[MultiSourceLoan.name_str],
        "addWhitelistedCallbackContract(address,(uint128,uint128))",
        [deployed[Leverage.name_str], f"({buy_tax},{sell_tax})"],
    )


def whitelist_user_vault(
    rpc_url: str, key: str, user_vault_address: str, collection_manager_address: str
):
    send_local(
        key,
        rpc_url,
        collection_manager_address,
        "add(address)",
        [user_vault_address],
    )
