import json
import sys

import requests

sys.path.append("../../contracts/python")
from definitions import TRANSACTION_TRACE_ENDPOINT


def _calc_inner_steps(resources):
    if len(resources) == 0:
        return 0

    out = resources[0]["execution_resources"]["n_steps"] + _calc_inner_steps(
        resources[0]["internal_calls"]
    )
    return out


# Cairo step	ECDSA	                range check	        bitwise	                Pedersen
# 0.05 gas/step	25.6 gas/application	0.4 gas/application	12.8 gas/application	0.4 gas/application
def _calc_inner_builtins(resources):
    if len(resources) == 0:
        return 0

    res = 0
    res += (
        resources[0]["execution_resources"]["builtin_instance_counter"][
            "pedersen_builtin"
        ]
        * 0.4
    )
    res += (
        resources[0]["execution_resources"]["builtin_instance_counter"][
            "range_check_builtin"
        ]
        * 0.4
    )
    res += (
        resources[0]["execution_resources"]["builtin_instance_counter"]["ecdsa_builtin"]
        * 25.6
    )
    res += (
        resources[0]["execution_resources"]["builtin_instance_counter"][
            "bitwise_builtin"
        ]
        * 12.8
    )

    out = res + _calc_inner_builtins(resources[0]["internal_calls"])
    return out


def calculate_execution(tx_hash):
    tx_trace_resp = requests.request("GET", TRANSACTION_TRACE_ENDPOINT + tx_hash).json()

    steps = _calc_inner_steps([tx_trace_resp["function_invocation"]])
    builtins = _calc_inner_builtins([tx_trace_resp["function_invocation"]])
    return (steps * 0.05) + builtins
