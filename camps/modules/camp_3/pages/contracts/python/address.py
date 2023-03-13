import os
from typing import Callable, Sequence

from starkware.cairo.common.hash_state import compute_hash_on_elements
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.class_hash import compute_class_hash
from starkware.starknet.services.api.contract_class import ContractClass

CONTRACT_ADDRESS_PREFIX = from_bytes(b"STARKNET_CONTRACT_ADDRESS")
CONTRACT_NAME = "counter"


def calculate_contract_address(
    salt: int,
    class_hash: int,
    constructor_calldata: Sequence[int],
    deployer_address: int,
) -> int:
    constructor_calldata_hash = compute_hash_on_elements(
        data=constructor_calldata, hash_func=pedersen_hash
    )
    return compute_hash_on_elements(
        data=[
            CONTRACT_ADDRESS_PREFIX,
            deployer_address,
            salt,
            class_hash,
            constructor_calldata_hash,
        ],
        hash_func=pedersen_hash,
    )


# must be in cairo environment
# os.system(
#     "starknet-compile {}.cairo --output {}_compiled.json".format(
#         "../cairo/" + CONTRACT_NAME, CONTRACT_NAME
#     )
# )

# -------------------------------------------------------------------------------------------------------
# Contract Classes - Starknet seperates contracts into classes(definition) and instances(implementation)
# - Class: cairo byte code, hint information, entry point names(all semantics)
# - Class Hash: similar to a 'class name' in OOP
# - Instance: deployed contract corresponding to a class
# - Declare: calles are added with a 'declare' call
# - library_call: to use the functionality of a declared class w/o deploying
# -------------------------------------------------------------------------------------------------------
contract_class = ContractClass.loads(
    data=open("../cairo/storage_compiled.json".format(CONTRACT_NAME), "r").read()
)
class_hash = compute_class_hash(contract_class=contract_class, hash_func=pedersen_hash)

# calculate contract address
address = calculate_contract_address(0, class_hash, [], 0)

print("\n\tClass Hash: 0x{:x}\n".format(class_hash))
print("\tContract Address: 0x{:x}\n".format(address))
