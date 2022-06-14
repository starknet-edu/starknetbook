<div align="center">
    <h1>Camp 1: STARKS</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[STARKs](https://drive.google.com/file/d/1asONnOcSnRJwMXF-Zx1uJBdpbMrLYnmE/view?usp=sharing)|-|[STARK 101](https://starkware.co/stark-101)

</div>

### Topics

<ol>
    <li>ZK Terminology</li>
    <li>Modular Arithmetic</li>
    <li>Finite Field Arithmetic</li>
    <li>Polynomials</li>
    <li>STARKs</li>
    <li>STARKs vs SNARKs</li>
</ol>

<h2 align="center" id="zk_terminology">ZK Terminology</h2>

Zero Knowledge Proof Systems are proof systems in which there is secret information known to the `prover` that is not known to the `verifier`, and the verifier is still convinced of the computational claim.

A `non-interactive` proof system is an abstract machine that models computation between the two parties(prover and verifier). Messages are sent in [one direction](https://www.youtube.com/watch?v=QJO3ROT-A4E) until the verifier is convinced of the computational claim.

A `succinct` proof system is one in which the verifier can run an order of magnitute aster than a naive re-execution of the program

`SNARKS`: Succint Non-Interactive Arguments of Knowledge

`STARKs`: Scalable Transparent Arguments of Knowledge

<div align="center">
    <h2 id="modular_arithmetic">Modular Arithmetic</h2>
    <p>A system of arithmetic for integers where numbers "wrap around" when reaching a certain value (aka 'modulus')</p>
    <img src="../misc/modular.png">
</div>

A real-world example of modular arithmetic is time-keeping via a clock. When the hour of the day exceed the modulus(12) we "wrap" around and begin at zero.

Example:

```bash
python3 finite_fields/python/modular_arithmetic.py
```

<h2 align="center" id="finite_fields">Finite Fields</h2>

Much of today's practical cryptography is based on `finite fields`. A finite field is a field that contains a finite number of elements and defines arithmetic operations for multiplication, addition, subtraction, and divsion. These arithmetic operations are.

A finite field cannot contain sub-fields and therefore typically implements the principles of modular arithmetic over a large, irreducible prime number. The number of elements in the field is also known as its `order`.

Example:

```bash
python3 finite_fields/python/finite_field_arithmetic.py
```

<h2 align="center" id="polynomials">Polynomials</h2>

`Polynomials` have properties that are very useful in [ZK proofs](https://www.youtube.com/watch?v=iAaSQfZ-2AM). A polynomial is an expression of more than two algebraic terms. The degree of a polynomial is the highest degree of any specific term.

For an example of how Polynomials can be built and expressed in code run:

```bash
python3 finite_fields/python/polynomial.py
```

<h2 align="center" id="starks">STARKs</h2>

<h3>Arithmetization</h3>

<h4>Low Degree Extension</h4>

<h4>Polynomial Constraints</h4>

<h4>Commitment</h4>

<h3>FRI</h3>

<h4>Commitment</h4>

<h4>Queries</h4>

<h3>Proof</h3>

<hr>

#### Sources

[<https://eprint.iacr.org/2018/046.pdf>
, <https://vitalik.ca/general/2017/11/09/starks_part_1.html>
, <https://github.com/starkware-libs/ethSTARK>
, <https://consensys.net/blog/blockchain-explained/zero-knowledge-proofs-starks-vs-snarks/>
, <https://aszepieniec.github.io/stark-anatomy/>
, <https://github.com/elibensasson/libSTARK>
, <https://eprint.iacr.org/2021/582.pdf>]
