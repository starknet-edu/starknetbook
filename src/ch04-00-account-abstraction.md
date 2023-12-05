# Account Abstraction

Account Abstraction (AA) represents an approach to managing accounts and transactions in blockchain networks. It involves two key concepts:

1. **Transaction Flexibility**:

   - Smart contracts validate their transactions, moving away from a universal validation model.
   - Benefits include smart contracts covering gas fees, supporting multiple signers for one account, and using alternative cryptographic signatures.

2. **User Experience Optimization**:
   - AA enables developers to design flexible security models, such as using different keys for routine and high-value transactions.
   - It offers alternatives to seed phrases for account recovery, simplifying the user experience.

Technically, AA replaces Externally Owned Accounts (EOA) with a broader account concept. In this model, accounts are smart contracts, each with its unique rules and behaviors. These rules can govern transaction ordering, signatures, access controls, and more, offering extensive customization.

**Key Definitions of AA**:

- **Definition 1**: As described by [Martin Triay at Devcon 6](https://www.youtube.com/watch?v=Osc_gwNW3Fw), AA allows smart contracts to pay for their transactions. This shifts away from traditional Externally Owned Accounts or Smart Wallets.
- **Definition 2**: [Lightclient at Devcon 6](https://app.devcon.org/schedule/9mvqce) defines AA as validation abstraction. Unlike Ethereum's Layer 1 single validation method, AA permits various signature types, cryptographic methods, and execution processes.

## Applications of Account Abstraction

Account Abstraction (AA) enhances the accessibility and security of self-custody in blockchain technology. Here are a few of the features that AA enables:

1. **Hardware Signer**:

   - AA enables transaction signing with keys stored in a smartphone’s secure enclave, incorporating biometric identity for enhanced security and ease of use.

2. **Social Recovery**:

   - In case of lost or compromised keys, AA allows for secure key replacement, removing the need for seed phrases and simplifying the user experience.

3. **Key Rotation**:

   - If a key is compromised, it can be easily replaced without needing to transfer assets.

4. **Session Keys**:

   - AA facilitates a _sign in once_ feature for web3 applications, allowing transactions on your behalf and minimizing constant approvals.

5. **Custom Transaction Validation Schemes**:
   - AA supports various signature schemes and security rules, enabling tailored security measures for individual needs.

AA also bolsters security in several ways:

1. **Improved Key Management**:

   - Multiple devices can be linked to your wallet, ensuring account access even if one device is lost.

2. **Diverse Signature and Validation Schemes**:

   - AA accommodates additional security measures like two-factor authentication for substantial transactions, catering to individual security needs.

3. **Custom Security Policies**:
   - Security can be customized for different user types or devices, incorporating best practices from banking and web2 sectors.

## Ethereum Account System

Understanding Ethereum's current account system is important to appreciating the benefits of Account Abstraction (AA). Ethereum's account system comprises two types:

1. **Externally Owned Accounts (EOAs)**:

   - Used by individuals, wallets, or entities external to the Ethereum network.
   - Identified by addresses derived from the public key of a cryptographic signer, which includes a private key and a public key.
   - The private key signs transactions or messages to prove ownership, while the public key verifies the signature.
   - Transactions must be signed by the EOA's private key to modify the account state, ensuring security through unique cryptographic identity.

2. **Contract Accounts (CAs)**:
   - Essentially smart contracts on the Ethereum blockchain.
   - Lack private keys and are activated by transactions or messages from EOAs.
   - Their behavior is defined by their code.

Challenges in the current account model include:

1. **Key Management**:

   - Loss of a private key means irreversible loss of account control and assets.
   - If stolen, the thief gains complete access to the account and its assets.

2. **User Experience**:

   - The Ethereum account model currently lacks user-friendly key or account recovery options.
   - Complex interfaces like crypto wallets can deter non-technical users, limiting broader adoption.

3. **Lack of Flexibility**:
   - The traditional model restricts custom transaction validation schemes, limiting potential security and access control enhancements.

AA aims to address these issues, presenting opportunities for improved security, scalability, and user experience.

## Why Isn’t Account Abstraction Implemented in Ethereum’s Layer 1 Yet?

Ethereum's Layer 1 (L1) currently lacks support for Account Abstraction (AA) at the protocol level, not due to a lack of interest or recognition of its value, but rather because of the complexity involved in its integration.

Key challenges to implementing AA in Ethereum’s L1 include:

- **Entrenched Nature of Externally Owned Accounts (EOAs)**:

  - EOAs are integral to Ethereum's core protocol.
  - Modifying them to support AA is a daunting task, especially as Ethereum's value and usage continue to grow.

- **Limitations of the Ethereum Virtual Machine (EVM)**:
  - The EVM, Ethereum's smart contract runtime environment, faces limitations that obstruct AA implementation.
  - Despite several AA proposals since Ethereum's inception, they have been delayed due to prioritization of other critical updates and improvements.

However, the rise of Layer 2 (L2) solutions offers a new avenue for AA:

- **Layer 2 Solutions**:
  - Focused on scalability and performance, L2 solutions are more accommodating for AA.
  - Platforms like Starknet and ZKSync, inspired by EIP4337, are pioneering native AA implementations.

Due to the ongoing delays and complexities of integrating AA into Ethereum’s L1, many advocates, have shifted their focus:

- **Shift to Layer 2 Advocacy**:
  - Instead of waiting for EOAs to phase out and AA to integrate into Ethereum's core, proponents now support the adoption of AA through L2 solutions.
  - This approach aims to deliver AA benefits to users more quickly and maintain Ethereum's competitive edge in the fast-evolving crypto space.

## Conclusion

In this subchapter, we've looked at Account Abstraction (AA) in Ethereum. AA makes transactions more flexible and improves how users manage their accounts. It's set to solve problems like key management and user experience in Ethereum, but its integration into Ethereum's main layer has been slow due to technical hurdles and established systems.

Layer 2 solutions, however, are opening doors for AA. Starknet is a key player here.

Next, we'll get practical. You'll learn to code AA contracts in Starknet.
