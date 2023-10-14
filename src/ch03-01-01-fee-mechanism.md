# Fee Mechanisms 
Including a fee system is a vital aspect of improving Starknet's performance. Without a small fee, we could end up with too many transactions, which would slow down the system, even with optimizations in place.

### Fee Collection

The fee is collected at the same time as the transaction is carried out on Layer 2 (L2). The Starknet operating system ensures that the fee, which matches the payment made, is transferred using ERC-20 tokens. The sender is the individual who submitted the transaction, while the sequencer is designated as the receiver of the fee.

## Fee Calculation

### Fee measurement
Currently, the fee is in ETH. Each transaction comes with a gas estimate, and by multiplying this with the gas price, we get the expected fee.

For example:
```
expected_fee = gas_estimate * gas_price;
```
### Fee Computation
Let's understand the following terms before understanding how computation is done.

1. Built-In: They are pre-defined operations that you can use in your code without having to create them from scratch. Builtins make it easier to perform common tasks or calculations, saving time and effort when writing programs.

    i. Cairo Steps: These are the building blocks of        computation in Cairo, responsible for                carrying out different operations within a          program. These steps are essential for              running smart contracts and applications on          blockchain platforms, and the total number of        steps used in a program can impact its cost          and efficiency.
    
   ii. Pedersen Hashes: Pedersen hashes are a way to turn data into a unique code, just like a fingerprint for information. They're used to ensure the security and integrity of data on blockchains and other computer systems.

   iii. Range Checks: Range checks are like safety limits in computer programs. They make sure that numbers or values used in a program stay within a specified range, preventing errors or unexpected behavior.
   
   iv. Signature Verifications: Signature verifications are akin to confirming that a digital signature on a message or transaction indeed matches the expected signature, ensuring the authenticity of the sender or entity involved.
  
2. Weight: Weight is a measure of how important or costly a specific operation is. It helps determine how much resources, like computation or gas, an operation consumes. Essentially, it tells you how "heavy" or significant an action is within the program.

### Computation
In Cairo, the execution trace is organized into separate slots, each dedicated to a specific built-in component. This slot allocation is essential in determining the fee.

Let's illustrate this with an example. Imagine a trace that involves 


| (up to) | (up to) | (up to) | (up to) |
| ------- | ------- | ------- | ------- |
| 200,000,000 Cairo Steps |5,000,000 Pedersen Hashes |1,000,000 Signature Verifications|2,500,000 Range Checks|

When any of these components reaches its limit, the proof is completed and sent to Layer 1. It's crucial to note that the division into built-in components must be decided in advance. We can't change it on the fly; for instance, we can't decide to have 5,000,001 Pedersen hashes and nothing else.

Suppose a transaction uses 10,000 Cairo steps and 500 Pedersen hashes. In this hypothetical trace, we can fit a maximum of 40,000 such transactions (20,000,000/500). Therefore, the gas price is determined by 1/40,000 of the proof submission cost. The number of Cairo steps is not the limiting factor in this case, so we didn't consider it in our performance estimation.

In a general scenario, the sequencer calculates a vector called CairoResourceUsage for each transaction. This vector includes:

1. The number of Cairo steps.
2. The number of applications of each Cairo built-in (e.g., range checks and Pedersen hashes).

The sequencer then combines this information with the CairoResourceFeeWeights vector. This vector specifies the relative gas cost of each component in the proof.

For example, 
> If the cost of submitting a proof with 20,000,000 Pedersen hashes is 5 million gas, the weight for the Pedersen built-in is 0.25 gas per application (5,000,000/20,000,000). The sequencer has predefined weight values in line with the proof parameters.

The fee is determined by the limiting factor, calculated as:
```
maxk[CairoResourceUsagek * CairoResourceFeeWeightsk]
```
Here, "k" represents the Cairo resource components, which include the number of steps and built-ins used. The weights for various components are as follows



| Steps       | Gas Cost       | Range         |
| --------    | --------       | --------      |
| Cairo Step  | 0.01 gwei/gas  |per step       |
| Pedersen    | 0.32 gwei/gas  |per application|
| Poseidon    | 0.32 gwei/gas  |per application|
| Range Check | 0.16 gwei/gas  |per application|
| ECDSA       | 20.48 gwei/gas |per application|
| Keccak      | 20.48 gwei/gas |per application|
| Bitwise     | 0.64 gwei/gas  |per application|
| EC_OP       | 10.24 gwei/gas |per application|