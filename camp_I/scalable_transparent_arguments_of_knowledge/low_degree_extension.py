from stark101.field import FieldElement
from stark101.polynomial import X, Polynomial, prod
from stark101.merkle import MerkleTree
from stark101.channel import Channel
try:
    from tqdm import tqdm
except ModuleNotFoundError:
    # tqdm is a wrapper for iterators implementing a progress bar. If it's
    # not available, simply return the iterator itself.
    tqdm = lambda x: x

####################
# Generate Input
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
p = 2*X**2 + 1 # The polynomial 2x^2 + 1

def calculate_lagrange_polynomials(x_values):
    """
    Given the x_values for evaluating some polynomials, it computes part of the lagrange polynomials
    required to interpolate a polynomial over this domain.
    """
    lagrange_polynomials = []
    monomials = [Polynomial.monomial(1, FieldElement.one()) -
                 Polynomial.monomial(0, x) for x in x_values]
    numerator = prod(monomials)
    for j in tqdm(range(len(x_values))):
        # In the denominator, we have:
        # (x_j-x_0)(x_j-x_1)...(x_j-x_{j-1})(x_j-x_{j+1})...(x_j-x_{len(X)-1})
        denominator = prod([x_values[j] - x for i, x in enumerate(x_values) if i != j])
        # Numerator is a bit more complicated, since we need to compute a poly multiplication here.
        # Similarly to the denominator, we have:
        # (x-x_0)(x-x_1)...(x-x_{j-1})(x-x_{j+1})...(x-x_{len(X)-1})
        cur_poly, _ = numerator.qdiv(monomials[j].scalar_mul(denominator))
        lagrange_polynomials.append(cur_poly)
    return lagrange_polynomials


def interpolate_poly_lagrange(y_values, lagrange_polynomials):
    """
    :param y_values: y coordinates of the points.
    :param lagrange_polynomials: the polynomials obtained from calculate_lagrange_polynomials.
    :return: the interpolated poly/
    """
    poly = Polynomial([])
    for j, y_value in enumerate(y_values):
        poly += lagrange_polynomials[j].scalar_mul(y_value)
    return poly


def interpolate_poly(x_values, y_values):
    """
    Returns a polynomial of degree < len(x_values) that evaluates to y_values[i] on x_values[i] for
    all i.
    """
    assert len(x_values) == len(y_values)
    assert all(isinstance(val, FieldElement) for val in x_values),\
        'Not all x_values are FieldElement'
    lp = calculate_lagrange_polynomials(x_values)
    assert all(isinstance(val, FieldElement) for val in y_values),\
        'Not all y_values are FieldElement'
    return interpolate_poly_lagrange(y_values, lp)

f = interpolate_poly(G[:-1], a)

####################
# Extend the
# Evaluation Domain
####################
w = FieldElement.generator()
h = w ** ((2 ** 30 * 3) // 8192) # 1024 * 8
H = [h ** i for i in range(8192)]
eval_domain = [w * x for x in H]

f = interpolate_poly(G[:-1], a)
f_eval = [f(d) for d in eval_domain]

# ####################
# # Commit
# ####################
# f_merkle = MerkleTree(f_eval)

# channel = Channel()
# channel.send(f_merkle.root)

####################
# Contraints
####################
print("Constraint 1: ", a[0], f(g**0))
print("Constraint 2: ", a[len(a)-1], f(g**1022))
print("Constraint 2: ", a[7], (f(g**6)**2 + f(g**5)**2))

print("Root Constraint 1: ", f(g**0) - 1)
print("Root Constraint 2: ", f(g**1022) - FieldElement(2338775057))
# to shift a row we multiply by the generator
x = g**5
print("Root Constraint 2: ", f((g**2)*x) - f(g*x)**2 - f(x)**2)

