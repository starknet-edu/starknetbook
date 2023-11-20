# Account Abstraction

Account Abstraction (AA) is a paradigm shift in how accounts and
transactions are managed in blockchain networks. To break it down, AA
refers to two intertwined notions:

1.  Transaction Flexibility: This gives the power to each smart contract
    to validate its transactions, rather than enforcing a
    one-size-fits-all validation process. This can lead to a variety of
    potential benefits such as enabling smart contracts to pay for gas
    fees, allowing multiple signers for a single account, and even
    introducing advanced cryptographic signatures.

2.  User Experience Optimization: AA provides a more intuitive
    experience for end-users. It allows developers to create a more
    flexible security model, for instance, allowing different keys for
    everyday use and high-value transactions. Additionally, it
    eliminates, if wished, the need for seed phrases, instead opting for
    easier recovery methods.

At a technical level, AA replaces Externally Owned Accounts (EOA) with a
generalized concept of accounts. Under this model, accounts can be
represented by a smart contract that dictates their specific rules and
behaviors. This means the user or contract account could dictate rules
about transaction ordering, signatures, access controls, and more,
providing a high level of customization.

Here are two commonly cited definitions of AA:

> Definition 1: Account Abstraction (AA) is when a **smart contract can
> pay for its own transactions** (Martin Triay, Devcon 6)\[1\]. In other
> words, abstract contracts (or account smart contracts) can pay for
> transactions. This is a departure from the traditional Externally
> Owned Accounts or Smart Wallets.

> Definition 2: AA is **validation abstraction**. Instead of relying on
> a single method of transaction validation, as with Ethereum’s Layer 1,
> AA enables an abstraction of the validation process. This implies the
> possibility of using different types of signatures, cryptographic
> primitives, execution processes, etc. (lightclient, Devcon 6)\[3\].

AA is positioned as the cornerstone of the next generation blockchain
technologies, with significant improvements in scalability, user
experience, and security. It is currently being pioneered by Layer 2
solutions, including Starknet, as they aim to revolutionize the way we
approach security, user experience, and self-custody in the crypto
space.

## Applications of Account Abstraction

Having defined Account Abstraction, let’s delve into its practical
applications. Account Abstraction aims to improve both the accessibility
and security of self-custody. Here are a few of the key features that AA
enables:

1.  **Hardware Signer:** With AA, you could sign transactions using a
    key generated and safeguarded by your smartphone’s secure enclave.
    This use of biometric identity makes the process more secure and
    user-friendly (Starkware)\[4\], (Braavos)\[7\].

2.  **Social recovery:** With the integration of AA, if you lose or
    compromise your key, you could securely replace it, thus eliminating
    the need for seed phrases. This change not only enhances security
    but also simplifies the user experience (Julien Niset, 2022)\[5\].

3.  **Key rotation:** If a key controlling your account is compromised,
    you can easily replace it, negating the need to transfer your
    assets.

4.  **Session keys:** AA can enhance the usability of web3 applications
    by allowing a _sign in once_ feature. This would enable websites to
    execute transactions on your behalf, reducing the need for
    continuous approvals.

5.  **Custom transaction validation schemes:** AA enables the use of
    various signature schemes, multisignatures, and other security
    rules. This flexibility allows for customizable security measures to
    meet individual user’s needs (Martin Triay, Devcon 6)\[1\], (Julien
    Niset, 2022)\[5\], (Motty Lavie)\[7\].

Moreover, AA provides enhanced security in several ways:

1.  **Improved key management:** With AA, you can associate multiple
    devices with your wallet, so if one device is lost, you still have
    access to your account.

2.  **Various signature and validation schemes:** AA supports additional
    security measures, like two-factor authentication for large
    transactions, providing a more secure environment that adapts to
    individual user’s needs.

3.  **Custom security policies:** Tailor security schemes to suit
    different types of users or devices and adapt good practices from
    the banking and web2 sectors.

AA opens up new possibilities for both developers and users in the
Ethereum ecosystem. It offers a promising pathway for a more secure,
user-friendly experience and lays the groundwork for widespread
adoption.

## Ethereum Account System

To fully understand the benefits of Account Abstraction (AA), let’s
delve into Ethereum’s current account system. The system is split into
two types of accounts:

- **Externally Owned Accounts** (EOAs)

- **Contract Accounts** (CAs).

