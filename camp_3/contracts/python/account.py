import json
import requests

from starkware.starknet.public.abi import get_selector_from_name

FEEDER_URL = "https://alpha4.starknet.io/feeder_gateway/call_contract"

def get_nonce(addr):
    nonce_selector = get_selector_from_name("get_nonce")
    nonce_resp = requests.request("POST", FEEDER_URL, data=json.dumps({
        "contract_address": hex(addr),
        "entry_point_selector": hex(nonce_selector),
        "calldata": [],
        "signature": []
    })).json()
    return int(nonce_resp["result"][0][2:], 16)