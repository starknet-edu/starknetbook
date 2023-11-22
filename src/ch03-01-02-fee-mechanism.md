# Fee Mechanism

**NOTE: This section is a work in progress. Contributions are welcome.**

Implementing a fee system enhances Starknet's performance. Without fees, the system risks becoming overwhelmed by numerous transactions, even with optimizations.

## Fee Collection

When a transaction occurs on Layer 2 (L2), Starknet collects the corresponding fee using ERC-20 tokens. The transaction submitter pays the fee, and the sequencer receives it.

## Fee Calculation

### Fee Measurement

Currently, fees are denominated in ETH. To determine the expected fee, multiply the transaction's gas estimate by the gas price:

```
expected_fee = gas_estimate * gas_price;
```

### Fee Computation

To grasp fee computation, understand these terms:

- **Built-In**: These are predefined operations in your code, simplifying common tasks or calculations. The following are built-ins:

  - **Cairo Steps**: These building blocks in Cairo facilitate various program operations. Essential for running smart contracts and apps on blockchain platforms, the steps used influence a program's cost and efficiency.
  - **Pedersen Hashes**: A method to convert data into a distinct code, similar to a data fingerprint, ensuring data integrity on blockchains.
  - **Range Checks**: Safety measures in programs, ensuring numbers or values stay within designated limits to avoid errors.
  - **Signature Verifications**: These confirm that a digital signature matches the anticipated one, verifying the sender's authenticity.

- **Weight**: Indicates the significance or cost of an operation, showing how resource-intensive an action is in the program.

### Computation

In Cairo, each execution trace is divided into distinct slots dedicated to specific built-in components, influencing fee calculation.

Consider a trace containing the following component limits:

| Component               | Limit       |
| ----------------------- | ----------- |
| Cairo Steps             | 200,000,000 |
| Pedersen Hashes         | 5,000,000   |
| Signature Verifications | 1,000,000   |
| Range Checks            | 2,500,000   |

When a component reaches its maximum, the proof is sent to Layer 1. It's imperative to set these component divisions beforehand as they cannot be adjusted dynamically.

Assuming a transaction utilizes 10,000 Cairo steps and 500 Pedersen hashes, it could accommodate 40,000 such transactions in this trace (given the calculation 20,000,000/500). The gas price becomes 1/40,000 of the proof submission cost. In this instance, the number of Cairo steps isn't the constraining factor, so it isn't factored into our performance estimate.

Typically, the sequencer determines a vector, `CairoResourceUsage`, for every transaction. This vector accounts for:

1. The count of Cairo steps.
2. The application count of each Cairo built-in (like range checks and Pedersen hashes).

The sequencer then pairs this data with the `CairoResourceFeeWeights` vector, dictating the gas cost of each proof component.

For instance:

> If a proof with 20,000,000 Pedersen hashes costs 5 million gas, then the Pedersen built-in has a weight of 0.25 gas per use (calculated as 5,000,000/20,000,000). Sequencers set these weight values based on proof parameters.

The fee is determined by the most restrictive component and is calculated as:

```
maxk[CairoResourceUsagek * CairoResourceFeeWeightsk]
```

Where "k" denotes the Cairo resource elements, encompassing step numbers and built-ins. The weightings for these components are:

| Component   | Gas Cost       | Range           |
| ----------- | -------------- | --------------- |
| Cairo Step  | 0.01 gwei/gas  | per step        |
| Pedersen    | 0.32 gwei/gas  | per application |
| Poseidon    | 0.32 gwei/gas  | per application |
| Range Check | 0.16 gwei/gas  | per application |
| ECDSA       | 20.48 gwei/gas | per application |
| Keccak      | 20.48 gwei/gas | per application |
| Bitwise     | 0.64 gwei/gas  | per application |
| EC_OP       | 10.24 gwei/gas | per application |
