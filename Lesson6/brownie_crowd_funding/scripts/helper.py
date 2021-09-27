from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-devv"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():

    print(f"The active network is {network.show_active()}")

    print("Deploying Mocks....")

    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(
            DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()}
        )

    print("Mocks Deployed!")

# adding a forking network
# brownie networks add development mainnet-fork-devv cmd=ganache-cli host=http://127.0.0.1 fork=https://eth-mainnet.alchemyapi.io/v2/mSAKafZetlnubw6exUfG3zF4wiHYLAev accounts=10 mnemonic=brownie port=8545
