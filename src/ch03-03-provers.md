# Provers

SHARP is like public transportation for proofs on Starknet, aggregating
multiple Cairo programs to save costs and boost efficiency. It uses
recursive proofs, allowing parallelization and optimization, making it
more affordable for all users. Critical services like the gateway,
validator, and Prover work together with a stateless design for
flexibility. SHARP’s adoption by StarkEx, Starknet, and external users
(through the Cairo Playground) highlights its significance and potential
for future optimization.

This chapter will discuss SHARP, how it has evolved to incorporate
recursive proofs, and its role in reducing costs and improving
efficiency within the Starknet network.

## What is SHARP?

SHARP, which stands for "Shared Prover", is a mechanism used in Starknet
that aggregates multiple Cairo programs from different users, each
containing different logic. These Cairo programs are then executed
together, generating a single proof common to all the programs. Rather
than sending the proof directly to the Solidity Verifier in Ethereum, it
is initially sent to a STARK Verifier program written in Cairo. The
STARK Verifier generates a new proof to confirm that the initial proofs
were verified, which can be sent back into SHARP and the STARK Verifier.
This recursive proof process will be discussed in more detail later in
this chapter. Ultimately, the last proof in the series is sent to the
Solidity Verifier on Ethereum. In other words, there are many proofs
generated until we reach Ethereum and the Solidity Verifier.

The primary benefit of SHARP system lies in its ability to decrease
costs and enhance efficiency within the Starknet network. It achieves
this by aggregating multiple Cairo jobs, which are individual sets of
computations. This aggregation allows the protocol to leverage the
exponential amortization offered by STARK proofs.

Exponential amortization means that as the computational load of the
proofs increases, the cost of verifying those proofs rises at a slower
logarithmic rate than the computation increase. In other words, the
computation itself grows slower than the verification cost. As a result,
the cost of each transaction within the aggregated set is significantly
reduced, making the overall process more cost-effective and accessible
for users.

In SHARP and Cairo context, "jobs" refer to the individual Cairo
programs or tasks submitted by different users. These jobs contain
specific logic or computations that must be executed on the Starknet
network.

Additionally, SHARP allows smaller users with limited computation to
benefit from joining other jobs and share the cost of generating the
proofs. This collaborative approach is similar to using public
transportation instead of a private car, where the cost is distributed
among all participants, making it more affordable for everyone.

## Recursive Proofs in SHARP

One of the most powerful features of SHARP is its use of recursive
proofs. Rather than directly sending the generated proofs to the
Solidity Verifier, they are first sent to a STARK Verifier program
written in Cairo. This Verifier, which is also a Cairo Program, receives
the proof and creates a new Cairo job that is sent to the Prover. The
Prover then generates a new proof to confirm that the initial proofs
were verified. These new proofs can be sent back into SHARP and the
STARK Verifier, restarting the process.

This process continues recursively, with each new proof being sent to
the Cairo Verifier until a trigger is reached. At this point, the last
proof in the series is sent to the Solidity Verifier on Ethereum. This
approach allows for greater parallelization of the computation and
reduces the time and cost associated with generating and verifying
proofs.

         Generated Proofs
                 |
                 V
    STARK Verifier program (in Cairo)
                 |
                 V
            Cairo Job
                 |
                 V
                Prover
                 |
                 V
      New Proof Generated
                 |
                 V
           Repeat Process
                 |
                 V
     Trigger Reached (last proof)
                 |
                 V
        Solidity Verifier

At first glance, recursive proofs may seem more complex and
time-consuming. However, there are several benefits to this approach:

1.  **Parallelization**: Recursive proofs allow for work
    parallelization, reducing user latency and improving SHARP
    efficiency.

2.  **Cheaper on-chain costs**: Parallelization enables SHARP to create
    larger proofs, which would have previously been limited by the
    availability of large cloud machines (which are rare and limited).
    As a result, on-chain costs are reduced.

3.  **Lower cloud costs**: Since each job is shorter, the required
    memory for processing is reduced, resulting in lower cloud costs.

4.  **Optimization**: Recursive proofs enable SHARP to optimize for
    various factors, including latency, on-chain costs, and time to
    proof.

5.  **Cairo support**: Recursive proofs only require support in Cairo,
    without the need to add support in the Solidity Verifier.

Latency in Starknet encompasses the time taken for processing,
confirming, and including transactions in a block. It is affected by
factors like network congestion, transaction fees, and system
efficiency. Minimizing latency ensures faster transaction processing and
user feedback.

