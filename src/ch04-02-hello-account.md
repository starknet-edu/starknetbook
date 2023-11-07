# Hello World! Account Contract

This section guides you through the creation of an account contract, adhering to the SNIP-6 and SRC-5 standards.

## Setting Up Your Project

For deploying an account contract to Starknet's testnet or mainnet, use Scarb version 2.3.1, which is compatible with the Sierra 1.3.0 target supported by both networks. For the latest information, review the [Starknet Release Notes](https://docs.starknet.io/documentation/starknet_versions/version_notes/). As of November 2023, Scarb version 2.3.1 is the recommended choice.

To check your current Scarb version, run:

```bash
scarb --version
```

To install or update Scarb, refer to the Basic Installation instructions in Chapter 2, covering macOS and Linux environments:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

## Starting a New Scarb Project

Begin by creating a new project (more details in the Scarb subchapter in Chapter 2):

```bash
scarb new aa
```

Check the generated project structure:

```bash
$ tree .
.
└── aa
    ├── Scarb.toml
    └── src
        └── lib.cairo
```

By default, Scarb sets up for vanilla Cairo. Add Starknet capacities by editing `Scarb.toml` to include the `starknet` dependency:

```bash
[package]
name = "aa"
version = "0.1.0"
cairo-version = "2.3.0"

[dependencies]
starknet = ">=2.3.0"

[[target.starknet-contract]]
sierra = true
casm = true
```

Replace the code in `src/lib.cairo` with an account contract scaffold:

```rust
#[starknet::contract]
mod Account {

    #[storage]
    struct Storage {
        public_key: felt252
    }
}
```

To validate signatures, store the public key associated with the signer's private key.

```rust
#[storage]
struct Storage {
    public_key: felt252
}
```

Compile your project to ensure the setup is correct:

```bash
scarb build
```

## Implementing SNIP-6 Standard

To define an account contract, implement the `ISRC6` trait:

```rust
trait ISRC6 {
  fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(calls: Array<Call>) -> felt252;
  fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}
```

The `#[external(v0)]` attribute marks functions with unique selectors for external interaction. The Starknet protocol exclusively uses `__execute__` and `__validate__`, whereas `is_valid_signature` is available for web3 applications to validate signatures.

The `trait IAccount<T>`\*\* with `#[starknet::interface]` attribute groups publicly accessible functions, like `is_valid_signature`. Functions `__execute__` and `__validate__`, though public, are accessible only indirectly.

```rust
use starknet::account::Call;

#[starknet::interface]
trait IAccount<T> {
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}

#[starknet::contract]
mod Account {
  use super::Call;

  #[storage]
  struct Storage {
    public_key: felt252
  }

  #[external(v0)]
  impl AccountImpl for super::IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 { ... }
  }

  // These functions are protocol-specific and not intended for direct external use.
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl for ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> { ... }
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 { ... }
  }
}
```

## Restricted Function Access for Security

The `__execute__` and `__validate__` functions are designed for exclusive use by the Starknet protocol to enhance account security. Despite their public accessibility, only the Starknet protocol can invoke these functions, identified by using the zero address.

```rust
#[starknet::contract]
mod Account {
  use starknet::get_caller_address;
  use zeroable::Zeroable;

  // Enforces Starknet protocol-only access to specific functions
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // Executes protocol-specific operations
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol(); // Verifies protocol-level caller
      // ... (implementation details)
    }

    // Validates protocol-specific operations
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol(); // Verifies protocol-level caller
      // ... (implementation details)
    }
  }

  // Defines a private function to check for protocol-level access
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    fn only_protocol(self: @ContractState) {
      // ... (access validation logic)
    }
  }
}
```

## Enhanced Security Through Protocol-Exclusive Functions

Starknet enhances the security of accounts by restricting the callability of certain functions. The `__execute__` and `__validate__` functions, though publicly visible, are callable solely by the Starknet protocol. This protocol asserts its unique calling rights by using a designated zero address—a special value that signifies protocol-level operations.

