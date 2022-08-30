<div align="center">
    <h1>Primer</h1>

|Presentation|Video|Definitions
|:----:|:----:|:----:|
|[Validity Rollups](https://drive.google.com/file/d/1UqYi482bpVyXO4nWkogmIXq281q70f6y/view?usp=sharing)|[StarkNet 101](https://www.youtube.com/watch?v=DrBJ9LWvsOQ)|[Perama Blog](https://perama-v.github.io/cairo/description)
</div>

### Topics

1. [Bitcoin](./bitcoin/README.md)
2. [Smart Contracts](#smart_contracts)
3. [Ethereum](./ethereum/README.md)
4. [Rollups](./rollups/README.md)

<h2 align="center">Overview</h2>
This primer is inteded to cover introductory concepts upon which Cairo and StarkNet are built, and also to get you acquainted with the format of this course. Each section will involve drilling down on a high-level concept as it pertains to StarkNet or Cairo until we hit an "atomic" or irreducible concept we can represent in a simple/runnable code example:

<div align="center">
    <img src="../misc/plat.png">
</div>

Code examples will be named by the programming language in which they are implemented, for example Bitcoin block verification in [Golang](https://go.dev/doc/install) (if you can implement these example in other languages we would love a PR):
<div align="center">
    <a href="./bitcoin/block_verification/go">bitcoin/block_verification/go</a>
</div>

The topics covered in this primer have been disected in hundreds of ways by thousands of people, so wherever possible I will be linking to those resources.

<div align="center">
    <em>Standing on the shoulders of giants blah blah blah lets get to the good stuff</em>
</div>

<h3 align="center"> What are we solving for?</h3>
The advent of blockchain technology has given the world computational systems with absolute transparency and inclusive accountabiliy. In order to obtain these characteristics, blockchain systems have been forced to make large trade offs which impact usability. Vitalik Buterin, summed up this issue in "The Blockchain Trilemma" stating:

<br>
<br>
<div align="center">
    <em>blockchains are forced to make trade-offs that prevent them from being decentralized, scalable, and secure.</em>
</div>
<br>

In this course you will learn how StarkWare attempts to tackle the Blockchain Trillemma and provide a system that is
inclusively accountable, decentralized, scalable, and secure through the use of zero-knowledge STARK proofs.

<p align="center">
    🎯
    <strong>Goals: </strong>
    secure, inclusively accountable, decentralized, scalable, expressive
    🎯
</p>

<h2 align="center"> Evolution of Data Security</h2>
<div align="center">
    <img src="../misc/evolution.png">
</div>

For a more concrete example of the trillemna we can move outside of the blockchain context entirely. Say Alice has an important piece of data she needs access to. To start we will represent this data as ascii characters in YAML format:

```yaml
alice_account: 5.00
```

Let's write it to a file on our computers disk and measure performance:

```bash
time echo "alice_account: 5.00" >> bank.yaml
```

Let's read that information:

```bash
time cat bank.yaml
```

It's obviously very fast to read and write this data from our local disk, and powerful [database mechanisms](https://www.postgresql.org) can be applied to optimize accesss to the data. BUT if you drop your computer or get too close to a large ACME magnet Alice looses her valuable bank account information.
<p align="center">
    🎯
    <strong>Goals: </strong>
    <s style="color: red">secure</s>,
    <s style="color: red">inclusively accountable</s>,
    <s style="color: red">decentralized</s>,
    <span style="color: green">scalable</span>,
    <span style="color: green">expressive</span>
    🎯
</p>
<p align="center">
    💡
    <strong>Let's replicate Alice's account on another computer</strong>
    💡
</p>
If we replicate Alice's bank account YAML file on multiple computers, when one fails we haven't lost the data!

Sender Questions:

- How do I locate a recieving host to send to?
- How do I know recieving host successfully wrote Alice's account data?
- If I change Alice's account value how will the recieving host know to update the same value?

Reciever Questions:

- Who will I recieve data from?
- If I change Alice's account value how will the sending host know to update the same value?

### Distributed Systems

These questions form the basis of distributed systems and distributed computing across a network, and have been studied since the inception of the internet.

Let's look briefly at how one of the more popular distributed databases [CassandraDB](https://cassandra.apache.org/doc/latest/cassandra/getting_started/configuring.html) handles these issues.

You can see when configuring the system you are required to whitelist the `seed node` IP Addresses that will form our trusted cluster that partake in a limited peer-to-peer [gossip](https://www.linkedin.com/pulse/gossip-protocol-inside-apache-cassandra-soham-saha). Although this is suitable for many traditional systems we are strive to build inclusive and permissionless systems.

Once the distributed database is setup we gain "Fault Tolerance" for Alice's valuable bank data. If someone accidently brings their large ACME magnet into one datacenter, the data is easily accesible on redundant hosts. Similar to blockchains these distributed systems made tradeoffs to the simple I/O example above. So what did we give up for this fault tolerance?

Banks Perspective:

- Network overhead impacts performance
- Redundancy and replication impacts performance
- Infrastructure maintenance ($$$$)

Alice's Perspective:

- Delegates trust to the bank:
  - database is configured correctly
  - operational security can handle attackers or intruders
  - is not doing anything duplicitous
  - etc.
- Costs typically get passed to Alice

<p align="center">
    🎯
    <strong>Goals: </strong>
    <span style="color: yellow">secure</span>,
    <s style="color: red">inclusively accountable</s>,
    <s style="color: red">decentralized</s>,
    <span style="color: green">scalable</span>,
    <span style="color: green">expressive</span>
    🎯
</p>
<p align="center">
    💡
    <strong>Let's replicate Alice's account on ANY computer</strong>
    💡
</p>

### [Bitcoin](./bitcoin/README.md)

Bitcoin brings various computer science concepts together with [game theory](https://en.wikipedia.org/wiki/Game_theory) to create a truly peer-to-peer network and negates the need to delegate our trust to a central part.

The nodes trust the block producer based on its valid [proof of work](./bitcoin/proof_of_work) and the network collectively agrees on a set of canonical updates to the state of the Bitcoin ledger and the state of Alice's account.

```bash
# proof of work example
cd bitcoin/proof_of_work/go
go run main.go
```

The Bitcoin nodes themselves listen for and [validate](./bitcoin/block_verifcation) blocks of transactions that are broadcast to the network by the miner of that block. They form a data structure called a Merkle Tree to obtain a root hash corresponding to all the transactions (and their order) in that block. If one tx changes by even a single bit the merkle root will be completely different.

```bash
# block verification example
cd bitcoin/block_verification/go && go mod tidy
go run main.go utils.go
```

Alice's information gets formatted as a [UTXO](https://en.wikipedia.org/wiki/Unspent_transaction_output) and is replicated on all of the [nodes](https://bitnodes.io) on the Bitcoin network. She can even validate that everything is acurate herself by rehashing the merkle tree of every block of transactions from genesis to now.
<p align="center">
    🎉
    <strong>NO DELEGATION OF TRUST</strong>
    🎉
</p>
Let's revisit the trillemma. What did we giveup to get this trustless data security?

- Miners expend energy as they attempt to get the nonce
- Full trustless verification requires EACH node to replicate the canonical state:
  - hash the merkle tree of transactions
  - hash the block header

Full Node Size: ~405GB
  
For a naive demonstration of "The Evolution of Data Security" run the following:

```bash
cd bitcoin/block_verification/go && go mod tidy
go test ./... -bench=. -count 5
```

<p align="center">
    🎯
    <strong>Goals: </strong>
    <span style="color: green">secure</span>,
    <span style="color: green">inclusively accountable</span>,
    <span style="color: green">decentralized</span>,
    <s style="color: red">scalable</s>,
    <s style="color: red">expressive</s>
    🎯
</p>
<p align="center">
    💡
    <strong>Let's let Alice use her data</strong>
    💡
</p>

<h2 align="center" id="smart_contracts">Smart Contracts</h2>

Smart contracts were first proposed by [Nick Szabo](https://www.fon.hum.uva.nl/rob/Courses/InformationInSpeech/CDROM/Literature/LOTwinterschool2006/szabo.best.vwh.net/smart.contracts.html) as a transaction protocol that executes the terms of a contract, giving all parties transparency into the rule set and execution. Bitcoin facilitates a limited version of [smart contracts](https://ethereum.org/en/whitepaper/#scripting), but the expressive smart contract model of Ethereum has been more widely adopted.

<h2 align="center">Ethereum</h2>

Ethereum provides a platform to implement these smart contracts with the use of the [Ethereum Virtual Machine](./ethereum/ethereum_virtual_machine). In the Ethereum paradigm Alice's bank account information is stored in a 20-byte address called an [account](https://ethereum.org/en/whitepaper/#ethereum-accounts). Her account balance along with a few more fields (nonce, storageRoot, codeHash) become a "node" in a data structure called a Patricia Trie where PATRICIA stands for "Practical Algorithm to Retrieve Information Coded in Alphanumeric".

This `Trie` is a specific type of tree that encodes a `key` as a path of common prefixes to its corresponding `value`. So Alice's Bank Account can be found at an address("key") that points to an account ("value") in Ethereum's World State (trie). The tree structure of the trie allows us to obtain a cryptographic hash of each node all the way up to a single hash corresponding to the `root` similar to the Merkle tree we saw in the Bitcoin block verification.

For an example of the MPT data structure you can use this diagram for reference:

<div align="center">
    <img src="../misc/trie.png">
</div>

and run the following:

```bash
cd ethereum/block_verification/go && go mod tidy
go run *.go
```

Ethereum then propogates its state by verifying transactions are well-formed and applying then to accounts. Alice has a public/private key pair to manager her "externally owned account" and can sign transactions that involve her balance or involve interacting with other contracts in the state.

In addition to EOAs Ethereum has "contract accounts" which are controlled by the contract code associated with them. Everytime the contract account receives a message the bytecode that is stored as an [RLP encoded](https://eth.wiki/fundamentals/rlp) value in the account storage trie begins to execute according to the rules of the EVM.

Trillemma visit: what did we give up to add expressivity?

- Every transaction still needs to be processed by every node in the network.
- With the addition of world state storage the blockchain can "bloat" leading to centralization risk
- Alice may pay $100 to use the money in her account

Full Node Size: ~700 GB

Archive Node Size: ~10 TB

<p align="center">
    🎯
    <strong>Goals: </strong>
    <span style="color: green">secure</span>,
    <span style="color: green">inclusively accountable</span>,
    <span style="color: green">decentralized</span>,
    <s style="color: red">scalable</s>,
    <span style="color: green">expressive</span>
    🎯
</p>
<p align="center">
    💡
    <strong>Let's optimize Alice's data utility</strong>
    💡
</p>

<h2 align="center"> Rollups</h2>

As demand for block space increases the cost to execute on `Layer 1` (full consensus protocols e.g. Bitcoin, Ethereum) will become increasingly expensive, and until certain [state expiry mechanisms](https://notes.ethereum.org/@vbuterin/verkle_and_state_expiry_proposal) are implemented
we can expect the state of the L1 to continue to bloat over time. This will require increasingly robust machine to maintain the state
and subsequently verify the blocks.

Rollups are one solution in which business logic is executed and stored in a protocol outside the Ethereum context and then
proves its succesful execution in the Ethereum context.

Typically this involves compressing a larger number of transactions at this `Layer 2` and commiting the state diffs to a smart contract deployed on L1.
For full interoperability with the L1 rollups also typically implement a messaging component for deposits and withdrawls.

There are currently two types of rollups that are being widely adopted:

- Optimistic Rollups
- Zero-Knowledge Rollups

Vitalik provides a good comparison of the two [here](https://vitalik.ca/general/2021/01/05/rollup.html#optimistic-rollups-vs-zk-rollups), and touches on the final pieces of our long
trilemma journey:

***No matter how large the computation, the proof can be very quickly verified on-chain.***

This allows Alice to move her money freely between L1 and L2 (...soon to be L3) and operate on an low-cost, expressive blockchain layer.
All while inheritting the highest form of data security evolution from the L1 and not having to delegate trust to any centralized party!

<p align="center">
    🎯
    <strong>Goals: </strong>
    <span style="color: green">secure</span>,
    <span style="color: green">inclusively accountable</span>,
    <span style="color: green">decentralized</span>,
    <span style="color: green">scalable</span>,
    <span style="color: green">expressive</span>
    🎯
</p>

<p align="center">
    🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉🎉
</p>
