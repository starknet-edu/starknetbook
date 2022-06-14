import os
import json
import web3
import requests
import sys

sys.path.append('../../fees/python')
from fees import calculate_execution, WEI_CONVERT, COST_PER_WORD
from pathlib import Path
from starknet_py.contract import Contract
from starknet_py.net.client import Client


FEEDER_URL = "https://alpha4.starknet.io/feeder_gateway/get_state_update?blockNumber="
TX=0x38d6ed8a35638b3947fa0a6cee902127cbebcdaba5705010599bc6979eb2456
GOERLI_CORE_CONTRACTS=0xde29d060D45901Fb19ED6C6e959EB22d8626708e
GOERLI_VERIFIER=0xAB43bA48c9edF4C2C4bB01237348D1D7B28ef168
GOERLI_MEMORY_REGISTRY=0x743789ff2fF82Bfb907009C9911a7dA636D34FA7
GOERLI_NODE=os.getenv("GOERLI_URL")

client = Client("testnet")

# get contract address
demo_tx = client.get_transaction_sync(TX)
account_addr = "0x{:x}".format(demo_tx.transaction.contract_address)
contract_addr = "0x{:x}".format(demo_tx.transaction.calldata[1])
print("\nAccount Address: 0x{}".format(account_addr))
print("Contract Address: 0x{}\n".format(contract_addr))
print("Storage Update TX ")
print("\tStatus:\t\t\t", demo_tx.status)

if "ACCEPT" in str(demo_tx.status):
    print("\tTransaction Index:\t", demo_tx.transaction_index)
    print("\tBlock Hash:\t\t 0x{:x}".format(demo_tx.block_hash))
    print("\tBlock Num:\t\t", demo_tx.block_number)

if "ACCEPTED_ON_L1" in str(demo_tx.status):
    print("\nTransaction Info: ")
    # fetch info
    block = client.get_block_sync(block_number=demo_tx.block_number)
    tx_receipt = client.get_transaction_receipt_sync(TX)
    state_update = requests.request("GET", FEEDER_URL+str(demo_tx.block_number)).json()
    account_state = state_update["state_diff"]["storage_diffs"][account_addr]
    contract_state = state_update["state_diff"]["storage_diffs"][contract_addr]

    gas_price = block.gas_price/WEI_CONVERT
    total_words = 2 * 2 + (2 * (len(account_state)+len(contract_state)))
    calldata_fee = int(gas_price) * COST_PER_WORD * total_words
    execution_fees = calculate_execution("0x{:x}".format(TX))

    print("\tFees(Gas-{}): max - {} actual - {}".format(gas_price, demo_tx.transaction.max_fee/WEI_CONVERT, tx_receipt.actual_fee/WEI_CONVERT))
    print("\tExecution Gas: {}\n".format(execution_fees))

    print("\tAccount Update: ")
    for i in range(len(account_state)):
        print("\t\tkey {} -> value {}".format(account_state[i]["key"], int(account_state[i]["value"][2:], 16)))

    print("\tContract Update: ")
    for i in range(len(contract_state)):
        print("\t\tkey {} -> value {}".format(contract_state[i]["key"], int(contract_state[i]["value"][2:], 16)))
