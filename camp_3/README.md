<div align="center">
    <h1>Camp 3: Deeper into StarkNet</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[StarkNet](https://drive.google.com/file/d/1_AQq4ulTmB0VAszmauvYUHEVjwdAgMim/view?usp=sharing)|StarkNet Basecamp [p1](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing), [p2](https://drive.google.com/file/d/185MMFmItlOE5qER8P2vhtVjKiH6Glj1G/view?usp=sharing)|[StarkNet Messaging Bridge](https://github.com/starknet-edu/starknet-messaging-bridge)|

</div>

### Topics

<ol>
    <li>Blocks</li>
    <li>The Lifecycle of Transactions</li>
    <li>Basics of Account Countracts</li>
    <li>StarkNet OS</li>
    <li>State Transition/Fees</li>
</ol>

<h2 align="center" id="blocks">Blocks</h2>

<h2 align="center" id="tx_lifecycle">The Lifecycle of Transactions</h2>

On StarkNet Alpha the two types of transactions are `DEPLOY` or `INVOKE`. They go through the following lifecycle as they are submitted from the clients to the sequencer:

<div align="center">
    NOT_RECEIVED -> RECEIVED -> PENDING -> REJECTED || ACCEPTED_ON_L2 -> ACCEPTED_ON_L1
</div>

<h2 align="center" id="accounts">Basics of Account Countracts</h2>

<h2 align="center" id="starknet_os">StarkNet OS</h2>

The StarkNet OS is the Cairo program that runs StarkNet. The OS handles everything which is done on the network — contract deployment, transaction execution, L1<>L2 messages and more.

<h2 align="center" id="state">State Transition/Fees</h2>

<hr>