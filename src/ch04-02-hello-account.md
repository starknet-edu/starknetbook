# Hello World! Account Contract

This section guides you through the creation of the simplest possible account contract, adhering to the SNIP-6 standard. The account contract will be the simplest implementation of an account contract, with the following features:

- Signature validation for transactions will be not enforced. In other words, every transaction will be considered valid no matter who signed it; there will be no pivate key.
- It will make a single call and not multicall in the execution phase.
- It will only implement the SNIP-6 standard which is the minimum to be considered an account contract.

We will deployed using `starknet.py` and use it to deploy other contracts.

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
scarb new hello_account
```

Check the generated project structure:

```bash
$ tree .
.
└── hello_account
    ├── Scarb.toml
    └── src
        └── lib.cairo
```

By default, Scarb sets up for vanilla Cairo. Add Starknet capacities by editing `Scarb.toml` to include the `starknet` dependency:

```bash
[package]
name = "hello_account"
version = "0.1.0"

[dependencies]
starknet = ">=2.3.0"

[[target.starknet-contract]]
sierra = true
casm = true
casm-add-pythonic-hints = true
```

Replace the code in `src/lib.cairo` with the Hello World account contract:

```rust
use starknet::account::Call;

// IERC6 obtained from Open Zeppelin's cairo-contracts/src/account/interface.cairo
#[starknet::interface]
trait ISRC6<TState> {
    fn __execute__(self: @TState, calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(self: @TState, calls: Array<Call>) -> felt252;
    fn is_valid_signature(self: @TState, hash: felt252, signature: Array<felt252>) -> felt252;
}

#[starknet::contract]
mod HelloAccount {
    use starknet::VALIDATED;
    use starknet::account::Call;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {} // Empty storage. No public key is stored.

    #[external(v0)]
    impl SRC6Impl of super::ISRC6<ContractState> {
        fn is_valid_signature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            // No signature is required so any signature is valid.
            VALIDATED
        }
        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
            let hash = 0;
            let mut signature: Array<felt252> = ArrayTrait::new();
            signature.append(0);
            self.is_valid_signature(hash, signature)
        }
        fn __execute__(self: @ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
            let sender = get_caller_address();
            assert(sender.is_zero(), 'Account: invalid caller');
            let Call{to, selector, calldata } = calls.at(0);
            let _res = starknet::call_contract_syscall(*to, *selector, calldata.span()).unwrap();
            let mut res = ArrayTrait::new();
            res.append(_res);
            res
        }
    }
}
```

Compile your project to ensure the setup is correct:

```bash
scarb build
```

## SNIP-6 Standard

To define an account contract, implement the `ISRC6` trait:

```rust
#[starknet::interface]
trait ISRC6<TState> {
    fn __execute__(self: @TState, calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(self: @TState, calls: Array<Call>) -> felt252;
    fn is_valid_signature(self: @TState, hash: felt252, signature: Array<felt252>) -> felt252;
}
```

The `__execute__` and `__validate__` functions are designed for exclusive use by the Starknet protocol to enhance account security. Despite their public accessibility, only the Starknet protocol can invoke these functions, identified by using the zero address. In this minimal account contract we will not enforce this restriction, but we will do it in the next examples.

## Validating Transactions

The `is_valid_signature` function is responsible for this validation, returning `VALIDATED` if the signature is valid. The `VALIDATED` constant is imported from the `starknet` module.

```rust
use starknet::VALIDATED;
```

Notice that the `is_valid_signature` function accepts all the transactions as valid. We are not storing a public key in the contract, so we cannot validate the signature. We will add this functionality in the next examples.

```rust
fn is_valid_signature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            // No signature is required so any signature is valid.
            VALIDATED
        }
```

The `__validate__` function calls the `is_valid_signature` function with a dummy hash and signature. The `__validate__` function is called by the Starknet protocol to validate the transaction. If the transaction is not valid, the execution of the transaction is aborted.

```rust
fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
            let hash = 0;
            let mut signature: Array<felt252> = ArrayTrait::new();
            signature.append(0);
            self.is_valid_signature(hash, signature)
        }
```

In other words we have implemented a contract that accepts all the transactions as valid. We will add the signature validation in the next examples.

## Executing Transactions

The `__execute__` function is responsible for executing the transaction. In this minimal account contract we will only execute a single call. We will add the multicall functionality in the next examples.

```rust
fn __execute__(self: @ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
            let Call{to, selector, calldata } = calls.at(0);
            let _res = starknet::call_contract_syscall(*to, *selector, calldata.span()).unwrap();
            let mut res = ArrayTrait::new();
            res.append(_res);
            res
        }
```

The `__execute__` function calls the `call_contract_syscall` function from the `starknet` module. This function executes the call and returns the result. The `call_contract_syscall` function is a Starknet syscall, which means that it is executed by the Starknet protocol. The Starknet protocol is responsible for executing the call and returning the result. The Starknet protocol will also validate the call, so we do not need to validate the call in the `__execute__` function.

## Deploying the Contract

[TODO]
