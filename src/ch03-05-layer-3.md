# Layer 3 (App Chains)

Appchains let you create a blockchain designed precisely for your
application’s needs. These specialized blockchains allow customization
in various aspects, such as hash functions and consensus algorithms.
Moreover, they inherit the security features of the Layer 1 or Layer 2
blockchains they are built upon.

Example:

Layer 3 blockchains can exist on top of Layer 2 blockchains. You can
even build additional layers (Layer 4 and so on) on top of Layer 3 for
more complex solutions. A sample layout is shown in the following
diagram.

<img alt="Example of an environment with a Layers 3 and 4" src="img/ch03-layer-3-ecosystem.png" class="center" style="width: 50%;" />

<span class="caption">Example of an environment with a Layers 3 and 4</span>

In this example ecosystem, Layer 3 options include:

- The Public Starknet (L2), which is a general-purpose blockchain for
  decentralized applications.

- A L3 Starknet optimized for cost-sensitive applications.

- Customized L3 Starknet systems designed for enhanced performance,
  using specific storage structures or data compression techniques.

- StarkEx systems used by platforms like dYdX and Sorare, offering
  proven scalability through data availability solutions like Validium
  or Rollup.

- Privacy-focused Starknet instances, which could also function as a
  Layer 4, for conducting transactions without including them in
  public Starknets.

## Benefits of Layer 3

Layer 3 app chains (with
[Madara](https://github.com/keep-starknet-strange/madara) as an apt
sequencer or other option), offer a variety of advantages due to its
modularity and flexibility. Here’s an overview of the key benefits:

- **Quick Iteration**: App chains enable rapid protocol changes,
  freeing you from the constraints of the public Layer 2 roadmap. For
  example, you could rapidly deploy new DeFi algorithms tailored to
  your user base.

- **Governance Independence**: You maintain complete control over
  feature development and improvements, avoiding the need for
  decentralized governance consensus. This enables, for example, quick
  implementation of user-suggested features.

- **Cost Efficiency**: Layer 3 offers substantial cost reductions,
  potentially up to 1 million times compared to Layer 1, making it
  economically feasible to run more complex applications.

- **Security**: While there may be some trade-offs, such as reduced
  censorship resistance, the core security mechanisms remain strong.

- **Congestion Avoidance**: App chains are shielded from network
  congestion, providing a more stable transaction environment, crucial
  for real-time applications like gaming.

- **Privacy Enhancements**: Layer 3 can serve as a testing ground for
  privacy-centric features, which could include anonymous transactions
  or encrypted messaging services.

- **Innovation Platform**: App chains act as experimental fields where
  novel features can be developed and tested. For instance, they could
  serve as a testbed for new consensus algorithms before these are
  considered for Layer 2.

In summary, Layer 3 provides the flexibility, cost-efficiency, and
environment conducive for innovation, without significant compromise on
security.

## Madara as a Sequencer for Layer 3 App Chains

[Madara](https://github.com/keep-starknet-strange/madara) is a
specialized sequencer developed to execute transactions and group them
into batches. Created by the StarkWare Exploration Team, it functions as
a starting point for building Layer 3 Starknet appchains. This expands
the possibilities for innovation within the Starknet ecosystem.

Madara’s flexibility allows for the creation of Layer 3 appchains
optimized for various needs, for example:

- Cost-Efficiency: Create an appchain for running a decentralized
  exchange (DEX) with lower fees compared to the public Starknet.

- Performance: Build an appchain to operate a DEX with faster
  transaction times.

- Privacy: Design an appchain to facilitate anonymous transactions or
  encrypted messaging services.

For more information on Madara, refer to the subchapter with the same
title.
