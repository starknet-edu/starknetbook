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

## Components of the ERC - 4337

These are the components of the ERC-4337: `UserOperation`, `Bundler`, `Paymaster`, `wallet`

- **UserOperation:**
  UserOperation is a structure that describes a transaction to be sent on behalf of a user. To avoid confusion, it is not named “transaction”.

i. Like a transaction, it contains “sender”, “to”, “calldata”, “maxFeePerGas”, “maxPriorityFee”, “signature”, “nonce”
ii. unlike a transaction, it contains several other fields, described below
iii. also, the “signature” field usage is not defined by the protocol, but by each account implementation

| Field                  |   Type    |                                                                                                                                         Description |
| ---------------------- | :-------: | --------------------------------------------------------------------------------------------------------------------------------------------------: |
| `sender`               | `address` |                                                                                                                    The account making the operation |
| `nonce`                | `uint256` |                                                                                        Anti-replay parameter (see “Semi-abstracted Nonce Support” ) |
| `initCode`             |  `bytes`  |                                         The initCode of the account (needed if and only if the account is not yet on-chain and needs to be created) |
| `callData`             |  `bytes`  |                                                                                       The data to pass to the sender during the main execution call |
| `callGasLimit`         | `uint256` |                                                                                               The amount of gas to allocate the main execution call |
| `verificationGasLimit` | `uint256` |                                                                                               The amount of gas to allocate the main execution call |
| `preVerificationGas`   | `uint256` | The amount of gas to pay for to compensate the bundler for pre-verification execution, calldata and any gas overhead that can’t be tracked on-chain |
| `maxFeePerGas`         | `uint256` |                                                                                           Maximum fee per gas (similar to EIP-1559 max_fee_per_gas) |
| `maxPriorityFeePerGas` | `uint256` |                                                                         Maximum priority fee per gas (similar to EIP-1559 max_priority_fee_per_gas) |
| `paymasterAndData`     |  `bytes`  |             Address of paymaster sponsoring the transaction, followed by extra data to send to the paymaster (empty for self-sponsored transaction) |
| `signature`            |  `bytes`  |                                                                      Data passed into the account along with the nonce during the verification step |

Instead of modifying the logic of the consensus layer itself, we replicate the functionality of the transaction mempool in a higher-level system. Users send `UserOperation` objects that package up the user’s intent along with signatures and other data for verification. Either miners or bundlers using services such as Flashbots can package up a set of UserOperation objects into a single “bundle transaction”, which then gets included into an Ethereum block.
Figure 1:

<img width="837" alt="image" src="https://github.com/starknet-edu/starknetbook/assets/125284347/037cdd3a-ec80-41a1-84d4-f71bce5bda0e">

- **Bundler:**
  A bundler is the core infrastructure component that allows account abstraction to work on any EVM network without requiring any without consensus-layer protocol adjustment. Its purpose is to work with a new mempool of `UserOperation`s and get the transaction added on-chain.
  The bundler pays the fee for the bundle transaction in ETH, and gets compensated though fees paid as part of all the individual UserOperation executions. Bundlers would choose which UserOperation objects to include based on similar fee-prioritization logic to how miners operate in the existing transaction mempool. A UserOperation looks like a transaction; it’s an ABI-encoded struct that includes fields such as:

- `sender`: the wallet making the operation
- `nonce` and `signature`: parameters passed into the wallet’s verification function so the wallet can verify an operation
- `initCode`: the init code to create the wallet with if the wallet does not exist yet
- `callData`: what data to call the wallet with for the actual execution step

