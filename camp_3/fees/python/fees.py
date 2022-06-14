import json
import sys
import requests

sys.path.append('../../signing/python')
from signing import sign_transaction
from starkware.crypto.signature.signature import private_to_stark_key
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

account_address = 0x126dd900b82c7fc95e8851f9c64d0600992e82657388a48d3c466553d4d9246
contract_address = 0x22b0f298db2f1776f24cda70f431566d9ef1d0e54a52ee6d930b80ec8c55a62
selector = get_selector_from_name("update_struct_store")
execute_selector = get_selector_from_name("__execute__")
calldata = [8273487, 23452352, 256262346]
agg_calldata = [1, contract_address, selector, 0, len(calldata), len(calldata), *calldata]
(sig_r, sig_s, nonce) = sign_transaction(account_address, agg_calldata)

fee_estimate_resp = requests.request("POST", FEE_ESTIMATE_URL, data=json.dumps({
    "contract_address": hex(account_address),
    "entry_point_selector": hex(execute_selector),
    "calldata": [str(i) for i in agg_calldata],
    "signature": [str(sig_r), str(sig_s)]
})).json()

fetched_estimate = int(fee_estimate_resp["amount"])/WEI_CONVERT
print("\nFee Estimate Fetched:")
print("\t{:.0f} gwei - ${:.04f}".format(fetched_estimate, (fetched_estimate/WEI_CONVERT)*ETH_PRICE))

"""
Storage Update:
    fee = gas_price * L1_calldata_cost_32B * number_of_words
    byte of calldata = either 4 gas (if = 0) or 16 gas (if > 0)
    calldata = contract_address, num_updated keys, key_to_update, new_value
"""
gas_oracle_resp = requests.request("GET", GAS_ORACLE_URL).json()
gas_price = gas_oracle_resp["result"]["ProposeGasPrice"]
total_words = 2 * 2 + (2 * (len(calldata)+(nonce > 0)))

fee_estimate = int(gas_price) * COST_PER_WORD * total_words

print("\nFee Estimate Calculated({} gp):".format(gas_price))
print("\t{} gwei - ${:.04f}".format(fee_estimate, (int(fee_estimate)/WEI_CONVERT)*ETH_PRICE))
