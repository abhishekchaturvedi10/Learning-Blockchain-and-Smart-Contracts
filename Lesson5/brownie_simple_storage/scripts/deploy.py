# to connect to custom network 
# brownie run scripts/deploy.py --network <network name>

# brownie makes up 10 fake accounts in ganache by itself when it is launched

# brownie is capable of differentiating between call and transaction


from brownie import accounts, config, SimpleStorage, network
from brownie.network import account


def deploy_simple_storage():

    # works only when connected to ganache
    # account = accounts[0] 

    account = get_account()

    simple_storage = SimpleStorage.deploy({"from": account})

    # since this is only a view function "from" is not required
    stored_value = simple_storage.retrieve()
    print(stored_value)

    transaction = simple_storage.store(10, {"from": account})
    transaction.wait(1) # waiting for 1 block

    updated_stored_value = simple_storage.retrieve()
    print(updated_stored_value)

    # account = accounts.load("Abhishek")  - newly created account using -> brownie accounts new Abhishek

    # accounts.add(config["wallets"]["from_key"])


def get_account():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def main():
    deploy_simple_storage()
