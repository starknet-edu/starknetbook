# MultiCaller Account

[Multicall](https://github.com/joshstevens19/ethereum-multicall#readme)
is a powerful technique that allows multiple constant smart contract
function calls to be aggregated into a single call, resulting in a
consolidated output. With Starknet’s account abstraction feature,
multicalls can be seamlessly integrated into account contracts.

## Why Multicalls?

Multicalls come handy in several scenarios. Here are some examples:

1.  **Token Swapping on Decentralized Exchanges**: In a typical token
    swap operation on a decentralized exchange (DEX), you first need to
    approve the spending of the tokens and then initiate the swap.
    Executing these operations separately could be cumbersome from a
    user experience perspective. With multicall, these calls can be
    combined into a single transaction, simplifying the user’s task.

2.  **Fetching Blockchain Data**: When you want to query the prices of
    two different tokens from the blockchain, it’s beneficial to have
    them both come from the same block for consistency. Multicall
    returns the latest block number along with the aggregated results,
    providing this consistency.

The benefits of multicall transactions can be realized more in the
context of account abstraction.

## Multicall Account Abstraction Creation.

[Multicall](https://github.com/joshstevens19/ethereum-multicall#readme)

This is because multicall is a feature of Account Abstraction that lets you bundle multiple user operations into a single transaction for a smoother UX.

The Call data type is a struct that has all the data you need to execute a single user operation.

There are different traits that a smart contract must implement to be considered an account contract. Let's create account abstraction from the scratch following the SNIP-6 and SRC-5 standards.

### Project Setup.

In order to be able to compile an account contract to Sierra, a prerequisite to deploy it to testnet or mainnet, you’ll need to make sure to have a version of Scarb that includes a Cairo compiler that targets Sierra 1.3 as it’s the latest version supported by Starknet’s testnet. At this point in time Scarb 0.7 is used.

```
~ $ scarb --version
>>>
scarb 0.7.0 (58cc88efb 2023-08-23)
cairo: 2.2.0 (https://crates.io/crates/cairo-lang-compiler/2.2.0)
sierra: 1.3.0
```

Create a new project with Scarb using the new command.

```dotnetcli
~ $ scarb new aa
```

The command creates a folder with the same name that includes a configuration file for Scarb.

```dotnetcli
~ $ cd aa
aa $ tree .
>>>
.
├── Scarb.toml
└── src
    └── lib.cairo
```

Scarb configures the project for vanilla Cairo instead of Starknet smart contracts by default.

```dotnetcli
# Scarb.toml

[package]
name = "aa"
version = "0.1.0"

[dependencies]
# foo = { path = "vendor/foo" }
```

There is a need to make some changes to the configuration file to activate the Starknet plugin in the compiler so we can work with smart contracts.

```dotnetcli
# Scarb.toml

[package]
name = "aa"
version = "0.1.0"

[dependencies]
starknet = "2.2.0"

[[target.starknet-contract]]
```

Let's now replace the content of the sample Cairo code that comes with a new project with the scaffold of our account contract.

```
#[starknet::contract]
mod Account {}
```

Given that one of the most important features of our account contract is to validate signatures, there is a need to store the public key associated with the private key of the signer.

```dotnetcli
#[starknet::contract]
mod Account {

  #[storage]
  struct Storage {
    public_key: felt252
  }
}
```

To make sure everything is wired up correctly, let’s compile our project.

```dotnetcli
aa $ scarb build
>>>
Compiling aa v0.1.0 (/Users/david/apps/sandbox/aa/Scarb.toml)
Finished release target(s) in 2 seconds
```

Welldone, It works, time to move to the interesting part of our tutorial.

## SNIP-6

Remember that for a smart contract to be considered an account contract, it must implement the trait defined by SNIP-6.

```dotnetcli
trait ISRC6 {
  fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(calls: Array<Call>) -> felt252;
  fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}
```

There is a need to eventually annotate the implementation of this trait with the `external` attribute, the contract state will be the first argument provided to each method. We can define the type of the contract state with the generic `T`.

```dotnetcli
trait ISRC6<T> {
  fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(self: @T, calls: Array<Call>) -> felt252;
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}
```

The **execute** function is the only one that receives a reference to the contract state because it’s the only one likely to either modify its internal state or to modify the state of another smart contract and thus to require the payment of gas fees for its execution. The other two functions, **validate** and **is_valid_signature**, are read-only and shouldn’t require the payment of gas fees. For this reason they are both receiving a snapshot of the contract state instead.

The question now becomes, how should we use this trait in our account contract. Should we annotate the trait with the **interface** attribute and then create an implementation like the code shown below?

```dotnetcli
#[starnet::interface]
trait ISRC6<T> {
  fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(self: @T, calls: Array<Call>) -> felt252;
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}

#[starknet::contract]
mod Account {
  ...
  #[external(v0)]
  impl ISRC6Impl of super::ISRC6<ContractState> {...}
}
```

Or should we use it instead `without` the interface attribute?

```dotnetcli
trait ISRC6<T> {
  fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(self: @T, calls: Array<Call>) -> felt252;
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}

#[starknet::contract]
mod Account {
  ...
  #[external(v0)]
  impl ISRC6Impl of super::ISRC6<ContractState> {...}
}
```

What happens without defining the trait explicitly?

```dotnetcli
#[starknet::contract]
mod Account {
  ...
  #[external(v0)]
  #[generate_trait]
  impl ISRC6Impl of ISRC6Trait {...}
}
```

From a technical view, both are all valid alternatives but they all fail to capture the right intention.

Every function inside an implementation annotated with the external attribute will have its own selector that other people and smart contracts can use to interact with my account contract. But the thing is, even though they can use the derived selectors to call those functions, but one will be recommended for users to use and for the Starknet protocol.

The functions **execute** and **validate** are meant to be used only by the Starknet protocol even if the functions are publicly accessible via its selectors. The only function that is made public for web3 apps to use for signature validation is **is_valid_signature**.

Furthermore, a separate trait annotated with the interface attribute will be created and group all the functions in an account contract that users are expected to interact with. On the other hand, the trait will be auto generated, for all those functions that users are not expected to use directly even though they are public.

```dotnetcli
use starknet::account::Call;

#[starnet::interface]
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

# Protecting Protocol-Only Functions

Although there might be legitimate use cases for other smart contracts to directly interact with the functions **execute** and **validate** of an account contract, these will rather be restricted to be callable only by the Starknet protocol in case there’s an attack vector that has not been foresee.

To create private functions, this simply create a new implementation that is not annotated with the external attribute so no public selectors are created.

```dotnetcli
#[starknet::contract]
mod Account {
 use starknet::get_caller_address;
 use zeroable::Zeroable;
 ...

 #[generate_trait]
 impl PrivateImpl of PrivateTrait {
   fn only_protocol(self: @ContractState) {
     let sender = get_caller_address();
     assert(sender.is_zero(), 'Account: invalid caller');
   }
 }
}
```

# Validate Declare and Deploy

**validate_declare** is used to validate the signature of a declare transaction while **validate_deploy** is used for the same purpose but for the deploy_account transaction. The latter is often referred to as “counterfactual deployment”.

```dotnetcli
#[starknet::contract]
mod Account {
  ...

  #[external(v0)]
  #[generate_trait]
  impl ProtocolImpl of ProtocolTrait {

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

# Execute Transactions

Looking at the signature of the **execute** function it is noticed that an array of calls are being passed instead of a single element.

```dotnetcli
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

This is because multicall is a feature of Account Abstraction that lets you bundle multiple user operations into a single transaction for a smoother UX.

The Call data type is a struct that has all the data you need to execute a single user operation.

```dotnetcli
#[derive(Drop, Serde)]
struct Call {
  to: ContractAddress,
  selector: felt252,
  calldata: Array<felt252>
}
```

Instead of trying to face the multicall head on, let’s first create a private function that deals with a single call that we can then reuse by iterating over the array of calls.

```
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

Destructure the `Call` struct and then we use the low level syscall `call_contract_syscall` to invoke a function on another smart contract without the help of a dispatcher.

However, with the single `call` function, multi call function can be built by iterating over a `Call` array and returning the responses as an array as well.

```dotnetcli
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

Finally, let's go back to the **execute** function and make use of the functions that was just created.

```dotnetcli
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

## Supported Transaction Versions

As Starknet evolved, changes have been required to the structure of the transactions to accommodate more advanced functionality. To avoid creating breaking changes whenever a transaction structure needs to be updated, a “version” field was added to all transactions so older and newer transactions can co-exist.

Maintaining different transaction versions is complex and because this is just a tutorial, I’ll restrict my account contract to only support the newest version of each type of transaction and those are:

- Version 1 for invoke transactions
- Version 1 for deploy_account transactions
- Version 2 for declare transactions

The supported transaction versions will be discussed below in a module for logical grouping.

```dotnetcli
...

mod SUPPORTED_TX_VERSION {
  const DEPLOY_ACCOUNT: felt252 = 1;
  const DECLARE: felt252 = 2;
  const INVOKE: felt252 = 1;
}

#[starknet::contract]
mod Account { ... }
```

Now create a private function that will check if the executed transaction is of the latest version and hence supported by your account contract. If not, you should abort the transaction execution with an **assert**.

```
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

## Simulated Transactions

It’s possible to request the Sequencer to estimate the amount of gas required to execute a transaction without actually executing it. Starkli for example provides the flag estimate-only that you can append to any transaction to instruct the Sequencer to only simulate the transaction and return the estimated cost.

To differentiate a regular transaction from a transaction simulation while protecting against replay attacks, the version of a transaction simulation is the same value as the normal transaction but offset by the value 2^128. For example, the version of a simulated declare transaction is 2^128 + 2 because the latest version of a regular declare transaction is 2.

With that in mind, we can modify the function only_supported_tx_version to account for simulated transactions.

```dotnetcli
...

#[starknet::contract]
mod Account {
  ...
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

Previously mentioned the standard SRC-5 is for introspection.

```dotnetcli
trait ISRC5 {
  fn supports_interface(interface_id: felt252) -> bool;
}

```

For an account contract to self identify as such, it must return true when passed the interface_id 1270010605630597976495846281167968799381097569185364931397797212080166453709. The reason why that particular number is used is explained in the previous article so go check it out for more details.

Because this is a public function that I do expect people and other smart contracts to call on my account contract, will add this function to its public interface.

```dotnetcli
...

#[starnet::interface]
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

## Exposing the Public Key

Although not required, it is a good idea to expose the public key associated with the account contract’s signer. One use case is to easily and safely debug the correct deployment of the account contract by reading the stored public key and comparing it (offline) to the public key of my signer.

```dotnetcli
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

Finally, we have a fully functional account contract.

## Conclusion

The account contract created now might look complex but it’s actually one of the simplests that can be created. The account contracts created by Braavos and Argent X are much more complex as they support features like social recovery, multisig, hardware signer, email/password signer, etc.

Both Braavos and Argent have open sourced their Cairo 0 version of their account contracts but Argent is the first one to also open source their Cairo version. OpenZeppelin (OZ) is also developing their own implementation of a Cairo account contract but it’s still a work in progress. This inspiration was deduced from OZ’s implementation when creating this tutorial.

SNIP-6 is referenced multiple times as a standard to follow for an account contract but so far it’s only a proposal under discussion that could change. This will not only affect the interface of your account contract but also the ID used for introspection.

## Considerations

While multicall provides significant benefits in terms of UX and data
consistency, it’s important to note that it may not significantly reduce
gas fees compared to individual calls. However, the primary advantage of
using multicall is that it ensures results are derived from the same
block, providing a much-improved user experience.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).

## Reference

- [1] OpenZeppelin, 2023: <https://github.com/OpenZeppelin/cairo-contracts/blob/release-v0.7.0-rc.0/src/account/account.cairo>
- [2] David Barreto, 2023: <https://medium.com/starknet-edu/account-abstraction-on-starknet-part-ii-24d52874e0bd>
