import json
import os
import sys

import requests

sys.path.append("../../signing/python")
sys.path.append("../../contracts/python")
from definitions import CAIRO_PATH, ESTIMATE_FEE_ENDPOINT, GOERLI_NODE
from execution import calculate_execution
from signing import PRIVATE, sign_transaction
from starkware.crypto.signature.signature import private_to_stark_key
from starkware.starknet.public.abi import get_selector_from_name

GAS_PER_BYTE = 16
WORD_WIDTH = 32
ETH_PRICE = 1_200
WEI_CONVERT = 1_000_000_000
GOERLI_GAS_PRICE_EST = 1788956216
COST_PER_WORD = GAS_PER_BYTE * WORD_WIDTH


def get_gas_price():
    gas_price_resp = requests.request(
        "POST",
        GOERLI_NODE,
        data=json.dumps(
            {"jsonrpc": "2.0", "method": "eth_gasPrice", "params": [], "id": 1}
        ),
    ).json()
    return int(gas_price_resp["result"], 16) / WEI_CONVERT


def calculate_fee_demo():
    #
    # Account Address - fee payer
    # Contract Address - contract to update state
    #
    account_address = 0x126DD900B82C7FC95E8851F9C64D0600992E82657388A48D3C466553D4D9246
    contract_address = 0x22B0F298DB2F1776F24CDA70F431566D9EF1D0E54A52EE6D930B80EC8C55A62

    #
    # Calldata to call '__execute__' on account contract AND update storage
    #
    calldata = [8273487, 23452352, 256262346]
    agg_calldata = [
        1,
        contract_address,
        get_selector_from_name("update_struct_store"),
        0,
        len(calldata),
        len(calldata),
        *calldata,
    ]
    (sig_r, sig_s, nonce) = sign_transaction(account_address, agg_calldata)

    #
    # Fee Estimate from 'estimate_fee' endpoint
    #
    fee_estimate_resp = requests.request(
        "POST",
        ESTIMATE_FEE_ENDPOINT,
        data=json.dumps(
            {
                "contract_address": hex(account_address),
                "entry_point_selector": hex(get_selector_from_name("__execute__")),
                "calldata": [str(i) for i in agg_calldata],
                "signature": [str(sig_r), str(sig_s)],
            }
        ),
    ).json()
    fetched_estimate = int(fee_estimate_resp["amount"]) / WEI_CONVERT

    print("\nFee Estimate Fetched:")
    print(
        "\t{:.0f} gwei - ${:.04f}".format(
            fetched_estimate, (fetched_estimate / WEI_CONVERT) * ETH_PRICE
        )
    )

    # Storage Update:
    #   - fee = gas_price * L1_calldata_cost_32B * number_of_words
    #   - byte of calldata = either 4 gas (if = 0) or 16 gas (if > 0)
    #   - calldata = contract_address, num_updated keys, key_to_update, new_value
    gas_price = get_gas_price()
    total_words = 2 * 2 + (2 * (len(calldata) + (nonce > 0)))

    storage_fee_estimate = int(gas_price) * COST_PER_WORD * total_words

    print("\nFee Estimate Calculated({:.02f} gp):".format(gas_price))
    print(
        "\t{} gwei - ${:.02f}\n".format(
            storage_fee_estimate, (int(storage_fee_estimate) / WEI_CONVERT) * ETH_PRICE
        )
    )


calculate_fee_demo()
