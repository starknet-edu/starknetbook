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

SHARP also supports recursive proofs, which means that multiple proofs can be combined into a single proof. This further increases the efficiency of SHARP, as it allows for parallel processing and verification of proofs.

SHARP is used to verify a wide range of transactions on StarkNet, including transfers, trades, and state updates. It is also used to verify the execution of smart contracts.

Here is an analogy to understand SHARP:

Imagine taking a bus to work. The bus driver is the prover, and the passengers are the Cairo programs. The bus driver takes all of the passengers to their destinations, but he only needs to check the tickets of the passengers who are getting off at the next stop. This is similar to how SHARP works. The prover generates a single proof for all of the Cairo programs in the batch, but only the proofs of the programs that are being executed on the next block are verified.

