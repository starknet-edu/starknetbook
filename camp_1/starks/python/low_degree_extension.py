import sys

sys.path.append('../../')

from random import randint
from stark101utils.python.field import FieldElement
from stark101utils.python.polynomial import interpolate_poly
from stark101utils.python.merkle import MerkleTree

def generate_interpolate_extend():
    ####################
    # Generate Input
    # Fibonacci Trace
    ####################
    a = [FieldElement(1), FieldElement(3141592)]
    while len(a) < 1023:
        a.append(a[-2] * a[-2] + a[-1] * a[-1])


    g = FieldElement.generator() ** (3 * 2 ** 20)
    G = [g ** i for i in range(1024)]

    ####################
    # Interpolate
    # A Polynomial
    ####################
    f = interpolate_poly(G[:-1], a)
    
    for _ in range(5):
        rand = randint(0, 1024)
        print("A representation: {}\t G Representation: {}\tF Representation: {}".format(a[rand], G[rand], f(g**rand)))
    print()

    ####################
    # Extend the
    # Evaluation Domain
    ####################
    w = FieldElement.generator()
    h = w ** ((2 ** 30 * 3) // 8192) # 1024 * 8
    H = [h ** i for i in range(8192)]
    eval_domain = [w * x for x in H]

    f_eval = [f(d) for d in eval_domain]


    # ####################
    # # Commit
    # ####################
    f_merkle = MerkleTree(f_eval)

    return a, f, g, f_eval, eval_domain, f_merkle.root
