# Architecture

This is an introduction to Starknet’s Layer 2 architecture,

Starknet is a coordinated system, with each component—Sequencers,
Provers, and nodes—playing a specific yet interconnected role. Although
Starknet hasn’t fully decentralized yet, it’s actively moving toward
that goal. This understanding of the roles and interactions within the
system will help you better grasp the intricacies of the Starknet
ecosystem.

## High-Level Overview

Starknet’s operation begins when a transaction is received by a gateway,
which serves as the Mempool. This stage could also be managed by the
Sequencer. The transaction is initially marked as "RECEIVED." The
Sequencer then incorporates the transaction into the network state and
tags it as "ACCEPTED_ON_L2." The final step involves the Prover, which
executes the operating system on the new block, calculates its proof,
and submits it to the Layer 1 (L1) for verification.

<img alt="Starknet Architecture" src="img/ch03-architecture.png" class="center" style="width: 50%;" />

<span class="caption">Starknet architecture</span>

In essence, Starknet’s architecture involves multiple components:

- The Sequencer is responsible for receiving transactions, ordering
  them, and producing blocks. It operates similarly to validators in
  Ethereum or Bitcoin.

- The Prover is tasked with generating proofs for the created blocks
  and transactions. It uses Cairo’s Virtual Machine to run provable
  programs, thereby creating execution traces necessary for generating
  STARK proofs.

- Layer 1 (L1), in this case Ethereum, hosts a smart contract capable
  of verifying these STARK proofs. If the proofs are valid, Starknet’s
  state root on L1 is updated.

Starknet’s state is a comprehensive snapshot maintained through Merkle
trees, much like in Ethereum. This establishes the architecture of the
validity roll-up and the roles of each component.

For a more in-depth look at each component, read on.

After exploring the introductory overview of the different components,
delve deeper into their specific roles by referring to their dedicated
subchapters in this Chapter.

## Sequencers

Sequencers are the backbone of the Starknet network, akin to Ethereum’s
validators. They usher transactions into the system.

Validity rollups excel at offloading some network chores, like bundling
and processing transactions, to specialized players. This setup is
somewhat like how Ethereum and Bitcoin delegate security to miners.
Sequencing, like mining, demands hefty resources.

For networks like Starknet and other platforms utilizing Validity
rollups, a similar parallel is drawn. These networks outsource
transaction processing to specialized entities and then verify their
work. These specialized entities in the context of Validity rollups are
known as "Sequencers."

Instead of providing security, as miners do, Sequencers provide
transaction capacity. They order (sequence) multiple transactions into a
single batch, executes them, and produce a block that will later be
proved by the Prover and submmited to the Layer 1 network as a single,
compact proof, known as a "rollup." In other words, just as validators
in Ethereum and miners in Bitcoin are specialized actors securing the
network, Sequencers in Validity rollup-based networks are specialized
actors that provide transaction capacity.

This mechanism allows Validity (or ZK) rollups to handle a higher volume
of transactions while maintaining the security of the underlying
Ethereum network. It enhances scalability without compromising on
security.

Sequencers follow a systematic method for transaction processing:

1.  Sequencing: They collect transactions from users and order
    (sequence) them.

2.  Executing: Sequencers then process these transactions.

3.  Batching: Transactions are grouped together in batches or blocks for
    efficiency.

4.  Block Production: Sequencers produce blocks that contain batches of
    processed transactions.

Sequencers must be reliable and highly available, as their role is
critical to the network’s smooth functioning. They need powerful and
well-connected machines to perform their role effectively, as they must
process transactions rapidly and continuously.

The current roadmap for Starknet includes decentralizing the Sequencer
role. This shift towards decentralization will allow more participants
to become Sequencers, contributing to the robustness of the network.

For more details in the Sequencer role, refer to the dedicated
subchapter in this Chapter.

## Provers

Provers serve as the second line of verification in the Starknet
network. Their main task is to validate the work of the Sequencers (when
they receive the block produced by the Sequencer) and to generate proofs
that these processes were correctly performed.

The duties of a Prover include:

1.  Receiving Blocks: Provers obtain blocks of processed transactions
    from Sequencers.

2.  Processing: Provers process these blocks a second time, ensuring
    that all transactions within the block have been correctly handled.

3.  Proof Generation: After processing, Provers generate a proof of
    correct transaction processing.

4.  Sending Proof to Ethereum: Finally, the proof is sent to the
    Ethereum network for validation. If the proof is correct, the
    Ethereum network accepts the block of transactions.

Provers need even more computational power than Sequencers because they
have to calculate and generate proofs, a process that is computationally
heavy. However, the work of Provers can be split into multiple parts,
allowing for parallelism and efficient proof generation. The proof
generation process is asynchronous, meaning it doesn’t have to occur
immediately or in real-time. This flexibility allows for the workload to
be distributed among multiple Provers. Each Prover can work on a
different block, allowing for parallelism and efficient proof
generation.

