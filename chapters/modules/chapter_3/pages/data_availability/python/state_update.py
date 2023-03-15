import json
import os
import sys

import requests
import web3

sys.path.append("../../fees/python")
sys.path.append("../../contracts/python")
from definitions import STATE_UPDATE_ENDPOINT
from execution import calculate_execution
from fees import COST_PER_WORD, WEI_CONVERT
from starknet_py.net.client import Client

TX = 0x38D6ED8A35638B3947FA0A6CEE902127CBEBCDABA5705010599BC6979EB2456

client = Client("testnet")

#
# fetch transaction/contract data
#
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
    #
    # fetch block data for 'gas_price'
    #
    block = client.get_block_sync(block_number=demo_tx.block_number)

    #
    # fetch state update/diffs for block
    #
    tx_receipt = client.get_transaction_receipt_sync(TX)
    state_update = requests.request(
        "GET", STATE_UPDATE_ENDPOINT + str(demo_tx.block_number)
    ).json()
    account_state = state_update["state_diff"]["storage_diffs"][account_addr]
    contract_state = state_update["state_diff"]["storage_diffs"][contract_addr]

    #
    # calculate fees
    #
    gas_price = block.gas_price / WEI_CONVERT
    total_words = 2 * 2 + (2 * (len(account_state) + len(contract_state)))
    calldata_fee = int(gas_price) * COST_PER_WORD * total_words
    execution_fees = calculate_execution("0x{:x}".format(TX))

    print("\nTransaction Info: ")
    print(
        "\tFees(Gas-{:.02f}): max - {:.02f} actual - {:.02f}".format(
            gas_price,
            demo_tx.transaction.max_fee / WEI_CONVERT,
            tx_receipt.actual_fee / WEI_CONVERT,
        )
    )
    print("\tExecution Fee: {}".format(execution_fees))
    print("\tCalldata Fee: {}\n".format(calldata_fee))

    print("\tAccount Update: ")
    for i in range(len(account_state)):
        print(
            "\t\tkey {} -> value {}".format(
                account_state[i]["key"], int(account_state[i]["value"][2:], 16)
            )
        )

    print("\n\tContract Update: ")
    for i in range(len(contract_state)):
        print(
            "\t\tkey {} -> value {}".format(
                contract_state[i]["key"], int(contract_state[i]["value"][2:], 16)
            )
        )
    print()
