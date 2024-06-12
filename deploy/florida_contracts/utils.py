import os
import re
import subprocess

VALID_URLS = {
    "http://127.0.0.1:8545",
    "http://localhost:8545",
    "http://blockchain:8545",
    "https://black-solemn-shard.quiknode.pro/3c2aad1affc129b0df429a13488fe310b3cc8027/",
}

LOCAL = "local"
GOERLI = "goerli"
MAIN = "main"

NETWORK_MAPPER = {LOCAL: "ANVIL", GOERLI: "GOERLI", MAIN: "MAIN"}


def get_network_params(network):
    if network not in NETWORK_MAPPER:
        raise KeyError(f"{network} not found.")
    prefix = NETWORK_MAPPER[network]
    variables = (
        os.getenv(f"{prefix}_RPC_URL"),
        os.getenv(f"{prefix}_PRIVATE_KEY"),
        os.getenv(f"{prefix}_SECOND_PRIVATE_KEY"),
    )
    if not variables[0] or not variables[1]:
        raise RuntimeError("Missing RPC or PRIVATE_KEY")
    return variables


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
    cmd = [
        "cast",
        "send",
        "--private-key",
        private_key,
        "--rpc-url",
        rpc_url,
        contract_address,
        method_signature,
        *args,
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
