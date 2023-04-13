import os

from web3 import Web3

# Pedersen hash of the compiled program
# - cairo-hash-program --program builtins_compiled.json
program_hash = 0x23CEFF06CCBA63F4EB8EC58999972B1BE1924E48F50F4FA32D04A350DFE211

# output of field elements from the cairo program run
program_output = [100, 200, 300]

# Keccak Hash of the two
kecOutput = Web3.solidityKeccak(["uint256[]"], [program_output])
fact = Web3.solidityKeccak(["uint256", "bytes32"], [program_hash, kecOutput])

# Etherscan: https://goerli.etherscan.io/address/0xAB43bA48c9edF4C2C4bB01237348D1D7B28ef168#readProxyContract
print("\nFact Output: {}\n".format(fact.hex()))
