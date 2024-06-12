import argparse
import yaml

from dotenv import load_dotenv
from deploy.florida_contracts.contracts import (
    Leverage,
)
from deploy import deploy, get_network_params, get_deployed_address

load_dotenv()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Deploy Leverage script. Please fill the .env file with the relevant variables."
    )
    parser.add_argument("config_file")
    parser.add_argument("ms_loan_address")
    parser.add_argument("marketplace_wl_address")
    args = parser.parse_args()
    with open(args.config_file) as f:
        config = yaml.load(f, Loader=yaml.Loader)
    network = config["network"].lower().strip()
    print(network)
    rpc_url, key, second_key = get_network_params(network)

    is_local = network == "local"

    if not rpc_url or not key:
        raise RuntimeError("Missing RPC_URL or KEY")

    deployed_leverage = deploy(
        Leverage.with_arguments(
            args.ms_loan_address,
            args.marketplace_wl_address,
            config['weth'],
            config['cryptopunks_market'],
            config['wrapped_cryptopunks'],
            config["seaport"],
        ),
        rpc_url,
        key,
        is_local=is_local,
    )
    deployed_leverage_address = get_deployed_address(deployed_leverage)
    print(f"Successfully deployed Leverage at: {deployed_leverage_address}")

    with open("config_leverage.yml", "w+") as f:
        yaml.dump(
            {
                "LEVERAGE": deployed_leverage_address,
            },
            f,
        )
