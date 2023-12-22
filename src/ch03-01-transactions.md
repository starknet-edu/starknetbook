# Transaction Versions

Understanding Starknet's transaction types is essential to master its architecture and capabilities. Each transaction type serves a unique purpose, and getting a grip on their differences is crucial for proficient Starknet usage.

## Starknet OS: The Backbone

Central to Starknet's functionality is the Starknet Operating System (OS), a Cairo program that fuels the network. This OS orchestrates key activities, including:

- Deploying contracts
- Executing transactions
- Facilitating L1<>L2 message exchanges

In Starknet terminology, "protocol level" alludes to modifications in the foundational Starknet OS Cairo program, ensuring its steadfastness.

## Transaction Types

- **Declare Transactions**: Unique in their ability to introduce new classes, leading to potential new smart contracts.
- **Invoke Transactions**: They call upon an action but can't introduce new ones.
- **Deploy Account Transactions**: Designed for setting up smart wallet contracts.

## Declare Transactions

Declare transactions are the sole mechanism for introducing new smart contracts to Starknet.

Recall programming in C++. Before employing a variable or function, it's first 'declared', signaling to the compiler its existence and type. Only then can you 'define' or use it. Declare transactions in Starknet operate on similar principles: they announce a new operation, prepping it for future use.

Versions:

- V0 - Suited for Cairo 0 contracts before nonces.
- V1 - Tailored for Cairo 0 with nonces.
- V2 (current) - Optimized for the modern Cairo contracts.

Here's a key distinction to understand between the different Cairo versions:

With Cairo 0, developers sent Cairo Assembly (CASM) code directly to the sequencer. But with the contemporary Cairo version, they send Sierra code to the Sequencer. Breaking it down, Cairo 0 compiled straight to CASM, while the current Cairo version compiles to Sierra, which subsequently compiles to CASM. A crucial difference is that Sierra executions are infallible and always provable, whereas in Cairo 0, transactions could fail. If they did, they became non-provable. The latest Cairo iteration ensures all code compiles to Sierra, making every transaction reliable.

When declaring a contract with the latest version, developers are essentially announcing Sierra code, not just raw CASM.

Examining the parameters of a V2 transaction reveals measures that ensure the class hash corresponds to the Sierra code being dispatched. The class hash encompasses the hash of the Cairo assembly code, but since developers send Sierra code, it's imperative to ensure that the dispatched code aligns with the indicated class hash.

// TODO -> Provide specifics about the parameters included in the transaction.

In essence, using the most recent Cairo version implies the utilization of the latest Declare transaction version.

## Invoke Transactions

Unlike Declare transactions, Invoke transactions don't add new functions. They ask the network to carry out actions, such as executing or deploying contracts. This method contrasts with Ethereum, where a contract can either be deployed by sending a distinct transaction or by having another smart contract factory to deploy it. Starknet uses only the second method.

The Universal Deployer Contract (UDC) in Starknet illustrates this idea. UDC, a public utility, helps deploy contracts. This mirrors how in C++, a declared function is called to perform tasks.

In computer science terms, think of how functions operate in C++. After declaring a function or object, you invoke it to take action. Starknet's Invoke transaction works similarly, activating pre-declared contracts or functions.

Every Invoke transaction in Starknet undergoes `__validate__` and `__execute__` stages. The `__validate__` step checks the transaction's correctness, similar to a syntax or logic check. After validation, the `__execute__` phase processes the transaction.

This two-step process, focusing on utilizing existing functionalities, highlights Starknet's distinct transaction strategy.

## Deploy Account Transactions

A challenge arises: How do you set up accounts without having one already? When creating your first smart wallet contract, deployment fees arise. How do you cover these without a smart wallet? The solution is deploy account transactions.

Uniquely in Starknet, addresses can accept funds even without an associated smart wallet. This trait is pivotal during deployment. Before an account is formally created, the `__validate__` function checks the proposed deployment address (even if it lacks a smart wallet) for sufficient funds. If present, the constructor proceeds, resulting in account deployment. This method guarantees the new account's legitimacy and financial readiness.

## Conclusion

It's vital to understand each transaction type. Declare transactions stand out for their role in presenting new functions. By likening the process to C++ declarations, developers can grasp the reasoning behind each transaction.
