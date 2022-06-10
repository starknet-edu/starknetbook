import sys

sys.path.append('../../')

from stark101utils.python.channel import Channel
from stark101utils.python.merkle import MerkleTree
from stark101utils.python.field import FieldElement
from low_degree_extension import generate_interpolate_extend
from stark101utils.python.polynomial import X, prod

def polynomial_constraints():
    ####################
    # Reduction 1:
    # Trace Polynomial
    ####################
    a, f, g, f_eval, eval_domain, root = generate_interpolate_extend()
    print("Reduction 1: Trace Polynomial")
    print("\tConstraint 1: ", a[0], f(g**0))
    print("\tConstraint 2: ", a[len(a)-1], f(g**1022))
    print("\tConstraint 2: ", a[7], (f(g**6)**2 + f(g**5)**2))
    print()

    ####################
    # Reduction 2:
    # Root Polynomial
    ####################
    print("Reduction 2: Root Polynomial")
    print("\tConstraint 1: ", f(g**0) - 1)
    print("\tConstraint 2: ", f(g**1022) - FieldElement(2338775057))
    # to shift an element we multiply by the generator
    x = g**5
    print("\tConstraint 2: ", f((g**2)*x) - f(g*x)**2 - f(x)**2)
    print()

    ####################
    # Reduction 3:
    # Rational Functions
    # (that are polys)
    ####################
    def get_CP(channel):
        alpha0 = channel.receive_random_field_element()
        alpha1 = channel.receive_random_field_element()
        alpha2 = channel.receive_random_field_element()
        return alpha0*p0 + alpha1*p1 + alpha2*p2
        
    def CP_eval(channel):
        CP = get_CP(channel)
        return [CP(d) for d in eval_domain]

    print("Reduction 3: Rational Functions")

    numer0 = f - 1
    denom0 = X - g**0
    p0 = numer0 / denom0
    print("\tConstraint 1: ", p0(2718), FieldElement(2509888982))


    numer1 = f - 2338775057
    denom1 = X - g**1022
    p1 = numer1 / denom1
    print("\tConstraint 2: ", p1(5772), f_eval[5772])

    lst = [(X - g**i) for i in range(1024)]
    prod(lst)
    numer2 = f(g**2 * X) - f(g * X)**2 - f**2
    denom2 = (X**1024 - 1) / ((X - g**1021) * (X - g**1022) * (X - g**1023))

    p2 = numer2 / denom2
    print("\tConstraint 3: ", p2(31415), FieldElement(2090051528))

    ####################
    # Create/Commit
    # The Composition
    # Polynomial
    ####################
    channel = Channel()
    CP_merkle = MerkleTree(CP_eval(channel))
    channel.send(CP_merkle.root)
    assert CP_merkle.root == 'a8c87ef9764af3fa005a1a2cf3ec8db50e754ccb655be7597ead15ed4a9110f1', 'Merkle tree root is wrong.'

    return get_CP(channel), CP_eval(channel), CP_merkle.root, eval_domain