<h1 align="center">Primer</h1>

### Topics
1. [Bitcoin](./bitcoin/README.md)
2. [Smart Contracts](#smart_contracts)
3. [Ethereum](./ethereum/README.md)
4. [Rollups](./rollups/README.md)

<h2 align="center"> Overview <br><a href="https://docs.google.com/presentation/d/1-ykeFFRwI2JTIyXAKd2AmVSIUnbjPk7EdfpHxL3CxYs/edit?usp=sharing">(slides, </a><a href="https://www.youtube.com/watch?v=DrBJ9LWvsOQ">video)</a></h2>
This primer is not only designed to cover introductory concepts upon which Cairo and StarkNet are built, but also to help you get acquainted with the format of the course. Each section will involve drilling down on a high-level concept as it pertains to StarkNet or Cairo until we hit an "atomic" or irreducible concept we can represent in a simple/runnable code example: 

<div align="center">
    <img src="../misc/plat.png">
</div>

These code examples will be named by the programming language in which they are implemented, for example bitcoin block verification in Golang:
<div align="center">
    <a href="./bitcoin/block_verification/go">bitcoin/block_verification/go</a>
</div>

The topics covered in this primer have been disected in hundreds of ways by thousands of people, so wherever possible I will be linking to those resources and not reinventing the circle thingy. The text you find in this repo will therefore be dedicated to how these concepts interplay with Cairo and StarkNet.

<div align="center">
    <em>Standing on the shoulders of giants blah blah blah lets get to the good stuff</em>
</div>

<h3 align="center"> What are we solving for?</h3>
The advent of blockchain technology has given the world computational systems with absolute transparency and inclusive accountabiliy. In order to obtain these characteristics these systems have typically given up scalability(usability). Vitalik Buterin, summed up this issue in "The Blockchain Trilemma" stating: blockchains are forced to make trade-offs that prevent them from being decentralized, scalable, and secure.

There have been many attempts at solving the trilemma and there will be many more. In this course you will learn how StarkWare attempts to tackle the trillemma and provide a system that is inclusively accountable, decentralized, scalable, and secure through the use of zero-knowledge STARK proofs.
<p align="center">🎯<strong>Goals: </strong>secure, inclusively accountable, decentralized, scalable, expressive🎯</p>

<h2 align="center"> Evolution of Data Security</h2>
<div align="center">
    <img src="../misc/evolution.png">
</div>

For a more concrete example of the trillemna we can extrapolate outside of blockchains entirely. Say we have an important piece of data we need access to. To start we will represent it as ascii characters in YAML format:
```
alice_account: 5.00
```
Let's write it to file on our computers disk and measure performance:
```
time echo "alice_account: 5.00" >> bank.yaml
```
Let's read that information:
```
time cat bank.yaml
```

It is obviously very fast to read and write this data to your disk, and [complex business logic](https://www.postgresql.org/) can be optimized on your disk, BUT let's say you get your disk too close to a large ACME magnet. Alice can say bye bye to all her valuable bank account information.
<p align="center">🎯<strong>Goals: </strong><s style="color: red">secure</s>, <s style="color: red">inclusively accountable</s>, <s style="color: red">decentralized</s>, <span style="color: green">scalable</span>, <span style="color: green">expressive</span>🎯</p>
<p align="center">💡<strong>Let's replicate Alice's account on another computer</strong>💡</p>

Sender Questions:
- How do I locate a recieving host to send to?
- How do I know recieving host successfully wrote Alice's account data?
- How do I know the recieving host wrote the value accurately?
- If I change Alice's account value how will the recieving host know to update the same value?

Reciever Questions:
- Who will I recieve data from?
- How will I know when a value has been updated?
- If I change Alice's account value how will the sending host know to update the same value?

### Distributed Systems
These problems form the basis of distributed systems and distributed computing across a network, and have been studied since the inception of the internet.

Let's look briefly at how one of the more popular distributed databases [CassandraDB](https://cassandra.apache.org/doc/latest/cassandra/getting_started/configuring.html) handles these issues. *Note: when configuring the system we whitelist the `seed nodes` that will make up our trusted cluster that partake in a limited peer-to-peer [gossip](https://www.linkedin.com/pulse/gossip-protocol-inside-apache-cassandra-soham-saha).*
<br>
Once the distributed database is setup we have "Fault Tolerance" for our valuable piece of data `alice_account: 5.00`. If someone accidently brings their large ACME magnet into one datacenter, we have our data easily accesible on another host. Blockchains are not the only systems that make trade-offs, so what did we give up for this new fault tolerance?

Banks Perspective:
- Network overhead impacts performace
- Redundancy and replication impacts performace
- We need to maintain muliple hosts($$$$)

Alice's Perspective:
- Alice delegates her trust to the bank that the database is configured correctly
- Alice delegates her trust to the bank that the database has enough capacity
- Alice delegates her trust to the bank that the banks operational security can handle attackers or intruders
- Alice delegates her trusts to the bank that it's not doing anything duplicitous
- Costs typically get passed to Alice

<p align="center">🎯<strong>Goals: </strong><span style="color: yellow">secure</span>, <s style="color: red">inclusively accountable</s>, <s style="color: red">decentralized</s>, <span style="color: green">scalable</span>, <span style="color: green">expressive</span>🎯</p>
<p align="center">💡<strong>Let's replicate Alice's account on ANY computer</strong>💡</p>

### [Bitcoin](./bitcoin/README.md)
In order to avoid the delegation of trust as we do in traditional systems Bitcoin brings various computer science concepts together with [game theory](https://en.wikipedia.org/wiki/Game_theory) to create a truly peer-to-peer network. Alice's information gets formatted as a [UTXO](https://en.wikipedia.org/wiki/Unspent_transaction_output) and is stored by all of the [nodes](https://bitnodes.io) on the Bitcoin network.

The nodes themselves listen for and [validate](./bitcoin/block_verifcation) blocks of transactions that are broadcast to the network by the miner of that block. The nodes trust the miner based on their valid [proof of work](./bitcoin/proof_of_work) and the network collectively agrees on a set of canonical updates to the state of the Bitcoin ledger and the state of Alice's account.
Alice's valuable information is now replicated on thousands of machines across the globe, and she can validate that everything is acurate herself by rehashing the merkle tree of every block of transactions from genesis to now.
<p align="center">🎉<strong>NO DELEGATION OF TRUST</strong>🎉</p>
Let's revisit the trillemma. What did we giveup to get this trustless data security?

- miners expend energy as they attempt to get the nonce
- for full trustless verification EACH node must replicate the canonical state by
  - hashing the merkle tree of transactions
  - hashing the block header
  - store the entirety of every block(5-11-22 ~405GB)
  
For a naive demonstration of "The Evolution of Data Security" run the following([to install go](https://go.dev/doc/install)):
```
cd bitcoin/block_verification
GO111MODULE=off go test ./... -bench=. -count 5
```

<p align="center">🎯<strong>Goals: </strong><span style="color: green">secure</span>, <span style="color: green">inclusively accountable</span>, <span style="color: green">decentralized</span>, <s style="color: red">scalable</s>, <s style="color: red">expressive</s>🎯</p>
<p align="center">💡<strong>Let's let Alice use her data</strong>💡</p>

<h2 align="center" id="smart_contracts">Smart Contracts</h2>

Smart contracts were first proposed by [Nick Szabo](https://www.fon.hum.uva.nl/rob/Courses/InformationInSpeech/CDROM/Literature/LOTwinterschool2006/szabo.best.vwh.net/smart.contracts.html) as a transaction protocol that executes the terms of a contract, giving all parties transparency into the rule set and execution. Bitcoin facilitates a limited version of [smart contracts](https://ethereum.org/en/whitepaper/#scripting), but the expressive smart contract model of Ethereum has been more widely adopted.
<br>
In our evolution of data security this gives utility to the already secure data of Alice's bank account. Alice would be able interact with a smart contract to read and approve the terms of a loan against her "bank account" and she is the only entity that can control/approve those terms.  

<h2 align="center">Ethereum</h2>

Ethereum offers a platform to implement these smart contracts with the use of the [Ethereum Virtual Machine](./ethereum/ethereum_virtual_machine). In the ethereum paradigm Alice's bank account information is stored in a 20-byte address called an [account](https://ethereum.org/en/whitepaper/#ethereum-accounts). Transaction then update the canonical state by interacting with these accounts. Since the accounts are smart contracts executing code each transaction specifies a limit on how many computational steps of code execution it can use. The fundamental unit of computation is gas and a computational step usually costs 1 gas. There is a 5 gas fee for every byte in the transaction data. Contracts can send [messages](https://ethereum.org/en/whitepaper/#messages). 

trillemma visit: what did we give up to add expressivity?
- Although Ethereum full nodes can simply store the state instead of the entire blockchain history, every transaction still needs to be processed by every node in the network.
- Centralization risk if the blockhain size gets too large, only those with access to large machines can maintain an accurate record

Full Node Size: 700 GB
Archive Node Size: 10 TB

<p align="center">🎯<strong>Goals: </strong><span style="color: green">secure</span>, <span style="color: green">inclusively accountable</span>, <span style="color: green">decentralized</span>, <s style="color: red">scalable</s>, <span style="color: green">expressive</span>🎯</p>
<p align="center">💡<strong>Let's optimize Alice's data utility</strong>💡</p>

<h2 align="center"> Rollups</h2>


<p align="center">🎯<strong>Goals: </strong><span style="color: green">secure</span>, <span style="color: green">inclusively accountable</span>, <span style="color: green">decentralized</span>, <span style="color: green">scalable</span>, <span style="color: green">expressive</span>🎯</p>
