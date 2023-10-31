# Solidity Verifier

Before diving into this chapter, refer to the Starknet Architecture chapter to understand the foundational architecture flow. We assume that you have a basic understanding of the following concepts: Sequencers, Provers, SHARP, and Sharp Jobs.

In the world of rollups, verifiers are key to ensuring trust and transparency. This is the role of Starknet's Solidity Verifier, checking the truth of transactions and smart contracts.

## SHARP and Sharp Jobs Review

NOTE: For a more detailed explanation of SHARP and Sharp Jobs, refer to the Provers subchapter in the Starknet Architecture chapter. This is a brief review.

SHARP, or Shared Prover, in Starknet, aggregates various Cairo programs from distinct users. These programs, each with unique logic, run together, producing a common proof for all, optimizing cost and efficiency.

![](https://hackmd.io/_uploads/HJ7UiFLfa.png)

Furthermore, SHARP supports combining multiple proofs into one, enhancing its efficiency by allowing parallel proof processing and verification.

SHARP verifies numerous Starknet transactions, like transfers, trades, and state updates. It also confirms smart contract executions.

To illustrate SHARP: Think of commuting by bus. The bus driver, the prover, transports passengers, the Cairo programs. The driver checks only the tickets of passengers alighting at the upcoming stop, much like SHARP. The prover forms a single proof for all Cairo programs in a batch, but verifies only the proofs of programs executing in the succeeding block.

**Sharp Jobs**. Known as Shared Prover Jobs, Sharp Jobs let multiple users present their Cairo programs for combined execution, distributing the proof generation cost. This shared approach makes Starknet more economical for users, enabling them to join ongoing jobs and leverage economies of scale.

## Solidity Verifiers

A Solidity verifier is an L1 smart contract, crafted in Solidity, designed to validate STARK proofs from SHARP (Shared Prover).

### Previous Architecture: Monolothic Verifier

Historically, the Solidity Verifier was a monolithic contract, both initiated and executed by the same contract. For illustration, the operator would invoke the `update state` function on the main contract, providing the state to be modified and confirming its validity. Subsequently, the main contract would present the proof to both the verifier and the validium committee. Once they validated the proof, the state would be updated in the main contract.

![](https://hackmd.io/_uploads/BJNEAKIzT.png)

However, this architecture faced several constraints:

- Batching transactions frequently surpassed the original geth32kb transaction size limit (later adjusted to 128kb) due to accumulating excessive transactions.
- The gas required often outstripped the block size (e.g., 8 Mgas), as the block couldn't accommodate a complete batch of proof.
- A prospective constraint was that the verifier wouldn't support proof bundling, which is fundamental for SHARP.

### Current Architecture: Multiple Smart Contracts

The current verifier utilizes multiple smart contracts rather than being a singular, monolithic structure.

Here are some key smart contracts associated with the verifier:

- [`GpsStatementVerifier`](https://etherscan.io/address/0x47312450b3ac8b5b8e247a6bb6d523e7605bdb60): This is the primary contract of the Sharp verifier. It verifies a proof and then registers the related facts using `verifyProofAndRegister`. It acts as an umbrella for various layouts, each named `CpuFrilessVerifier`. Every layout has a unique combination of built-in resources.

![](https://hackmd.io/_uploads/SyqKDqLzT.png)

The system routes each proof to its relevant layout.

- [`MemoryPageFactRegistry`](https://etherscan.io/address/0xfd14567eaf9ba941cb8c8a94eec14831ca7fd1b4): This registry maintains facts for memory pages, primarily used to register outputs for data availability in rollup mode. The Fact Registry is a separate smart contract ensuring the verification and validity of attestations or facts. The verifier function is separated from the main contract to ensure each segment works optimally within its limits. The main proof segment relies on other parts, but these parts operate independently.

- [`MerkleStatementContract`](https://etherscan.io/address/0x5899efea757e0dbd6d114b3375c23d7540f65fa4): This contract verifies merkle paths.

- [`FriStatementContract`](https://etherscan.io/address/0x3e6118da317f7a433031f03bb71ab870d87dd2dd): It focuses on verifying the FRI layers.

### Sharp Verifier Contract Map

![](https://hackmd.io/_uploads/r1Re_qUG6.png)
![](https://hackmd.io/_uploads/HkkOOc8M6.png)

### Constructor Parameters of Key Contracts

The `CpuFrilessVerifiers` and `GpsStatementVerifier` are the contracts that accept constructor parameters. Here are the parameters passed to their constructors:

![](https://hackmd.io/_uploads/rJgPt5UMp.png)

### Sharp Verification Flow

![](https://hackmd.io/_uploads/ByPO5qUMa.png)

1. The Sharp dispatcher transmits all essential transactions for verification, including:
   a. `MemoryPages` (usually many).
   b. `MerkleStatements` (typically between 3 and 5).
   c. `FriStatements` (generally ranging from 5 to 15).

2. The Sharp dispatcher then forwards the proof using `verifyProofAndRegister`.

3. Applications, such as the Starknet monitor, validate the status. Once verification completes, they send an `updateState` transaction.

## Conclusion

Starknet transformed the Solidity Verifier from a single unit to a flexible, multi-contract system, highlighting its focus on scalability and efficiency. Using SHARP and refining verification steps, Starknet makes sure the Solidity Verifier stays a strong cornerstone in its setup.
