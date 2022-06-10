import sys

sys.path.append('../../')

from random import randint
from stark101utils.python.polynomial import X, Polynomial
from stark101utils.python.field import FieldElement

# The degree of a polynomial is the highest degree of any term

print("Polynomial Math Operators:")
####################
# Poly Bit Pattern 
# representation
####################
bin=0
# Bit pattern
print("\tBit Pattern x^2 + 1:\t\t {0:b}".format(bin | 2**2 | 1))
print("\tBit Pattern x^2 + x +  1:\t {0:b}\n".format(bin | 2**2 | 2 | 1))

####################
# Poly Random
####################
# Polynomial by hand 
# poly = 19x^5 - 3x^2 + 9
p1 = 19*X**5 - 3*X**2 + 9

raw_poly=[]
# Stored least signifigant term first
# then coeficients stored in the degree
# first construct the degree plus the free term || 0 
raw_poly=[0]*(p1.degree()+1)
print("\tEmpty Poly:\t\t\t\t", raw_poly)

raw_poly[0] = FieldElement(9)
print("\tPopulate Free Term:\t\t\t", raw_poly)

raw_poly[2] = FieldElement(-3)
raw_poly[5] = FieldElement(19)
print("\tPopulate coefficients(index = degree):\t", raw_poly == p1.poly, raw_poly)
print()

####################
# Poly Addition
####################
p2 = 7*X**2 + 15

add = p1 + p2
# In the same way we would group terms in typical addition: 19x^5 + 4x^2 + 24
# Except that all elements are in a finite field and therefore wrap
print("\tPolynomial addition:\t\t\t", FieldElement(24), FieldElement(4), add.poly)


# ####################
# # Poly Subtraction
# ####################
sub = p1 - p2

# In the same way we would group terms in typical addition: 19x^5 + 10x^2 - 6
# Except that all elements are in a finite field and therefore wrap
print("\tPolynomial subtraction:\t\t\t", FieldElement(-6), FieldElement(-10), sub.poly)

# ####################
# # Poly Multiplication
# ####################
mult = p1 * p2

# In the same way we would group terms in typical addition:
# 19x^5(7x^2 + 15) - 3x^2*(7x^2 + 15) + 9*(7x^2 + 15)
# 133x^7 + 285x^5 - 21x^4 -  45x^2 + 63x^2 + 135
# 133x^7 + 285x^5 - 21x^4 + 18x^2 + 135
p3 = 133*X**7 + 285*X**5 - 21*X**4 + 18*X**2 + 135
print("\tPolynomial multiplication by hand:\t", p3.poly)
print("\tPolynomial multiplication:\t\t", mult.poly)

# ####################
# # Poly Division
# ####################
deg_a = randint(0, 4)
leading = FieldElement.random_element(exclude_elements=[FieldElement.zero()])
a_raw = [FieldElement.random_element() for i in range(deg_a)] + [leading]
a = Polynomial(a_raw)

deg_b = randint(0, 3)
leading = FieldElement.random_element(exclude_elements=[FieldElement.zero()])
b_raw = [FieldElement.random_element() for i in range(deg_b)] + [leading]
b = Polynomial(b_raw)

(q, r) = a.qdiv(b)
d = r + q * b

print("\tPolynomial division:\t\t\t {} / {}".format(a_raw, b_raw))
print("\tPolynomial division:\t\t\t Remainder degree ({}) < divisor degree: ({})".format(r.degree(), b.degree()))
print("\tQ satisfies 'f = q * g + r'\t\t {} == {}".format(d.poly, a.poly))