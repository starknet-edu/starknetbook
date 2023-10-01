# Transactions

A transaction's journey in Starknet, from its inception to finality, comprises a series of carefully orchestrated steps. Each stage plays a crucial role in ensuring data is accurately transmitted, processed, and stored within the network. In this chapter, we explore the lifecycle of a Starknet transaction.

## Preparing the Groundwork: Transaction Creation

Every transaction's journey commences with its preparation. The sender queries the nonce of their account, serving as a unique identifier for each transaction, signs the transaction, and dispatches it to their Node. It's critical to understand the sender must be online during this process to access real-time data.

```
Preparing Transactions

1. Query the nonce of your account
2. Sign your transaction
3. Send your transaction to your Node
```

The Node, analogous to a post office, receives the transaction and broadcasts it on the Starknet network, primarily to the Sequencer. As the network evolves, the transaction will be broadcasted to multiple Sequencers.

It is worth mentioning that before broadcasting the transaction to the Sequencer, the gateways perform some validations, such as checking that the max fee exceeds a minimum fee and the account's balance is greater than the max fee. The transaction will be saved in the storage if the validation function passes.

## Reception and Processing: The Sequencer's Role

On receiving the transaction, the Sequencer acknowledges its receipt but hasn't processed it yet—similar to Ethereum's mempool state. 

```
Sequencer's Process

Receive the transaction
Validate the transaction
Execute the transaction
Update the state
```


It's crucial to remember the sequentiality of transaction processing in Starknet: the nonce won't update until the Sequencer processes your transaction. This aspect could become a hurdle when building backend applications, as sending multiple transactions consecutively may result in confusion or errors.

## Acceptance on Layer-2 (L2)

When the Sequencer validates and executes a transaction, it immediately updates the state without waiting for the block emission. The transaction status changes from 'received' to 'accepted on L2' at this stage.

Following the state update, the transaction is included in a block. However, the block isn't emitted immediately. The Sequencer decides the opportune moment to emit the block, either when there are enough transactions to form a block or after a certain time has passed. When the block is emitted, the block becomes available for other Nodes to query.

```
Transaction Status Transition

1. Received -> Accepted on L2
```


If a transaction fails during execution, it will be included in the block with the status 'reverted'.

It's essential to remember that at this stage, no proof has been generated, and the transaction relies on L2 consensus for security against censorship. There remains a slim possibility of transaction reversal if all Sequencers collude. Therefore, these stages should be seen as different layers of transaction finality.

## Acceptance on Layer-1 (L1)

The final step in the transaction's lifecycle is its acceptance on Layer-1 (L1). A Prover receives the block containing the transaction, re-executes the block, generates a proof, and sends it to Ethereum. Specifically, the proof is sent to a smart contract on Ethereum called the Verifier smart contract, which checks the proof's validity. If valid, the transaction's status changes to 'accepted on L1', signifying the transaction's security by Ethereum consensus.

```
Transaction Status Transition

1. Accepted on L2 -> Accepted on L1
```

## [Optional] Transaction Finality in Starknet

Transaction finality refers to the point at which a transaction is considered irreversible and is no longer susceptible to being reversed or undone. It's the assurance that once a transaction is committed, it can't be altered or rolled back, hence securing the integrity of the transaction and the system as a whole.

Let's dive into the transaction finality in both Starknet and Ethereum, and how they compare.

### Ethereum Transaction Finality

Ethereum operates on a Proof of Stake (PoS) consensus mechanism. A transaction has the finality status when it is part of a block that can't change without a significant amount of ETH getting burned. The number of blocks required to ensure that a transaction won't be rolled back is called 'blocks to finality', and the time to create those blocks is called 'time to finality'.

It is considered to be an average of 6 blocks to reach the finality status; given that a new block is validated each 12 seconds, the average time to finality for a transaction is 75 seconds.

### Starknet Transaction Finality

Starknet, a Layer-2 (L2) solution on Ethereum, has a two-step transaction finality process. The first step is when the transaction gets accepted on Layer-2 (Starknet), and the second step is when the transaction gets accepted on Layer-1 (Ethereum).

- Accepted on L2: When a transaction is processed by the Sequencer and included in a block on Starknet, it reaches L2 finality. However, this finality relies on the L2 consensus and comes with a slight risk of collusion among Sequencers leading to transaction reversal.
- Accepted on L1: The absolute finality comes when the block containing the transaction gets a proof generated, the proof is validated by the Verifier contract on Ethereum, and the state is updated on Ethereum. At this point, the transaction is as secure as the Ethereum's PoW consensus can provide, meaning it becomes computationally infeasible to alter or reverse.

### Comparison

The main difference between Ethereum and Starknet's transaction finality lies in the stages of finality and their reliance on consensus mechanisms.

- Ethereum's transaction finality becomes increasingly unlikely to be reversed as more blocks are added.
- Starknet's finality process is two-fold. The initial finality (L2) is quicker but relies on L2 consensus

