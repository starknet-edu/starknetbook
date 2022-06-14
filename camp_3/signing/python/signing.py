from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.crypto.signature.signature import get_random_private_key, private_to_stark_key, sign, verify

FELT_SIZE=2**251 + 17 * 2**192 + 1

priv = get_random_private_key()
pub = private_to_stark_key(priv)
first_elem = 0xDEAD
second_elem = 0xBEEF
msg_hash = pedersen_hash(first_elem, second_elem)

print("\nRandom Private Key({}bits): 0x{:x}".format(len(bin(priv)), priv))
print("Random Public Key({}bits): 0x{:x}".format(len(bin(pub)), pub))
print("Message Hash(0x{:X}, 0x{:X}): 0x{:x}({}bits)\n".format(first_elem, second_elem, msg_hash, len(bin(msg_hash))))

signature = sign(msg_hash, priv)
print("\n\tSignature -")
print("\t\tr: {}".format(signature[0]))
print("\t\ts: {}".format(signature[1]))

print("\n\t Verify - ", verify(msg_hash, signature[0], signature[1], pub))
