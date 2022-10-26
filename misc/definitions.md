## Definitions

<h3 id="zero_knowledge_proof_system">Zero Knowledge Proof System</h3>
A proof system in which there is secret information known to the prover and not known to the verifier, and the verifier is still convinced of the computational claim without learning any information about the inputs or secrets.

<h3 id="interactive_proof_system">Interactive Proof System</h3>
An abstract machine that models computation as the exchange of messages between two parties: a prover and a verifier. Messages are sent BIDIRECTIONALLY between the verifier and prover until the verifier has an answer to the problem and has "convinced" itself that it is correct.

<h3 id="non_interactive_proof_system">Non-interactive Proof System</h3>
A method by which one party can prove(prover) to another party(verifier) that a given statement is true and requires no bidirectional interaction between prover and verifier.

<h3 id="polynomial">Polynomial</h3>
An expression consisting of indeterminates (also called variables) and coefficients, that involves only the operations of addition, subtraction, multiplication, and non-negative integer exponentiation of variables

<h3 id="low_degree_polynomial">Polynomial</h3>
Degree is the number of terms in the polynomial. 

<h3 id="fiat_shamir_transform">Fiat Shamir Transform</h3>
A technique for taking an interactive proof of knowledge and creating a digital signature based on it.

<h3 id="finite_field">[Finite Field](https://en.wikipedia.org/wiki/Factorization_of_polynomials_over_finite_fields#Finite_field)</h3>

A finite field or Galois field is a field with a finite order (number of elements). The order of a finite field is always a prime or a power of prime. For each prime power q = p^r, there exists exactly one finite field with q elements, up to isomorphism. This field is denoted GF(q) or Fq. If p is prime, GF(p) is the prime field of order p; it is the field of residue classes("wrap around integers") modulo p, and its p elements are denoted 0, 1, ..., p−1. Thus a = b in GF(p) means the same as a ≡ b (mod p).

<h3 id="quasilinear">Quasilinear</h3>
O(n log n)

<h3 id="poly_logarithmic">Soundness</h3>
O(log(n)^k)

<h3 id="soundness">Soundness</h3>

<h3 id="oracles">Oracles</h3>

<h3 id="turing_complete">Turing Complete</h3>
A system of data-manipulation rules that can be used to simulate any model of computation describing an abstract machine.

<h3 id="succinct">Succinct</h3>
A proof system in which the verifier can run an order of magnitude faster than a naive re-execution of the program. This typically requires short proofs.

<h3 id="air">AIR</h3>
Algebraic Intermediate Representation

<h3 id="fri">FRI</h3>
Fast Reed-Solomon IOP of Proximity

<h3 id="iop">IOP</h3>
Interactive Oracle Proof

<h3 id="aet">AET</h3>
Algebraic Execution Trace

<h3 id="interpolation">Interpolation</h3>
Finding a representation of the arithmetic constraint system in terms of polynomials during the STARK compilation pipeline.
