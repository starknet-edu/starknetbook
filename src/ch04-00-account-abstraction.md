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
