# Foundry Forge: Testing 🚧

[Starknet Foundry](https://github.com/foundry-rs/starknet-foundry) is a tool designed for testing and developing Starknet contracts. It is an adaptation of the Ethereum Foundry for Starknet, aiming to expedite the development process.

The project consists of two primary components:

- **Forge**: A testing tool specifically for Cairo contracts. This tool acts as a test runner and boasts features designed to enhance your testing process. Tests are written directly in Cairo, eliminating the need for other programming languages. Additionally, the Forge implementation uses Rust, mirroring Ethereum Foundry's choice of language.
- **Cast**: This serves as a DevOps tool for Starknet, initially supporting a series of commands to interface with Starknet. In the future, Cast aims to offer deployment scripts for contracts and other DevOps functions.

## Forge

Merely deploying contracts is not the end game. Many tools have offered this capability in the past. Forge sets itself apart by hosting a Cairo VM instance, enabling the sequential execution of tests. It employs Scarb for contract compilation.

To utilize Forge, define test functions and label them with test attributes. Users can either test standalone Cairo functions or integrate contracts, dispatchers, and test contract interactions on-chain.

## `snForge` Command-Line Usage

This section guides you through the Starknet Foundry `snforge` command-line tool. Learn how to set up a new project, compile the code, and execute tests.

To start a new project with Starknet Foundry, use the `--init` command and replace `project_name` with your project's name.

```shell
snforge --init project_name
```

Once you've set up the project, inspect its layout:

```shell
cd project_name
tree . -L 1
```

The project structure is as follows:

```shell
.
├── README.md
├── Scarb.toml
├── src
└── tests
```

- `src/` holds your contract source code.
- `tests/` is the location of your test files.
- `Scarb.toml` is for project and **`snforge`** configurations.

Ensure the casm code generation is active in the `Scarb.toml` file:

```shell
# ...
[[target.starknet-contract]]
casm = true
# ...
```

To run tests using `snforge`:

```shell
snforge

Collected 2 test(s) from the `test_name` package
Running 0 test(s) from `src/`
Running 2 test(s) from `tests/`
[PASS] tests::test_contract::test_increase_balance
[PASS] tests::test_contract::test_cannot_increase_balance_with_zero_value
Tests: 2 passed, 0 failed, 0 skipped
```

## Integrating `snforge` with Existing Scarb Projects

For those with an established Scarb project who wish to incorporate `snforge`, ensure the `snforge_std package` is declared as a dependency. Insert the line below in the [dependencies] section of your `Scarb.toml`:

```shell
# ...
[dependencies]
snforge_std = { git = "https://github.com/foundry-rs/starknet-foundry.git", tag = "[VERSION]" }
```

Ensure the tag version corresponds with your `snforge` version. To verify your `snforge` version:

```sh
snforge --version
```

Or, add this dependency using the `scarb` command:

```shell
scarb add snforge_std --git https://github.com/foundry-rs/starknet-foundry.git --tag VERSION
```

With these steps, your existing Scarb project is now **`snforge`**-ready.

## Testing with `snforge`

Utilize Starknet Foundry's `snforge` command to efficiently run tests.

### Executing Tests

Navigate to the package directory and issue this command to run tests:

```shell
snforge
```

Sample output might resemble:

```shell
Collected 3 test(s) from `package_name` package
Running 3 test(s) from `src/`
[PASS] package_name::executing
[PASS] package_name::calling
[PASS] package_name::calling_another
Tests: 3 passed, 0 failed, 0 skipped
```

### Filter Tests

Run specific tests using a filter string after the `snforge` command. Tests matching the filter based on their absolute module tree path will be executed:

```shell
$ snforge calling
```

### Run a Specific Test

Use the `--exact` flag and a fully qualified test name to run a particular test:

```shell
snforge package_name::calling --exact
```

### Stop After First Test Failure

To stop after the first test failure, add the `--exit-first` flag to the `snforge` command:

```shell
snforge --exit-first
```

## Basic Example

The example provided below demonstrates how to test a Starknet contract using `snforge`.

```rust
#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[external(v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        // Increases the balance by the specified amount.
        fn increase_balance(ref self: ContractState, amount: felt252) {
            self.balance.write(self.balance.read() + amount);
        }

        // Returns the balance.
        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
```

Remember, the identifier following `mod` signifies the contract name. Here, the contract name is `HelloStarknet`.

### Craft the Test

Below is a test for the **`HelloStarknet`** contract. This test deploys **`HelloStarknet`** and interacts with its functions:

```rust
use snforge_std::{ declare, ContractClassTrait };

#[test]
fn call_and_invoke() {
    // Declare and deploy the contract
    let contract = declare('HelloStarknet');
    let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

    // Instantiate a Dispatcher object for contract interactions
    let dispatcher = IHelloStarknetDispatcher { contract_address };

    // Invoke a contract's view function
    let balance = dispatcher.get_balance();
    assert(balance == 0, 'balance == 0');

    // Invoke another function to modify the storage state
    dispatcher.increase_balance(100);

    // Validate the transaction's effect
    let balance = dispatcher.get_balance();
    assert(balance == 100, 'balance == 100');
}
```

To run the test, execute the `snforge` command. The expected output is:

```shell
Collected 1 test(s) from using_dispatchers package
Running 1 test(s) from src/
[PASS] using_dispatchers::call_and_invoke
Tests: 1 passed, 0 failed, 0 skipped
```