```rust
#[starknet::contract]
mod Account {
  use starknet::get_caller_address;
  use zeroable::Zeroable;

  // Implements function access control for Starknet protocol
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // The __execute__ function is a protocol-exclusive operation
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol(); // Validates the caller as the Starknet protocol
      // ... (execution logic)
    }

    // The __validate__ function ensures the integrity of protocol-level calls
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol(); // Ensures the caller is the Starknet protocol
      // ... (validation logic)
    }
  }

  // A private function, only_protocol, to enforce protocol-level access
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // only_protocol checks the caller's address against the zero address
    fn only_protocol(self: @ContractState) {
      // If the caller is not the zero address, access is denied
      // This guarantees that only the Starknet protocol can call the function
      // ... (access control logic)
    }
  }
}
```

The `is_valid_signature` function, by contrast, is not bounded by `only_protocol`, maintaining its availability for broader use.

## Transaction Signature Validation

To verify transaction signatures, the account contract stores the public key of the signer. The `constructor` method initializes this public key during the contract's deployment.

```rust
#[starknet::contract]
mod Account {
  // Persistent storage for account-related data
  #[storage]
  struct Storage {
    public_key: felt252  // Stores the public key for signature validation
  }

  // Sets the public key during contract deployment
  #[constructor]
  fn constructor(ref self: ContractState, public_key: felt252) {
    self.public_key.write(public_key);  // Records the signer's public key
  }
  // ... Additional implementation details
}
```

The `is_valid_signature` function outputs `VALID` for an authentic signature and `0` for an invalid one. Additionally, the `is_valid_signature_bool` internal function provides a Boolean result for the signature's validity.

```rust
#[starknet::contract]
mod Account {
  // Import relevant cryptographic and data handling modules
  use array::ArrayTrait;
  use ecdsa::check_ecdsa_signature;
  use array::SpanTrait;  // Facilitates the use of the span() method

  // External function to validate the transaction signature
  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
      // Converts the signature array into a span for processing
      let is_valid = self.is_valid_signature_bool(hash, signature.span());
      if is_valid { 'VALID' } else { 0 }  // Returns 'VALID' or '0' based on signature validity
    }
  }

  // Private function to check the signature validity and return a Boolean
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Validates the signature using a span of elements
    fn is_valid_signature_bool(self: @ContractState, hash: felt252, signature: Span<felt252>) -> bool {
      // Checks if the signature has the correct length
      let is_valid_length = signature.len() == 2_u32;

      // If the signature length is incorrect, returns false
      if !is_valid_length {
        return false;
      }

      // Verifies the signature using the stored public key
      check_ecdsa_signature(
        hash, self.public_key.read(), *signature.at(0_u32), *signature.at(1_u32)
      )
    }
  }
  // ... Additional implementation details
}

```

In the `__validate__` function, the `is_valid_signature_bool` method is utilized to confirm the integrity of transaction signatures.

```rust
#[starknet::contract]
mod Account {
  // Import modules for transaction information retrieval
  use box::BoxTrait;
  use starknet::get_tx_info;

  // Protocol implementation for transaction validation
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // Validates the signature of a transaction
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();  // Ensures protocol-only access

      // Retrieves transaction information and unpacks it
      let tx_info = get_tx_info().unbox();
      let tx_hash = tx_info.transaction_hash;
      let signature = tx_info.signature;

      // Validates the signature and asserts its correctness
      let is_valid = self.is_valid_signature_bool(tx_hash, signature);
      assert(is_valid, 'Account: Incorrect tx signature');  // Stops execution if the signature is invalid
      'VALID'  // Indicates a valid signature
    }
  }
  // ... Additional implementation details
}
```

## Unified Signature Validation for Contract Operations

The `__validate_declare__` function is responsible for validating the signature
of the `declare` function. On the other hand, `__validate_deploy__` facilitates
counterfactual deployment,a method to deploy an account contract without
associating it to a specific deployer address.

To streamline the validation process, we'll unify the behavior of the three
validation functions `__validate__`,`__validate_declare__` and `__validate_deploy__`.
The core logic from `__validate__` is abstracted to `validate_transaction` private
function, which is then invoked by the other two validation functions.

