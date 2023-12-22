# The Starknet Network

## Preamble

Historically, societal roles like currency, property rights, and social status titles have been governed by _protocols_ and _registries_. Their value stems from a widely accepted understanding of their integrity. These functions have predominantly been overseen by centralized entities prone to challenges such as corruption, agency conflicts, and exclusion ([Eli Ben-Sasson, Bareli, Brandt, Volokh, 2023](https://hackmd.io/@Elibensasson/ryMelVulp)).

Satoshi's creation, Bitcoin, introduced a novel approach for these functions, termed an _integrity web_. This is an infrastructure for societal roles that:

1. Is openly described by a public protocol.
2. Operates over a wide, inclusive, peer-to-peer network.
3. Distributes value fairly and extensively to maintain societal consensus on its integrity.

While Bitcoin addressed monetary functions, Ethereum expanded this to include any function that can be defined by computer programming. Both faced the challenge of balancing scalability with decentralization. These integrity webs have often favored inclusivity over capacity, ensuring even those with limited resources can authenticate the system's integrity. Yet, this means they struggle to meet global demand.

## Defining "Blockchain"

In the ever-evolving realm of technology, defining a term as multifaceted as "Blockchain" can be challenging. Based on current understandings and applications, a Blockchain can be characterized by the following three properties ([Eli Ben-Sasson, 2023](https://twitter.com/EliBenSasson/status/1709272086504485265)):

1. **Public Protocol:** The foundation of a Blockchain rests upon a protocol that is openly available. This transparency ensures that any interested party can understand its workings, fostering trust and enabling wider adoption.
2. **Open P2P Network:** Instead of relying on a centralized entity, a Blockchain operates over a peer-to-peer (P2P) network. This decentralized approach ensures that operations are distributed across various participants or nodes, making the system more resilient to failures and censorship.
3. **Value Distribution:** Central to the Blockchain's operation is the way it rewards its operators. The system autonomously distributes value in a manner that is wide-ranging and equitable. This incentivization not only motivates participants to maintain the system's integrity but also ensures a broader societal consensus.

While these properties capture the essence of many Blockchains, the term's definition might need refinement as the technology matures and finds new applications. Engaging in continuous dialogue and revisiting definitions will be crucial in this dynamic landscape.

## Starknet Definition

Starknet is a Layer-2 network that makes Ethereum transactions faster, cheaper, and more secure using zk-STARKs technology. Think of it as a boosted layer on top of Ethereum, optimized for speed and cost.

Starknet bridges the gap between scalability and broad consensus. It integrates a mathematical framework to navigate the balance between capacity and inclusivity. Its integrity hinges on the robustness of succinct, transparent proofs of computational integrity. This method lets powerful operators enhance Starknet's capacity, ensuring everyone can authenticate Starknet's integrity using universally accessible tools ([Eli Ben-Sasson, Bareli, Brandt, Volokh, 2023](https://hackmd.io/@Elibensasson/ryMelVulp)).

## Starknet’s Mission

_Starknet’s mission is to allow individuals to freely implement and use any social function they desire._

## Starknet’s Values

Starknet's ethos is anchored in core principles ([Eli Ben-Sasson, Bareli, Brandt, Volokh, 2023](https://hackmd.io/@Elibensasson/ryMelVulp)):

- **Lasting Broadness.** Starknet continuously resists power consolidation. Key points include:

  - Broad power distribution underpins Starknet's legitimacy and must persist across operations and decision-making. While centralized operation may be necessary at times, it should be short-lived.
  - Starknet's protocol and governance should always be open and transparent.
  - Governance should bolster inclusivity, with a flexible structure that can evolve to ensure enduring inclusivity.

- **Neutrality.** Starknet remains impartial to the societal functions it supports.

  - The objectives and ethos of functions on Starknet lie with their creators.
  - **Censorship resistance:** Starknet remains agnostic to the nature and meaning of user transactions.

- **Individual Empowerment.** At its core, Starknet thrives on a well-informed and autonomous user base. This is achieved by fostering a culture rooted in its core mission and values, with a strong emphasis on education.

## Key Features

These are some key features of Starknet:

- Low Costs: Transactions on Starknet cost less than on Ethereum.
  Future updates like Volition and EIP 4844 will make it even cheaper.

- Developer-Friendly: Starknet lets developers easily build
  decentralized apps using its native language, Cairo.

- Speed and Efficiency: Upcoming releases aim to make transactions
  even faster and cheaper.

- CVM: Thanks to Cairo, Starknet runs on it´s own VM, called Cairo VM
  (CVM), that allow us to innovate beyond the Ethereum Virtual Machine
  (EVM) and create a new paradigm for decentralized applications.

Here are some of them:

- Account Abstraction: Implemented at the protocol level, this
  facilitates diverse signing schemes while ensuring user security and
  self-custody of assets.

- Volition: Will be implemented on testnet during Q4 2023 will allow
  developers to regulate data availability on Ethereum (L1) or on
  Starknet (L2). Reducing L1 onchain data can radically reduce costs.

- Paymaster: Starknet will allow users to choose how to pay for
  transaction fee, follows the guidelines laid out in EIP 4337 and
  allows the transaction to specify a specific contract, a
  **Paymaster**, to pay for their transaction. Supports gasless
  transactions, enhancing user accessibility.

## Cairo: The Language of Starknet

Cairo is tailor-made for creating STARK-based smart contracts. As
Starknet’s native language, it’s central to building scalable and secure
decentralized apps. To start learning now, check out the [Cairo
Book](https://cairo-book.github.io/) and
[Starklings](https://github.com/shramee/starklings-cairo1).

Inspired by Rust, Cairo lets you write contracts safely and
conveniently.

## Governance

The Starknet Foundation oversees Starknet’s governance. Its duties
include:

- Managing Starknet’s development and operations

- Overseeing the Starknet DAO, which enables community involvement

- Setting rules to maintain network integrity

Our focus is on technical input and debate for improving the protocol.
While we value all perspectives, it’s often the technical insights that
steer us forward.

Members can influence Starknet by voting on changes. Here’s the process:
A new version is tested on the Goerli Testnet. Members then have six
days to review it. A Snapshot proposal is made, and the community votes.
A majority of _YES_ votes means an upgrade to the Mainnet.

In short, governance is key to Starknet’s evolution.

To propose an improvement, create a SNIP.

### SNIP: Starknet Improvement Proposals

SNIP is short for Starknet Improvement Proposal. It’s essentially a
blueprint that details proposed enhancements or changes to the Starknet
ecosystem. A well-crafted SNIP includes both the technical
specifications of the change and the reasons behind it. If you’re
proposing a SNIP, it’s your job to rally community support and document
any objections (more details
[here](https://community.starknet.io/t/draft-simp-1-simp-purpose-and-guidelines/1197#what-is-a-snip-2)).
Once a SNIP is approved, it becomes a part of the Starknet protocol. All
the SNIPs can be found in [this
repository](https://github.com/starknet-io/SNIPs).

SNIPs serve three crucial roles:

1.  They are the main avenue for proposing new features or changes.

2.  They act as a platform for technical discussions within the
    community.

3.  They document the decision-making process, offering a historical
    view of how Starknet has evolved.

Because SNIPs are stored as text files in a [version-controlled
repository](https://github.com/starknet-io/SNIPs), you can easily track
changes and understand the history of proposals.

For those who are building on Starknet, SNIPs aren’t just
suggestions—they’re a roadmap. It’s beneficial for implementers to keep
a list of the SNIPs they’ve executed. This transparency helps users
gauge the state of a particular implementation or software library.
