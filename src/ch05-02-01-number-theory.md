# Euler’s Theorem

In [number theory](https://en.wikipedia.org/wiki/Number_theory),
**Euler’s theorem** (also known as the **Fermat–Euler theorem** or
**Euler’s totient theorem**) states that, if *n* and *a* are
[coprime](https://en.wikipedia.org/wiki/Coprime_integers) positive
integers, and *φ(n)* is [Euler’s totient
function](https://en.wikipedia.org/wiki/Euler%27s_totient_function),
then *a* raised to the power *φ(n)* is congruent to 1
[modulo](https://en.wikipedia.org/wiki/Modular_arithmetic) *n*; that is

# Modular Arithmetic

A system of arithmetic for integers where numbers "wrap around" when
reaching a certain value (aka *modulus*)

![modular](modular.png)

A real-world example of modular arithmetic is time-keeping via a clock.
When the hour of the day exceeds the modulus(12) we "wrap" around and
begin at zero.

Example:

    python3 finite_fields/python/modular_arithmetic.py

In other words, of a division we sometimes are more interested in the
**remainder**. Here is where we use the operator named as **modulo
operator** or simply **mod**. For example, $13\bmod5 = 3$ because
$\frac{13}{5}=2$ remainder $3$.

Let’s go through a couple examples:

-   $-29\bmod3 = 1$

If we divide $-29$ by $3$ we get a quotient of $9$ with a remainder of
$-2$; we substract $-2$ from $3$ (our modulus) to get $1$.

-   $-9\bmod6 = 3$

Divide $-9$ by $6$ to get $-1$ as quotient with a remainder of $-3$. We
then substract $-3$ from $6$ to get $3$ as our result.

-   $7\bmod6 = 1$

Divide $7$ by $6$ to get a quotient of $1$ with a remainder of $1$, our
result.

Note that the mod operator only gives positive numbers.

Modular arithmetic is the stepping stone for Fine Field Arithmetic which
will take us to understand elliptic curve cryptography, which in turn,
gives us the signing and verification algorithms in Ethereum. Signing
and verification are key for transactions in a blockchain.

# Finite Fields

Much of today’s practical cryptography is based on finite fields: a
finite set of numbers with two operations (addition and multiplication
from which we can define subtraction and division too).

The order or size of the field is usually called $p$ and is a prime
number. This is a finite field of order $p$: $F\_p = {0, 1, 2, …, p—1
}$. A finite field of order 3 would be: $F\_3 = {0, 1, 2}$.

A finite field cannot contain sub-fields since their order is prime.
Therefore, the fine field implements the principles of modular
arithmetic over a large, irreducible prime number.

Example:

    python3 finite_fields/python/finite_field_arithmetic.py

A key property of the finite field is that if `a` and `b` are in the
set, `a + b` and `a ⋅ b` should be in the set too. This is the
**closed** property. Thus, if we have $F\_3$ then the sum $1 + 2 = 3$
violates the closed property because $3$ is not in the set $F\_3$.
Something similar happens with the multiplication.

We need to make our finite field closed under arithmetic operations as
addition, substraction, multiplication and division. Here is where
modular arithmetic comes in handy. Most operations with finite fields
will be using modular arithmetic. We represent a finite field addition
as $+\_f$ to distinguish it from a simple addition. We will do the same
for the symbols of other arithmetic operators.

Now, for our finite field $F\_3$, $1$ $+\_f$ $2$ $=$ $(1+2) \bmod 3$ $=$
$0$. Also $2$ $⋅\_f$ $2$ $=$ $(2⋅2) \bmod 3$ $=$ $1$. Now we have close
operations for our finite field.

What about substraction? It is the same. For a finite field $F\_3$, $1$
$-\_f$ $2$ $=$ $(1-2) \bmod 3$ $=$ $2$. We are basically performing
modular arithmetic where the modulo is the finite field’s order. For
multiplication the case is similar.

Addition, Multiplication, Exponentiation, and Substraction of fields are
intuitive. However, Division of fields can be a bit challenging at the
beginning. Let’s begin with easy operations:

-   For the finite field $F\_3$, $2$ $/\_f$ $2$ $=$ $(2/2) \bmod 3$ $=$
    $1$. It makes sense since $2/2=1$.

-   For the finite field $F\_3$, $6$ $/\_f$ $2$ $=$ $(0/2) \bmod 3$ $=$
    $0$. It makes sense since $0/2=0$.

-   For the finite field $F\_3$, the operation $1$ $/\_f$ $0$ $=$ $(1/0)
    \bmod 3$ can not be performed since we can not divide by 0.

-   For the finite field $F\_3$, $8$ $/\_f$ $5$ $=$ $(2/2) \bmod 3$ $=$
    $1$. It makes sense since $2/2=1$.

Until now everything seems ok. However, what happens when, for the
finite field $F\_5$, we divide $8$ $/\_f$ $4$ $=$ $(3/4) \bmod 5$? The
result is not trivial.

# Congruences

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
