# Solidity Verifier 🚧

To better understand this chapter, it's important to go over the starknet architecture chapter for a fundamental understanding and overview of the flow of the architecture. 

Let's also discuss the following concepts to have the foundational knowledge of this topic.

#### Verifiers 
Smart contracts whichs verifies and checks the validity of a proof. These smart contracts can be L1 verifiers or L2 verifiers.

#### Sequencers 
Sequencers are responsible for ordering and batching transactions on the StarkNet network. They play a vital role in ensuring the scalability and security of the network.


#### Provers 
Provers are responsible for generating proofs that verify the correctness of transactions and state transitions on the StarkNet network. These proofs are used to secure the network and ensure that all transactions are processed correctly. 

#### STARK 
StarkNet provers use a cryptographic technique called STARKs (Scalable Transparent ARguments of Knowledge) to generate proofs. STARK proofs are a type of zero-knowledge proof, which means that they can be used to prove that something is true without revealing any additional information.

#### SHARP 

SHARP stands for Shared Prover, and it is a mechanism used in StarkNet that aggregates multiple Cairo programs from different users, each containing different logic. These Cairo programs are then executed together, generating a single proof common to all the programs. This allows for significant cost savings and efficiency gains, as the cost of generating a proof is amortized across all of the programs in the batch.

![](https://hackmd.io/_uploads/HJ7UiFLfa.png)

SHARP also supports recursive proofs, which means that multiple proofs can be combined into a single proof. This further increases the efficiency of SHARP, as it allows for parallel processing and verification of proofs.

SHARP is used to verify a wide range of transactions on StarkNet, including transfers, trades, and state updates. It is also used to verify the execution of smart contracts.

Here is an analogy to understand SHARP:

Imagine taking a bus to work. The bus driver is the prover, and the passengers are the Cairo programs. The bus driver takes all of the passengers to their destinations, but he only needs to check the tickets of the passengers who are getting off at the next stop. This is similar to how SHARP works. The prover generates a single proof for all of the Cairo programs in the batch, but only the proofs of the programs that are being executed on the next block are verified.

#### Sharp Jobs
Sharp jobs, also known as shared prover jobs, are a Starknet feature that allows multiple users to submit their Cairo programs to be executed together and share the cost of proof generation. This makes Starknet more affordable for smaller users, as they can join existing jobs and benefit from economies of scale.


### Introducing Solidity Verifiers
Solidity verifiers are L1 smart contracts written in solidity that verifies STARK proofs from SHARP (Shared Prover).

#### Prehistoric Architecture

The Solidity Verifier was a verifier contract that was monolithic and triggered by the same contract.
For instance, the operator will call the update stae function on the main contract which provides to the contract the state that is to be changed and updated, and also approve that the change is valid. Then the main contract will provide the proof to the verifier and validium committee, then they attest that the proof is valid and return back to the main contract, then the state will get updated.

![](https://hackmd.io/_uploads/BJNEAKIzT.png)

The monolithic verifier suffered some limitations as follows:
* Batching transactions broke the geth32kb transaction size limit (changed to 128kb) as accumulating too much transactions reaches the size limit.
* The gas needed exceeded block size (8 Mgas...) as the block limit was not big enough to contain one batch of proof.
* Futuristic limitation was the verifier would not allow proof bundling (corner-stone for Sharp).

#### Current Verifier Architecture
 The current verifier is not monolithic but has several verifier smart contracts.
 
 To further the discussion, we would look at various externally facing smart contracts:
* GpsStatementVerifier: Main contract of Sharp verifier that verifies a proof and registers the corresponding facts using *verifyProofAndRegister*. The GpsStatementVerifier is an umbrella for multiple layouts. Each is a verifier (named CpuFrilessVerifier), with distinct layout, that is specific makeup of built-in, resources, e.t.c. 

![](https://hackmd.io/_uploads/SyqKDqLzT.png)

Each proof is routed to it's appropriate layout.
* MemoryPageFactRegistry: Fact registry for memory pages. Used for registration of outputs, needed for data availabilty (rollup mode).The Fact Registry is a smart contract that handles the verification and validity of an attestation or a fact. Splitting the verifier function from the main contract. The verifier is splitted so that all parts fits nicely within limits and the main proof part depends on all other parts but all other parts are independent.
* MerkleStatementContract: The verifier contract that verifies the merkle paths.
* FriStatementContract: The contract which verifies the FRI layers.

### Sharp Verifier Full Contract Map.
![](https://hackmd.io/_uploads/r1Re_qUG6.png)
![](https://hackmd.io/_uploads/HkkOOc8M6.png)

### Construtor Parameters For The Various Contracts.
The CpuFrilessVerifiers and GpsStatementVerifier are the contracts that takes in constructor parameters and below are the parameters passed into their constructors.
![](https://hackmd.io/_uploads/rJgPt5UMp.png)

### NEW SHARP FLOW

![](https://hackmd.io/_uploads/ByPO5qUMa.png)

1. Sharp dispatcher sends all transactions that verification depends on:
    a.    MemoryPages (lots of those).
    b.    MerkleStatements (typically 3 - 5).
    c.    FriStatements (typically 5 - 15).
2. Sharp dispatcher sends the proof (verifyProofAndRegister).
3. Sharp application - e.g. Starknet monitor proves status, and when  done - sends an updateState transaction.

