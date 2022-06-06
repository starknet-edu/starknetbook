<h1 align="center">STARKs</h1>

### TMP

SCALABLE:

- refers to the fact that two things happen simultaneously
- the prover has a running time that is at most quasilinear to the size of computation
  - SNARKs the prover is allowed to have prohibitively expensive complexity
- verification time is poly-logarithmic in the size of computation

Transparent:

- all verifiers messages are just publicly sampled random coins
- no trusted setup procedure is neeed to instantiate a proof system no toxic waste
- compilation pipeline,

Computation Pipeline:

- Computation
----> arithmetization
- Arithmetic Constraint System
----> interpolation
- Polynomial IOP
----> Cryptographic compilation
- Cryptographic Proof System

What are we "proving"?
    Computation of any of the following:
    - time
    - memory
    - randomness
    - secret information
    - parallelism
    Goal being to transform the computation into a format that enables resource-constrained verifier to verify its integrity
    Possible to study more types of resources, entabld quits, non-determinsim, oracles

Prime number p,  and use the elements from 0 -> p-1,

#### Sources

- <https://eprint.iacr.org/2018/046.pdf>
- <https://vitalik.ca/general/2017/11/09/starks_part_1.html>
- <https://github.com/starkware-libs/ethSTARK>
- <https://consensys.net/blog/blockchain-explained/zero-knowledge-proofs-starks-vs-snarks/>
- <https://aszepieniec.github.io/stark-anatomy/>
- <https://github.com/elibensasson/libSTARK>
- <https://github.com/iden3/circom>
- <https://eprint.iacr.org/2021/582.pdf>

---
upper_tags: []

lower_tags: []
