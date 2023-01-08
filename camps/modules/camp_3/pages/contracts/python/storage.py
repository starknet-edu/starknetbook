import os
from pathlib import Path

from starknet_py.contract import Contract
from starknet_py.net.client import Client
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.python.utils import to_bytes
from starkware.starknet.public.abi import starknet_keccak

CONTRACT_NAME = "storage"
SLOTS = 2**251

print("\nTotal Storage Slots: ", SLOTS)

#
# Raw Keys
#
single_key = starknet_keccak(b"single_store")
print("\n\tSingle Store's Key: 0x{:x}".format(single_key))

# mapping variable first hash element(pedersen(this, index))
mapping_key = starknet_keccak(b"mapping_store")
print(
    "\n\tMapping Store's 1st Hash Element: 0x{:x}".format(
        pedersen_hash(mapping_key, 100)
    )
)

# multiple value continuous storage
multi_key = starknet_keccak(b"multi_store")
print("\n\tMulti Store's Key Left: 0x{:x}".format(multi_key))
print("\tMulti Store's Key Right: 0x{:x}".format(multi_key + 1))

# struct value continuous storage
struct_key = starknet_keccak(b"struct_store")
print("\n\tStruct Store's Key Left: 0x{:x}".format(struct_key))
print("\tStruct Store's Key Center: 0x{:x}".format(struct_key + 1))
print("\tStruct Store's Key right: 0x{:x}\n".format(struct_key + 2))

#
# deploy with starknet.py
#
# os.system("starknet-compile {}.cairo --output {}_compiled.json".format("../cairo/" + CONTRACT_NAME, CONTRACT_NAME))

# client = Client(net="http://localhost:5050", chain="SN_GOERLI")

# compiled = Path("{}_compiled.json".format(CONTRACT_NAME)).read_text()
# storage = Contract.deploy_sync(
#     client, compiled_contract=compiled, constructor_args=[]
# )

# # get contract address
# storage_tx = client.get_transaction_sync(storage.hash)
# storage_contract = storage_tx.transaction.contract_address

# #
# # query storage slots
# #
# # single value storage
# single_key = starknet_keccak(b'single_store')
# single_val = int(client.get_storage_at_sync(storage_contract, single_key)[2:], 16)
# print("\n\tSingle Store's Key: 0x{:x} - {}".format(single_key, single_val))

# # multiple value continuous storage
# multi_key = starknet_keccak(b'multi_store')
# multi_left_val = int(client.get_storage_at_sync(storage_contract, multi_key)[2:], 16)
# multi_right_val = int(client.get_storage_at_sync(storage_contract, multi_key + 1)[2:], 16)
# print("\n\tMulti Store's Key Left: 0x{:x} - {}".format(multi_key, multi_left_val))
# print("\tMulti Store's Key Right: 0x{:x} - {}".format(multi_key+1, multi_right_val))

# # struct value continuous storage
# struct_key = starknet_keccak(b'struct_store')
# struct_left_val = int(client.get_storage_at_sync(storage_contract, struct_key)[2:], 16)
# struct_center_val = int(client.get_storage_at_sync(storage_contract, struct_key + 1)[2:], 16)
# struct_right_val = int(client.get_storage_at_sync(storage_contract, struct_key + 2)[2:], 16)
# print("\n\tStruct Store's Key Left: 0x{:x} - {}".format(struct_key, struct_left_val))
# print("\tStruct Store's Key Center: 0x{:x} - {}".format(struct_key + 1, struct_center_val))
# print("\tStruct Store's Key right: 0x{:x} - {}\n".format(struct_key + 2, struct_right_val))
