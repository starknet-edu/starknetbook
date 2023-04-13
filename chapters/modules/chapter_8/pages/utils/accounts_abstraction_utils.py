import os
from typing import Optional, Sequence

from starkware.cairo.common.hash_state import compute_hash_on_elements
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.crypto.signature.signature import sign
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.class_hash import compute_class_hash
from starkware.starknet.core.os.contract_address.contract_address import (
    calculate_contract_address,
)
from starkware.starknet.core.os.transaction_hash.transaction_hash import (
    TransactionHashPrefix,
    calculate_transaction_hash_common,
)
from starkware.starknet.public.abi import get_selector_from_name
from starkware.starknet.services.api.contract_class import ContractClass
from starkware.starknet.services.api.gateway.transaction import InvokeFunction
from enum import Enum

CONTRACT_ADDRESS_PREFIX = from_bytes(b"STARKNET_CONTRACT_ADDRESS")
MAX_FEE = 3000000000000000
TESTNET_ID = from_bytes(b"SN_GOERLI")
MAINNET = from_bytes(b"SN_MAIN")
TESTNET = from_bytes(b"SN_GOERLI")
TESTNET2 = from_bytes(b"SN_GOERLI2")

# Calculates the pedersen hash of a contract
def calculate_contract_hash(
    salt: int,
    class_hash: int,
    constructor_calldata: Sequence[int],
    deployer_address: int,
) -> int:

    # Hash constructor calldata
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


# Gets the class of a contract using ContractClass.loads
def get_contract_class(contract_name: str) -> ContractClass:

    with open(contract_name, "r") as fp:
        contract_class = ContractClass.loads(data=fp.read())

    return contract_class


# Gets the address of the account contract
def get_address(
    contract_path_and_name: str,
    salt: int,
    constructor_calldata: Sequence[int],
    deployer_address: int = 0,
    compiled: bool = False,
) -> int:

    # Compile the account contract: must be in cairo environment
    # `compiled_account_contract` looks similar to "build/contract_compiled.json"
    if compiled:
        compiled_account_contract: str = contract_path_and_name
    else:
        os.system(
            f"starknet-compile {contract_path_and_name}.cairo --output {contract_path_and_name}_compiled.json"
        )
        compiled_account_contract: str = f"{contract_path_and_name}_compiled.json"

    # Get contract class
    contract_class = get_contract_class(contract_name=compiled_account_contract)

    # Get contract class hash for information purposes
    class_hash = compute_class_hash(
        contract_class=contract_class, hash_func=pedersen_hash
    )

    contract_address: int = calculate_contract_address(
        salt=salt,
        contract_class=contract_class,
        constructor_calldata=constructor_calldata,
        deployer_address=deployer_address,
    )

    print(
        f"""\
Account contract address: 0x{contract_address:064x}
Class contract hash: 0x{class_hash:064x}
Salt: 0x{salt:064x}
Constructor call data: {constructor_calldata}

Move the appropriate amount of funds to the account. Then deploy the account.
"""
    )

    return contract_address


def sign_invoke_transaction(
    contract_address: int,
    function_name: str,
    calldata: Sequence[int],
    signer_address: int,
    private_key: Optional[int],
    nonce: Optional[int] = 0,
    version: Optional[int] = 1,
    chain_id: int = TESTNET_ID,
    max_fee: Optional[int] = MAX_FEE,
) -> InvokeFunction:
    """
    Given a function to invoke (contract address, selector, calldata) and the account contract's identifiers
    (signer address, possibly private key) prepares and signs an account invocation to this
    function. The transaction will connect to the Testnet automatically with the `chain_id` argument.

    Args:
        contract_address (`int`):
            Address of the contract to be called by the signer.
        selector (`int`):
            Function selector to be called by the signer.
        calldata (`int`, *Sequence*):
            Calldata of the function to be called by the signer.
        signer_address (`int`):
            Address of the account contract that will sign the transaction.
        private_key (`int`, *optional*):
            If there is a private key for signing. Account abstraction allow us not to depend on a private key.
        max_fee (`int`):
            Max fee to be paid by the signerm contract for the transaction.
        nonce (`int`, *optional*):
            Nonce.
        version (`int`):
            Version.
        chain_id (`int`):
            Chain ID.
    """

    data_offset = 0
    # How many inputs does the function's calldata asks for?
    data_len = len(calldata)
    # call_array follows the members of CallArray struct in our contract
    selector = get_selector_from_name(function_name)
    call_array = [contract_address, selector, data_offset, data_len]
    # call_array_len = 1, since we are only making a call
    call_array_len = 1
    calldata_len = len(calldata)
    # We need to provide __execute__ with the arguments:
    # call_array_len: felt, call_array: CallArray*, calldata_len: felt, calldata: felt*
    execute_calldata = [call_array_len, *call_array, calldata_len, *calldata]

    print(f"Execute calldata: {execute_calldata}\n\n")

    # Calculates the transaction hash in the Starknet network - a unique identifier of the transaction
    # This is valuable only if we need to sign the transaction
    hash_value = calculate_transaction_hash_common(
        tx_hash_prefix=TransactionHashPrefix.INVOKE,
        version=version,
        contract_address=signer_address,
        entry_point_selector=0,
        calldata=execute_calldata,
        max_fee=max_fee,
        chain_id=chain_id,
        additional_data=[nonce],
    )

    print(f"Transaction hash: {hash_value}\n")

    # If there is a private key then we sign the transaction
    if private_key is None:
        signature = []
    else:
        signature = list(sign(msg_hash=hash_value, priv_key=private_key))

    # execute_calldata contains the calldata of the __execute__ function in the account contract
    invoke_function = InvokeFunction(
        contract_address=signer_address,
        calldata=execute_calldata,
        max_fee=max_fee,
        nonce=nonce,
        signature=signature,
        version=version,
    )

    return invoke_function


sign_invoke_transaction(
    contract_address=0x07D960D57C020BE3BDDBA01FCE139800590BAF8E58B8ABDB7B45BDF518B0A16E,
    function_name="admin",
    calldata=[],
    signer_address=0x2B0FC135CAE406BBC27766C189972DD3AAE5FC79A66D5191A8D6AC76A0CE8F9,
    private_key=0x7398FB40A1C5B537D97D1E8ED9439B3A3807F02814DDF501C7521AB84E5B4A7,
)
