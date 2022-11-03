import sys

sys.path.append('../../contracts/python')

from account import get_nonce
from starkware.python.utils import from_bytes
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.starknet.public.abi import get_selector_from_name
from starkware.crypto.signature.signature import get_random_private_key, private_to_stark_key, sign, verify
from starkware.starknet.core.os.transaction_hash.transaction_hash import TransactionHashPrefix, calculate_transaction_hash_common

VERSION = 0
MAX_FEE = 0
TESTNET = from_bytes(b"SN_GOERLI")
PRIVATE=0x879d7dad7f9df54e1474ccf572266bba36d40e3202c799d6c477506647c126

def sign_transaction_v0(addr, calldata, nonce=None):
    if nonce is None:
        nonce = get_nonce(addr)
    calldata.append(nonce)

    exec_selector = get_selector_from_name("__execute__")
    msg_hash = calculate_transaction_hash_common(
        tx_hash_prefix=TransactionHashPrefix.INVOKE,
        version=VERSION,
        contract_address=addr,
        entry_point_selector=exec_selector,
        calldata=calldata,
        max_fee=MAX_FEE,
        chain_id=TESTNET,
        additional_data=[],
    )

    sig = sign(msg_hash, PRIVATE)
    return sig[0], sig[1], nonce

def demo_stark_signing():
    priv = get_random_private_key()
    pub = private_to_stark_key(priv)
    first_elem = 0xDEAD
    second_elem = 0xBEEF
    msg_hash = pedersen_hash(first_elem, second_elem)

    print("\nRandom Private Key({}bits): 0x{:x}".format(len(bin(priv)), priv))
    print("Random Public Key({}bits): 0x{:x}".format(len(bin(pub)), pub))
    print("Message Hash(0x{:X}, 0x{:X}): 0x{:x}({} bits)\n".format(first_elem, second_elem, msg_hash, len(bin(msg_hash))))

    signature = sign(msg_hash, priv)
    print("\n\tSignature -")
    print("\t\tr: {}".format(signature[0]))
    print("\t\ts: {}".format(signature[1]))

    print("\n\t Verify - ", verify(msg_hash, signature[0], signature[1], pub))

demo_stark_signing()