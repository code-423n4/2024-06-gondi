import argparse
import os
import re
import subprocess
import yaml
from pathlib import Path

from dotenv import load_dotenv
from deploy.florida_contracts.contracts import (
    AuctionLoanLiquidator,
    AddressManager,
    DelegateRegistry,
    Leverage,
    LiquidationDistributor,
    MultiSourceLoan,
    RangeValidator,
    SampleCollection,
    SampleToken,
    USDCSampleToken,
    WETH,
)

load_dotenv()


FAKE_ADDRESS = f"0xFA4E{0:036}"


def get_network_params(network):
    if network == "local":
        prefix = "ANVIL"
    elif network == "goerli":
        prefix = "GOERLI"
    elif network == "main":
        prefix = "MAIN"
    else:
        raise KeyError(f"{network} not found.")
    return (
        os.getenv(f"{prefix}_RPC_URL"),
        os.getenv(f"{prefix}_PRIVATE_KEY"),
        os.getenv(f"{prefix}_SECOND_PRIVATE_KEY"),
    )


def get_deployed_address(output):
    return re.findall("Deployed to: (.*)", output.stdout)[0]


def get_deployed_address_from_cast(output):
    return re.findall("contractAddress[\s]+(.*)", output.stdout)[0]


def deploy(contract, rpc_url, private_key, libraries=None, is_local=True):
    cmd = [
        "forge",
        "create",
        f"{contract.filename}:{contract.contract_name}",
        "--rpc-url",
        rpc_url,
        "--private-key",
        private_key,
        "--optimize",
        "--via-ir",
    ]
    if not is_local:
        cmd += ["--verify"]
    if contract.arguments:
        cmd += ["--constructor-args"] + list(contract.arguments)
    if libraries:
        cmd += ["--libraries"] + libraries
    print(cmd)
    output = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        text=True,
    )
    if output.returncode not in {0, 1}:
        raise RuntimeError(f"Could not deploy: {contract}\n{output}")
    return output


def deploy_from_hex(code, rpc_url, private_key):
    cmd = [
        "cast",
        "send",
        "--private-key",
        private_key,
        "--rpc-url",
        rpc_url,
        "--create",
        code,
    ]
    print("Deploying from hex")
    output = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        text=True,
    )
    if output.returncode not in {0, 1}:
        raise RuntimeError("Could not deploy from code")
    return output


