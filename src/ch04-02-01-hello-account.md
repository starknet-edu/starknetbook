# Hello World Account Contract

In this subchapter we will create an account contract
from scratch following the SNIP-6 and SRC-5 standards.

## Project Setup

To deploy an account contract to Starknet's testnet or mainnet,
ensure you're using a version of Scarb that supports the Sierra 1.3.0 target,
as both Starknet's testnet and mainnet currently support this version.
Refer to [Starknet Release Notes](https://docs.starknet.io/documentation/starknet_versions/version_notes/)
for more details.
As of October 2023, the recommended Scarb version is 0.7.0.

```bash
$ scarb --version
scarb 0.7.0 (58cc88efb 2023-08-23)
cairo: 2.2.0 (https://crates.io/crates/cairo-lang-compiler/2.2.0)
sierra: 1.3.0

```

To install or Update Scarb follow the instructions [here.](https://docs.swmansion.com/scarb/)

## Setting up a new Scarb project

Initialize a new project:

```bash
$ scarb new aa
Created `aa` package.

```

Inspect the default project structure:

```bash
$ tree .
.
└── aa
    ├── Scarb.toml
    └── src
        └── lib.cairo

```

By default, Scarb sets up for vanilla Cairo. To target Starknet,
modify `Scarb.toml` to activate the Starknet plugin.

```bash
[package]
name = "aa"
version = "0.1.0"

[dependencies]
starknet = "2.2.0"

[[target.starknet-contract]]

```

In the `src/lib.cairo` file,replace the Cairo code with the scaffold for your account contract:

```rust
#[starknet::contract]
mod Account {

}

```

To validate signatures, store the public key associated with the signer's private key.

```rust
#[starknet::contract]
mod Account {

    #[storage]
    struct Storage {

        public_key: felt252
    }
}

```

Finally, compile the project to verify the setup:

```bash
aa/src$ scarb build
   Compiling aa v0.1.0 (/home/Cyndie/account_abstraction__starknet/aa/Scarb.toml)
    Finished release target(s) in 1 second

```

## Implementing SNIP-6

As explained in the previous subchapter, to classify a smart contract as an  
account contract, it must adhere to the `ISRC6` trait:

```rust
trait ISRC6 {
  fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(calls: Array<Call>) -> felt252;
  fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}
```

Functions within the account contract annotated with `#[external(v0)]` attribute
possess unique selectors, facilitating interactions with the contract by external entities.

However, while these functions are publicly accessible via their selectors, it is essential
to distinguish their intended users. Specifically, the `__execute__` and `__validate__`
functions are reserved exclusively for the Starknet protocol. In contrast, `is_valid_signature`
is publicly available, catering to web3 applications for signature validation.

The `trait IAccount<T>` trait, marked with the `#[starknet::interface]` attribute,
encapsulates functions intended for public interaction,such as `is_valid_signature`.
The `__execute__` and `__validate__` functions, though public, are indirectly accessed.

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
  impl AccountImpl of super::IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 { ... }
  }

  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> { ... }
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 { ... }
  }
}
```

## Protocol-Only Function Protection

For enhanced account security,`__execute__` and `__validate__` functions are exclusively
callable by the Starknet protocol, even though they are publicly accessible.
The Starknet protocol uses the zero address when invoking a function.
The private function `only_protocol` ensures that only Starknet protocol can access these functions

```rust
...

//Starknet uses zero address as caller when calling function
#[starknet::contract]
mod Account {
  use starknet::get_caller_address;
  use zeroable::Zeroable;
  ...

  //protection of protocol-only functions using only_protocol()
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol();
      ...
    }
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();
      ...
    }
  }

  //creation of private function only_protocol()
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    fn only_protocol(self: @ContractState) {...}
  }
}

```

Note that the function `is_valid_signature` is not protected by the `only_protocol` function
as its to be used freely.

## Signature Validation

The public key associated with the account contract's signer is stored for transaction signature validation.
The `constructor` method is defined to capture the public key's value during deployment.
.

```rust
...

#[starknet::contract]
mod Account {
  ...

  #[storage]
  struct Storage {
    public_key: felt252
  }

  #[constructor]
  fn constructor(ref self: ContractState, public_key: felt252) {
    self.public_key.write(public_key);
  }
  ...
}
```

The `is_valid_signature` function returns `VALID` for a valid signature and `0` otherwise.
An internal function, `is_valid_signature_bool`, provides a boolean result for signature validation.

```rust
...

#[starknet::contract]
mod Account {
  ...
  use array::ArrayTrait;
  use ecdsa::check_ecdsa_signature;
  use array::SpanTrait;  //Implements span() method

  ...

