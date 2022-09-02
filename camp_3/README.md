<div align="center">
    <h1>Camp 3: StarkNet</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[StarkNet](https://drive.google.com/file/d/1_AQq4ulTmB0VAszmauvYUHEVjwdAgMim/view?usp=sharing)|StarkNet Basecamp [p1](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing), [p2](https://drive.google.com/file/d/185MMFmItlOE5qER8P2vhtVjKiH6Glj1G/view?usp=sharing)|[StarkNet Messaging Bridge](https://github.com/starknet-edu/starknet-messaging-bridge)|

</div>

### Topics

<ol>
    <li>Blocks</li>
    <li>TX Lifecycle</li>
    <li>StarkNet Contracts</li>
    <li>Storage</li>
    <li>Accounts</li>
    <li>StarkNet OS</li>
    <li>State Transition/Fees</li>
</ol>

<h2 align="center" id="blocks">Blocks</h2>

<h2 align="center" id="tx_lifecycle">TX Lifecycle</h2>

On StarkNet Alpha the two types of transactions are `DEPLOY` or `INVOKE`. They go through the following lifecycle as they are submitted from the clients to the sequencer:

<div align="center">
    NOT_RECEIVED -> RECEIVED -> PENDING -> REJECTED || ACCEPTED_ON_L2 -> ACCEPTED_ON_L1
</div>

<h2 align="center" id="starknet_contracts">StarkNet Contracts</h2>

Contracts on StarkNet are written in Cairo or can be transpiled to Cairo from Solidity code via [Warp](https://github.com/NethermindEth/warp). We will be building more sophisticated smart contracts in the next camps, for now let's compile and deploy our simple examples:

***Cairo***

```bash
cd contracts/cairo
starknet-compile ../counter.cairo --output counter_compiled.json --abi counter_abi.json
starknet deploy --contract counter_compiled.json
```

***Solidity***

```bash
cd contracts/solidity
warp transpile ERC20.sol WARP
warp deploy ERC20.json
```

`UNDER CONSTRUCTION`:

While this section is being built we recommend reading the video session for this camp and the [starknet docs](https://docs.starknet.io).

<hr>

<h2 align="center" id="storage">Storage</h2>

<h2 align="center" id="accounts">Accounts</h2>

<h2 align="center" id="starknet_os">StarkNet OS</h2>

The StarkNet OS is the Cairo program that runs StarkNet. The OS handles everything which is done on the network — contract deployment, transaction execution, L1<>L2 messages and more.

<h2 align="center" id="state">State Transition/Fees</h2>

<hr>

#### Sources

[<https://github.com/eqlabs/pathfinder/blob/2fe6f549a0b8b9923ed7a21cd1a588bc571657d6/crates/pathfinder/resources/fact_retrieval.py>]
