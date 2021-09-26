from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv

# imports .env file
load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

install_solc("0.6.0")

# compiling solidity source code
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        },
    },
    solc_version="0.6.0",
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = json.loads(
    compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["metadata"]
)["output"]["abi"]

# Connecting to rinkeby
w3 = Web3(
    Web3.HTTPProvider("https://rinkeby.infura.io/v3/e16752d293f7410b89dc27408f2119d4")
)
chain_id = 4
my_address = "0x1b397afD7d1eCe38Ee66008635FDa030338bdF56"
private_key = os.getenv("PRIVATE_KEY")


# creating the contract
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)  # contact object

# nonce - no. of transactions sent from an address
# getting the nonce value
nonce = w3.eth.getTransactionCount(my_address)

# build the transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce}
)

# signing the transaction
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)

print("Deplying contract.....")

# send this transaction
txn_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)

# waiting for the transaction to go through
txn_receipt = w3.eth.wait_for_transaction_receipt(txn_hash)

print("Contract deployed")

# interacting with contract

simple_storage = w3.eth.contract(txn_receipt.contractAddress, abi=abi)

# two ways to interact with a contract
# 1. call -> simply make a call and no state change
# 2. transact -> state change but can be used as call only also

# initial value of favorite number
print(simple_storage.functions.retrieve().call())

store_txn = simple_storage.functions.store(10).buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce + 1}
)

print("Updating contract.....")

signed_store_txn = w3.eth.account.sign_transaction(store_txn, private_key=private_key)

send_store_txn = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)

txn_receipt = w3.eth.wait_for_transaction_receipt(send_store_txn)

print("Contract updated")

# updated value of favorite number
print(simple_storage.functions.retrieve().call())
