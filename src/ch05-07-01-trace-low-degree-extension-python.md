*Copyright 2019 Starkware Industries Ltd. Licensed under the Apache
License, Version 2.0 (the "License"). You may not use this file except
in compliance with the License. You may obtain a copy of the License at
<https://www.starkware.co/open-source-license/> Unless required by
applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for
the specific language governing permissions and limitations under the
License.*

# Part 1: Trace and Low-Degree Extension

-   [Video Lecture
    (youtube)](https://www.youtube.com/watch?v=Y0uJz9VL3Fo)

-   [Slides
    (PDF)](https://starkware.co/wp-content/uploads/2021/12/STARK101-Part1.pdf)

Today we will develop a STARK prover for the FibonacciSq sequence over a
finite field. The FibonacciSq sequence is defined by the recurrence
relation . By the end of the day, your code will produce a *STARK* proof
attesting to the following statement: **I know a field element such that
the 1023rd element of the FibonacciSq sequence starting with is** .

## The Basics

### FieldElement class

We use our `+FieldElement+` class to represent field elements. You can
construct instances of `+FieldElement+` from integers, and then add,
multiply, divide, get inverse, and so on. The underlying field of this
class is (), so all operations are done modulo 3221225473. Try it by
running the following cell (shift  
enter):

    from field import FieldElement
    FieldElement(3221225472) + FieldElement(10)

# FibonacciSq Trace

To start, let’s construct a list `+a+` of length 1023, whose first two
elements will be FieldElement objects representing 1 and 3141592,
respectively. The next 1021 elements will be the FibonacciSq sequence
induced by these two elements. `+a+` is called the trace of FibonacciSq,
or, when the context is clear, the trace. We can calculate `+a+` as
follows:

    a = [FieldElement(1), FieldElement(3141592)]
    while len(a) < 1023:
        a.append(a[-2] * a[-2] + a[-1] * a[-1])

# Test Your Code

Run the next cell to test that you have filled `+a+` correctly. Note
that this is in fact a verifier, albeit very naive and non-succinct one,
as it goes over the sequence, element by element, making sure it is
correct.

    assert len(a) == 1023, 'The trace must consist of exactly 1023 elements.'
    assert a[0] == FieldElement(1), 'The first element in the trace must be the unit element.'
    for i in range(2, 1023):
        assert a[i] == a[i - 1] * a[i - 1] + a[i - 2] * a[i - 2], f'The FibonacciSq recursion rule does not apply for index {i}'
    assert a[1022] == FieldElement(2338775057), 'Wrong last element!'
    print('Success!')

# Thinking of Polynomials

We now want to think of the sequence as the evaluation of some, yet
unknown, polynomial of degree 1022 (due to the Unisolvence Theorem). We
will choose the domain to be some subgroup of size 1024, for reasons
that will become clear later.

(Recall that denotes the multiplicative group of , which we get from by
omitting the zero element with the induced multiplication from the
field. A subgroup of size 1024 exists because is a cyclic group of size
, so it contains a subgroup of size for any ).

## Find a Group of Size 1024

If we find an element whose (multiplicative) order is 1024, then will
generate such a group. The class `+FieldElement+` provides a static
method `+generator()+` which returns an element that generates (whose
order is ).

1.  Use it to obtain a generator for .

2.  Create a list called `+G+` with all the elements of , such that :=
    g^i\].

*Hint: When divides , generates a group of size , and the n-th power of
some `+FieldElement+` can be computed by calling `+x ** n+`.*

Solution:

    g = FieldElement.generator() ** (3 * 2 ** 20)
    G = [g ** i for i in range(1024)]

Run the next cell to test your code.

    # Checks that g and G are correct.
    assert g.is_order(1024), 'The generator g is of wrong order.'
    b = FieldElement(1)
    for i in range(1023):
        assert b == G[i], 'The i-th place in G is not equal to the i-th power of g.'
        b = b * g
        assert b != FieldElement(1), f'g is of order {i + 1}'

    if b * g == FieldElement(1):
        print('Success!')
    else:
        print('g is of order > 1024')

# Polynomial class

We provide you with a class called `+Polynomial+`. The simplest way to
construct a `+Polynomial+` is by using the variable `+X+` (note that
it’s a capital `+X+`) which represents the formal variable :

    from polynomial import X
    # The polynomial 2x^2 + 1.
    p = 2*X**2 + 1
    # Evaluate p at 2:
    print(p(2))

# Interpolating a Polynomial

Our `+polynomial+` module provides a Lagrange interpolation function,
whose arguments are:

-   x\_values: x-values of G that the polynomial’s values for them is
    known. \[List\]

-   y\_values: the corresponding y-values. \[List\]

It returns the unique `+Polynomial+` of degree &lt; `+len(x_values)+`
instance that evaluates to `+y_values[i]+` on `+x_values[i]+` for all i.

Run the following cell to get help on the function `+interpolate_poly+`.

    from polynomial import interpolate_poly
    interpolate_poly?

Suppose that `+a+` contains the values of some polynomial over `+G+`
(except for `+G[-1]+`, since `+a+` is one element shorter). Use
`+interpolate_poly()+` to get `+f+` and get its value at
`+FieldElement(2)+`.

Solution:

    f = interpolate_poly(G[:-1], a)
    v = f(2)

Run test:

    assert v == FieldElement(1302089273)
    print('Success!')

# Evaluating on a Larger Domain

The trace, viewed as evaluations of a polynomial on , can now be
extended by evaluating over a larger domain, thereby creating a
Reed-Solomon error correction code.

## Cosets

To that end, we must decide on a larger domain on which will be
evaluated. We will work with a domain that is 8 times larger than . A
natural choice for such a domain is to take some group of size 8192
(which exists because 8192 divides ), and shift it by the generator of ,
thereby obtaining a [coset](https://en.wikipedia.org/wiki/Coset) of .

Create a list called `+H+` of the elements of , and multiply each of
them by the generator of to obtain a list called `+eval_domain+`. In
other words, eval\_domain = for the generator of and the generator of .

Hint: You already know how to obtain - similarly to the way we got a few
minutes ago.

Solution:

    w = FieldElement.generator()
    h = w ** ((2 ** 30 * 3) // 8192)
    H = [h ** i for i in range(8192)]
    eval_domain = [w * x for x in H]

Run test:

    from hashlib import sha256
    assert len(set(eval_domain)) == len(eval_domain)
    w = FieldElement.generator()
    w_inv = w.inverse()
    assert '55fe9505f35b6d77660537f6541d441ec1bd919d03901210384c6aa1da2682ce' == sha256(str(H[1]).encode()).hexdigest(),\
        'H list is incorrect. H[1] should be h (i.e., the generator of H).'
    for i in range(8192):
        assert ((w_inv * eval_domain[1]) ** i) * w == eval_domain[i]
    print('Success!')

# Evaluate on a Coset

Time to use `+interpolate_poly+` and `+Polynomial.poly+` to evaluate
over the coset. Note that it is implemented fairly naively in our Python
module, so interpolation may take up to a minute. Indeed - interpolating
and evaluating the trace polynomial is one of the most
computationally-intensive steps in the STARK protocol, even when using
more efficient methods (e.g. FFT).

Solution:

    f = interpolate_poly(G[:-1], a)
    f_eval = [f(d) for d in eval_domain]

Run test:

    # Test against a precomputed hash.
    from hashlib import sha256
    from channel import serialize
    assert '1d357f674c27194715d1440f6a166e30855550cb8cb8efeb72827f6a1bf9b5bb' == sha256(serialize(f_eval).encode()).hexdigest()
    print('Success!')

# Commitments

We will use [Sha256](https://en.wikipedia.org/wiki/SHA-2)-based [Merkle
Trees](https://en.wikipedia.org/wiki/Merkle_tree) as our commitment
scheme. A simple implementation of it is available to you in the
`+MerkleTree+` class. Run the next cell (for the sake of this tutorial,
this also serves as a test for correctness of the entire computation so
far):

    from merkle import MerkleTree
    f_merkle = MerkleTree(f_eval)
    assert f_merkle.root == '6c266a104eeaceae93c14ad799ce595ec8c2764359d7ad1b4b7c57a4da52be04'
    print('Success!')

# Channel

Theoretically, a STARK proof system is a protocol for interaction
between two parties - a prover and a verifier. In practice, we convert
this interactive protocol into a non-interactive proof using the
[Fiat-Shamir
Heuristic](https://en.wikipedia.org/wiki/Fiat%E2%80%93Shamir_heuristic).
In this tutorial you will use the `+Channel+` class, which implements
this transformation. This channel replaces the verifier in the sense
that the prover (which you are writing) will send data, and receive
random numbers or random `+FieldElement+` instances.

This simple piece of code instantiates a channel object, sends the root
of your Merkle Tree to it. Later, the channel object can be called to
provide random numbers or random field elements.

    from channel import Channel
    channel = Channel()
    channel.send(f_merkle.root)

Lastly - you can retrieve the proof-so-far (i.e., everything that was
passed in the channel up until a certain point) by printing the member
`+Channel.proof+`.

    print(channel.proof)