```rust
#[starknet::contract]
mod Account {
  // Protocol implementation for the account contract
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {

    // Validates general contract function calls
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();  // Ensures only the Starknet protocol can call
      self.validate_transaction()  // Centralized validation logic
    }

    // Validates the 'declare' function signature
    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
      self.only_protocol();  // Ensures only the Starknet protocol can call
      self.validate_transaction()  // Reuses the validation logic
    }

    // Validates counterfactual contract deployment
    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252 {
      self.only_protocol();  // Ensures only the Starknet protocol can call
      // Even though public_key is provided, it uses the one stored from the constructor
      self.validate_transaction()  // Applies the same validation logic
    }
  }

  // Private trait implementation that contains shared validation logic
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Abstracted core logic for validating transactions
    fn validate_transaction(self: @ContractState) -> felt252 {
      let tx_info = get_tx_info().unbox();  // Extracts transaction information
      let tx_hash = tx_info.transaction_hash;
      let signature = tx_info.signature;

      // Validates the transaction signature using an internal boolean function
      let is_valid = self.is_valid_signature_bool(tx_hash, signature);
      assert(is_valid, 'Account: Incorrect tx signature');  // Ensures signature correctness
      'VALID'  // Returns 'VALID' if the signature checks out
    }
  }
}
```

It's important to note that the `__validate_deploy__` function receives the public key
as an argument. While this key is captured during the constructor phase before this function
is invoked, it remains crucial to provide it when initiating the transaction.
Alternatively, the public key can be directly utilized within the `__validate_deploy__` function,
bypassing the constructor.

## Efficient Multicall Transaction Execution

The `__execute__` function within the `Account` module of a Starknet contract is designed to process an array of `Call` structures. This multicall feature consolidates several user operations into a single transaction, significantly improving the user experience by enabling batched operations.

````rust
```rust
#[starknet::contract]
mod Account {
  // Protocol implementation to handle execution of calls
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // The __execute__ function processes an array of calls
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol(); // Ensures Starknet protocol level access
      self.execute_multiple_calls(calls) // Invokes batch processing of calls
    }
    // ... Additional implementation details
  }
}
````

Each `Call` represents the details required for executing a single operation by the smart contract:

```rust
// Data structure encapsulating a contract call
#[derive(Drop, Serde)]
struct Call {
  to: ContractAddress,       // The target contract address
  selector: felt252,         // The function selector
  calldata: Array<felt252>   // The parameters for the function call
}
```

The contract defines a private function `execute_single_call` to handle individual calls. It utilizes the `call_contract_syscall` to directly invoke a function on another contract:

```rust
#[starknet::contract]
mod Account {
  // Import syscall for contract function invocation
  use starknet::call_contract_syscall;

  // Private trait implementation for individual call execution
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Executes a single call to another contract
    fn execute_single_call(self: @ContractState, call: Call) -> Span<felt252> {
      let Call{to, selector, calldata} = call; // Destructures the Call struct
      call_contract_syscall(to, selector, calldata.span()).unwrap_syscall() // Performs the contract call
    }
  }
  // ... Additional implementation details
}
```

For the execution of multiple calls, `execute_multiple_calls` iterates over the array of Call structures, invoking `execute_single_call` for each and collecting the responses:

```rust
#[starknet::contract]
mod Account {
  // Private trait implementation for batch call execution
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Handles an array of calls and accumulates the results
    fn execute_multiple_calls(self: @ContractState, mut calls: Array<Call>) -> Array<Span<felt252>> {
      let mut res = ArrayTrait::new(); // Initializes the result array
      loop {
        match calls.pop_front() {
          Option::Some(call) => {
            let response = self.execute_single_call(call); // Executes each call individually
            res.append(response); // Appends the result of the call to the result array
          },
          Option::None(_) => {
            break (); // Exits the loop when no more calls are left
          },
        };
      };
      res // Returns the array of results
    }
  }
  // ... Additional implementation details
}
```

In summary, the `__execute__` function orchestrates the execution of multiple calls within a single transaction. It leverages these internal functions to handle each call efficiently and return the collective results:

```rust
#[starknet::contract]
mod Account {
  // External function definition within the protocol implementation
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // The __execute__ function takes an array of Call structures and processes them
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol(); // Verifies that the function caller is the Starknet protocol
      self.execute_multiple_calls(calls) // Delegates to a function for processing multiple calls
    }
    // ... Additional implementation details may follow
  }
  // ... Further module code may be present
}
```

The `__execute__` function first ensures that it is being called by the Starknet protocol itself, a security measure to prevent unauthorized access. It then calls the `execute_multiple_calls` function to handle the actual execution of the calls.

## Ensuring Compatibility with Transaction Versioning

Starknet incorporates a versioning system for transactions to maintain backward compatibility while introducing new functionalities. The account contract tutorial showcases support for the latest transaction versions through a specific module, ensuring smooth operation of both legacy and updated transaction structures.

To accommodate the evolution of Starknet and its enhanced functionalities,
a versioning system was introduced for transactions. This ensures backward compatibility,
allowing both old and new transaction structures to operate concurrently.

- Version 1 for `invoke` transactions
- Version 1 for `deploy_account` transactions
- Version 2 for `declare` transactions

These supported versions are logically grouped in a module called `SUPPORTED_TX_VERSION`:

```rust
// Module defining supported transaction versions
mod SUPPORTED_TX_VERSION {
  // Constants representing the supported versions
  const DEPLOY_ACCOUNT: felt252 = 1;  // Supported version for deploy_account transactions
  const DECLARE: felt252 = 2;         // Supported version for declare transactions
  const INVOKE: felt252 = 1;          // Supported version for invoke transactions
}

