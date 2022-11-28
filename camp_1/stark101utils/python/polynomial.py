###############################################################################
# Copyright 2019 StarkWare Industries Ltd.                                    #
#                                                                             #
# Licensed under the Apache License, Version 2.0 (the "License").             #
# You may not use this file except in compliance with the License.            #
# You may obtain a copy of the License at                                     #
#                                                                             #
# https://www.starkware.co/open-source-license/                               #
#                                                                             #
# Unless required by applicable law or agreed to in writing,                  #
# software distributed under the License is distributed on an "AS IS" BASIS,  #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
# See the License for the specific language governing permissions             #
# and limitations under the License.                                          #
###############################################################################


"""
A polynomial interface with the functionality required for STARK101.
"""

import operator
from functools import reduce

try:
    from tqdm import tqdm
except ModuleNotFoundError:
    # tqdm is a wrapper for iterators implementing a progress bar. If it's
    # not available, simply return the iterator itself.
    tqdm = lambda x: x

from stark101utils.python.field import FieldElement
from stark101utils.python.list_utils import (remove_trailing_elements,
                                             scalar_operation,
                                             two_lists_tuple_operation)


def trim_trailing_zeros(p):
    """
    Removes zeros from the end of a list.
    """
    return remove_trailing_elements(p, FieldElement.zero())