EOAs are the accounts used by individuals, wallets, or any entity
external to the Ethereum network. These accounts are identified by their
address, which is derived from the public key of an associated
cryptographic object called a signer. This signer, or keypair, consists
of a private key and a public key.

The private key, also known as the secret key, is used to digitally sign
transactions or messages, establishing proof of ownership. The
corresponding public key is used to verify this signature, ensuring it
was indeed signed by the respective private key.

This means, in order to modify the state of an account, a transaction
must be initiated and signed by the corresponding private key of the
account’s EOA. This design choice ensures security by associating each
account with a unique cryptographic identity.

On the other hand, CAs are smart contracts living on the Ethereum
blockchain. Unlike EOAs, they do not have a private key. They are
triggered through transactions or messages initiated by EOAs, and their
behavior is determined by their associated code.

However, the current account model presents some challenges:

1.  **Key Management:** The loss of a private key is catastrophic. Given
    that the private key represents the ownership of the account, if it
    is lost, all the assets within the account are lost too. Similarly,
    if it gets stolen, the perpetrator gains full control over the
    account and its assets.

2.  **User Experience:** Currently, the Ethereum account model lacks
    user-friendly methods for key recovery or account recovery, which
    can discourage non-technical users. Additionally, user interfaces,
    such as crypto wallets, can be overwhelming and difficult to use,
    presenting barriers for wider adoption.

3.  **Lack of Flexibility:** The traditional model doesn’t allow for
    custom transaction validation schemes, limiting the possible
    security and access control improvements.

Account Abstraction proposes to improve upon these limitations, offering
new possibilities in terms of security, scalability, and user
experience.

## The Need for Account Abstraction

As the crypto ecosystem matures and attracts a broader user base, it
faces pivotal challenges that demand innovative solutions. Among these,
the question of Account Abstraction (AA) has taken center stage.
Ethereum, one of the leading platforms for smart contracts and
Decentralized Applications (dApps), is in a precarious position: it must
embrace Account Abstraction or risk its position in the crypto world.

Without AA, Ethereum’s ability to provide a seamless, empowering, and
secure experience for its users is hampered. This could lead to users
abandoning the platform for centralized exchanges and wallets, a trend
that would undermine the very ethos of decentralization that
cryptocurrency and blockchain technology espouse.

There are several compelling reasons why Ethereum, and the larger crypto
ecosystem, need Account Abstraction:

- **Risk of Centralization:** The inefficiencies and limitations of
  the current account model may push users towards centralized
  exchanges and wallets. These entities defy the principles of
  decentralization, presenting familiar risks such as censorship,
  discrimination, and potential abuse of power. Account Abstraction,
  by enabling easier and more secure account management, can help
  uphold the principles of decentralization.

- **Quantum Threat:** Quantum computing poses a potential threat to
  cryptographic systems, with its ability to break traditional
  security measures. Account Abstraction can address this by enabling
  the use of different signature schemes, including quantum-resistant
  ones, enhancing the security of assets on the blockchain.

- **Scaling Self-Custody:** As the next billion users approach the
  crypto ecosystem, the importance of scaling self-custody becomes
  paramount. AA can improve the scalability of self-custody, which is
  essential for onboarding these new users.

- **User Experience:** Simplifying the onboarding process and user
  experience is essential for widespread adoption. The complexity
  associated with current wallets and key management systems can be
  daunting for newcomers. Account Abstraction promises to simplify
  these aspects, paving the way for a more intuitive user experience.

Starknet is currently leading the efforts to implement Account
Abstraction at the protocol level. Many consider it to be the "proving
ground" for the future of AA. With numerous experts from different
organizations collaborating, Starknet aims to redefine the approach to
security, user experience, and self-custody in the crypto space.

The stakes are high. The future of Ethereum, and by extension, the
crypto ecosystem, is deeply intertwined with the success of Account
Abstraction. If Ethereum cannot adapt, it risks losing its prominence to
other, more adaptable platforms.

Account Abstraction is a win for usability in web3 and on Starknet it has been supported from the beginning at the protocol level. For a smart contract to be considered an account contract it must at least implement the interface defined by SNIP-6. Additional methods might be required for advanced account functionality.

```
// Cheat sheet

struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(calls: Array<Call>) -> felt252;
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}

trait IAccountAddon {
    fn __validate_declare__(class_hash: felt252) -> felt252;
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;
    fn public_key() -> felt252;
}
```