def send_local(private_key, rpc_url, contract_address, method_signature, args):
    if "http://127.0.0.1:8545" not in rpc_url and "http://localhost:8545" not in rpc_url and "http://blockchain:8545" not in rpc_url:
        raise RuntimeError("Not a local network: send implemented for local networks only")
    cmd = [
        "cast",
        "send",
        "--private-key",
        private_key,
        "--rpc-url",
        rpc_url,
        contract_address,
        method_signature,
        *args
    ]
    print(cmd)
    output = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        text=True,
    )
    if output.returncode not in {0, 1}:
        raise RuntimeError(f"Could not send: {contract_address} {method_signature}")
    return output


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
    rpc_url, key, second_key = get_network_params(network)
    collections_count = args.collections_count
    collection_addresses = []

    deployed_liquidator_address = None
    deployed_ms_loan_address = None
    deployed_erc20_address = None
    deployed_usdc_erc20_address = None
    deployed_currency_manager_address = None
    deployed_collection_manager_address = None
    deployed_range_validator_address = None
    deployed_delegate_address = None
    deployed_leverage_address = None
    deployed_weth_address = None

    is_local = network == "local"

    if not rpc_url or not key:
        raise RuntimeError("Missing RPC_URL or KEY")

    ## Deploy sample tokens for testing
    if is_local:
        punks_path = Path(__file__).parent / "punks"
        with open(punks_path / "CryptoPunksMarket.hex") as f:
            cpm_code = f.read().strip()
        deployed_cpm = deploy_from_hex(cpm_code, rpc_url, key)
        deployed_cpm_address = get_deployed_address_from_cast(deployed_cpm)

        with open(punks_path / "WrappedPunksBase.hex") as f:
            wp_code = f"{f.read().strip()}{deployed_cpm_address[2:]}"

        deployed_wp = deploy_from_hex(wp_code, rpc_url, key)
        deployed_wp_address = get_deployed_address_from_cast(deployed_wp)
        collection_addresses.append(deployed_wp_address)

        # deployed_cpm_address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
        # deployed_wp_address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

        deployed_weth = deploy(WETH, rpc_url, key, is_local=is_local)
        deployed_weth_address = get_deployed_address(deployed_weth)
        print(f"Successfully deployed WETH at: {deployed_erc20_address}")

        deployed_delegate = deploy(DelegateRegistry, rpc_url, key, is_local=is_local)
        deployed_delegate_address = get_deployed_address(deployed_delegate)

        deployed_erc20_output = deploy(SampleToken, rpc_url, key, is_local=is_local)
        deployed_erc20_address = get_deployed_address(deployed_erc20_output)
        print(f"Successfully deployed Sample ERC 20 at: {deployed_erc20_address}")
        deployed_erc721_output = deploy(
            SampleCollection, rpc_url, key, is_local=is_local
        )
        deployed_erc721_address = get_deployed_address(deployed_erc721_output)
        print(f"Successfully deployed Sample ERC 721 at: {deployed_erc721_address}")
        collection_addresses.append(deployed_erc721_address)
        for _ in range(1, collections_count):
            deployed_erc721_output = deploy(
                SampleCollection, rpc_url, second_key, is_local=is_local
            )
            deployed_erc721_address = get_deployed_address(deployed_erc721_output)
            print(f"Successfully deployed Sample ERC 721 at: {deployed_erc721_address}")
            collection_addresses.append(deployed_erc721_address)
        deployed_usdc_erc20_output = deploy(
            USDCSampleToken, rpc_url, second_key, is_local=is_local
        )
        deployed_usdc_erc20_address = get_deployed_address(deployed_usdc_erc20_output)
        print(
            f"Successfully deployed Sample USDC ERC 20 at: {deployed_usdc_erc20_address}"
        )

    elif network == "goerli":
        if "ERC20" not in config or not config["ERC20"]:
            deployed_erc20_output = deploy(SampleToken, rpc_url, key, is_local=is_local)
            deployed_erc20_address = get_deployed_address(deployed_erc20_output)
            print(f"Successfully deployed Sample ERC 20 at: {deployed_erc20_address}")
        else:
            deployed_erc20_address = config["ERC20"]
        if "ERC721" not in config or not config["ERC721"]:
            deployed_erc721_output = deploy(
                SampleCollection, rpc_url, key, is_local=is_local
            )
            deployed_erc721_address = get_deployed_address(deployed_erc721_output)
            print(f"Successfully deployed Sample ERC 721 at: {deployed_erc721_address}")
            collection_addresses.append(deployed_erc721_address)
        else:
            deployed_erc721_address = config["ERC721"]
            collection_addresses.append(deployed_erc721_address)
    elif network == "main":
        deployed_erc20_address = config["ERC20"]

    # Deploy Whitelisted Currencies
    whitelisted_currencies = (
        f"[{deployed_erc20_address},{deployed_usdc_erc20_address},{deployed_weth_address}]"
        if deployed_usdc_erc20_address
        else f"[{deployed_erc20_address}]"
    )
    deployed_currency_wl = deploy(
        AddressManager.with_arguments(whitelisted_currencies),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_currency_manager_address = get_deployed_address(deployed_currency_wl)
    print(
        f"Successfully deployed Whitelist for currencies at: {deployed_currency_manager_address}"
    )

    # Deploy Whitelisted Collections
    deployed_collection_manager = deploy(
        AddressManager.with_arguments("[" + ",".join(collection_addresses) + "]"),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_collection_manager_address = get_deployed_address(
        deployed_collection_manager
    )
    print(
        f"Successfully deployed Whitelist for collections at: {deployed_collection_manager_address}"
    )

    # Deployed Marketplace Whitelisted
    deployed_marketplace_wl = deploy(
        AddressManager.with_arguments(f"[{deployed_cpm_address}]"),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_marketplace_wl_address = get_deployed_address(deployed_marketplace_wl)

    ## Deploy Liquidator
    deployed_liquidation_distributor_address = FAKE_ADDRESS # TODO: update this if we are using this deploy process for mainnet deploy
    deployed_liquidator = deploy(
        AuctionLoanLiquidator.with_arguments(
            deployed_liquidation_distributor_address,
            deployed_currency_manager_address,
            deployed_collection_manager_address,
            config["trigger_fee"],
        ),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_liquidator_address = get_deployed_address(deployed_liquidator)
    print(
        f"Successfully deployed AuctionLoanLiquidator at: {deployed_liquidator_address}"
    )

    ## Deploy MSL
    deployed_ms_loan = deploy(
        MultiSourceLoan.with_arguments(
            deployed_liquidator_address,
            f"({config['fee_recipient']},{config['fee_fraction']})",
            deployed_currency_manager_address,
            deployed_collection_manager_address,
            config["max_sources"],
            config["min_lock_period"],
            deployed_delegate_address,
            f"0x{0:040}",
        ),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_ms_loan_address = get_deployed_address(deployed_ms_loan)
    print(f"Successfully deployed MultiSourceLoan at: {deployed_ms_loan_address}")

    deployed_range_validator = deploy(RangeValidator, rpc_url, key, is_local=is_local)
    deployed_range_validator_address = get_deployed_address(deployed_range_validator)
    print(
        f"Successfully deployed RangeValidator at: {get_deployed_address(deployed_range_validator)}"
    )

    # deployed_leverage = deploy(
    #     Leverage.with_arguments(
    #         deployed_ms_loan_address,
    #         deployed_marketplace_wl_address,
    #         config['weth'],
    #         config['cryptopunks_market'],
    #         config['wrapped_cryptopunks'],
    #         config["seaport"],
    #     ),
    #     rpc_url,
    #     key,
    #     is_local=is_local,
    # )
    # deployed_leverage_address = get_deployed_address(deployed_leverage)
    # print(f"Successfully deployed Leverage at: {deployed_leverage_address}")

    if is_local:
        deployed_liquidation_distributor = deploy(
            LiquidationDistributor,
            rpc_url,
            key,
            is_local=is_local,
        )
        deployed_liquidation_distributor_address = get_deployed_address(deployed_liquidation_distributor)
        send_local(key, rpc_url, deployed_liquidator_address, "updateLiquidationDistributor(address)", [deployed_liquidation_distributor_address])
        print(f"Successfully deployed LiquidationDistributor at: {deployed_liquidation_distributor_address}")

    with open("config.yml", "w+") as f:
        yaml.dump(
            {
                "LIQUIDATOR": deployed_liquidator_address,
                "LIQUIDATION_DISTRIBUTOR": deployed_liquidation_distributor_address,
                "MULTI_SOURCE_LOAN": deployed_ms_loan_address,
                "ERC20": deployed_erc20_address,
                "USDC_ERC20": deployed_usdc_erc20_address,
                "ERC721": deployed_erc721_address or "",
                "CURRENCY_MANAGER": deployed_currency_manager_address,
                "COLLECTION_MANAGER": deployed_collection_manager_address,
                "RANGE_VALIDATOR": deployed_range_validator_address,
                "ERC721_ADDRESSES": collection_addresses,
                "WETH": deployed_weth_address,
                "DELEGATE": deployed_delegate_address,
                "CRYPTOPUNKSMARKET": deployed_cpm_address,
                "WRAPPED_PUNKS": deployed_wp_address,
                "DEPLOYED_MARKETPLACE_MANAGER": deployed_marketplace_wl_address,
            },
            f,
        )
