# Account Contracts

With a clearer understanding of the AA concept, let's proceed to code it in Starknet.

## Account Contract Interface

Account contracts, being a type of smart contracts, are distinguished by specific methods. A smart contract becomes an account contract when it follows the public interface outlined in SNIP-6 ([Starknet Improvement Proposal-6: Standard Account Interface](https://github.com/ericnordelo/SNIPs/blob/feat/standard-account/SNIPS/snip-6.md)). This standard draws inspiration from SRC-6 and SRC-5, similar to Ethereum's ERCs, which establish application conventions and contract standards.

```rust
/// @title Represents a call to a target contract
/// @param to The target contract address
/// @param selector The target function selector
/// @param calldata The serialized function parameters
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

/// @title SRC-6 Standard Account
trait ISRC6 {
    /// @notice Execute a transaction through the account
    /// @param calls The list of calls to execute
    /// @return The list of each call's serialized return value
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;

    /// @notice Assert whether the transaction is valid to be executed
    /// @param calls The list of calls to execute
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate__(calls: Array<Call>) -> felt252;

    /// @notice Assert whether a given signature for a given hash is valid
    /// @param hash The hash of the data
    /// @param signature The signature to validate
    /// @return The string 'VALID' represented as felt when the signature is valid
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

/// @title SRC-5 Standard Interface Detection
trait ISRC5 {
    /// @notice Query if a contract implements an interface
    /// @param interface_id The interface identifier, as specified in SRC-5
    /// @return `true` if the contract implements `interface_id`, `false` otherwise
    fn supports_interface(interface_id: felt252) -> bool;
}

```

From the proposal, an account contract should have the `__execute__`, `__validate__`, and `is_valid_signature` methods from the `ISRC6` trait.

The provided functions serve these purposes:

- `__validate__`: Validates a list of calls intended for execution based on the contract's rules. Instead of a boolean, it returns a short string like 'VALID' within a `felt252` to convey validation results. In Cairo, this short string is the ASCII representation of a single felt. If verification fails, any felt other than 'VALID' can be returned. Often, `0` is chosen.
- `is_valid_signature`: Confirms the authenticity of a transaction's signature. It takes a transaction data hash and a signature, and compares it against a public key or another method chosen by the contract's author. The result is a short 'VALID' string within a `felt252`.
- `__execute__`: After validation, `__execute__` carries out a series of contract calls (as `Call` structs). It gives back an array of `Span<felt252>` structs, showing the return values of those calls.

Moreover, the `SNIP-5` (Standard Interface Detection) trait needs to be
defined with a function called `supports_interface`. This function
verifies whether a contract supports a specific interface, receiving an
interface ID and returning a boolean.

```rust
    trait ISRC5 {
        fn supports_interface(interface_id: felt252) -> bool;
    }
```

In essence, when a user dispatches an `invoke` transaction, the protocol initiates by invoking the `__validate__` method. This verifies the associated signer's authenticity. For security reasons, particularly to safeguard the Sequencer from Denial of Service (DoS) attacks [1], there are constraints on the operations within the `__validate__` method. If the signature is verified, the method yields a `'VALID'` `felt252` value. If not, it returns 0.

After the protocol verifies the signer, it proceeds to invoke the `__execute__` function, passing an array of all desired operations—referred to as "calls"—as an argument. Each of these calls specifies a target smart contract address (`to`), the method to be executed (`selector`), and the arguments this method requires (`calldata`).

```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {

    ....

    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;

    ....

}
```

Executing a `Call` may yield a return value from the target smart contract. Whether it's a felt252, boolean, or a more intricate data structure like a struct or array, Starknet protocol serializes the return using `Span<felt252>`. Since `Span` captures a segment of an Array [2], the `__execute__` function outputs an array of `Span<felt252>` elements. This array signifies the serialized feedback from every operation in the multicall.

The `is_valid_signature` method isn't mandated or employed by the Starknet protocol. Instead, it's a convention within the Starknet developer community. Its purpose is to facilitate user authentication in web3 applications. For instance, consider a user attempting to log into an NFT marketplace using their digital wallet. The web application prompts the user to sign a message, then it uses the `is_valid_signature` function to confirm the authenticity of the associated wallet address.

To ensure other smart contracts recognize the compliance of an account contract with the SNIP-6 public interface, developers should incorporate the `supports_interface` method from the `ISRC5` introspection trait. This method requires the Interface ID of SNIP-6 as its argument.

```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    // Implementations for __execute__, __validate__, and is_valid_signature go here.
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}
```

The `interface_id` corresponds to the aggregated hash of the trait's selectors, as detailed in Ethereum's ERC165 [3]. Developers can either compute the ID using the `src5-rs` utility [4] or rely on the pre-calculated ID: `1270010605630597976495846281167968799381097569185364931397797212080166453709`.

The fundamental structure for the account contract, aligning with the SNIP-G Interface standard, looks like this:

```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(calls: Array<Call>) -> felt252;
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}
```

## Expanding the Interface

While the components mentioned earlier lay the foundation for an account contract in alignment with the SNIP-6 standard, developers can introduce more features to enhance the contract's capabilities.

For example, integrate the `__validate_declare__` function if the contract declares other contracts and handles the corresponding gas fees. This offers a way to authenticate the contract declaration. For those keen on counterfactual smart contract deployment, the `__validate_deploy__` function can be included.

Counterfactual deployment lets developers set up an account contract without depending on another account contract for gas fees. This method is valuable when there's no desire to link a new account contract with its deploying address, ensuring a fresh start.

This approach involves:

1. Locally determining the potential address of our account contract without actual deployment, feasible with the Starkli [5] tool.
2. Transferring sufficient ETH to the predicted address to cover the deployment costs.
3. Sending a `deploy_account` transaction to Starknet containing our contract's compiled code. The sequencer then activates the account contract at the estimated address, compensating its gas fees from the transferred ETH. No `declare` action is needed beforehand.

For better compatibility with tools like Starkli later on, expose the signer's `public_key` through a view function in the public interface. Below is the augmented account contract interface:

```rust
/// @title IAccountAddon - Extended account contract interface
trait IAccountAddon {
    /// @notice Validates if a declare transaction can proceed
    /// @param class_hash Hash of the smart contract under declaration
    /// @return 'VALID' string as felt, if valid
    fn __validate_declare__(class_hash: felt252) -> felt252;

    /// @notice Validates if counterfactual deployment can proceed
    /// @param class_hash Hash of the account contract under deployment
    /// @param salt Modifier for account address
    /// @param public_key Account signer's public key
    /// @return 'VALID' string as felt, if valid
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;

    /// @notice Fetches the signer's public key
    /// @return Public key
    fn public_key() -> felt252;
}
```

In conclusion, a comprehensive account contract incorporates the **SNIP-5**, **SNIP-6**, and the Addon interfaces.

```rust
// Cheat sheet

struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(calls: Array<Call>) -> felt252;
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}

trait IAccountAddon {
    fn __validate_declare__(class_hash: felt252) -> felt252;
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;
    fn public_key() -> felt252;
}

```

## Recap

We've broken down the distinctions between account contracts and basic smart contracts, particularly focusing on the methods laid out in SNIP-6.

- Introduced the `ISRC6` trait, spotlighting essential functions:

  - `__validate__`: Validates transactions.
  - `is_valid_signature`: Verifies signatures.
  - `__execute__`: Executes contract calls.

- Discussed the `ISRC5` trait and highlighted the importance of the `supports_interface` function in confirming interface support.

- Detailed the `Call` struct to represent a single contract call, explaining its components: `to`, `selector`, and `calldata`.

- Touched on advanced features for account contracts, such as the `__validate_declare__` and `__validate_deploy__` functions.

Coming up, we'll craft a basic account contract and deploy it on Starknet, offering hands-on insight into their functionality and interactions.