  //Implementation of is_valid_signature method
  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
      //Derive Span from signature passed as Array to be used in is_valid_signature_bool()
      let is_valid = self.is_valid_signature_bool(hash, signature.span());
      if is_valid { 'VALID' } else { 0 }
    }
  }

  ...

  //Implementation of is_valid_signature_bool to return bool
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...

    //function signature expects a Span instead of an Array
    fn is_valid_signature_bool(self: @ContractState, hash: felt252, signature: Span<felt252>) -> bool {
      let is_valid_length = signature.len() == 2_u32;

      if !is_valid_length {
        return false;
      }

      check_ecdsa_signature(
        hash, self.public_key.read(), *signature.at(0_u32), *signature.at(1_u32)
      )
    }
  }
}

```

The `__validate__` function uses `is_valid_signature_bool` to ensure transaction signature validity.

```rust
...

#[starknet::contract]
mod Account {
  ...
  use box::BoxTrait;
  use starknet::get_tx_info;

  ...

  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    ...

    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();

      let tx_info = get_tx_info().unbox();
      let tx_hash = tx_info.transaction_hash;
      let signature = tx_info.signature;

      let is_valid = self.is_valid_signature_bool(tx_hash, signature);
      assert(is_valid, 'Account: Incorrect tx signature');  //assert stops transaction execution if signature invalid
      'VALID'
    }
  }

  ...
}

```

## Validation for Declare and Deploy Functions

The `__validate_declare__` function is responsible for validating the signature
of the `declare` function. On the other hand, `__validate_deploy__` facilitates
counterfactual deployment,a method to deploy an account contract without
associating it to a specific deployer address.

To streamline the validation process, we'll unify the behavior of the three
validation functions `__validate__`,`__validate_declare__` and `__validate_deploy__`.
The core logic from `__validate__` is abstracted to `validate_transaction` private
function, which is then invoked by the other two validation functions.

```rust
...

#[starknet::contract]
mod Account {
  ...

  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {

    //The three validation signatures pooled to function similarly
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
      self.only_protocol();
      self.validate_transaction()
    }

    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
      self.only_protocol();
      self.validate_transaction()
    }

    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252 {
      self.only_protocol();
      self.validate_transaction()
    }
  }

  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...

    //Logic extraction from __validate__ to validate_transaction
    fn validate_transaction(self: @ContractState) -> felt252 {
      let tx_info = get_tx_info().unbox();
      let tx_hash = tx_info.transaction_hash;
      let signature = tx_info.signature;

      let is_valid = self.is_valid_signature_bool(tx_hash, signature);
      assert(is_valid, 'Account: Incorrect tx signature');
      'VALID'
    }
  }
}
```

It's important to note that the `__validate_deploy__` function receives the public key
as an argument. While this key is captured during the constructor phase before this function
is invoked, it remains crucial to provide it when initiating the transaction.
Alternatively, the public key can be directly utilized within the `__validate_deploy__` function,
bypassing the constructor.

## Transaction Execution

The `__execute__` function in the `Account` module accepts an array of `Call` structures,
allowing for multicall functionality. This feature bundles multiple user operations
into one transaction, enhancing user experience.

```rust
...
#[starknet::contract]
mod Account {
  ...
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> { ... }
    ...
  }
}
```

The `Call` data structure contains the necessary information for a single user operation.

```rust
#[derive(Drop, Serde)]
struct Call {
  to: ContractAddress,
  selector: felt252,
  calldata: Array<felt252>
}
```

To manage individual calls, a private function `execute_single_call` is defined. It uses the low-level
`call_contract_syscall` syscall to invoke another smart contract function directly.

```rust
...
#[starknet::contract]
mod Account {
  ...
  use starknet::call_contract_syscall;

  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...
    fn execute_single_call(self: @ContractState, call: Call) -> Span<felt252> {
      let Call{to, selector, calldata} = call;
      call_contract_syscall(to, selector, calldata.span()).unwrap_syscall()
    }
  }
}
```

For handling multiple calls, the `execute_multiple_calls` function iterates over the
`Call` array and returns an array of responses.

```rust
...
#[starknet::contract]
mod Account {
  ...
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...
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
  }
}
```

Finally, the main `__execute__` function utilizes these helper functions to process the array
of `Call` structures:

```rust
...
#[starknet::contract]
mod Account {
  ...
  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {
    fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
      self.only_protocol();
      self.execute_multiple_calls(calls)
    }
    ...
  }
  ...
}
```

## Transaction Version Support

To accommodate the evolution of Starknet and its enhanced functionalities,
a versioning system was introduced for transactions. This ensures backward compatibility,
allowing both old and new transaction structures to operate concurrently.

For simplicity in this tutorial, the account contract is designed to support
only the latest versions of each transaction type:

- Version 1 for `invoke` transactions
- Version 1 for `deploy_account` transactions
- Version 2 for `declare` transactions

These supported versions are logically grouped in a module called `SUPPORTED_TX_VERSION`:

```rust
...