Much has been said about the need to improve the user experience (UX) of web3 if we want to increase adoption. Account Abstraction (AA) is one of the most powerful tools on Starknet to improve UX as it enables users to sign transactions with FaceID or TouchID, to execute multiple operations in a single transaction and to allow for third party services to perform operations on behalf of the user with fine grain control. No wonder why Visa has been so interested in exploring Starknet for auto payments [1].

With Account Abstraction, and in contrast to Externally Owned Accounts (EOA), the signer is decoupled from the account. The signer is the piece of code that signs transactions using a private key and elliptic curve cryptography to uniquely identify a user. The account is a smart contract on Starknet that defines how signature verification is performed, executes the transactions signed by the user and ultimately owns the user’s assets (aka tokens) on L2.

Note: Using an Elliptic Curve Digital Signature Algorithtm (ECDSA) is not the only way to authenticate a signer, other mechanisms are possible but they come with tradeoffs of performance, cost and ecosystem support. ECDSA remains the most widely used algorithm on Starknet and different curves are supported.

## SNIP-6

For a smart contract to be considered an account (aka account contract) it must adhere to a specific public interface defined by the Starknet Improvement Proposal number 6 (SNIP-6)

```
/// @title Represents a call to a target contract
/// @param to The target contract address
/// @param selector The target function selector
/// @param calldata The serialized function parameters
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

/// @title SRC-6 Standard Account
trait ISRC6 {
    /// @notice Execute a transaction through the account
    /// @param calls The list of calls to execute
    /// @return The list of each call's serialized return value
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;

    /// @notice Assert whether the transaction is valid to be executed
    /// @param calls The list of calls to execute
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate__(calls: Array<Call>) -> felt252;

    /// @notice Assert whether a given signature for a given hash is valid
    /// @param hash The hash of the data
    /// @param signature The signature to validate
    /// @return The string 'VALID' represented as felt when the signature is valid
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

/// @title SRC-5 Standard Interface Detection
trait ISRC5 {
    /// @notice Query if a contract implements an interface
    /// @param interface_id The interface identifier, as specified in SRC-5
    /// @return `true` if the contract implements `interface_id`, `false` otherwise
    fn supports_interface(interface_id: felt252) -> bool;
}
```

As you can see in the proposal, an account contract must implement at least the methods **execute**, **validate** and is_valid_signature.

The methods **execute** and **validate** are meant to be called by the Starknet protocol during different stages of the lifecycle of a transaction. This doesn’t mean that only the Starknet protocol can use those methods, as a matter of fact, anyone can call those methods even if the contract account doesn’t belong to them. Something to keep an eye on when securing our account.

When a user sends an invoke transaction, the first thing that the protocol does is to call the **validate** method to check the signature of the transaction. In other words, to authenticate the signer associated with the account. There are restrictions on what you can do inside the **validate** method to protect the Sequencer against Denial of Service (DoS) attacks.

Notice that if the signature verification is successful, the **validate** method should return the short string VALID as opposed to a boolean. In Cairo, a short string is simply the ASCII representation of a single felt and not a real string. This is why the return type of the method is felt252. If the signature verification fails, you can stop execution with an assert or return literally any other felt that is not the aforementioned short string.

If the protocol is able to authenticate the signer, it will then call the function **execute** passing as an argument an array of all the operations or “calls” the user wants to perform as a multicall. Each one of these calls define a target smart contract, a method to call (the “selector”) and the arguments expected by the method.

The execution of each Call might result in a value being returned from the target smart contract. This value could be a simple scalar like a felt252 or a boolean, or a complex data structure like a struct or an array. In any case, the Starknet protocol serializes the response using a Span of felt252 elements. Remember that Span represents a snapshot of an Array. This is why the return type of the **execute** method is an Array of Spans which represents a serialized response from each call in the multicall.

The method is_valid_signature is not defined or used by the Starknet protocol. It was instead an agreement between builders in the Starknet community as a way to allow web3 apps to perform user authentication. Think of a user trying to authenticate to an NFT marketplace using their wallet. The web app will ask the user to sign a message and then it will call the function is_valid_signature to verify that the connected wallet address belongs to the user.

To allow other smart contracts to know if your account contract adheres to the SNIP-6 interface, you should implement the method supports_interface from the SRC5 introspection standard. The interface_id for the SNIP-6 interface is the combined hash of the trait’s selectors as defined by Ethereum’s ERC165. You can calculate the id yourself by using the src5-rs utility or you can take my word for it that the id is 1270010605630597976495846281167968799381097569185364931397797212080166453709.

## Additional Interface

