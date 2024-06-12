from pathlib import Path
from typing import Any


from florida_contracts.contracts import (
    AddressManager,
    AuctionLoanLiquidator,
    Contract,
    Leverage,
    MultiSourceLoan,
    SampleToken,
    USDCSampleToken,
    WETH,
)
from florida_contracts.utils import (
    deploy,
    deploy_from_hex,
    get_deployed_address,
    get_deployed_address_from_cast,
)

CRYPTOPUNKSMARKET = "CRYPTOPUNKSMARKET"
WRAPPED_PUNKS = "WRAPPEDCRYPTOPUNKS"
RESOURCES = Path(__file__).parent.parent / "resources"


def e2e_deploy(
    deployed_addresses: dict[str, str],
    contract: Contract,
    rpc_url: str,
    key: str,
    is_local: bool,
):
    if contract.name_str in deployed_addresses:
        return deployed_addresses[contract.name_str]
    deployed = deploy(contract, rpc_url, key, is_local=True)
    return get_deployed_address(deployed)


def deploy_cpm(
    deployed_addresses: dict[str, str], rpc_url: str, key: str, is_local: bool
) -> str:
    if CRYPTOPUNKSMARKET in deployed_addresses:
        return deployed_addresses[CRYPTOPUNKSMARKET]
    if not is_local:
        raise ValueError("Deploying CryptoPunksMarket is only supported locally")
    with open(RESOURCES / "CryptoPunksMarket.hex") as f:
        cpm_code = f.read().strip()
    deployed_cpm = deploy_from_hex(cpm_code, rpc_url, key)
    return get_deployed_address_from_cast(deployed_cpm)


def deploy_wp(
    deployed_addresses: dict[str, str],
    rpc_url: str,
    key: str,
    deployed_cpm_address: str,
    is_local: bool,
):
    if WRAPPED_PUNKS in deployed_addresses:
        return deployed_addresses[WRAPPED_PUNKS]
    if not is_local:
        raise ValueError("Deploying WrappedPunksBase is only supported locally")
    with open(RESOURCES / "WrappedPunksBase.hex") as f:
        wp_code = f"{f.read().strip()}{deployed_cpm_address[2:]}"
    deployed_wp = deploy_from_hex(wp_code, rpc_url, key)
    deployed_wp_address = get_deployed_address_from_cast(deployed_wp)
    return deployed_wp_address


def deploy_address_manager(
    deployed_addresses: dict[str, str],
    contract: Contract,
    rpc_url: str,
    key: str,
    is_local: bool,
    addresses: list[str],
):
    if contract.name_str in deployed_addresses:
        return deployed_addresses[contract.name_str]
    whitelisted_currencies = f"[{','.join(set(addresses))}]"
    deployed_currency_wl = deploy(
        contract.with_arguments(whitelisted_currencies),
        rpc_url,
        key,
        is_local=is_local,
    )
    return get_deployed_address(deployed_currency_wl)


def deploy_liquidator(
    deployed_addresses: dict[str, str],
    rpc_url: str,
    key: str,
    is_local: bool,
    trigger_fee: int,
    deployed_currency_manager_address,
    deployed_collection_manager_address,
    deployed_liquidation_distributor_address,
):
    if AuctionLoanLiquidator.name_str in deployed_addresses:
        return deployed_addresses[AuctionLoanLiquidator.name_str]
    contract = AuctionLoanLiquidator.with_arguments(
        deployed_liquidation_distributor_address,
        deployed_currency_manager_address,
        deployed_collection_manager_address,
        trigger_fee,
    )
    deployed_liquidator = deploy(
        contract,
        rpc_url,
        key,
        is_local=is_local,
    )
    return get_deployed_address(deployed_liquidator)


def deploy_msl(
    deployed_addresses: dict[str, str],
    rpc_url: str,
    key: str,
    is_local: bool,
    deployed_liquidator_address: str,
    deployed_currency_manager_address: str,
    deployed_collection_manager_address: str,
    deployed_delegate_address: str,
    fee_recipient: str,
    fee_fraction: int,
    max_sources: int,
    min_lock_period: int,
):
    if MultiSourceLoan.name_str in deployed_addresses:
        return deployed_addresses[MultiSourceLoan.name_str]
    deployed_ms_loan = deploy(
        MultiSourceLoan.with_arguments(
            deployed_liquidator_address,
            f"({fee_recipient},{fee_fraction})",
            deployed_currency_manager_address,
            deployed_collection_manager_address,
            max_sources,
            min_lock_period,
            deployed_delegate_address,
            f"0x{0:040}",
        ),
        rpc_url,
        key,
        is_local=is_local,
    )
    return get_deployed_address(deployed_ms_loan)


def deploy_leverage(
    deployed_addresses: dict[str, str],
    rpc_url: str,
    key: str,
    is_local: bool,
    deployed_ms_loan_address: str,
    deployed_marketplace_wl_address: str,
    weth: str,
    cryptopunks_market: str,
    wrapped_cryptopunks: str,
    seaport: str,
    fee_recipient: str,
    fee_fraction: int,
) -> str:
    if Leverage.name_str in deployed_addresses:
        return deployed_addresses[Leverage.name_str]
    print(deployed_ms_loan_address)
    print(deployed_marketplace_wl_address)
    print(weth)
    print(cryptopunks_market)
    print(wrapped_cryptopunks)
    print(seaport)
    deployed_leverage = deploy(
        Leverage.with_arguments(
            deployed_ms_loan_address,
            deployed_marketplace_wl_address,
            weth,
            cryptopunks_market,
            wrapped_cryptopunks,
            seaport,
            f"({fee_recipient},{fee_fraction})",
        ),
        rpc_url,
        key,
        is_local=is_local,
    )
    return get_deployed_address(deployed_leverage)


def deploy_currencies(
    deployed_addresses: dict[str, str],
    rpc_url: str,
    key: str,
    second_key: str,
    is_local: bool,
) -> (Contract, Contract, str, str, str, str):
    deployed_weth_address = e2e_deploy(deployed_addresses, WETH, rpc_url, key, is_local)
    erc20 = SampleToken.with_name("ERC20")
    deployed_erc20_address = e2e_deploy(
        deployed_addresses, erc20, rpc_url, key, is_local=is_local
    )

    deployed_usdc_address = e2e_deploy(
        deployed_addresses, USDCSampleToken, rpc_url, second_key, is_local=is_local
    )
    currencies = [deployed_usdc_address, deployed_weth_address]
    if is_local:
        currencies.append(deployed_erc20_address)
    curr_mgr = AddressManager.with_name("CURRENCY_MANAGER")
    deployed_currency_manager_address = deploy_address_manager(
        deployed_addresses, curr_mgr, rpc_url, key, is_local, currencies
    )
    return (
        erc20,
        curr_mgr,
        deployed_erc20_address,
        deployed_usdc_address,
        deployed_weth_address,
        deployed_currency_manager_address,
    )