The design of Starknet relies on these two types of actors — Sequencers
and Provers — working in tandem to ensure efficient processing and
secure verification of transactions.

For more details in the Prover role, refer to the dedicated subchapter
in this Chapter.

## Optimizing Sequencers and Provers: Debunking Common Misconceptions

The relationship between Sequencers and Provers in blockchain technology
often sparks debate. A common misunderstanding suggests that either the
Prover or the Sequencer is the main bottleneck. To set the record
straight, let’s discuss the optimization of both components.

Starknet, utilizing the Cairo programming language, currently supports
only sequential transactions. Plans are in place to introduce parallel
transactions in the future. However, as of now, the Sequencer operates
one transaction at a time, making it the bottleneck in the system.

In contrast, Provers operate asynchronously and can execute multiple
tasks in parallel. The use of proof recursion allows for task
distribution across multiple machines, making scalability less of an
issue for Provers.

Given the asynchronous and scalable nature of Provers, focus in Starknet
has shifted to enhancing the Sequencer’s efficiency. This explains why
current development efforts are primarily aimed at the sequencing side
of the equation.

## Nodes

When it comes to defining what nodes do in Bitcoin or Ethereum, people
often misinterpret their role as keeping track of every transaction
within the network. This, however, is not entirely accurate.

Nodes serve as auditors of the network, maintaining the state of the
network, such as how much Bitcoin each participant owns or the current
state of a specific smart contract. They accomplish this by processing
transactions and preserving a record of all transactions, but that’s a
means to an end, not the end itself.

In Validity rollups and specifically within Starknet, this concept is
somewhat reversed. Nodes don’t necessarily have to process transactions
to get the state. In contrast to Ethereum or Bitcoin, Starknet nodes
aren’t required to process all transactions to maintain the state of the
network.

There are two main ways to access network state data: via an API gateway
or using the RPC protocol to communicate with a node. Operating your own
node is typically faster than using a shared architecture, like the
gateway. Over time, Starknet plans to deprecate APIs and replace them
with a JSON RPC standard, making it even more beneficial to operate your
own node.

It’s worth noting that encouraging more people to run nodes increases
the resilience of the network and prevents server flooding, which has
been an issue in networks in other L2s.

Currently, there are primarily three methods for a node to keep track of
the network’s state and we can have nodes implement any of these
methods:

1.  **Replaying Old Transactions**: Like Ethereum or Bitcoin, a node can
    take all the transactions and re-execute them. Although this
    approach is accurate, it isn’t scalable unless you have a powerful
    machine that’s capable of handling the load. If you can replay all
    transactions, you can become a Sequencer.

2.  **Relying on L2 Consensus**: Nodes can trust the Sequencer(s) to
    execute the network correctly. When the Sequencer updates the state
    and adds a new block, nodes accept the update as accurate.

3.  **Checking Proof Validation on L1**: Nodes can monitor the state of
    the network by observing L1 and ensuring that every time a proof is
    sent, they receive the updated state. This way, they don’t have to
    trust anyone and only need to keep track of the latest valid
    transaction for Starknet.

Each type of node setup comes with its own set of hardware requirements
and trust assumptions.

### Nodes That Replay Transactions

Nodes that replay transactions require powerful machines to track and
execute all transactions. These nodes don’t have trust assumptions; they
rely solely on the transactions they execute, guaranteeing that the
state at any given point is valid.

### Nodes That Rely on L2 Consensus

Nodes relying on L2 consensus require less computational power. They
need sufficient storage to keep the state but don’t need to process a
lot of transactions. The trade-off here is a trust assumption.
Currently, Starknet revolves around one Sequencer, so these nodes are
trusting Starkware not to disrupt the network. However, once a consensus
mechanism and leader election amongst Sequencers are in place, these
nodes will only need to trust that a Sequencer who staked their stake to
produce a block is not willing to lose it.

### Nodes That Check Proof Validation on L1

Nodes that only update their state based on proof validation on L1
require the least hardware. They have the same requirements as an
Ethereum node, and once Ethereum light nodes become a reality,
maintaining such a node could be as simple as using a smartphone. The
only trade-off is latency. Proofs are not sent to Ethereum every block
but intermittently, resulting in delayed state updates. Plans are in
place to produce proofs more frequently, even if they are not sent to
Ethereum immediately, allowing these nodes to reduce their latency.
However, this development is still a way off in the Starknet roadmap.

## Conclusion

Through this chapter, we delve into Starknet’s structure, uncovering the
importance of Sequencers, Provers, and nodes. Each plays a unique role,
but together, they create a highly scalable, efficient, and secure
network that marks a significant step forward in Layer 2 solutions. As
Starknet evolves towards decentralization, understanding these roles
will provide valuable insight into the inner workings of this network.

As we venture further into the Starknet universe, our next stop will be
an exploration of the transaction lifecycle before we dive into the
heart of coding with Cairo.