Although the interface defined by the SNIP-6 is enough to guarantee that a smart contract is in fact an account contract, it is the minimum requirement and not the whole story. For an account to be able to declare other smart contracts and pay for the associated gas fees it will need to also implement the method **validate_declare**. If we also want to be able to deploy our account contract using the counterfactual deployment method then it also needs to implement the **validate_deploy** method.

Counterfactual deployment is a mechanism to deploy an account contract without relying on another account contract to pay for the related gas fees. This is important if we don’t want to associate a new account contract with its deployer address and instead have a “pristine” beginning.

This deployment process starts by calculating locally the would-be-address of our account contract without actually deploying it yet. This is possible to do with tools like Starkli. Once we know the address, we then send enough ETH to that address to cover the costs of deploying our account contract. Once the address is funded we can finally send a deploy_account transaction to Starknet with the compiled code of our account contract. The Sequencer will deploy the account contract to the precalculated address and pay itself gas fees with the ETH we sent there. There’s no need to declare an account contract before deploying it.

To allow tools like Starkli to easily integrate with our smart contract in the future, it is recommended to expose the public_key of the signer as a view function as part of the public interface. With all this in mind, the extended interface of an account contract is shown below.

```dotnetcli
/// @title IAccount Additional account contract interface
trait IAccountAddon {
    /// @notice Assert whether a declare transaction is valid to be executed
    /// @param class_hash The class hash of the smart contract to be declared
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_declare__(class_hash: felt252) -> felt252;

    /// @notice Assert whether counterfactual deployment is valid to be executed
    /// @param class_hash The class hash of the account contract to be deployed
    /// @param salt Account address randomizer
    /// @param public_key The public key of the account signer
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;

    /// @notice Exposes the signer's public key
    /// @return The public key
    fn public_key() -> felt252;
}

```

In summary, a fully fledged account contract should implement the SNIP-5, SNIP-6 and the Addon interface.

## Why Isn’t Account Abstraction Implemented in Ethereum’s Layer 1 Yet?

Ethereum’s Layer 1 (L1) doesn’t yet support Account Abstraction (AA) at
a protocol level, not due to lack of desire or understanding of its
importance, but rather due to the complexity of its implementation.

The most prominent roadblock in integrating AA is the entrenched nature
of Externally Owned Accounts (EOAs) in Ethereum’s architecture. These
accounts, as fundamental elements of the Ethereum core protocol, would
need significant alteration to support AA, an undertaking that becomes
more daunting as the value secured by Ethereum continues to rise.

One key aspect that complicates the integration of AA into Ethereum’s L1
is the Ethereum Virtual Machine (EVM). The EVM, as the runtime
environment for smart contracts in Ethereum, has limitations that hinder
the implementation of AA. While there have been several proposals for AA
since Ethereum’s inception, they have been consistently delayed due to
other pressing updates and improvements to the Ethereum network.

However, the emergence of Layer 2 (L2) solutions provides a new pathway
for the implementation of AA. With their focus on scalability and
performance enhancements, these new virtual machines can better
accommodate AA. Starknet and ZKSync are examples of platforms that have
native AA inspired by EIP4337 – a proposal deemed superior by industry
experts like Argent’s Julien Niset.

The repeated postponements and challenges in implementing AA on
Ethereum’s L1 have led many proponents, including Niset, to shift their
focus. Instead of hoping for EOAs to be phased out and AA integrated at
Ethereum’s core, they are now advocating for the broad adoption of AA
through L2 solutions like Starknet. This strategy could bring the
benefits of AA to users sooner and help the Ethereum network remain
competitive in the rapidly evolving crypto landscape.

## (OPTIONAL) ERC-4337 Components Explained

ERC-4337 brings a new transaction layer to Ethereum without altering the core consensus mechanism. It's comprised of several components: `UserOperation`, `Bundler`, `Wallet`, and `Paymaster`.

### UserOperation Component

`UserOperation` is a structured definition that encapsulates user transaction details. Unlike a conventional transaction, it encompasses several fields:

- `sender`: Ethereum address initiating the operation.
- `nonce`: A sequential number preventing transaction replay, critical for security.
- `initCode`: Initialization code for account creation when the account doesn't exist on the blockchain.
- `callData`: Data payload for the execution call to the `sender` address.
- `callGasLimit`: Gas allocation for the execution call.
- `verificationGasLimit`: Gas allocation for the verification process.
- `preVerificationGas`: Gas paid to the bundler for pre-execution verification efforts.
- `maxFeePerGas` and `maxPriorityFeePerGas`: Fees per gas unit, aligning with EIP-1559 standards.
- `paymasterAndData`: Information about any third-party paymaster responsible for transaction fees.