mod SUPPORTED_TX_VERSION {
  const DEPLOY_ACCOUNT: felt252 = 1;
  const DECLARE: felt252 = 2;
  const INVOKE: felt252 = 1;
}

#[starknet::contract]
mod Account { ... }
```

To ensure that only the latest transaction versions are processed,
a private function `only_supported_tx_version` is introduced.
This function checks the version of the incoming transaction against the supported versions.
If there's a mismatch, the transaction execution is halted with an assertion error.

The main functions `__execute__`, `__validate__`, `__validate_declare__` and `__validate_deploy__`
utilize this version check to ensure only the supported transaction versions are processed.

```rust
...

#[starknet::contract]
mod Account {
  ...
  use super::SUPPORTED_TX_VERSION;

  ...

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
    ...

    fn only_supported_tx_version(self: @ContractState, supported_tx_version: felt252) {
      let tx_info = get_tx_info().unbox();
      let version = tx_info.version;
      assert(
        version == supported_tx_version,
        'Account: Unsupported tx version'
      );
    }
  }
}
```

## Handling Simulated Transactions

In Starknet, transactions can be simulated to estimate gas without actual execution.
Tools like Starkli offer an `estimate-only` flag for this purpose, signaling the Sequencer
to simulate the transaction and return the estimated cost.

To differentiate between real and simulated transactions, the version of a simulated transaction is offset
by 2^128 from its actual counterpart. For instance, a simulated `declare` transaction has a version of 2^128 + 2
if the regular `declare` transaction's latest version is 2.

The `only_supported_tx_version` function is adjusted to recognize both actual and simulated versions,
ensuring accurate processing for both types.

```rust
...

#[starknet::contract]
mod Account {
  ...
  //Represents simulated transactions
  const SIMULATE_TX_VERSION_OFFSET: felt252 = 340282366920938463463374607431768211456; // 2**128

  ...

  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...
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

## Introspection

Introspection allows an account contract to self-identify using the SRC-5 standard.

```rust
trait ISRC5 {
  fn supports_interface(interface_id: felt252) -> bool;
}
```

An account contract should return `true` for the `supports_interface` function when provided with the
specific `interface_id` of `1270010605630597976495846281167968799381097569185364931397797212080166453709`.
The reason for using this specific identifier is explained in the previous subchapter.

The `supports_interface` function has been added to the public interface of the account
contract to facilitate external queries by other smart contracts.

```rust
...

#[starknet::interface]
trait IAccount<T> {
  ...
  fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::contract]
mod Account {
  ...
  const SRC6_TRAIT_ID: felt252 = 1270010605630597976495846281167968799381097569185364931397797212080166453709;

  ...

  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    ...
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
      interface_id == SRC6_TRAIT_ID
    }
  }
  ...
}
```

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

## Recap

Account Contract Creation Recap:

- SNIP-6 Implementation

  - The account contract is designed to adhere to the `ISRC6` trait, which dictates the structure of an account contract.

- Protecting Protocol-Only Functions

  - `__validate__` and `__execute__` functions were restricted to be accessed only by the Starknet protocol.

  - `is_valid_signature` was exposed for external interactions.

  - Private function `only_protocol` was introduced to enforce this restriction.

- Signature Validation

  - Public key associated with signer of account contract was stored to facilitate transaction signature validation.

  - `constructor` method was defined to capture the public key's value during deployment.

  - The `is_valid_signature` function was implemented to validate signatures, returning `VALID` or `0`.

  - The helper function `is_valid_signature_bool` was introduced to return a boolean result.

- Validation of Declare and Deploy Functions

  - The `__validate_declare__` function was setup to validate signature of `declare` function.

  - The `__validate_deploy__` function was designed for counterfactual deployment.

  - The core validation logic was abstracted to a private function named `validate_transaction`.

- Transaction Execution

  - Introduced multicall functionality via the `__execute__` function.

  - Implemented `execute_single_call` and `execute_multiple_calls` to manage individual and multiple calls respectively.

- Transaction Version Support

  - Implemented a versioning system to ensure backward compatibility with evolving Starknet functionalities.

  - Created `SUPPORTED_TX_VERSION` module to define supported versions for various transaction types.

  - Introduced `only_supported_tx_version` to validate transaction versions.

- Handling Simulated Transactions

  - Adjusted the `only_supported_tx_version` function to recognize both actual and simulated transaction versions.

- Introspection

  - Enabled the account contract to self-identify using the SRC-5 standard.

  - The `supports_interface` function was added to the public interface for external queries about the contract's capabilities.

- Public Key Accessibility

  - Enhanced transparency by making the public key of the account contract's signer accessible.

- Final Implementation

  - Final Implementation of the account contract.

Coming up, we'll use Starkli to deploy to testnet the account created, and use it to interact with other smart contracts.