#[starknet::contract]
mod Account {
  // The rest of the account contract module code
  ...
}
```

To handle the version checking, the account contract includes a private function `only_supported_tx_version`. This function compares the version of an incoming transaction against the specified supported versions, halting execution with an error if a discrepancy is found.

The critical contract functions such as `__execute__`, `__validate__`, `__validate_declare__`, and `__validate_deploy__` implement this version check to confirm transaction compatibility.

```rust
#[starknet::contract]
mod Account {
  // Importing constants from the SUPPORTED_TX_VERSION module
  use super::SUPPORTED_TX_VERSION;

  // Protocol implementation for Starknet functions
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    // Function to execute multiple calls with version check
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol(); // Checks if the function caller is the Starknet protocol
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::INVOKE); // Ensures the transaction is the supported version
      self.execute_multiple_calls(calls) // Processes the calls if version check passes
    }

    // Each of the following functions also includes the version check to ensure compatibility
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::INVOKE);
      self.validate_transaction()
    }

    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::DECLARE);
      self.validate_transaction()
    }

    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::DEPLOY_ACCOUNT);
      self.validate_transaction()
    }
  }

  // Private implementation for checking supported transaction versions
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Function to assert the transaction version is supported
    fn only_supported_tx_version(self: @ContractState, supported_tx_version: felt252) {
      let tx_info = get_tx_info().unbox(); // Retrieves transaction details
      let version = tx_info.version; // Extracts the version from the transaction
      assert(
        version == supported_tx_version,
        'Account: Unsupported tx version' // Error message for unsupported versions
      );
    }
    // ... Additional private functions
  }
}
```

By integrating transaction version control, the contract ensures it operates consistently with the network's current standards, providing a clear path for upgrading and maintaining compatibility with Starknet's evolving ecosystem.

## Handling Simulated Transactions

Starknet's simulation feature allows developers to estimate the gas cost of transactions without actually committing them to the network. This is particularly useful during development and testing phases. The `estimate-only` flag available in tools like Starkli triggers the simulation process. To differentiate between actual transaction execution and simulation, Starknet uses a version offset strategy.

Simulated transactions are assigned a version number that is the sum of \(2^{128}\) and the version number of the actual transaction type. For example, if the latest version of a `declare` transaction is 2, then a simulated `declare` transaction would have a version number of \(2^{128} + 2\). The same logic applies to other transaction types like `invoke` and `deploy_account`.

Here's how the `only_supported_tx_version` function is adjusted to accommodate both actual and simulated transaction versions:

```rust
#[starknet::contract]
mod Account {
  // Constant representing the version offset for simulated transactions
  const SIMULATE_TX_VERSION_OFFSET: felt252 = 340282366920938463463374607431768211456; // This is 2^128

