import argparse

import yaml

from florida_contracts.contracts import (
    AddressManager,
    AuctionLoanLiquidator,
    DelegateRegistry,
    Leverage,
    LiquidationDistributor,
    MultiSourceLoan,
    RangeValidator,
    SampleCollection,
    USDCSampleToken,
    UserVault,
    WETH,
)
from florida_contracts.deployers import (
    deploy_address_manager,
    deploy_cpm,
    deploy_currencies,
    deploy_leverage,
    deploy_liquidator,
    deploy_msl,
    deploy_wp,
    e2e_deploy,
)
from florida_contracts.setup_contracts import (
    setup_distributor,
    setup_liquidator,
    setup_whitelisted_callback,
    whitelist_user_vault,
)
from florida_contracts.utils import get_network_params, send_local


def deploy_full(config, is_local: bool) -> dict[str, str]:
    deployed_addresses = (
        config["deployed_addresses"] if "deployed_addresses" in config else {}
    )
    rpc_url, key, second_key = get_network_params(network)
    deployed_cpm_address = deploy_cpm(deployed_addresses, rpc_url, key, is_local)
    deployed_wp_address = deploy_wp(
        deployed_addresses, rpc_url, key, deployed_cpm_address, is_local
    )
    deployed_delegate_address = e2e_deploy(
        deployed_addresses, DelegateRegistry, rpc_url, key, is_local
    )
    erc721 = SampleCollection.with_name("ERC721")
    deployed_erc721_address = e2e_deploy(
        deployed_addresses, erc721, rpc_url, key, is_local=is_local
    )
    (
        erc20,
        curr_mgr,
        deployed_erc20_address,
        deployed_usdc_address,
        deployed_weth_address,
        deployed_currency_manager_address,
    ) = deploy_currencies(deployed_addresses, rpc_url, key, key, is_local)

    collections = []
    if is_local:
        collections.append(deployed_erc721_address)
    coll_mgr = AddressManager.with_name("COLLECTION_MANAGER")
    deployed_collection_manager_address = deploy_address_manager(
        deployed_addresses,
        coll_mgr,
        rpc_url,
        key,
        is_local,
        collections,
    )

    old_coll_mgr = AddressManager.with_name("OLD_COLLECTION_MANAGER")
    deployed_old_collection_manager_address = deploy_address_manager(
        deployed_addresses, old_coll_mgr, rpc_url, key, is_local, []  # collections,
    )

    seaport_address = deployed_addresses["SEAPORT"]
    whitelisted_marketplaces = [deployed_wp_address, seaport_address]
    marketplace_mgr = AddressManager.with_name("MARKETPLACE_MANAGER")
    deployed_marketplace_wl_address = deploy_address_manager(
        deployed_addresses,
        marketplace_mgr,
        rpc_url,
        key,
        is_local,
        whitelisted_marketplaces,
    )

    deployed_liquidation_distributor_address = e2e_deploy(
        deployed_addresses,
        LiquidationDistributor,
        rpc_url,
        key,
        is_local=is_local,
    )

    deployed_liquidator_address = deploy_liquidator(
        deployed_addresses,
        rpc_url,
        key,
        is_local,
        config["trigger_fee"],
        deployed_currency_manager_address,
        deployed_collection_manager_address,
        deployed_liquidation_distributor_address,
    )

    deployed_ms_loan_address = deploy_msl(
        deployed_addresses,
        rpc_url,
        key,
        is_local,
        deployed_liquidator_address,
        deployed_currency_manager_address,
        deployed_collection_manager_address,
        deployed_delegate_address,
        config["fee_recipient"],
        config["fee_fraction"],
        config["max_sources"],
        config["min_lock_period"],
    )

    deployed_range_validator_address = e2e_deploy(
        deployed_addresses, RangeValidator, rpc_url, key, is_local=is_local
    )

    deployed_leverage_address = deploy_leverage(
        deployed_addresses,
        rpc_url,
        key,
        is_local,
        deployed_ms_loan_address,
        deployed_marketplace_wl_address,
        deployed_weth_address,
        deployed_cpm_address,
        deployed_wp_address,
        seaport_address,
        config["fee_recipient"],
        config["fee_fraction"],
    )

    deployed_user_vault = e2e_deploy(
        deployed_addresses,
        UserVault.with_arguments(
            deployed_currency_manager_address,
            deployed_collection_manager_address,
            deployed_old_collection_manager_address,
        ),
        rpc_url,
        key,
        is_local,
    )
    ## TODO: check if it's not already whiteslited
    ## PATCH
    if UserVault.name_str not in deployed_addresses:
        whitelist_user_vault(
            rpc_url, key, deployed_user_vault, deployed_collection_manager_address
        )

    return {
        "WRAPPED_PUNKS": deployed_wp_address,
        "CRYPTOPUNKSMARKET": deployed_cpm_address,
        WETH.name_str: deployed_weth_address,
        DelegateRegistry.name_str: deployed_delegate_address,
        erc20.name_str: deployed_erc20_address,
        erc721.name_str: deployed_erc721_address,
        USDCSampleToken.name_str: deployed_usdc_address,
        curr_mgr.name_str: deployed_currency_manager_address,
        coll_mgr.name_str: deployed_collection_manager_address,
        old_coll_mgr.name_str: deployed_old_collection_manager_address,
        marketplace_mgr.name_str: deployed_marketplace_wl_address,
        LiquidationDistributor.name_str: deployed_liquidation_distributor_address,
        AuctionLoanLiquidator.name_str: deployed_liquidator_address,
        MultiSourceLoan.name_str: deployed_ms_loan_address,
        RangeValidator.name_str: deployed_range_validator_address,
        Leverage.name_str: deployed_leverage_address,
        UserVault.name_str: deployed_user_vault,
    }


def setup(deployed: dict[str, str], buy_tax: int, sell_tax: int):
    rpc_url, key, second_key = get_network_params(network)
    setup_distributor(rpc_url, key, deployed)
    setup_liquidator(rpc_url, key, deployed)
    setup_whitelisted_callback(rpc_url, key, deployed, buy_tax, sell_tax)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Deploy script. Please fill the .env file with the relevant variables."
    )
    parser.add_argument("config_file")
    parser.add_argument("collections_count", type=int, default=1, nargs="?")
    args = parser.parse_args()
    with open(args.config_file) as f:
        config = yaml.load(f, Loader=yaml.Loader)
    network = config["network"].lower().strip()
    collections_count = args.collections_count
    collection_addresses = []

    addresses = config["deployed_addresses"]

    deployed = deploy_full(config, network)
    if config["should_setup"]:
        setup(deployed, config["buy_tax"], config["sell_tax"])

    with open(f"deployed_{network}.yml", "w+") as f:
        yaml.dump(
            deployed,
            f,
        )