Time to proof, however, specifically pertains to the duration required
to generate and verify cryptographic proofs for transactions or
operations.

## SHARP Backend Architecture and Data Pipeline

SHARP back end architecture consists of several services that work
together to process Cairo jobs and generate proofs. These services
include:

1.  **Gateway**: Cairo jobs enter SHARP through the gateway.

2.  **Job Creator**: It prevents job duplication and ensures that the
    system operates consistently, regardless of multiple identical
    requests.

3.  **Validator**: This is the first important step. The validator
    service runs validation checks on each job, ensuring they meet the
    requirements and can fit within the prover machines. Invalid jobs
    are tagged as such and do not proceed to the Prover.

4.  **Scheduler**: The scheduler service creates "trains" that aggregate
    jobs and send them to the Prover. Recursive jobs are paired and sent
    to the Prover together.

5.  **Cairo Runner**: This service runs Cairo for the Prover’s needs.
    The Cairo Runner service runs Cairo programs, executing the
    necessary computations and generating the execution trace as an
    intermediate result. The Prover then uses this execution trace.

6.  **Prover**: The Prover computes the proofs for each train (that
    contains a few jobs).

7.  **Dispatcher**: The Dispatcher serves two functions in the SHARP
    system.

    1.  In the case of a recursive proof, the Dispatcher runs the Cairo
        Verifier program on the proof it has received from the Prover,
        resulting in a new Cairo job that goes back to the Validator.

    2.  In the case of a proof that needs to go on chain (e.g., to
        Ethereum), the Dispatcher creates "packages" from the proof,
        which can then be sent to the Blockchain Writer.

8.  **Blockchain Writer**: Once the packages have been created by the
    Dispatcher, they are sent to the Blockchain Writer. The Blockchain
    Writer is responsible for sending the packages to the appropriate
    blockchain (e.g., Ethereum) for verification. This is an important
    step in the SHARP system, as it ensures that the proofs are properly
    verified and that the transactions are securely recorded on the
    blockchain.

9.  **Catcher**: The Catcher monitors blockchain (e.g., Ethereum)
    transactions to ensure that they have been accepted. While the
    Catcher is relevant for internal monitoring purposes, it is
    important to note that if a transaction fails, the fact won’t be
    registered on-chain in the fact registry. As a result, the soundness
    of the system is still preserved even without the catcher.

SHARP is designed to be stateless (each Cairo job is executed in its own
context and has no dependency on other jobs), allowing for greater
flexibility in processing jobs.

## Current SHARP Users

Currently, the primary users of SHARP include:

- StarkEx

- Starknet

- External users who use the Cairo Playground

## Challenges and Optimization

Optimizing the Prover involves numerous challenges and potential
projects on which the Starkware team and the community are currently
working:

- Exploring more efficient hash functions: SHARP is constantly
  exploring more efficient hash functions for Cairo, the Prover, and
  Solidity.

- Investigating smaller fields: Investigating smaller fields for
  recursive proof steps could lead to more efficient computations.

- Adjusting various parameters: SHARP is continually adjusting various
  parameters of the STARK protocol, such as FRI parameters and block
  factors.

- Optimizing the Cairo code: SHARP is optimizing the Cairo code to
  make it faster, resulting in a faster recursive prover.

- Developing dynamic layouts: This will allow Cairo programs to scale
  resources depending on their needs.

- Improving scheduling algorithm: This is another optimization path
  that can be taken. It is not within the Prover itself.

In particular, dynamic layouts (you can learn more about layouts here
(TODO)) will allow Cairo programs to scale resources depending on their
needs. This can lead to more efficient computation and better
utilization of resources. Dynamic layouts allow SHARP to determine the
required resources for a specific job and adjust the layout accordingly
instead of relying on predefined layouts with fixed resources. This
approach can provide tailored solutions for each job, improving overall
efficiency.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).

## Conclusion

In conclusion, SHARP is a critical component of Starknet’s architecture,
providing a more efficient and cost-effective solution for processing
Cairo programs and verifying their proofs. By leveraging the power of
STARK technology and incorporating recursive proofs, SHARP plays a vital
role in improving the overall performance and scalability of the
Starknet network. The stateless nature of SHARP and the reliance on the
cryptographic soundness of the STARK proving system make it an
innovative and valuable addition to the blockchain ecosystem.