  // Private trait implementation updated to validate transaction versions
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    // Function to check for supported transaction versions, accounting for simulations
    fn only_supported_tx_version(self: @ContractState, supported_tx_version: felt252) {
      let tx_info = get_tx_info().unbox(); // Retrieves the transaction metadata
      let version = tx_info.version; // Extracts the version for comparison

      // Validates whether the transaction version matches either the supported actual version or the simulated version
      assert(
        version == supported_tx_version ||
        version == SIMULATE_TX_VERSION_OFFSET + supported_tx_version,
        'Account: Unsupported tx version' // Assertion message for version mismatch
      );
    }
    // Additional private functions may follow
  }
  // Remaining contract code may continue here
}
```

The code snippet showcases the account contract's capability to recognize and process both actual and simulated versions of transactions by incorporating the large numerical offset. This ensures that the system can seamlessly operate with and adjust to the estimation process without affecting the actual transaction processing logic.

## SRC-5 Standard and Contract Introspection

Contract introspection is a feature that allows Starknet contracts to self-report the interfaces they support, in compliance with the SRC-5 standard. The `supports_interface` function is a fundamental part of this introspection process, enabling contracts to communicate their capabilities to others.

For a contract to be SRC-5 compliant, it must return `true` when the `supports_interface` function is called with a specific `interface_id`. This unique identifier is chosen to represent the SRC-6 standard's interface, which the contract claims to support. The identifier is a large integer specifically chosen to minimize the chance of accidental collisions with other identifiers.

In the account contract, the `supports_interface` function is part of the public interface, allowing other contracts to query its support for the SRC-6 standard:

```rust
// SRC-5 trait defining the introspection method
trait ISRC5 {
  // Function to check interface support
  fn supports_interface(interface_id: felt252) -> bool;
}

// Extension of the account contract's interface for SRC-5 compliance
#[starknet::interface]
trait IAccount<T> {
  // ... Additional methods
  // Method to validate interface support
  fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::contract]
mod Account {
  // Constant identifier for the SRC-6 trait
  const SRC6_TRAIT_ID: felt252 = 1270010605630597976495846281167968799381097569185364931397797212080166453709;

  // Public interface implementation for the account contract
  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    // ... Other function implementations
    // Implementation of the interface support check
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      // Compares the provided interface ID with the SRC-6 trait ID
      interface_id == SRC6_TRAIT_ID
    }
  }
  // ... Additional account contract code
}
// SRC-5 trait defining the introspection method
trait ISRC5 {
  // Function to check interface support
  fn supports_interface(interface_id: felt252) -> bool;
}

// Extension of the account contract's interface for SRC-5 compliance
#[starknet::interface]
trait IAccount<T> {
  // ... Additional methods
  // Method to validate interface support
  fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::contract]
mod Account {
  // Constant identifier for the SRC-6 trait
  const SRC6_TRAIT_ID: felt252 = 1270010605630597976495846281167968799381097569185364931397797212080166453709;

  // Public interface implementation for the account contract
  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    // ... Other function implementations
    // Implementation of the interface support check
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      // Compares the provided interface ID with the SRC-6 trait ID
      interface_id == SRC6_TRAIT_ID
    }
  }
  // ... Additional account contract code
}
```

By implementing this function, the account contract declares its ability to interact with other contracts expecting SRC-6 features, thus adhering to the standards of the Starknet protocol and enhancing interoperability within the network.

## Public Key Accessibility

For enhanced transparency and debugging purposes, it's recommended to make the public key
of the account contract's signer accessible. This allows users to verify the correct deployment
of the account contract by comparing the stored public key with the signer's public key offline.

```rust
...

#[starknet::contract]
mod Account {
  ...

  #[external(v0)]
  impl AccountImpl of IAccount<ContractState> {
    ...
    fn public_key(self: @ContractState) -> felt252 {
      self.public_key.read()
    }
  }
}
```

## Final Implementation

We now have a fully functional account contract. Here's the final implementation;

```rust
use starknet::account::Call;

mod SUPPORTED_TX_VERSION {
  const DEPLOY_ACCOUNT: felt252 = 1;
  const DECLARE: felt252 = 2;
  const INVOKE: felt252 = 1;
}

#[starknet::interface]
trait IAccount<T> {
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
  fn supports_interface(self: @T, interface_id: felt252) -> bool;
  fn public_key(self: @T) -> felt252;
}

#[starknet::contract]
mod Account {
  use super::{Call, IAccount, SUPPORTED_TX_VERSION};
  use starknet::{get_caller_address, call_contract_syscall, get_tx_info, VALIDATED};
  use zeroable::Zeroable;
  use array::{ArrayTrait, SpanTrait};
  use ecdsa::check_ecdsa_signature;
  use box::BoxTrait;

  const SIMULATE_TX_VERSION_OFFSET: felt252 = 340282366920938463463374607431768211456; // 2**128
  const SRC6_TRAIT_ID: felt252 = 1270010605630597976495846281167968799381097569185364931397797212080166453709; // hash of SNIP-6 trait

  #[storage]
  struct Storage {
    public_key: felt252
  }

  #[constructor]
  fn constructor(ref self: ContractState, public_key: felt252) {
    self.public_key.write(public_key);
  }