def prod(values):
    """
    Computes a product.
    """
    len_values = len(values)
    if len_values == 0:
        return 1
    if len_values == 1:
        return values[0]
    return prod(values[: len_values // 2]) * prod(values[len_values // 2 :])


def latex_monomial(exponent, coef, var):
    """
    Returns a string representation of a monomial as LaTeX.
    """
    if exponent == 0:
        return str(coef)
    if coef == 1:
        coef = ""
    if coef == -1:
        coef = "-"
    if exponent == 1:
        return f"{coef}{var}"
    return f"{coef}{var}^{{{exponent}}}"


class Polynomial:
    """
    Represents a polynomial over FieldElement.
    """

    @classmethod
    def X(cls):
        """
        Returns the polynomial x.
        """
        return cls([FieldElement.zero(), FieldElement.one()])

    def __init__(self, coefficients, var="x"):
        # Internally storing the coefficients in self.poly, least-significant (i.e. free term)
        # first, so $9 - 3x^2 + 19x^5$ is represented internally by the list  [9, 0, -3, 0, 0, 19].
        # Note that coefficients is copied, so the caller may freely modify the given argument.
        self.poly = remove_trailing_elements(coefficients, FieldElement.zero())
        self.var = var

    def _repr_latex_(self):
        """
        Returns a LaTeX representation of the Polynomial, for Jupyter.
        """
        if not self.poly:
            return "$0$"
        res = ["$"]
        first = True
        for exponent, coef in enumerate(self.poly):
            if coef == 0:
                continue
            monomial = latex_monomial(exponent, coef, self.var)
            if first:
                first = False
                res.append(monomial)
                continue
            oper = "+"
            if monomial[0] == "-":
                oper = "-"
                monomial = monomial[1:]
            res.append(oper)
            res.append(monomial)
        res.append("$")
        return " ".join(res)

    def __eq__(self, other):
        try:
            other = Polynomial.typecast(other)
        except AssertionError:
            return False
        return self.poly == other.poly

    @staticmethod
    def typecast(other):
        """
        Constructs a Polynomial from `FieldElement` or `int`.
        """
        if isinstance(other, int):
            other = FieldElement(other)
        if isinstance(other, FieldElement):
            other = Polynomial([other])
        assert isinstance(
            other, Polynomial
        ), f"Type mismatch: Polynomial and {type(other)}."
        return other

    def __add__(self, other):
        other = Polynomial.typecast(other)
        return Polynomial(
            two_lists_tuple_operation(
                self.poly, other.poly, operator.add, FieldElement.zero()
            )
        )

    __radd__ = __add__  # To support <int> + <Polynomial> (as in `1 + x + x**2`).

    def __sub__(self, other):
        other = Polynomial.typecast(other)
        return Polynomial(
            two_lists_tuple_operation(
                self.poly, other.poly, operator.sub, FieldElement.zero()
            )
        )

    def __rsub__(
        self, other
    ):  # To support <int> - <Polynomial> (as in `1 - x + x**2`).
        return -(self - other)

    def __neg__(self):
        return Polynomial([]) - self

    def __mul__(self, other):
        other = Polynomial.typecast(other)
        pol1, pol2 = [[x.val for x in p.poly] for p in (self, other)]
        res = [0] * (self.degree() + other.degree() + 1)
        for i, c1 in enumerate(pol1):
            for j, c2 in enumerate(pol2):
                res[i + j] += c1 * c2
        res = [FieldElement(x) for x in res]
        return Polynomial(res)

    __rmul__ = __mul__  # To support <int> * <Polynomial>.

    def compose(self, other):
        """
        Composes this polynomial with `other`.
        Example:
        >>> f = X**2 + X
        >>> g = X + 1
        >>> f.compose(g) == (2 + 3*X + X**2)
        True
        """
        other = Polynomial.typecast(other)
        res = Polynomial([])
        for coef in self.poly[::-1]:
            res = (res * other) + Polynomial([coef])
        return res

    def qdiv(self, other):
        """
        Returns q, r the quotient and remainder polynomials respectively, such that
        f = q * g + r, where deg(r) < deg(g).
        * Assert that g is not the zero polynomial.
        """
        other = Polynomial.typecast(other)
        pol2 = trim_trailing_zeros(other.poly)
        assert pol2, "Dividing by zero polynomial."
        pol1 = trim_trailing_zeros(self.poly)
        if not pol1:
            return [], []
        rem = pol1
        deg_dif = len(rem) - len(pol2)
        quotient = [FieldElement.zero()] * (deg_dif + 1)
        g_msc_inv = pol2[-1].inverse()
        while deg_dif >= 0:
            tmp = rem[-1] * g_msc_inv
            quotient[deg_dif] = quotient[deg_dif] + tmp
            last_non_zero = deg_dif - 1
            for i, coef in enumerate(pol2, deg_dif):
                rem[i] = rem[i] - (tmp * coef)
                if rem[i] != FieldElement.zero():
                    last_non_zero = i
            # Eliminate trailing zeroes (i.e. make r end with its last non-zero coefficient).
            rem = rem[: last_non_zero + 1]
            deg_dif = len(rem) - len(pol2)
        return Polynomial(trim_trailing_zeros(quotient)), Polynomial(rem)

    def __truediv__(self, other):
        div, mod = self.qdiv(other)
        assert mod == 0, "Polynomials are not divisible."
        return div

    def __mod__(self, other):
        return self.qdiv(other)[1]

    @staticmethod
    def monomial(degree, coefficient):
        """
        Constructs the monomial coefficient * x**degree.
        """
        return Polynomial([FieldElement.zero()] * degree + [coefficient])

    @staticmethod
    def gen_linear_term(point):
        """
        Generates the polynomial (x-p) for a given point p.
        """
        return Polynomial([FieldElement.zero() - point, FieldElement.one()])

    def degree(self):
        """
        The polynomials are represented by a list so the degree is the length of the list minus the
        number of trailing zeros (if they exist) minus 1.
        This implies that the degree of the zero polynomial will be -1.
        """
        return len(trim_trailing_zeros(self.poly)) - 1

    def get_nth_degree_coefficient(self, n):
        """
        Returns the coefficient of x**n
        """
        if n > self.degree():
            return FieldElement.zero()
        else:
            return self.poly[n]

    def scalar_mul(self, scalar):
        """
        Multiplies polynomial by a scalar
        """
        return Polynomial(scalar_operation(self.poly, operator.mul, scalar))

    def eval(self, point):
        """
        Evaluates the polynomial at the given point using Horner evaluation.
        """
        point = FieldElement.typecast(point).val
        # Doing this with ints (as opposed to `FieldElement`s) speeds up eval significantly.
        val = 0
        for coef in self.poly[::-1]:
            val = (val * point + coef.val) % FieldElement.k_modulus
        return FieldElement(val)

    def __call__(self, other):
        """
        If `other` is an int or a FieldElement, evaluates the polynomial on `other` (in the field).
        If `other` is a polynomial, composes self with `other` as self(other(x)).
        """
        if isinstance(other, (int)):
            other = FieldElement(other)
        if isinstance(other, FieldElement):
            return self.eval(other)
        if isinstance(other, Polynomial):
            return self.compose(other)
        raise NotImplementedError()

    def __pow__(self, other):
        """
        Calculates self**other using repeated squaring.
        """
        assert other >= 0
        res = Polynomial([FieldElement(1)])
        cur = self
        while True:
            if other % 2 != 0:
                res *= cur
            other >>= 1
            if other == 0:
                break
            cur = cur * cur
        return res


# The python representation of the formal variable x.
X = Polynomial.X()


def calculate_lagrange_polynomials(x_values):
    """
    Given the x_values for evaluating some polynomials, it computes part of the lagrange polynomials
    required to interpolate a polynomial over this domain.
    """
    lagrange_polynomials = []
    monomials = [
        Polynomial.monomial(1, FieldElement.one()) - Polynomial.monomial(0, x)
        for x in x_values
    ]
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
    assert all(
        isinstance(val, FieldElement) for val in x_values
    ), "Not all x_values are FieldElement"
    lp = calculate_lagrange_polynomials(x_values)
    assert all(
        isinstance(val, FieldElement) for val in y_values
    ), "Not all y_values are FieldElement"
    return interpolate_poly_lagrange(y_values, lp)
