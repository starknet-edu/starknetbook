import sys

# FELTS = an integer in the range 0 < x < FELT_SIZE
FELT_SIZE=2**251 + 17 * 2**192 + 1
UINT_SIZE=2**64

print("Felts:")
print("\tFELT Int Size: ", FELT_SIZE)
print("\tSystem UInt Size: ", UINT_SIZE)
print()

print("\tFELT Overflow: ", (FELT_SIZE + 1) % FELT_SIZE)
print()

print("\tFELT Negative: ", -17 % FELT_SIZE)
print()

print("\tFELT Size is even: ", FELT_SIZE % 2 == 0)
print("\tFELT Size+1 is even: ", ((FELT_SIZE+1)%FELT_SIZE) % 2 == 0)
print()