  #[external(v0)]
  impl AccountImpl of IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
      let is_valid = self.is_valid_signature_bool(hash, signature.span());
      if is_valid { VALIDATED } else { 0 }
    }

    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      interface_id == SRC6_TRAIT_ID
    }

    fn public_key(self: @ContractState) -> felt252 {
      self.public_key.read()
    }
  }

  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::INVOKE);
      self.execute_multiple_calls(calls)
    }
    
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::INVOKE);
      self.validate_transaction()
    }

    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::DECLARE);
      self.validate_transaction()
    }

    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252 {
      self.only_protocol();
      self.only_supported_tx_version(SUPPORTED_TX_VERSION::DEPLOY_ACCOUNT);
      self.validate_transaction()
    }
  }

  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    fn only_protocol(self: @ContractState) {
      let sender = get_caller_address();
      assert(sender.is_zero(), 'Account: invalid caller');
    }

    fn is_valid_signature_bool(self: @ContractState, hash: felt252, signature: Span<felt252>) -> bool {
      let is_valid_length = signature.len() == 2_u32;

      if !is_valid_length {
        return false;
      }
      
      check_ecdsa_signature(
        hash, self.public_key.read(), *signature.at(0_u32), *signature.at(1_u32)
      )
    }

    fn validate_transaction(self: @ContractState) -> felt252 {
      let tx_info = get_tx_info().unbox();
      let tx_hash = tx_info.transaction_hash;
      let signature = tx_info.signature;
      
      let is_valid = self.is_valid_signature_bool(tx_hash, signature);
      assert(is_valid, 'Account: Incorrect tx signature');
      VALIDATED
    }

    fn execute_single_call(self: @ContractState, call: Call) -> Span<felt252> {
      let Call{to, selector, calldata} = call;
      call_contract_syscall(to, selector, calldata.span()).unwrap()
    }

    fn execute_multiple_calls(self: @ContractState, mut calls: Array<Call>) -> Array<Span<felt252>> {
      let mut res = ArrayTrait::new();
      loop {
        match calls.pop_front() {
          Option::Some(call) => {
            let _res = self.execute_single_call(call);
            res.append(_res);
          },
          Option::None(_) => {
            break ();
          },
        };
      };
      res
    }

    fn only_supported_tx_version(self: @ContractState, supported_tx_version: felt252) {
      let tx_info = get_tx_info().unbox();
      let version = tx_info.version;
      assert(
        version == supported_tx_version ||
        version == SIMULATE_TX_VERSION_OFFSET + supported_tx_version,
        'Account: Unsupported tx version'
      );
    }
  }
}
```

## Account Contract Creation Summary

- **SNIP-6 Implementation**

  - Implements the `ISRC6` trait, defining the account contract's structure.

- **Protocol-Only Function Access**

  - Restricts `__validate__` and `__execute__` to StarkNet protocol access.
  - Makes `is_valid_signature` available for external calls.
  - Adds a `only_protocol` private function to enforce access rules.

- **Signature Validation Process**

  - Stores a public key to verify the signer's transactions.
  - Initializes with a `constructor` to set the public key.
  - Validates signatures with `is_valid_signature`, returning `VALID` or `0`.
  - Uses `is_valid_signature_bool` to return a true or false validation result.

- **Declare and Deploy Function Validation**

  - Sets up `__validate_declare__` to check the `declare` function's signature.
  - Designs `__validate_deploy__` for counterfactual deployments.
  - Abstracts core validation to `validate_transaction`.

- **Transaction Execution Logic**

  - Enables multicall capability with `__execute__`.
  - Handles calls individually with `execute_single_call` and in batches with `execute_multiple_calls`.

- **Transaction Version Compatibility**

  - Ensures compatibility with StarkNet updates using a versioning system.
  - Defines supported transaction types in `SUPPORTED_TX_VERSION`.
  - Checks transaction versions with `only_supported_tx_version`.

- **Simulated Transaction Handling**

  - Adapts `only_supported_tx_version` to recognize both actual and simulated versions.

- **Contract Self-Identification**

  - Allows self-identification with the SRC-5 standard via `supports_interface`.

- **Public Key Visibility**

  - Provides public key access for transparency.

- **Complete Implementation**
  - Presents the final account contract code.

Next, we will deploy the account using Starkli to the testnet and interact with other smart contracts.
