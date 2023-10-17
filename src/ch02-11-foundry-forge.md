# Foundry Forge: Testing 🚧

[Starknet Foundry](https://github.com/foundry-rs/starknet-foundry) is a tool designed for testing and developing Starknet contracts. It is an adaptation of the Ethereum Foundry for Starknet, aiming to expedite the development process.

The project consists of two primary components:

- **Forge**: A testing tool specifically for Cairo contracts. This tool acts as a test runner and boasts features designed to enhance your testing process. Tests are written directly in Cairo, eliminating the need for other programming languages. Additionally, the Forge implementation uses Rust, mirroring Ethereum Foundry's choice of language.
- **Cast**: This serves as a DevOps tool for StarkNet, initially supporting a series of commands to interface with StarkNet. In the future, Cast aims to offer deployment scripts for contracts and other DevOps functions.

## Forge

Merely deploying contracts is not the end game. Many tools have offered this capability in the past. Forge sets itself apart by hosting a Cairo VM instance, enabling the sequential execution of tests. It employs Scarb for contract compilation.

To utilize Forge, define test functions and label them with test attributes. Users can either test standalone Cairo functions or integrate contracts, dispatchers, and test contract interactions on-chain.


##  Using `snForge` command-line

This section provides an introduction to the Starknet Foundry `snforge` command-line tool. We will walk you through the process of creating a new project, compiling your code, and running tests.

## Creating a New Project

To initiate a new project using Starknet Foundry, you can use the `--init` command. Replace `project_name` with the desired name for your project.

```shell
snforge --init project_name
```
After creating the project, you can explore its structure as follows:
```shell
$ cd project_name
$ tree . -L 1
.
├── README.md
├── Scarb.toml
├── src
└── tests
```
- src/ contains the source code for all your contracts.
- tests/ is where your test files are located.
- Scarb.toml contains the project and `snforge` configuration.
Make sure that the casm code generation is enabled in the Scarb.toml file:

```shell
# ...
[[target.starknet-contract]]
casm = true
# ...
```
Now, you can run tests with `snforge`:
```shell
$ snforge
Collected 2 test(s) from the `test_name` package
Running 0 test(s) from `src/`
Running 2 test(s) from `tests/`
[PASS] tests::test_contract::test_increase_balance
[PASS] tests::test_contract::test_cannot_increase_balance_with_zero_value
Tests: 2 passed, 0 failed, 0 skipped
```
## Using snforge with Existing Scarb Projects
If you have an existing Scarb project and want to use `snforge`, ensure that you have declared the `snforge_std package` as a dependency in your project. Add the following line under the [dependencies] section in your Scarb.toml file:
```shell
# ...
[dependencies]
snforge_std = { git = "https://github.com/foundry-rs/starknet-foundry.git", tag = "v0.7.1" }
```
Make sure that the version in the tag matches the version of snforge. You can check the installed snforge version with the following command:
```shell
$ snforge --version
forge 0.7.1
```
Alternatively, you can add this dependency using the `scarb` command:
```shell
$ scarb add snforge_std --git https://github.com/foundry-rs/starknet-foundry.git --tag v0.7.1
```
Now, you are ready to use `snforge` with your existing Scarb project.


## Running Tests with snforge
To run tests using the Starknet Foundry `snforge` command, follow these instructions. We will cover `test execution`, `test filtering`, `running specific tests`, and `handling test execution failures`.

### Running Tests
To execute tests, navigate to the package directory and run the following command:
```shell
$ snforge
```
This command collects and runs tests within the specified package. Here's an example output:
```shell
Collected 3 test(s) from `package_name` package
Running 3 test(s) from `src/`
[PASS] package_name::executing
[PASS] package_name::calling
[PASS] package_name::calling_another
Tests: 3 passed, 0 failed, 0 skipped
```
### Filtering Tests
You can filter the tests to run by passing a filter string after the `snforge` command. By default, tests with an absolute module tree path matching the filter will be executed:
```shell
$ snforge calling
Collected 2 test(s) from `package_name` package
Running 2 test(s) from `src/`
[PASS] package_name::calling
[PASS] package_name::calling_another
Tests: 2 passed, 0 failed, 0 skipped
```
### Running a Specific Test
To run a specific test, you can use the `--exact` flag along with the filter string. Ensure that you use a fully qualified test name, including the module name:
```shell
$ snforge package_name::calling --exact
Collected 1 test(s) from `package_name` package
Running 1 test(s) from `src/`
[PASS] package_name::calling
Tests: 1 passed, 0 failed, 0 skipped

```
### Stopping Test Execution After First Failed Test
To halt test execution after the first failed test, include the `--exit-first` flag with the `snforge` command:
```shell
$ snforge --exit-first
Collected 6 test(s) from package_name package
Running 6 test(s) from src/
[PASS] package_name::executing
[PASS] package_name::calling
[PASS] package_name::calling_another
[FAIL] package_name::failing

Failure data:
    original value: [8111420071579136082810415440747], converted to a string: [failing check]
    
[SKIP] package_name::other_test
[SKIP] package_name::yet_another_test
Tests: 3 passed, 1 failed, 2 skipped

Failures:
    package_name::failing
```

## Testing Starknet contract with `snforge` (Example)
In this example we'll be using the below starknet contract:
```shell
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
        // Increases the balance by the given amount.
        fn increase_balance(ref self: ContractState, amount: felt252) {
            self.balance.write(self.balance.read() + amount);
        }

        // Gets the balance. 
        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
``` 
It should be noted that the name written after `mod` is the contract name which would be referenced later on; in this case, it is `HelloStarknet`.

## Writing the test 
let's write the test cases for `HelloStarknet` contract. In this test, we'll deploy `Hellostarknet` and interact with some functions:

```shell
use snforge_std::{ declare, ContractClassTrait };

#[test]
fn call_and_invoke() {
    // First declare and deploy a contract
    let contract = declare('HelloStarknet');
    let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
    
    // Create a Dispatcher object that will allow interacting with the deployed contract
    let dispatcher = IHelloStarknetDispatcher { contract_address };

    // Call a view function of the contract
    let balance = dispatcher.get_balance();
    assert(balance == 0, 'balance == 0');

    // Call a function of the contract
    // Here we mutate the state of the storage
    dispatcher.increase_balance(100);

    // Check that transaction took effect
    let balance = dispatcher.get_balance();
    assert(balance == 100, 'balance == 100');
}
```
Now we are ready to run `snforge`. once you run the `snforge` command, you should get the below output
```shell
$ snforge
Collected 1 test(s) from using_dispatchers package
Running 1 test(s) from src/
[PASS] using_dispatchers::call_and_invoke
Tests: 1 passed, 0 failed, 0 skipped
```
Now you have successfully created and tested your starknet contract using `snforge`.

## snforge Commands
- Running `snforge` in the Current Directory
To run the snforge command in the current directory, simply execute the following command:

### Test Filter Options
- `-e, --exact`: Use the `-e` or `--exact` option to run a test with a name that exactly matches the provided test filter. The test filter should be a fully qualified test name, including the package name. For example, instead of specifying just `my_test`, use `package_name::my_test` as the test filter.

- `--init` <NAME>: The `--init` <NAME> option allows you to create a new directory and forge project with the specified name <NAME>.

- `-x`, `--exit-first`: By using the` -x` or `--exit-first` option, you can stop the execution of tests after the first test failure is encountered.

### Package Selection
- `-p`, `--package`: The `-p` or `--package` option is used to specify the packages on which to run the `snforge` command. You can either provide a concrete package name (e.g., foobar) or use a prefix glob (e.g., foo*) to match multiple packages.

- `-w`, `--workspace`: Use the `-w` or `--workspace` option to run tests for all packages in the workspace.

### Fuzzer Configuration
- `-r`, `--fuzzer-runs` <FUZZER_RUNS>: Specify the number of fuzzer runs using the `-r` or `--fuzzer-runs` option, followed by the desired number of runs <FUZZER_RUNS>.

- `-s`, `--fuzzer-seed` <FUZZER_SEED>: Set the seed for the fuzzer by using the `-s` or `--fuzzer-seed` option, followed by the desired seed value <FUZZER_SEED>.

### Cache Management
- `-c`, `--clean-cache`: To clean the `snforge` cache directory, simply use the `-c` or `--clean-cache` option.

### Help and Version Information
- `-h`,` --help`: Use the `-h` or `--help` option to print the help information, providing guidance on how to use `snforge`.

- `-V`, `--version`: To display the current version of `snforge`, use the `-V` or `--version` option.

Note: Replace <NAME>, <FUZZER_RUNS>, and <FUZZER_SEED> with your specific values when using the `snforge` command.