`UserOperation` objects are submitted by users, encapsulating their intended actions, signatures, and required validation data. Bundlers collect these objects into bundles, which are then incorporated into Ethereum blocks as singular transactions.

<img width="837" alt="image" src="https://github.com/starknet-edu/starknetbook/assets/125284347/037cdd3a-ec80-41a1-84d4-f71bce5bda0e">

### Bundler Component

The Bundler serves as the keystone in ERC-4337, enabling account abstraction across EVM-compatible networks without consensus layer alterations. It manages a specialized mempool of `UserOperation` objects, ensuring transactions are added on-chain efficiently. The Bundler is responsible for:

- Paying the ETH fee for the bundled transaction.
- Receiving compensation through execution fees from `UserOperation` executions.
- Selecting `UserOperation` objects for inclusion based on fee-prioritization logic, mirroring traditional miner operations in the Ethereum mempool.

`UserOperation` objects are ABI-encoded structures containing:

- `sender`: The wallet initiating the operation.
- `nonce` and `signature`: Critical for the wallet's verification function to authenticate operations.
- `initCode`: Necessary for creating the wallet if it does not already exist.
- `callData`: The data invoked for the wallet's execution step.

Bundlers balance the `UserOperation` inclusion based on potential fee earnings against the computational and financial costs, analogous to how miners select transactions for block inclusion. The remaining fields have to do with gas and fee management; a complete list of fields can be found in the [ERC 4337](#https://eips.ethereum.org/EIPS/eip-4337) spec.

## Wallet Component

The Wallet in the ERC-4337 framework is a critical interface for managing user operations, which includes executing the `validateUserOp` function. This function is central to ensuring transactional integrity and security. It's designed with several restrictions that enforce deterministic transaction validation:

- The function is prohibited from reading or writing the storage of other contracts, maintaining each contract's state integrity.
- It cannot use environment opcodes like `TIMESTAMP`, which prevents non-determinism in validation.
- Interaction with other contracts is restricted to those that cannot self-destruct, mitigating potential vulnerabilities and ensuring contract interaction stability.

These limitations are essential for ensuring that a simulated execution of `validateUserOp` by bundlers and mempool nodes aligns with its actual execution upon inclusion in a future block.

Once a `UserOperation` has been successfully validated, it is assured of inclusion in the blockchain until the sender's account undergoes an internal state change. This change could be triggered by another `UserOperation` or contract interaction, each requiring a substantial amount of gas (over 7500) to modify the account state.

Additionally, the `UserOperation` must specify a conservative gas limit for the `validateUserOp` process. Mempool nodes and bundlers are required to enforce this limit strictly, rejecting any operation that proposes a gas limit beyond an established threshold, such as 200,000 gas. This policy mirrors the protective measures in Ethereum's current transaction system to protect against DoS attacks.

By adopting transactional models akin to Ethereum's current system, the Wallet ensures the secure and predictable handling of `UserOperation` objects. Bundlers and mempool nodes utilize this logic to make informed decisions on including or forwarding operations, thus maintaining the network's resilience to potential threats and ensuring the trustworthiness of the system's stability.

<img width="647" alt="image2" src="https://github.com/starknet-edu/starknetbook/assets/125284347/02fb5b75-2169-4bc2-bf96-47ae8be9d190">

### Paymaster Component

Paymasters in ERC-4337 address the challenge of obtaining ETH for transaction fees by allowing gas payment abstraction. This enables:

- Developers to sponsor transaction fees for their users.
- Users to pay fees with ERC20 tokens via an intermediary contract converting tokens to ETH.

The Paymaster is an optional role within a `UserOperation`, determined during the verification step. If a Paymaster agrees to cover the operation fees, they are deducted from the Paymaster's staked ETH. Following execution, the Paymaster may be further involved during the `postOp` call.

Key workflows include:

- Validating sponsor signatures within `paymasterData` to confirm fee sponsorship.
- Ensuring sufficient ERC20 token balances for transaction fee coverage, with the Paymaster converting and claiming these tokens as compensation during `postOp`.

Paymasters can operate passively, requiring minimal active management, which is a substantial advancement over previous sponsorship models that demanded continuous online presence and active transaction wrapping.

The Paymaster system significantly reduces the entry barrier for users by offloading the necessity of holding ETH for transaction fees, promoting inclusivity and flexibility in the Ethereum ecosystem.

<img width="676" alt="Paymaster Flow" src="https://github.com/starknet-edu/starknetbook/assets/125284347/b7deae91-56a8-4361-9697-ca4793546b1e">

### ERC-4337 Design Properties

ERC-4337 updates the Ethereum transaction process while preserving core aspects of the current mempool:

**Maintained Properties:**

- Decentralization: Transactions remain peer-to-peer without centralized control.
- DoS Protection: `UserOperation` objects, once validated, are includable until the sender's state changes, safeguarding against denial-of-service attacks.
- Simplified Wallet Setup: Wallets are automatically created at deterministic addresses without user intervention.
- EIP 1559 Compliance: This design supports fee structures that allow users to be included in blocks quickly and at fair prices.
- Fee Replacement: Users can expedite transactions by increasing the fee premium through a new `UserOperation`.

**Design Advantages:**

- Flexible Verification: The `validateUserOp` function supports various signature and nonce verification methods.
- Quantum-Resilient: This design sets the stage for a quantum-resistant execution layer. Users can upgrade wallets for enhanced security.
- Wallet Upgradability: Wallets can adapt over time, changing public keys or code as needed.
- Execution Flexibility: Wallets can execute complex operations, such as atomic multi-operations, aligning with EIP 3074 goals.

**Limitations:**
The design also introduces certain trade-offs:

- DoS Risk: The complex verification logic introduces a minor increase in DoS vulnerability.
- Gas Usage: The gas costs are slightly higher, offset by the efficiency of multi-operation transactions.
- Single Transaction Queueing: Multiple transactions cannot be queued simultaneously, but the design's support for atomic multi-operations compensates for this limitation.

## Conclusion

Account Abstraction is a win for usability in web3 and on Starknet it has been supported from the beginning at the protocol level. For a smart contract to be considered an account contract it must at least implement the interface defined by SNIP-6. Additional methods might be required for advanced account functionality.

An account contract can be deployed using another account contract to pay for gas fees or doing a counterfactual deployment for a pristine start.

To bring it all home, imagine the Ethereum account system as a kind of
multifunctional Swiss Army knife, currently under renovation. What we’re
doing with Account Abstraction is swapping out a few tools - while it
was once a knife and a corkscrew, we’re making it into a magnifying
glass and a set of tweezers.

Why the change? The original tools served us well, but they didn’t fit
every task we found ourselves up against. Some jobs required precision;
others needed a broader lens. That’s where Account Abstraction shines.
It expands Ethereum’s capabilities, adjusting and adapting to our
ever-evolving requirements.

Remember the complications of Ethereum’s current account system? Account
Abstraction seeks to transform those by offering more flexible,
personalized, and safer solutions. It’s like tailoring the tools of your
Swiss Army knife to your unique needs.

However, it’s not yet implemented into Ethereum’s Layer 1. And why? The
kitchen is bustling, and the chefs are wary of spilling the soup. The
implementation process has its challenges, it’s true. But the cook who
never dropped a pan never learned to make an omelette. That’s why
research and development continue relentlessly.

Through the lens of Account Abstraction, we see Ethereum’s
future—secure, accessible, flexible. It’s an exciting, transformative
prospect that’s redefining what we thought possible. And though the path
may be fraught with complexities and risks, it’s a journey well worth
taking.

After all, the Swiss Army knife was once just a knife. Imagine what it
could become next.

# References:

- \[1\] Martin Triay, Devcon 6:
  <https://www.youtube.com/watch?v=Osc_gwNW3Fw>

- \[2\] Julien Niset: <https://www.youtube.com/watch?v=OwppworJGzs>

- \[3\] lightclient, Devcon 6:
  <https://app.devcon.org/schedule/9mvqce>

- \[4\] Starkware:
  <https://medium.com/@starkware/how-starknet-is-revolutionizing-crypto-signing-ba3724077a79>

- \[5\] Julien Niset, 2022:
  <https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/>

- \[6\] Yoav, Devcon 6: <https://app.devcon.org/schedule/9mvqce>

- \[7\] Motty Lavie, 2023:
  <https://www.youtube.com/watch?v=FrxAdJYhSY8>

- David Barreto,2023: https://medium.com/starknet-edu/account-abstraction-on-starknet-part-i-2ff84c6a3c30

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
