<div align="center">
    <h1>Camp 5: Peering into the Future</h1>

|Presentation|Video|Workshop|
|:----:|:----:|:----:|
|[B E Y O N D](https://drive.google.com/file/d/1LOvpX8mXvXIXaj2eybQz6ZvnvtkiTi8n/view?usp=sharing)|[video](https://drive.google.com/file/d/1o8vbsAWQs0VndlUWhmsKckdyNr7HYeCx/view?usp=sharing)| local meetups/mentoship |

</div>

### Topics

<ol>
    <li><a>Data Availability</a></a>
    <li><a>Recursion</a></a>
    <li><a>Throughput</a></a>
    <li><a>Decentralization</a></a>
    <li><a>Building Community</a></a>
</ol>

<h2 align="center" id="data_availability">Data Availability</h2>

The data availability problem:

- STARK proofs generate a proof of computation
  - ex: valid execution from genesis to block 100
- you don't need the output of the program to validate the program ran correctly
  - ex: state of block 100
- my contract logic requires the state of block 100
  - ex: if we don't have the state of block 100 "stored" somewhere our contract is essentially stuck

***Solution: Validity Rollup - store the state on secure L1***

- current state of StarkNet
- periodically store the rollup state to Ethereum
- inherit the security of the base chain

***Solution: Validium - store data "off chain"***

- IPFS, Celestia, cloud providers
- can secure with a Data Availablility Committee(DAC)
- data can be private
- less expensive

***Solution: Volition - hybrid***

- single chain can dynamically chose where data is stored
- application flexibility
- composability implications

<div align="center">
    <h2 id="recurison">Recursion</h2>

[video](https://www.youtube.com/watch?v=hjTCIT9BGkA), [slides](https://docs.google.com/presentation/d/e/2PACX-1vRbnDDuGdjcMaUAg1rRztGsLpGhtPsMX1vCKk-sX4v0cHMZdOMWZh177qXYM8lacqGoSJ4X8NvEg8RX/pub?slide=id.g12fb33eb0c0_0_386)
</div>

Ability to verify a proof within a cairo program:

- Prover generates a proof of computation in `time T`
- Verifier uses proof to check the correctness of the compuation in `log(T)`

Enables the parallelization of proofs.

<h2 align="center" id="throughput">Throughput</h2>

### Parallelization

- access lists

### Compiler/VM Rust Rewrite

### Fractal Scaling

<h2 align="center" id="decentralization">Decentralization</h2>

StarkNet continues to evolve, and we gradually shift our gaze towards decentralization. While we expect StarkNet to be decentralized only at the end of the year, it’s not too early to decide on the decentralization scheme.

While every other decentralized network has only Sequencers, StarkNet has two components: Sequencers (that determine which transactions to execute) and Provers (that prove the correctness of the chosen transactions). A good decentralization approach is required to decentralize the Provers and answer questions like “who can publish proofs” or even “when do we publish proofs”? However, an approach that says: “let’s take some consensus algorithm for sequencing, and demand each sequencer to prove what he sequenced” is too naive and creates what we refer to as the "handoff problem.”

***Design Goals:***

`Permissionlessness` - anyone can be a Sequencer or a Prover (given they invest enough resources to it).

`Assuming rationality, not honesty` - Since anyone can participate, the protocol can’t assume parties blindly follow the protocol and enforce correct behavior by explicit checks and economic incentivization.

`Sufficiently Scalable` - the protocol should scale reasonably well, up until a point where we have a reasonably large number of participants. It’s hard to determine what number is “reasonably large.”

`Strong and Fast L2 Finality` - StarkNet state becomes final only after a batch is proven to L1 (which might take as long as several hours today). Therefore, the L2 decentralization protocol should make meaningful commitments regarding the planned execution order well before the next batch is proved.

`Inexpensive` - the users shouldn’t pay excessively high transaction fees to sponsor the work done by the entities (Sequencers and Provers) that run the StarkNet consensus protocol.

`Lightweight` - We want to leave most of StarkNet computational “real estate” for the applicative layer of StarkNet. As an extreme counterexample, a situation where 50% of the Cairo steps proven in each block are dedicated to verifying the consensus protocol itself is wasteful and does not make sense.

<h2 align="center" id="community">Building Community</h2>

It's all about relationships and the goal is to focus on the builders, not what is being built. Your objective is to plant the seed and let it grow:

- Involve community members early
- Lets them take the lead, even if they do things differently
- Focus on builders and not investors
- Make concrete call to actions

<h3>Organizing Meetups</h3>

Organizing a meetup is surprisingly time consuming you’ll probably have to do the first one on your own.

Call for volunteers at the beginning at the end. When growing this group, ask for suggestions and ideas openly.
When decisions drag on, step in to move the ball forward.

Steps:

- Register on meetup.com: ask us to create a group so you don't have to pay
- Pick a date(2-3 weeks in advance)
- Tweet about it, and we'll relay
- Find a venue, check equipment, plan for food and drinks
- Define Program
  - 3 talks, 15-20min each
  - We can present remotely if you want
  - We can connect you to local builders, or fly some to present!
- We’ll send you swag
- We sponsor meetups with 1k USD to cover costs, ask for it

<h3>Running Workshop</h3>
Send a survey after your first meetup, with a form asking if people are interested in technical workshops.

Types of workshops

- 0 to 1
- Thematic (ERC20, ERC721)

Define Program (2-3h):

- Introduction 20-30mn
- Then people work
- Co education is a great tool
- Have people work in pair, 2 behind a single screen
- If a question is recurrent, say “ask these girls they solved it”
- Follow our repo to check new workshops
- Try to do them once before
- If you are looking for a specific theme, ask us
- Better yet, write your own

#### Sources

[<https://community.starknet.io/t/starknet-decentralization-kicking-off-the-discussion/711>]
