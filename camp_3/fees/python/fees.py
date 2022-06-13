import json
import requests

from starkware.starknet.public.abi import get_selector_from_name

GAS_PER_BYTE = 16
WORD_WIDTH = 32
ETH_PRICE = 1_200
WEI_CONVERT = 1_000_000_000
COST_PER_WORD = GAS_PER_BYTE * WORD_WIDTH

FEEDER_URL = "https://alpha4.starknet.io/feeder_gateway"
FEE_ESTIMATE_URL = FEEDER_URL+"/estimate_fee"
TX_TRACE_URL = FEEDER_URL+"/get_transaction_trace?transactionHash="
GAS_ORACLE_URL = "https://api.etherscan.io/api?module=gastracker&action=gasoracle"

DEMO_PAYLOAD = {"contract_address": "0x22b0f298db2f1776f24cda70f431566d9ef1d0e54a52ee6d930b80ec8c55a62", "signature": []}
DEMO_PAYLOAD["entry_point_selector"] = "0x{:x}".format(get_selector_from_name("update_struct_store"))
DEMO_PAYLOAD["calldata"] = ["1818584692", "109287295968626", "491394656372"]

def _calc_inner_steps(resources):
    if len(resources) == 0:
        return 0

    out = resources[0]["execution_resources"]["n_steps"] + _calc_inner_steps(resources[0]["internal_calls"])
    return out


# Cairo step	ECDSA	                range check	        bitwise	                Pedersen
# 0.05 gas/step	25.6 gas/application	0.4 gas/application	12.8 gas/application	0.4 gas/application
def _calc_inner_builtins(resources):
    if len(resources) == 0:
        return 0

    res = 0
    res += (resources[0]["execution_resources"]["builtin_instance_counter"]["pedersen_builtin"] * .4)
    res += (resources[0]["execution_resources"]["builtin_instance_counter"]["range_check_builtin"] * .4)
    res += (resources[0]["execution_resources"]["builtin_instance_counter"]["ecdsa_builtin"] * 25.6)
    res += (resources[0]["execution_resources"]["builtin_instance_counter"]["bitwise_builtin"] * 12.8)

    out = res + _calc_inner_builtins(resources[0]["internal_calls"])
    return out

def calculate_execution(tx_hash):
    tx_trace_resp = requests.request("GET", TX_TRACE_URL+tx_hash).json()

    steps = _calc_inner_steps([tx_trace_resp["function_invocation"]])
    builtins = _calc_inner_builtins([tx_trace_resp["function_invocation"]])
    return (steps *.05), builtins


# fee_estimate_resp = requests.request("POST", FEE_ESTIMATE_URL, data=json.dumps(DEMO_PAYLOAD)).json()

# Storage Update:
# fee = gas_price * L1_calldata_cost_32B * number_of_words
# byte of calldata = either 4 gas (if = 0) or 16 gas (if > 0)
# calldata = contract_address, num_updated keys, key_to_update, new_value
# gas_oracle_resp = requests.request("GET", GAS_ORACLE_URL).json()
# gas_price = gas_oracle_resp["result"]["ProposeGasPrice"]
# total_words = 2 * 1 + (2 * len(DEMO_PAYLOAD["calldata"]))
# execution_costs = 155 # TODO: look through execution trace

# fee_estimate = int(gas_price) * COST_PER_WORD * total_words
# fetched_estimate = int(fee_estimate_resp["amount"])/WEI_CONVERT

# print("Fee Estimate Calculated: {} gwei - ${:.04f}".format(fee_estimate, (int(fee_estimate)/WEI_CONVERT)*ETH_PRICE))
# print("Fee Estimate Fetched: {:.0f} gwei - ${:.04f}".format(fetched_estimate, (fetched_estimate/WEI_CONVERT)*ETH_PRICE))