The remaining fields have to do with gas and fee management; a complete list of fields can be found in the [ERC 4337](#https://eips.ethereum.org/EIPS/eip-4337) spec.

- **Wallet:**
  The wallet serves as an entry point of the smart point contract functionality. There are 2 separate entry point methods: handleOps and handleAggregatedOps.
- `validateUserOp:` which takes a UserOperation as input. This function is supposed to verify the signature and nonce on the UserOperation, pay the fee and increment the nonce if verification succeeds, and throw an exception if verification fails.
- An op execution function, that interprets calldata as an instruction for the wallet to take actions. How this function interprets the calldata and what it does as a result is completely open-ended; but we expect most common behavior would be to parse the calldata as an instruction for the wallet to make one or more calls.

To simplify the wallet’s logic, much of the complicated smart contract trickery needed to ensure safety is done not in the wallet itself, but in a global contract called the entry point. The `validateUserOp` and execution functions are expected to be gated with `require(msg.sender == ENTRY_POINT)`, so only the trusted entry point can cause a wallet to perform any actions or pay fees. The entry point only makes an arbitrary call to a wallet after `validateUserOp` with a `UserOperation` carrying that `calldata` has already succeeded, so this is sufficient to protect wallets from attacks. The entry point is also responsible for creating a wallet using the provided `initCode` if the wallet does not exist already.

<img width="647" alt="image2" src="https://github.com/starknet-edu/starknetbook/assets/125284347/02fb5b75-2169-4bc2-bf96-47ae8be9d190">

Figure 2: _Entry point control flow when running `handleOps`_

There are some restrictions that mempool nodes and bundlers need to enforce on what `validateUserOp` can do: particularly, the `validateUserOp` execution cannot read or write storage of other contracts, it cannot use environment opcodes such as `TIMESTAMP`, and it cannot call other contracts unless those contracts are provably not capable of self-destructing. This is needed to ensure that a simulated execution of `validateUserOp`, used by bundlers and `UserOperation` mempool nodes to verify that a given `UserOperation` is okay to include or forward, will have the same effect if it is actually included into a future block.

If a `UserOperation`'s verification has been simulated successfully, the `UserOperation` is guaranteed to be includable until the sender account has some other internal state change (because of another `UserOperation` with the same sender or another contract calling into the `sender`; in either case, triggering this condition for one account requires spending 7500+ gas on-chain). Additionally, a `UserOperation` specifies a gas limit for the `validateUserOp` step, and mempool nodes and bundlers will reject it unless this gas limit is very small (eg. under 200000). These restrictions replicate the key properties of existing Ethereum transactions that keep the mempool safe from DoS attacks. Bundlers and mempool nodes can use logic similar to today’s Ethereum transaction handling logic to determine whether or not to include or forward a ``UserOperation.

**Paymasters**

One of the main reasons why the user experience of using EOAs is so difficult is because the wallet owner needs to find a way to get some ETH before they can perform any actions on-chain. With paymasters, ERC-4337 allows abstracting gas payments altogether, meaning ​​someone other than the wallet owner can pay for the gas instead.

<img width="676" alt="image3" src="https://github.com/starknet-edu/starknetbook/assets/125284347/b7deae91-56a8-4361-9697-ca4793546b1e">

Figure 3: _Paymaster flow_

Sponsored transactions have a number of key use cases. The most commonly cited desired use cases are:

- Allowing application developers to pay fees on behalf of their users
- Allowing users to pay fees in ERC20 tokens, with a contract serving as an intermediary to collect the ERC20s and pay in ETH

This proposal can support this functionality through a built-in paymaster mechanism. A UserOperation can set another address as its paymaster. If the paymaster is set (ie. nonzero), during the verification step the entry point also calls the paymaster to verify that the paymaster is willing to pay for the UserOperation. If it is, then fees are taken out of the paymaster’s ETH staked inside the entry point (with a withdrawal delay for security) instead of the wallet. During the execution step, the wallet is called with the calldata in the UserOperation as normal, but after that the paymaster is called with postOp.

Example workflows for the above two use cases are:

- The paymaster verifies that the `paymasterData` contains a signature from the sponsor, verifying that the sponsor is willing to pay for the `UserOperation`. If the signature is valid, the paymaster accepts and the fees for the `UserOperation` get paid out of the sponsor’s stake.
- The paymaster verifies that the `sender` wallet has enough ERC20 balance available to pay for the `UserOperation`. If it does, the paymaster accepts and pays the ETH fees, and then claims the ERC20 tokens as compensation in the `postOp` (if the `postOp` fails because the `UserOperation` drained the ERC20 balance, the execution will revert and `postOp` will get called again, so the paymaster always gets paid). Note that for now, this can only be done if the ERC20 is a wrapper token managed by the paymaster itself.

Note particularly that in the second case, the paymaster can be purely passive, perhaps with the exception of occasional rebalancing and parameter re-setting. This is a drastic improvement over existing sponsorship attempts, that required the paymaster to be always online to actively wrap individual transactions.

## What properties does this design add, maintain and sacrifice compared to the regular Ethereum transaction mempool?

**Maintained properties:**

- No centralized actors; everything is done through a peer-to-peer mempool
  DoS safety (a UserOperation that passes simulation checks is guaranteed to be includable until the sender has another state change, which would require the attacker to pay 7500+ gas per sender)
- No user-side wallet setup complexity: users do not have to care about whether or not their wallet contract has been “already published”; wallets exist at deterministic CREATE2 addresses, and if a wallet does not yet exist the first UserOperation creates it automatically
- Full EIP 1559 support, including fee-setting simplicity (users can set a fixed fee premium and a high max total fee, and expect to be included quickly and charged fairly)
- Ability to replace-by-fee, sending a new UserOperation with a significantly higher premium than the old one to replace the operation or get it included faster

**Benefits of the Design:**

- Verification logic flexibility: the validateUserOp function can add arbitrary signature and nonce verification logic (new signature schemes, multisig…)
- Sufficient to make the execution layer quantum-safe: if this proposal gets universally adopted, no further work on the execution layer needs to be done for quantum-safety. Users can individually upgrade their wallets to quantum-safe ones. Even the wrapper transaction is safe, as the miner can use a new freshly created and hence hash-protected EOA for each bundle transaction and not publish the transaction before it is added in a block.
- Wallet upgradeability: wallet verification logic can be stateful, so wallets can change their public keys or (if published with DELEGATECALL) upgrade their code entirely.
- Execution logic flexibility: wallets can add custom logic for the execution step, eg. making atomic multi-operations (a key goal of EIP 3074)

**Limitations:**
This proposal is not without its own limitations;

- Slightly increased DoS vulnerability despite the protocol’s best effort, simply because verification logic is allowed to be somewhat more complex than the status quo of a single ECDSA verification.
- Gas overhead: somewhat more gas overhead than regular transactions (though made up for in some use cases by multi-operation support).
- One transaction at a time: accounts cannot queue up and send multiple transactions into the mempool. However, the ability to do atomic multi-operations makes this feature much less necessary.

## Conclusion

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

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
