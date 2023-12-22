# Nodes

This chapter explores the role and functionality of nodes in the Starknet ecosystem, their interactions with sequencers, and their overall importance.

## Contributing to the Guide

Your contributions can help enhance this guide. Specifically, you can add:

- Additional hardware options for running a Starknet node.
- Alternative methods to set up and operate a Starknet node.

To contribute, feel free to [open a PR](https://github.com/starknet-edu/starknetbook) with your suggestions or additions.

## Overview of Nodes in the Starknet Ecosystem

A node in the Starknet ecosystem is a computer equipped with Starknet software, contributing significantly to the network's operations. Nodes are vital for the Starknet ecosystem's functionality, security, and overall health. Without nodes, the Starknet network would not be able to function effectively.

Nodes in Starknet are categorized into two types:

- **Full Nodes**: Store the entire Starknet state and validate all transactions, crucial for the network's integrity.

- **Light Nodes**: Do not store the entire Starknet state but rely on full nodes for information. They are faster and more efficient but offer less security than full nodes.

### Core Functions of Nodes

Nodes are fundamental to the Starknet network, performing a variety of critical functions:

- **Transaction Validation**: Nodes ensure transactions comply with Starknet's rules, helping prevent fraud and malicious activities.

- **Block Creation and Propagation**: They create and circulate blocks to maintain a consistent blockchain view across the network.

- **State Maintenance**: Nodes track the Starknet network's current state, including user balances and smart contract code, essential for transaction processing and smart contract execution.

- **API Endpoint Provision**: Nodes provide API endpoints, aiding developers in creating applications, wallets, and tools for network interaction.

- **Transaction Relay**: They relay user transactions to other nodes, improving network performance and reducing congestion.

## Interplay of Nodes, Sequencers, Clients, and Mempool in the Starknet Network

### Nodes and Sequencers

Nodes and sequencers are interdependent:

- **Nodes and Block Production**: Nodes depend on sequencers to create blocks and update the network state. Sequencers integrate the transactions validated by nodes into blocks, maintaining a consistent and current Starknet state.

- **Sequencers and Transaction Validation**: Sequencers rely on nodes for transaction validation and network consensus. Prior to executing transactions, sequencers work with nodes to confirm transaction legitimacy, deterring fraudulent activities. Nodes also contribute to the consensus mechanism, ensuring uniformity in the blockchain state.

### Nodes and Clients

The relationship between nodes and clients in the Starknet ecosystem is characterized by a client-server model:

- **Client Requests and Node Responses**: Clients initiate by sending requests, like transaction submissions or state queries. Nodes process these, validating transactions, updating the network state, and furnishing clients with the requested data.

- **Client Experience**: Clients receive node responses, updating their local view with the latest network information. This loop enables user interaction with Starknet DApps, with nodes maintaining network integrity and clients offering a user-friendly interface.

### Nodes and the Mempool

The mempool acts as a holding area for unprocessed transactions:

- **Transaction Validation and Mempool Storage**: Upon receiving a transaction, nodes validate it. Valid transactions are added to the mempool and broadcast to other network nodes.

- **Transaction Selection and Block Inclusion**: Nodes select transactions from the mempool for processing, incorporating them into blocks that are added to the blockchain.

## Node Implementations in Starknet

Starknet's node implementations bring unique strengths:

- **[Pathfinder](https://github.com/eqlabs/pathfinder)**: By Equilibrium, Pathfinder is a Rust-written full node. It excels in high performance, scalability, and aligns with the Starknet Cairo specification.

- **[Juno](https://github.com/NethermindEth/juno)**: Nethermind's Juno, another full node in Golang, is known for user-friendliness, ease of deployment, and Ethereum tool compatibility.

- **[Papyrus](https://github.com/starkware-libs/papyrus)**: StarkWare's Papyrus, a Rust-based full node, focuses on security and robustness. It's integral to the upcoming Starknet Sequencer, expected to boost network throughput.

These implementations are under continuous improvement, with new features and enhancements. The choice of implementation depends on user or developer preferences and requirements.

Key characteristics of each node implementation are summarized below:

| Node Implementation | Language | Strengths                                                     |
| ------------------- | -------- | ------------------------------------------------------------- |
| Pathfinder          | Rust     | High performance, scalability, Cairo specification adherence  |
| Papyrus             | Rust     | Security, robustness, Starknet Sequencer foundation           |
| Juno                | Golang   | User-friendliness, ease of deployment, Ethereum compatibility |
