"""
An implementation of field elements
"""

import unittest


class FieldElement:
    """
    Represents an element of F_(order).
    """

    def __init__(self, value, order=3 * 2**30 + 1):
        # Make modulus operation
        self.order = order
        self.value = value % self.order

    def __repr__(self):
        # Choose representation when printing the FieldElement
        return f"FieldElement_{self.order}({self.value})"

    def __eq__(self, other):
        # Defining the operation that takes place when the operator == is used.
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        return self.value == other.value

    def __ne__(self, other):
        # Defining the operation that takes place when the operator != is used.
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        return self.value != other.value

    def __add__(self, other):
        # Defining the operation that takes place when the operator + is used.
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        # Return a FieldElement
        return self.__class__(
            value=(self.value + other.value) % self.order, order=self.order
        )

    def __sub__(self, other):
        # Defining the operation that takes place when the operator - is used.
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        # Return a FieldElement
        return self.__class__(
            value=(self.value - other.value) % self.order, order=self.order
        )

    def __mul__(self, other):
        # Defining the operation that takes place when the operator * is used.
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        # Return a FieldElement
        return self.__class__(
            value=(self.value * other.value) % self.order, order=self.order
        )

    def __pow__(self, exponent):
        # assert n >= 0
        # cur_pow = self
        # res = self.__class__(value=1, order=self.order)
        # while n > 0:
        #     if n % 2 != 0:
        #         res *= cur_pow
        #     n = n // 2
        #     cur_pow *= cur_pow
        # return res
        n = exponent % (self.order - 1)  # <1>
        num = pow(self.value, n, self.order)
        return self.__class__(num, self.order)

    def __truediv__(self, other):
        if isinstance(other, int):
            other = self.__class__(value=other, order=self.order)
        elif isinstance(other, FieldElement) and other.order != self.order:
            error = f"FieldElement {other} is not of order {self.order}. We can not operate on FieldElements of different order."
            raise ValueError(error)

        if other.value == 0:
            error = "You can't get the inverse of 0. If you're doing division, you can't divide a field by 0"
            raise ValueError(error)
        # Fermat's theorem:
        # self.num**(p-1) % p == 1
        # this means:
        # 1/n == pow(n, p-2, p)
        # we return an element of the same class
        num = self.value * pow(other.value, self.order - 2, self.order) % self.order
        return self.__class__(value=num, order=self.order) 


# Tests for the Field operations 
class FieldElementTest(unittest.TestCase):
    def test_equality(self):
        a = FieldElement(2, 31)
        b = FieldElement(2, 31)
        c = FieldElement(15, 31)
        self.assertEqual(a, b)
        self.assertTrue(a != c)
        self.assertFalse(a != b)

    def test_addition(self):
        a = FieldElement(2, 3)
        res = a + 2
        self.assertEqual(res, FieldElement(1, 3))

        b = FieldElement(-2, 3)
        res = a + b
        self.assertEqual(res, FieldElement(0, 3))

        with self.assertRaises(ValueError):
            c = FieldElement(-2, 10)
            a + c

    def test_substraction(self):
        a = FieldElement(2, 3)
        res = a - 4
        self.assertEqual(res, FieldElement(1, 3))

        b = FieldElement(-5, 3)
        self.assertEqual(b, FieldElement(1, 3))
        res = a - b
        self.assertEqual(res, FieldElement(1, 3))

        with self.assertRaises(ValueError):
            c = FieldElement(-2, 10)
            a - c

    def test_multiplication(self):
        a = FieldElement(2, 3)
        res = a * 2
        self.assertEqual(res, FieldElement(1, 3))

        a = FieldElement(6, 3)
        res = a * 2
        self.assertEqual(res, FieldElement(0, 3))

        b = FieldElement(-5, 3)
        res = a * b
        self.assertEqual(res, FieldElement(6, 3))

        with self.assertRaises(ValueError):
            c = FieldElement(-2, 10)
            a * c

    def test_division(self):
        a = FieldElement(2, 3)
        res = a / 2
        self.assertEqual(res, FieldElement(1, 3))

        a = FieldElement(6, 3)
        res = a / 2
        self.assertEqual(res, FieldElement(0, 3))

        a = FieldElement(1, 3)
        with self.assertRaises(ValueError):
            res = a / 0        

        a = FieldElement(8, 3)
        res = a / 5
        self.assertEqual(res, FieldElement(1, 3))


        a = FieldElement(8, 5)
        res = a / 4
        self.assertEqual(res, FieldElement(2, 5))

        a = FieldElement(3, 31)
        b = FieldElement(24, 31)
        self.assertEqual(a / b, FieldElement(4, 31))
        
        a = FieldElement(17, 31)
        self.assertEqual(a**-3, FieldElement(29, 31))
        
        a = FieldElement(4, 31)
        b = FieldElement(11, 31)
        self.assertEqual(a**-4 * b, FieldElement(13, 31))

        with self.assertRaises(ValueError):
            c = FieldElement(-2, 10)
            a * c

if __name__ == "__main__":
    unittest.main()