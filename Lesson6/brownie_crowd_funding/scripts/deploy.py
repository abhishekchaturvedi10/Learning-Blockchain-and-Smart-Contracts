from brownie import FundMe, network, config, MockV3Aggregator
from brownie.network import account
from scripts.helper import deploy_mocks, get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS


def deploy_fund_me():

    account = get_account()

    # if we are on a persistent network like rinkeby, use this address
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    # first parameter is the price feed address to FundMe contract
    # third parameter is for publishing the source code of the contract for verification
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )

    print(f"Contract deployed to {fund_me.address}")

    return fund_me


def main():
    deploy_fund_me()


#  brownie networks add Ethereum ganache-local host=http://127.0.0.1:8545 chainid=1337 to local ganache to etereum so that it can be tracked in build/deployments 