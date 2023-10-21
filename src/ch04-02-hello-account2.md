# Hello World Account Contract

In this subchapter we will create an account contract
from scratch following the SNIP-6 and SRC-5 standards.

## Project Setup

To be able to compile an account contract to Sierra, so as to
deploy it to testnet or mainnet, you'll need to make sure to
have a version of scarb that includes cairo compiler targetting
Sierra 1.3.0 as the latest version.
This is because currently, both Starknet's testnet and mainnet
support Sierra 1.3.0 [1]
As of October 2023, the latest stable Scarb version is 0.7.0

```bash
$ scarb --version
scarb 0.7.0 (58cc88efb 2023-08-23)
cairo: 2.2.0 (https://crates.io/crates/cairo-lang-compiler/2.2.0)
sierra: 1.3.0

```

To install or Update Scarb [click here.](https://docs.swmansion.com/scarb/)

Create a new project using Scarb;

```bash
$ scarb new aa
Created `aa` package.

```

Here's the current project structure;

```bash
$ tree .
.
└── aa
    ├── Scarb.toml
    └── src
        └── lib.cairo

```

By default, Scarb configures our project for Vanilla Cairo,
so we'll configure our `Scarb.toml` file to activate the
Starknet plugin in the Compiler, to handle Starknet smart contracts.

```bash
[package]
name = "aa"
version = "0.1.0"

[dependencies]
starknet = "2.2.0"

[[target.starknet-contract]]

```

With that done, in the `src/lib.cairo` file, we can now
replace the Cairo code with the scaffold of our account contract.

```rust
#[starknet::contract]
mod Account {

}

```

Given that one of the most important features of our account contract
is to validate signatures, we'll need to store the public key
associated with the signer's private key.

```rust
#[starknet::contract]
mod Account {

    #[storage]
    struct Storage {

        public_key: felt252
    }
}

```

We'll then compile the project to ensure everything is working correctly.

```bash
aa/src$ scarb build
   Compiling aa v0.1.0 (/home/Cyndie/account_abstraction__starknet/aa/Scarb.toml)
    Finished release target(s) in 1 second

```

## SNIP-6


Here's the final implementation of the account smart contract;


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
## SNIP-6

As explained in the previous subchapter, for a smart contract to be recognized as
an account contract, it needs to implement the `ISRC6` trait as follows;

```rust
trait ISRC6 {
  fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(calls: Array<Call>) -> felt252;
  fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}
```

In the account contract above, every function inside an implementation annotated 
with the external `#[external(v0)]` attribute will have its own selector
which other people and contracts can use to interact with the account contract.

But even though they can use the derived selectors to call those functions,
we'll signal which ones will be used, and which are reserved for the Starknet protocol.

With that in mind, the functions `__execute__` and `__validate__` are to be used only
by the Starknet protocol, even if its functions are publicly accessible via its selectors.
`is_valid_signature` will be made public for web3 apps to use for signature validation.

Therefore, `trait IAccount<T>` interfaced with the `#[starknet::interface]` attribute 
will group all the functions in the account contract people are expected to interact
with,such as `is_valid_signature`, then `__execute__` and `__validate__` will be auto-generated 
so they are accessed indirectly, even though public.
 

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
## Protecting Protocol-Only Functions
Even though there are legitimate use cases for other smart contracts 
to directly interact with `__execute__` and `__validate__` functions of our smart contract,
for account security the two functions are restricted to be called only by the Starknet 
protocol, so as to mitigate any potential attack vectors.

When the Starknet protocol calls a function, it uses the zero address as the caller. 
With this in mind, the private function `only_protocol` is created, so as to protect our
protocol-only functions, `__execute__` and `__validate__`. Private functions are created
without the `#[external(v0)]` attribute to avoid creation of public selectors. 

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
For validation of a transaction's signature the public key associated with the signer
of the account contract will be used, which is already stored in the account.

```rust
...

#[starknet::contract]
mod Account {
  ...

  #[storage]
  struct Storage {
    public_key: felt252
  }

  ...
}
```

To capture the public key's value during deployment, the `constructor` method is defined.

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

The logic of `is_valid_signature` can now be implemented, where if the signature is 
valid, it returns a short string `VALID`, and if not, returns `0`. To avoid 
confusion over returning `felt252` instead of a boolean, an internal function
`is_valid_signature_bool` will perform the same logic, but will return a boolean
instead of `felt252`, depending on the result of validating the signature.

```rust
...

#[starknet::contract]
mod Account {
  ...  
  use array::ArrayTrait;
  use ecdsa::check_ecdsa_signature;

  ...

  //Implementation of is_valid_signature method 
  #[external(v0)]
  impl AccountImpl of super::IAccount<ContractState> {
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
      let is_valid = self.is_valid_signature_bool(hash, signature);
      if is_valid { 'VALID' } else { 0 }
    }
  }

  ...

  //Implementation of is_valid_signature_bool to return bool
  #[generate_trait]
  impl PrivateImpl of PrivateTrait {
    ...

    fn is_valid_signature_bool(self: @ContractState, hash: felt252, signature: Array<felt252>) -> bool {
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


## References

- /[1/] Starknet Release Notes - https://docs.starknet.io/documentation/starknet_versions/version_notes/
