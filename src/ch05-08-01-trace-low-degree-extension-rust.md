*Copyright 2019 StarkWare Industries Ltd. Licensed under the Apache
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

We use our `+FieldElement+` struct to represent field elements. You can
construct values of type `+FieldElement+` from integers, and then add,
multiply, divide, get inverse, and so on. The underlying field of this
class is (), so all operations are done modulo 3221225473.

Try it by running the following cell (shift + enter):

    :dep stark101-rs = { path = "stark101" }
    :dep sha256 = "1.1.2"

    use stark101_rs::field::*;
    println!("The result is: {:?}", FieldElement::new(3221225472) + FieldElement::new(10));

    The result is: FieldElement(9)

# FibonacciSq Trace

To start, let’s construct a vector `+a+` of length 1023, whose first two
elements will be FieldElement objects representing 1 and 3141592,
respectively. The next 1021 elements will be the FibonacciSq sequence
induced by these two elements. `+a+` is called the trace of FibonacciSq,
or, when the context is clear, the trace. Correct the code below to fill
`+a+`:

    let mut a = vec![FieldElement::new(1), FieldElement::new(3141592)];
    todo!("Put your code here");

    thread '<unnamed>' panicked at 'not yet implemented: Put your code here', src/lib.rs:160:1
    stack backtrace:
       0: _rust_begin_unwind
       1: core::panicking::panic_fmt
       2: <unknown>
       3: <unknown>
       4: evcxr::runtime::Runtime::run_loop
       5: evcxr::runtime::runtime_hook
       6: evcxr_jupyter::main
    note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.

Solution (click to the … to unhide):

    let mut a = vec![FieldElement::new(1), FieldElement::new(3141592)];
    let mut n = 2usize;
    while a.len() < 1023 {
        a.push(a[n-2] * a[n-2] + a[n-1] * a[n-1]);
        n += 1;
    }

    ()

# Test Your Code

Run the next cell to test that you have filled `+a+` correctly. Note
that this is in fact a **verifier**, albeit very naive and non-succinct
one, as it goes over the sequence, element by element, making sure it is
correct.

    assert_eq!(a.len(), 1023, "The trace must consist of exactly 1023 elements.");
    assert_eq!(a[0], FieldElement::new(1), "The first element in the trace must be the unit element.");
    for i in 2..1023 {
        assert_eq!(a[i], a[i - 1] * a[i - 1] + a[i - 2] * a[i - 2], "The FibonacciSq recursion rule does not apply for index {i}");
    }
    assert_eq!(a[1022], FieldElement::new(2338775057), "Wrong last element!");
    println!("Success!");

    Success!

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
generate such a group. The struct `+FieldElement+` provides a method
`+generator()+` which returns an element that generates (whose order is
).

1.  Use it to obtain a generator for .

2.  Create a vec called `+G+` with all the elements of , such that :=
    g^i\].

*Hint: When divides , generates a group of size , and the n-th power of
some `+FieldElement+` can be computed by calling `+x ** n+`.*

    // Change the following line so that g will generate a group of size 1024
    let g = FieldElement::generator();
    // Fill G with the elements of G such that G[i] := g ** i
    let G: Vec<FieldElement> = vec![];

Solution:

    let g = FieldElement::generator().pow(3 * 2usize.pow(20));
    let G: Vec<FieldElement> = (0..1024).into_iter().map(|i| g.pow(i)).collect();

Run the next cell to test your code.

    // Checks that g and G are correct.
    assert!(g.is_order(1024), "The generator g is of wrong order.");
    let mut b = FieldElement::one();
    for i in 0..1023 {
        assert_eq!(b, G[i], "The i-th place in G is not equal to the i-th power of g.");
        b = b * g;
        let wrong_order = i + 1;
        assert!(b != FieldElement::one(), "g is of order {wrong_order}");
    }
    if b * g == FieldElement::one() {
        println!("Success!");
    } else {
        println!("g is of order > 1024");
    }

    Success!

    ()

# Polynomial class

We provide you with a struct called `+Polynomial+`. The simplest way to
construct a `+Polynomial+` is by using the function **x()** which
represents the formal variable :

    use stark101_rs::polynomial::*;
    // The polynomial 2x^2 + 1.
    let p: Polynomial = 2*x().pow(2) + 1;
    // Evaluate p at 2:
    println!("{:?}", p(2));

    FieldElement(9)

# Interpolating a Polynomial

Our `+Polynomial+` datatype provides a Lagrange interpolation method,
whose arguments are:

-   x\_values: x-values of G that the polynomial’s values for them is
    known. &\[FieldElement\]

-   y\_values: the corresponding y-values. &\[FieldElement\]

It returns the unique `+Polynomial+` of degree &lt; `+x_values.len()+`
instance that evaluates to `+y_values[i]+` on `+x_values[i]+` for all i.

Suppose that `+a+` contains the values of some polynomial over `+G+`
(except for `+G[-1]+`, since `+a+` is one element shorter). Use
`+Polynomial::interpolate()+` to get `+f+` and get its value at
`+FieldElement::new(2)+`.

    // Fix the following so that you create a variable called v that will contain the value of f at FieldElement(2)
    // Note that Polynomial::interpolate may take up to a minute to run.
    todo!("Put your code here.");

    thread '<unnamed>' panicked at 'not yet implemented: Put your code here.', src/lib.rs:162:1
    stack backtrace:
       0: _rust_begin_unwind
       1: core::panicking::panic_fmt
       2: <unknown>
       3: <unknown>
       4: evcxr::runtime::Runtime::run_loop
       5: evcxr::runtime::runtime_hook
       6: evcxr_jupyter::main
    note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.

