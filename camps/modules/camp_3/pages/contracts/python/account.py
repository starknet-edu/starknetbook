import json

import requests
from definitions import CALL_CONTRACT_ENDPOINT
from starkware.starknet.public.abi import get_selector_from_name


def get_nonce(addr):
    nonce_selector = get_selector_from_name("get_nonce")
    nonce_resp = requests.request(
        "POST",
        CALL_CONTRACT_ENDPOINT,
        data=json.dumps(
            {
                "contract_address": hex(addr),
                "entry_point_selector": hex(nonce_selector),
                "calldata": [],
                "signature": [],
            }
        ),
    ).json()
    return int(nonce_resp["result"][0][2:], 16)
