# Cryptographic Hash Functions

*Hashing* is a process that uses an algorithm to take data and convert
it to a fixed length known as a hash value, which varies widely even
with small variations in the input.

Here are two examples using the `SHA-256 hash function` (one of the most
broadly used hash functions in use today):

-   If the input is `"Starknet"`, this would be the output:

`a22979efeb74ca6aa02eaf2be8899e65b43dca9788a45ea687a96d970c32d96b`

-   And if the input is `"Starknet."` then the output is:

`78874a2e5dc07ce99d6fb8d71016e7edcb4fda2e64c0642762999baa6b5a0568`

As you can see, the **difference between the two inputs is only one
point** and the two outputs differ greatly from each other.

Hash functions are designed to protect data integrity and this will be
very important in the **STARK protocol**.

With several data, in collaboration with hashing, we can build [Merkle
Trees](https://en.wikipedia.org/wiki/Merkle_tree) that will allow us to
generate commitments and decommitments in the protocol, guaranteeing
that a determined computation was performed correctly.

# Asymmetric Encryption

# Digital Signatures

# Zero-Knowledge Proofs

A party (P) executing a computation © on a dataset (D) may have
incentive to misreport the correct output (C(D)), raising the problem of
computational integrity (CI) (also known as delegation of computation,
certified computation, and verifiable computation). That is, ensuring
that P indeed reports C(D) rather than an output more favorable to P.

When the dataset D is public, any party (V) interested in verifying CI
can re-execute C on D and compare its output to that reported by P, as a
customer might inspect a restaurant bill, or as a new Ethereum node will
verify its blockchain. This solution does not scale because the time
spent by the verifier (TV) is as large as the time required to execute
the program (TC) and V must read the full dataset D. Thus, the
computational integrity solution we seek should have scalable
verification.

Additionally, when the dataset D contains confidential data, the
previous solution can no longer be implemented and the party P in charge
of D may conceal violations of computational integrity under the veil of
secrecy.

Zero knowledge (ZK) proof and argument systems are automated protocols
that guarantee computational integrity over confidential data for any
efficient computation, eliminating corruptibility (possibly of auditors)
and reducing costs. A ZK system S for a computation C is a pair of
randomized algorithms, S = (P, V); the prover P is the algorithm used to
prove computational integrity and the verifier V checks such proofs.
Ideally we want the proof to be succinct: the proof should be quicker to
verify than computing it.

The completeness and soundness of S imply that P can efficiently prove
all truisms but will fail to convince V of any falsities (with all but
negligible probability).

## Terminology

Zero Knowledge Proof Systems are proof systems in which there is secret
information known to the `prover` that is not known to the `verifier`,
and the verifier is still convinced of the computational claim.

A `non-interactive` proof system is an abstract machine that models
computation between the two parties(prover and verifier). Messages are
sent in [one direction](https://www.youtube.com/watch?v=QJO3ROT-A4E)
until the verifier is convinced of the computational claim.

A `succinct` proof system is one in which the verifier can run an order
of magnitude faster than a naive re-execution of the program

`SNARKS`: Succinct Non-Interactive Arguments of Knowledge

`STARKs`: Scalable Transparent Arguments of Knowledge

## SNARKs

SNARK means Succinct Non-interactive Argument of Knowledge. They were
pushed by a 2012 paper from [Alessandro Chiesa et.
al.](https://dl.acm.org/doi/10.1145/2090236.2090263). Alessandro is
Co-Founder and Scientific Advisor at Starkware. SNARKs use elliptic
curves to secure the randomness required for a proof. Elliptic curves
are collision resistant, which means that it is very hard to find two
separate inputs that produce the same output ([pseudotheos,
2022](https://pseudotheos.mirror.xyz/_LAi4cCFz2gaC-3WgNmri1eTvckA32L7v31A8saJvqg)).

The main limitations of SNARKs are:

1.  No post-quantum resistance.

2.  Initial trust requirements.

> [Vitalik
> (2017)](https://vitalik.ca/general/2017/11/09/starks_part_1.html) -
> "What you might not know is that ZK-SNARKs have a newer, shinier
> cousin: ZK-STARKs."

STARKs were introduced in 2018 in a [paper by Eli Ben-Sasson et.
al.](https://eprint.iacr.org/2018/046.pdf). Eli is Co-Founder of
Starkware. That is right, Starkware was founded by some of the creators
of both SNARKs and STARKs.

The main difference between SNARKs and STARKs is that a STARK uses
collision resistant hash functions instead of elliptic curves. These are
much simpler cryptographic assumptions. STARKs rely purely on hashes and
information theory; meaning that they are secure against attackers with
quantum computers ([Vitalik,
2017](https://vitalik.ca/general/2017/11/09/starks_part_1.html)).

What is the downside? Mainly that proof sizes go up from 288 bytes, in
SNARKs case, to a few hundred kilobytes. The tradeoff could be worth it
or not. Authors suggest it could be worth it because it This tradeoff is
worth STARKs allow us to have a much higher effective TPS and throughput
than a SNARK ([pseudotheos,
2022](https://pseudotheos.mirror.xyz/_LAi4cCFz2gaC-3WgNmri1eTvckA32L7v31A8saJvqg)),
and if elliptic curves break or when quantum computers come around
([Vitalik,
2017](https://vitalik.ca/general/2017/11/09/starks_part_1.html)).

"With the T standing for "transparent", ZK-STARKs resolve one of the
primary weaknesses of ZK-SNARKs, its reliance on a 'trusted setup´."
[(Vitalik
2017)](https://vitalik.ca/general/2017/11/09/starks_part_1.html).

# Commitment Schemes

# Secure Multi-Party Computation (MPC)

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