Solution:

    let xs: Vec<FieldElement> = G.into_iter().rev().skip(1).rev().collect();
    let f: Polynomial = Polynomial::interpolate(&xs, &a);
    let v = f(2);

Run test:

    assert_eq!(v, FieldElement::new(1302089273));
    println!("Success!");

    Success!

# Evaluating on a Larger Domain

The trace, viewed as evaluations of a polynomial on , can now be
extended by evaluating over a larger domain, thereby creating a
**Reed-Solomon error correction code**.

## Cosets

To that end, we must decide on a larger domain on which will be
evaluated. We will work with a domain that is 8 times larger than . A
natural choice for such a domain is to take some group of size 8192
(which exists because 8192 divides ), and shift it by the generator of ,
thereby obtaining a [coset](https://en.wikipedia.org/wiki/Coset) of .

Create a vec called `+H+` of the elements of , and multiply each of them
by the generator of to obtain a vec called `+eval_domain+`. In other
words, eval\_domain = for the generator of and the generator of .

Hint: You already know how to obtain - similarly to the way we got a few
minutes ago.

    // Fix the following, make sure that the element of H are powers of its generator (let's call it h) in
    // order, that is - H[0] will be the unit (i.e 1), H[1] will be h (H's generator), H[2] will be H's
    // generator squared (h^2), etc.
    let h: FieldElement = todo!();
    let H: Vec<FieldElement> = todo!();
    let eval_domain: Vec<FieldElement> = todo!();

    thread '<unnamed>' panicked at 'not yet implemented', src/lib.rs:160:23
    stack backtrace:
       0: _rust_begin_unwind
       1: core::panicking::panic_fmt
       2: core::panicking::panic
       3: <unknown>
       4: <unknown>
       5: evcxr::runtime::Runtime::run_loop
       6: evcxr::runtime::runtime_hook
       7: evcxr_jupyter::main
    note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.

Solution:

    let w = FieldElement::generator();
    let exp = (2usize.pow(30) * 3) / 8192;
    let h = w.pow(exp);
    let H: Vec<FieldElement> = (0..8192).into_iter().map(|i| h.pow(i)).collect();
    let eval_domain: Vec<FieldElement> = H.into_iter().map(|x| w * x).collect();

Run test:

    let field_generator = FieldElement::generator();
    let w_inverse = w.inverse();

    for i in 0..8192 {
        assert_eq!((w_inverse * eval_domain[1]).pow(i) * field_generator, eval_domain[i]);
    }
    println!("Success!");

    Success!

# Evaluate on a Coset

Time to use `+interpolate+` and `+eval+` to evaluate over the coset.
Note that it is implemented fairly naively in our Rust module, so
interpolation may take some seconds. Indeed - interpolating and
evaluating the trace polynomial is one of the most
computationally-intensive steps in the STARK protocol, even when using
more efficient methods (e.g. FFT).

    // Fill f_eval with the evaluations of f on eval_domain.
    let f_eval: FieldElement = todo!();

    thread '<unnamed>' panicked at 'not yet implemented', src/lib.rs:162:28
    stack backtrace:
       0: _rust_begin_unwind
       1: core::panicking::panic_fmt
       2: core::panicking::panic
       3: <unknown>
       4: <unknown>
       5: evcxr::runtime::Runtime::run_loop
       6: evcxr::runtime::runtime_hook
       7: evcxr_jupyter::main
    note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.

Solution:

    let G_values: Vec<FieldElement> = (0..1024).into_iter().map(|i| g.pow(i)).collect();;
    let x_values: Vec<FieldElement> = G_values.into_iter().rev().skip(1).rev().collect();
    let interpolated_f: Polynomial = Polynomial::interpolate(&x_values, &a);
    let interpolated_f_eval: Vec<FieldElement> = eval_domain.into_iter().map(|d| interpolated_f.clone().eval(d)).collect();

Run test:

    // Test against a precomputed hash.
    use sha256::digest;
    let hashed = digest(format!("{:?}", interpolated_f_eval));
    assert_eq!("d78b6a5f70e91dd8fa448f628528434dbfaf3caefab0a26519e1f2d8ac992f23".to_string(), hashed);
    println!("Success!");

    Success!

# Commitments

We will use [Sha256](https://en.wikipedia.org/wiki/SHA-2)-based [Merkle
Trees](https://en.wikipedia.org/wiki/Merkle_tree) as our commitment
scheme. A simple implementation of it is available to you in the
`+MerkleTree+` class. Run the next cell (for the sake of this tutorial,
this also serves as a test for correctness of the entire computation so
far):

    //from merkle import MerkleTree
    //f_merkle = MerkleTree(f_eval)
    //assert f_merkle.root == '6c266a104eeaceae93c14ad799ce595ec8c2764359d7ad1b4b7c57a4da52be04'
    //print('Success!')

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

    ///from channel import Channel
    //channel = Channel()
    //channel.send(f_merkle.root)

Lastly - you can retrieve the proof-so-far (i.e., everything that was
passed in the channel up until a certain point) by printing the member
`+Channel.proof+`.

    //print(channel.proof)
