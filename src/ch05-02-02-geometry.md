# Polynomials

`Polynomials` have properties that are very useful in [ZK
proofs](https://www.youtube.com/watch?v=iAaSQfZ-2AM). A polynomial is an
expression of more than two algebraic terms. The degree of a polynomial
is the highest degree of any specific term.

For an example of how Polynomials can be built and expressed in code.
Run:

# \[,bash\]

python3 finite_fields/python/polynomial.py ---

Polynomial arithmetic deals with the addition, subtraction,
multiplication, and division of polynomials.

We can represent a bit pattern by a polynomial in, say, the variable
$x$. Each power of $x$ in the polynomial can stand for a bit position in
a bit pattern. For example, we can represent:

-

-

- the pattern $011$ by the polynomial $x + 1$.

Representing bit patterns with polynomials will allow us to create a
finite field with bit patterns.

In general, a polynomial is an expression of the form:

<figure>
<img src="poly1.png" alt="poly1" />
</figure>

for some non-negative integer $n$ and where the coefficients $a\_{0}$,
$a\_{1}$, $…$, $a\_{n}$ are drawn from some designated set $S$. $S$ is
called the coefficient set. $n$ marks de degree of the polynomial. A
$0$-degree polynomial is called a constant polynomial.

In reality, we do not have intentions of evaluating the value of a
polynomial for a certain value of $x$. We will be dealing with finding
the point at which these polynomials equal 0.

Polynomial arithmetic is quite simple. The more complex operation is the
division which is not in the scope of this tutorial for now.

<figure>
<img src="poly2.png" alt="poly2" />
</figure>

We can define several polynomials belonging to the same field. For
example, for the $F\_2$ field, which only contains $0$ and $1$ as
members, we can generate an infinite number of polynomials without
caring for their degree. That is, the members of the field only populate
the coefficients of the polynomial without caring for the exponents.

<figure>
<img src="poly6.png" alt="poly6" />
</figure>

We can follow the same logic for polynomial arithmetic operations when
the coefficients belong to finite field. We just need to remember the
modular nature of finite fields. As an example, let’s operate with
polynomials whose coefficients belong to the $F\_7$ field. You will
notice that we are simply using field arithmetic within the
coefficients.

Addition:

<figure>
<img src="poly3.png" alt="poly3" />
</figure>

Subtraction:

<figure>
<img src="poly4.png" alt="poly4" />
</figure>

Multiplication:

<figure>
<img src="poly5.png" alt="poly5" />
</figure>

Again the division case is out of the scope of this tutorial for now.

A polynomial $f(x)$ over a field $F$ is called prime or irreducible if
$f(x)$ cannot be expressed as a product of two polynomials. Both
polynomials have to be part of $F$ and of a lower degree than $f(x)$.
That is, an irreducible polynomial as a polynomial that cannot be
factorized into lower-degree polynomials.

# Points, Lines, and Curves

# Algebraic Varieties

# Divisors

# Algebraic Morphisms

# Sheaves

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
