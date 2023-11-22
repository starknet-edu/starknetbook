# Censorship Risk and Mitigation in Centralized Roll-ups

Starknet, as a yet centralized roll-ups, while offering Layer 1 (L1) security, face a notable downside: the risk of censorship. It's important to understand that StarkNet still maintains strong security features:

- **Security Inheritance**: StarkNet's state transitions inherit Ethereum's security.
- **State Recreation**: The state of StarkNet can be reconstructed using Ethereum's available data.

This means, while your assets are secure (i.e., they won't be stolen), there's a risk of transaction delays or non-execution, constituting censorship. StarkNet is at the early stages of its journey towards decentralization, with StarkWare currently operating all sequencer and prover nodes.

## Addressing Censorship

Currently all Starknet users trust Starkware to add their transactions to blocks and trust that they will not censor these transactions. But the StarkNet ecosystem aims to create a censorship-resistant network. This leads to two primary approaches:

1. **Decentralization**: The long-term goal is to increase the number of sequencers, diversifying entities validating the network. Although this doesn't completely eliminate censorship, it significantly reduces the risk.
2. **Escape Hatches**: Designed to ensure roll-ups remain censorship-resistant, allowing assets to be moved to Ethereum. This adds either protocol or application complexity and involves trade-offs.

## Ensuring Self-Custody and Asset Security

Ensuring self-custody in the face of potentially dishonest sequencers presents a significant challenge. Key questions include:

- **Handling Dishonest Sequencers**: If sequencers refuse to include transactions, how can we guarantee the security and autonomy of user assets?
- **Chain Interruptions**: What measures are in place if the chain stops producing blocks, leading to stranded assets?

These concerns underscore the importance of both decentralization and applicative escape hatches as vital mechanisms to safeguard user assets and maintain transaction integrity, even in scenarios of compromised sequencer integrity or chain functionality disruptions.

## Decentralization and Escape Hatches

### Decentralization

StarkNet is committed to decentralization as a key strategy for countering censorship. The plan involves expanding the number of sequencers, thereby diversifying the network's validators. With more validators, the risk of censorship decreases, though it's acknowledged that decentralization is a complex challenge, involving various incentives and strategic considerations. Despite its complexity, decentralization is not just a long-term goal but an essential immediate action. It's recognized as a crucial first step, though it might not be the complete solution to all issues.

Looking ahead to 2024, StarkNet's focus is on making the system operation as broad and permissionless as possible. The emphasis is not on resolving more subtle challenges like monopolies in searchers or builders at this stage. The primary objective is to remove operational barriers, enhancing accessibility and hopefully, this approach will significantly address the concerns around censorship.

    On the other side, a talked about topic are escape hatches.

---

    1. Escape Hatch:

    lets think about an apllication that does not want to be decentralize right of the way. In their priorities they have two things: 1) be able to claim they maintain self-custody of their funds and that they wont censor transactions and 2) to make money. These are very credible and common requirements by companies. The question, do they need to be decentralize from the get go in order to make money and claim censorship resistance? Notice that they need to start earning money as soon as possible, they are entrepreneurs that might not want to decentralize their applications: create a token, economic incentives, consensus mechanism, voting and so on. They are entrepreneurs and clients not necesarilly means they need to be your community. They will want full decentralization eventually but they need a solution in the meantime but at the same time they want to legally claim that they maintain self custody and for this they need to confirm they are implementing a solution to be censorship resistance. But consider the real case that clients might not look for decentralization.

    We are talking about Starknet Appchains, not the public Starknet layer 2 which is in its way to full decentralization. However, on the other side, notice that a escape hatch does not mean full decentralization. Only certain transactions are the ones that can be escaped from. In other words it is not that any aribitrary transactin can be escaped from. If you want to be full censorship resistance then you need all transactions to be non censaroable which is what we are looking for with decentralization. Supose the case of an exchange, for them the to crutial transactions to be non censraoble are trades and withdraws. Those are the msin things. The escpa hatch can handle those. Why not make the escape hatch able to escape all transactions? because the more transactions it handle the higher the risk the escape hatch can be hacked. You want your escape hatch to be secure. It has a attack surfface we want to limit their functionality to the minimum necessary. That is why having a generic escape hatch for a large network such as starknet would be really complex to build, however, we can have a escape hatch that with some tweaks is able to adapt itself to different types froo transactions.

    As an extension of what we believe in Starknet: In order to guarantee self custody of funds, thereby preventing censorship, for example StarkEx enables a user to perform a forced request at any point in time. The user initiates a forced request with an on-chain transaction. If you, the operator, do not serve the request within a specific time frame, the user can freeze the contract, and thus the exchange, and withdraw directly from the frozen contract.

    Currently the Starknet public network does not have escape hatches implementations neither the appchains that would conform the Layer 3s. However, possible implementations would likely be inspired by the already battle tested escape hatches in the StarkEx implementation. For example the implementation for a trading platform would support the following forced operations (source https://docs.starkware.co/starkex/spot/shared/README-forced-operations.html):

    * Full Withdrawal

    * Forced Trade

    The flow of the escape hatch is the following although they vary depending on the specific application StarkEx serves. However, in general, there are two possible flows, based on how you, the aplication, respond to the forced request:

    * Option 1: The application serves the forced operation.
    * Option 2: They do not serve the forced operation.

    The application sends the forced operation to StarkEx and StarkEx decides whether the on-chain request is valid based on the identity of the exact request and the business logic involved. Whether the request is valid or invalid, after the proof for this request is submitted, the request is removed from the pending forced operations area in the StarkEx contract, so it can no longer justify any future request to freeze the contract.

    If the application does not serve the forced operation. in other words, If the freeze grace period has passed, and the forced operation is still in the pending forced operations area, the user can call the freezeRequest function, with the public Stark key and the vault ID they used in the ignored forced operation.

    As a result, the exchange becomes frozen, and it can accept no further state updates. Withdrawals of on-chain funds are still possible.

    The following diagram illustrates the workflow.

    [IMAGE HERE]

    The same flow but in technical terms: The function fullWithdrawalRequest is a part of an anti-censorship mechanism that lets the user withdraw their funds. The user supplies the vault ID and the Stark key. Only the user to whom this Stark key belongs may submit this request. When this function is called, the event LogFullWithdrawalRequest (with the relevant starkKey, vaultId) is emitted.
    If the application fails to service the request, upon the expiration of a FREEZE_GRACE_PERIOD, the user is entitled to freeze the contract by calling freezeRequest.

    The user supplies the vaultId and the Stark key and indicating the vaultId for which the full withdrawal request has not been serviced. Once the contract is frozen, funds can be extracted using the escape operation. More details on the functions called here https://docs.starkware.co/starkex/spot/in-spot-trading-smart-contracts.html.


    Risks with escape hatches

    Escape hatches are delicate components and the less the number of transactions they cover the better. the most common attack a escape hatch could receive are Denial of Services Attacks (DoS). Where attackers spam the network with forced transactions not allowing the application to invalidate or validate all of them in time and thus reaching the freezing of the application. For this The Full Withdrawal function consumes a lot of gas and is expected to be used only as an anticensorship mechanism. This works to prevent spamming as much as possible. To avoid the potential attack of the application by a flood of full withdrawal requests, the rate of such requests must be limited. In the current implementation, this is achieved by making the request’s cost exceed 1M gas.

    A generic enough escape hatch is a really complicated task if we want to preserve security. This would work kind of for a public network like the whole starknet layer 2. However, once Starknet is fully decentralized the escape hatch would not be needed anymore (likely). However, for the appchains, the escape hatch would be needed. The escape hatch would be needed for the appchains because they might not be fully decentralized.

    Design for Appchains
    [image from slides]
    Since it is an appchain, they are running a sequencer. On the top right part of the slide you can see there is the starknet app chain. The network has two contracts: the Forc Tx Handler and the Balance Calculator. In the middle we have a Escape Tool using Madara and Stone.


    Lets see the different cases:
    A user wants to make a forced transaction (only two types: forced withdrawal or forced trade) to the transaction queue. They send the transaction trough the layer 1 so theoritically it can not be censored. The forced transaction queue stores the transaction and sends it as a L1 to L2 message.
    Then if the message is not consumed within for example 7 days the user uses the forced transaction queue to start a freeze to the Starknet Core contract. which means the L1 will not receiving any state updates from L2 anymore. So you have effectively frozen the application. This is a big penalty not serving the transaction in teh transaction queue from the appchain.
    Then the user suses an offchain tool taht is using madara sequcener and Stone prover. The Madara sequencer will sync up from the L1 from the last state update and then use the balance calculator contract which says how you calculate your remaining balance from the last state update. You can calulate your balance then create a proof using stone of funds whatever your balance is, gives it to the verifier whichverifies it, theen submit that proof to the verufier which will create a fact and then you can withdraw your money from the bridge. This only happens if the appchain is frozen. If the appchain is not frozen then you can not withdraw your money. This is the escape hatch for the appchain. Everyone can escape their funds from the frozen app.

# Handling Forced Transactions in Appchain

Forced transactions include two types: forced withdrawals and forced trades.

## Process Flow

1. **Initiating a Forced Transaction:**

   - The user sends a forced transaction (withdrawal or trade) through Layer 1 (L1), theoretically avoiding censorship.
   - The forced transaction queue receives and stores this transaction, then forwards it as an L1 to Layer 2 (L2) message.

2. **Transaction Queue and Starknet Core Contract:**

   - If the transaction remains unconsumed for a set period (e.g., 7 days), the user initiates a freeze on the Starknet Core contract via the forced transaction queue.
   - This freeze stops all state updates from L2 to L1, effectively freezing the application. It's a significant penalty for not processing transactions in the appchain's queue.

3. **Using Offchain Tools for Balance Calculation and Proof Submission:**

   - In case of a freeze, the user employs an offchain tool that uses the Madara Sequencer and Stone Prover.
   - The Madara Sequencer syncs up with the last L1 state update.
   - The user then utilizes the Balance Calculator Contract to determine their remaining balance from the last state update.
   - After calculating the balance, the user creates a proof of funds using Stone, which is verified by the verifier.
   - The verified proof is then submitted to the verifier, which generates a fact, allowing the user to withdraw funds from the bridge.

4. **Withdrawal Conditions:**
   - Withdrawals are only permissible if the appchain is frozen.
   - If the appchain is operational, fund withdrawal is not possible.
   - This mechanism serves as an escape hatch, enabling users to retrieve funds from a frozen appchain.

### Approaches to Ensuring Censorship Resistance

#### Decentralization as a Long-term Strategy

- **Goal:** Increase the number of sequencers to diversify network validation, substantially reducing censorship risks.
- **Challenge:** Achieving decentralization involves complex incentive structures and strategic planning.
- **2024 Focus:** StarkNet aims to make the operation of the system permissionless, inviting a wider range of participants and thereby reducing potential points of control or censorship.

#### Escape Hatches for Immediate Solutions

- **Purpose:** Provide a mechanism for users to transfer assets back to Ethereum in case of censorship or operational failures in StarkNet.
- **Design Considerations:** These mechanisms must balance between security and complexity, covering only essential transactions to mitigate risk.
- **Implementation Examples:** StarkEx showcases a model where users can initiate forced operations, such as Full Withdrawal or Forced Trade. If these requests are ignored, users can freeze the contract and withdraw assets directly.

## Escape Hatch Workflow in StarkEx Applications

The escape hatch flow in StarkEx applications varies, but generally follows two possible scenarios based on the application's response to a forced request:

- **Option 1**: The application serves the forced operation.
- **Option 2**: The application does not serve the forced operation.

This is the workflow:

1. **Initial Request**: The application sends the forced operation to StarkEx. StarkEx then assesses the on-chain request's validity based on the specific request identity and underlying business logic.

2. **Request Processing**:

   - If valid or invalid, once proof for this request is submitted, it's removed from the pending forced operations area in the StarkEx contract. This prevents it from justifying any future contract freeze requests.

3. **Non-Service of Operation**:

   - If the application doesn't serve the forced operation and the freeze grace period expires with the operation still pending, the user can activate the `freezeRequest` function using their public Stark key and the relevant vault ID from the ignored forced operation.

4. **Result of Freeze Request**:

   - Triggering this function freezes the exchange, halting state updates. Withdrawals of on-chain funds remain possible.

5. **Workflow Illustration**:
   - [IMAGE HERE]

Technically this is what happens:

- **`fullWithdrawalRequest` Function**: Part of an anti-censorship mechanism, it allows users to withdraw funds by providing their vault ID and Stark key. This request is exclusive to the Stark key owner.
  - On invocation, the event `LogFullWithdrawalRequest` is emitted with the relevant starkKey and vaultId.
- **Contract Freeze**: If the application fails to service the request within the `FREEZE_GRACE_PERIOD`, the user can freeze the contract by calling `freezeRequest`.

  - The user indicates the vaultId and Stark key for the unattended full withdrawal request. Once frozen, funds can be extracted using the escape operation.

- For more details on the functions involved, visit [Starkware Documentation](https://docs.starkware.co/starkex/spot/in-spot-trading-smart-contracts.html).

## Risks with Escape Hatches

- **Nature of Risk**: Escape hatches are sensitive components, best suited for a minimal number of transactions.
- **Common Attack - DoS**: Attackers may spam the network with forced transactions, preventing the application from processing them in time, leading to a freeze.
  - **Mitigation**: The Full Withdrawal function consumes substantial gas (over 1M) to deter spamming and is intended solely as an anti-censorship measure.

### Managing Risks in the Transition to Decentralization

StarkNet's journey involves carefully managing various risks:

- **Censorship Risks:** Centralized control of transaction processing can lead to censorship, which StarkNet aims to mitigate through decentralization and escape hatches.
- **Security Risks in Escape Hatches:** Escape hatches, while crucial for user autonomy, are susceptible to Denial of Service (DoS) attacks. StarkNet mitigates this by imposing high gas costs for operations like Full Withdrawal, deterring frivolous or malicious requests.
- **Complexity and User Experience:** Balancing the technical complexity of escape hatches and the user experience is critical. StarkNet's approach involves implementing mechanisms that are secure yet user-friendly, ensuring that users can exercise their rights without unnecessary complexity.

In conclusion, StarkNet's path towards a decentralized and censorship-resistant ecosystem involves addressing security challenges, implementing effective escape hatches, and carefully managing the transition to ensure user empowerment and network integrity.

## Case Study - FinTech Ventures Inc.

FinTech Ventures Inc., a fintech startup, offers a high-speed trading platform designed for professional traders and financial institutions. It stands out for its reliability, speed, and sophisticated features.

FinTech Ventures Inc. recognizes the benefits of decentralization but limits its engagement in the process. The company focuses on:

- **Self-Custody and Non-Censorship**: Ensuring platform users retain control over their funds and that transactions are uncensored.
- **Business Profitability**: As a startup, the priority is generating revenue and building a profitable business, rather than diverting resources to decentralize through token creation, economic incentives, or consensus mechanisms.

### Adopting Escape Hatches

In line with these priorities, FinTech Ventures Inc. implements escape hatches in their platform. This choice allows them to claim non-censorship and self-custody without fully embracing decentralization.

The escape hatch mechanism includes:

- **Forced Operations**: Supports critical operations like Full Withdrawal and Forced Trade, allowing users to maintain control over their assets.
- **Operation Flow**:
  - _Option 1_: User-initiated operations (e.g., withdrawals) are processed normally.
  - _Option 2_: If not processed timely, users can freeze the contract, halting all platform operations.
- **Security and Implementation**: Escape hatches are designed to focus on critical transactions, enhancing security and reducing attack risks.

## Risks and Mitigation

- **Denial of Service (DoS) Attacks**: The Full Withdrawal function requires high gas consumption to prevent frivolous requests.
- **Rate Limiting**: The platform limits the rate of full withdrawal requests to prevent system overload and maintain stability.

This way, FinTech Ventures Inc. effectively integrates escape hatches, balancing self-custody and non-censorship with business goals. This strategy enhances profitability and user satisfaction, while providing security and autonomy for users.

Imagine you're playing a game where you have a special mailbox (the application inbox on Layer 1, or L1). Now, your game (the Layer 2, or L2 contract) runs smoothly as long as this mailbox is empty. But if someone puts a letter (a pending transaction) in your mailbox and you don't deal with it, your game pauses. It's like a "freeze" button gets hit.

Your game knows when to pause because it's constantly getting little "hello" notes (keepalive messages) from your mailbox. If these notes stop coming, it means there's an unhandled letter waiting, and it's time to pause the game.

Sounds simple, right? But here's the catch. First, it makes the whole gaming system more complicated. Imagine every player's game could pause anytime. They would need to plan for this, making everything more complex. For example, if you're trading in-game items (like DAI contracts on Uniswap), and suddenly your game pauses, everyone else must adapt or pretend it didn't happen, ignoring the potential problem of being censored.

Secondly, this system works only if the person controlling the game (the operator) has your best interests at heart. What if they don't? Suppose a powerful player (like a law enforcement agency) tells the game controller to ignore your letter on purpose. Just by doing that, they can pause your game. So, it's not foolproof.

With Cairo 0 that was the mainw ay to create Starknet code until February 2023, you were not able to prove invalid transactions which makes them indistinguisahable from censored transactions. In other words: It is impossible to distinguish between censorship (when a sequencer purposefully decides not to include certain transactions) and invalid transactions since both types of transactions will not be included in blocks.

Soundness ensures that valid transactions are not rejected, preventing censorship. this is needed to be achieved or takled by starknet.
