import os
from typing import Callable, Sequence

from starkware.cairo.common.hash_state import compute_hash_on_elements
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.class_hash import compute_class_hash
from starkware.starknet.services.api.contract_class import ContractClass

CONTRACT_ADDRESS_PREFIX = from_bytes(b"STARKNET_CONTRACT_ADDRESS")


def get_contract_class(compiled_contract_name: str) -> ContractClass:
    main_dir_path = os.path.dirname(__file__)
    file_path = os.path.join(main_dir_path, compiled_contract_name)

    with open(file_path, "r") as fp:
        return ContractClass.loads(data=fp.read())


def calculate_contract_address(
    salt: int,
    contract_class: ContractClass,
    constructor_calldata: Sequence[int],
    deployer_address: int,
) -> int:
    class_hash = compute_class_hash(contract_class=contract_class, hash_func=pedersen_hash)
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
os.system("starknet-compile ../cairo/counter.cairo --output counter_compiled.json")

counter_class = ContractClass.loads(data=open("counter_compiled.json", "r").read())

address = calculate_contract_address(0, counter_class, [], 0)

print("Contract Address: 0x{:x}".format(address))
