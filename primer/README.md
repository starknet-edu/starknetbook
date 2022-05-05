<h1 align="center">Primer</h1>

### Tenets
1. [Bitcoin](./bitcoin/README.md)
2. [Ethereum](./ethereum/README.md)
3. [Smart Contracts](./smart_contracts/README.md)
4. [Rollups](./rollups/README.md)

<h2 align="center"> Overview <br><a href="https://docs.google.com/</h3>presentation/d/1-ykeFFRwI2JTIyXAKd2AmVSIUnbjPk7EdfpHxL3CxYs/edit?usp=sharing">(slides)</a><a href="https://www.youtube.com/watch?v=DrBJ9LWvsOQ">(video)</a></h2>
This primer is not only designed to cover introductory concepts upon which Cairo and StarkNet are built, but also to help you get acquainted with the format of the course. 

Each section will involve drilling down on a high level concept as it pertains to StarkNet or Cairo until we hit an "atomic" or irreducible concept we can represent in a simple/runnable code example: 

<div align="center">
    <img src="../misc/plat.png">
</div>

These code examples will be named by the programming language in which they are implemented, for example bitcoin block verification in Golang:
<div align="center">
    <a href="./bitcoin/block_verification/go">./bitcoin/block_verification/go</a>
</div>

The topics covered in this primer have been disected in hundreds of ways by thousands of people, so wherever possible I will be linking to those resources and not reinventing the circle thingy. The text you find in this repo will therefore be dedicated to how these concepts interplay with Cairo and StarkNet.

<div align="center">
    <em>Standing on the shoulders of giants blah blah blah lets get to the good stuff</em>
</div>

<h3 align="center"> What are we solving for?</h3>
The advent of blockchain technology has given the world distributed systems with absolute transparency and inclusive accountabiliy.
The price these systems have paid is scalability(usability) due to "The Blockchain Trilemma". Blockchains are forced to make trade-offs that prevent them from being decentralized, scalable, and secure.
There have been many attempts at solving the trilemma and there will be many more. In this course you will learn how StarkWare attempts to tackle the trillemma and provide a system that is inclusively accountable, decentralized, scalable, and secure through the use of zero-knowledge SNARK proofs.

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

It is obviously very fast to read and write this data to your disk, and [complex business logic](https://www.postgresql.org/) can be optimized on your disk. BUT let's say you get your disk too close to a big ACME magnet, you can say bye bye Alice's bank account information.
<p align="center">💡<strong>Let's replicate Alice's account on another computer</strong>💡<br>After all how many big ACME magnets can there really be?</p>

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
Once the distributed database is setup we have "Fault Tolerance" for our valueble piece of data `alice_account: 5.00`. If someone accidently brings their big ACME magnet into one datacenter, we have our data easily accesible on another host. Blockchains are not the only systems that make trade-offs, so what did we give up for this new fault tolerance?

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

<p align="center">💡<strong>Let's replicate Alice's account on ANY computer</strong>💡</p>

### [Bitcoin](./bitcoin/README.md)
In order to avoid the delegation of trust as we do in traditional systems Bitcoin brings various computer science concepts together with [game theoretics](https://en.wikipedia.org/wiki/Game_theory) to create a truly peer-to-peer network. Alice's information gets formatted as a [UTXO](https://en.wikipedia.org/wiki/Unspent_transaction_output) and is stored by all of the [nodes](https://bitnodes.io) on the Bitcoin network.

The nodes themselves listen for and [validate blocks and transactions](./bitcoin/proof_of_work) broadcast to the network by the miner who mined that block. The nodes trust the miner based on their valid [proof of work](./bitcoin/proof_of_work).
Alice's valueble information is now replicated on thousands of machines across the globe, and she can validate that everything is acurate herself.
<p align="center">🎉<strong>NO DELEGATION OF TRUST</strong>🎉</p>
Let's revisit the trilemna. What did we giveup to get this trustless data security?

- miners expend energy as they attempt to get the nonce
- for full trustless verification EACH node must replicate the state by
  - hashing the merkle tree of transactions
  - hashing the block header
  
For a naive demonstration of "The Evolution of Data Security" run the following([to install go](https://go.dev/doc/install)):
```
cd bitcoin/block_verification
curl https://blockchain.info/rawblock/0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947 > rawBTCBlock.json
GO111MODULE=off go test ./... -bench=. -count 5
```

<h2 align="center"> Smart Contracts</h2>

Smart Contracts were first proposed by [Nick Szabo](https://www.fon.hum.uva.nl/rob/Courses/InformationInSpeech/CDROM/Literature/LOTwinterschool2006/szabo.best.vwh.net/smart.contracts.html) as a transaction protocol that executes the terms of a contract, giving all parties transparency into the rule set and execution. Bitcoin facilitates a limited version of [smart contracts](https://ethereum.org/en/whitepaper/#scripting), but the expressive smart contract model of Ethereum has been more widely adopted.
<br><br>
To extend our previous example. Let's say "The Bank" wants to create applications surrounding things like payment terms, liens, and even enforcement.
This traditionally will be engineered by a development team(either in-house or outsourced), to implement the business logic in any number of programming languages and will enact state changes on the distributed database described above.
The trust delegation issues outlined above not only still remain, but their is no transparency into how this business logic is implemented or maintained.

### [Ethereum](./ethereum/README.md)
