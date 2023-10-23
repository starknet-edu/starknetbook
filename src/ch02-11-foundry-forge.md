# Foundry Forge: Testing 🚧

[Starknet Foundry](https://github.com/foundry-rs/starknet-foundry) is a tool designed for testing and developing Starknet contracts. It is an adaptation of the Ethereum Foundry for Starknet, aiming to expedite the development process.

The project consists of two primary components:

- **Forge**: A testing tool specifically for Cairo contracts. This tool acts as a test runner and boasts features designed to enhance your testing process. Tests are written directly in Cairo, eliminating the need for other programming languages. Additionally, the Forge implementation uses Rust, mirroring Ethereum Foundry's choice of language.
- **Cast**: This serves as a DevOps tool for StarkNet, initially supporting a series of commands to interface with StarkNet. In the future, Cast aims to offer deployment scripts for contracts and other DevOps functions.

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

## Diving deep into Smart contract testing with `snforge` command line.

Ideally, there are various way to test your smart contract which may include unit and integration test, fuzz, fork, E2E test, and testing with foundry cheatcodes. In this section, we'll be considering an ERC20 example contract from starknet-js examples, And we'll be taking into consideration unit and integration tests, filtering, foundry cheatcodes and fuzz testing using `snforge` cli.

## An ERC20 example

After initializing your foundry project, include the below in your `Scarb.toml` in your dependencies:

```shell
    openzeppelin = { git = "https://github.com/OpenZeppelin/cairo-contracts.git", tag = "v0.7.0" }
```

Now, Take a look at the erc20 smart contract below:

```rust
    use starknet::ContractAddress;
    #[starknet::interface]
    trait Ierc20<TContractState> {
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::contract]
mod erc20 {
    use starknet::ContractAddress;
    use openzeppelin::token::erc20::ERC20;

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(
        ref self: ContractState,
        initial_supply: felt252,
        recipient: ContractAddress
    ) {
        let name = 'MyToken';
        let symbol = 'MTK';

        let mut unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::InternalImpl::initializer(ref unsafe_state, name, symbol);
        ERC20::InternalImpl::_mint(ref unsafe_state, recipient, initial_supply.into());
    }

    #[external(v0)]
    impl Ierc20Impl of super::Ierc20<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::balance_of(@unsafe_state, account)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let mut unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::transfer(ref unsafe_state, recipient, amount)
        }
    }
}
```

It's a basic erc20 contract that allows us to `mint` token to recipient at deployment, check the `balance of` addresses and `transfer` tokens. We are relying on openzeppelin ERC20 library.

## Test setup

Structure the test file as below and bring in necessary imports as below;

```rust
    #[cfg(test)]
    mod tests {
    use array::ArrayTrait;
    use result::ResultTrait;
    use option::OptionTrait;
    use traits::TryInto;
    use starknet::ContractAddress;
    use starknet::Felt252TryIntoContractAddress;

    use snforge_std::{declare, ContractClassTrait};

        //rest of the code goes here.
    }
```

When writing test cases we need an helper function to deploy an instance of the contract. The helper function will take in two arguments i.e the `supply` amount and the `recipient` address as below;

```rust
    // ...
    use snforge_std::{declare, ContractClassTrait};


    fn deploy_contract(name: felt252) -> ContractAddress {
    let recipient = starknet::contract_address_const::<0x01>();
    let supply : felt252 = 20000000;
    let contract = declare(name);
    let mut calldata = array![supply, recipient.into()];
    contract.deploy(@calldata).unwrap()
}
    //...rest for the code
```

We then import the `declare` and `ContractClassTrait` from `snforge_std`, after which we initialize the arguments(`supply`,`recipient`), declare the contract, compute the calldata and deploy.

## Writing the Test cases

Firstly, we need to test deployment helper function and the balance of the recipient to confirm mint value as below;

```rust
    // ...
    use erc20_contract::erc20::Ierc20SafeDispatcher;
    use erc20_contract::erc20::Ierc20SafeDispatcherTrait;

    #[test]
    #[available_gas(3000000000000000)]
    fn test_balance_of() {
        let contract_address = deploy_contract('erc20');
        let safe_dispatcher = Ierc20SafeDispatcher { contract_address };
        let recipient = starknet::contract_address_const::<0x01>();
        let balance = safe_dispatcher.balance_of(recipient).unwrap();
        assert (balance == 20000000, 'Invalid Balance');
    }
```

Run `snforge` you should get this output:

```shell
    snforge

    Collected 1 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 1 test(s) from tests/
    [PASS] tests::test_erc20::tests::test_balance_of
    Tests: 1 passed, 0 failed, 0 skipped
```

## Testing with foundry cheat codes

What are cheat codes? they are basically helper functions exposed by `snforge_std` which enables us to carry out various test scenarios; we could decide to warp time, change block number for contract or change block timestamp in order for us to test out different edge cases. Cheat codes includes `start_prank`, `start_roll`, `get_class_hash`, `l1_handler_execute` etc. For the sake of this example, we'll be considering `start_prank` and `stop_prank`. The start_prank will set the caller of the function i.e changes the address initiating the function call while stop_prank cancels the start_prank. Consider the test example below:

```rust
    /// ...
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};

    #[test]
    #[available_gas(3000000000000000)]
    fn test_transfer() {
    let contract_address = deploy_contract('erc20');
    let safe_dispatcher = Ierc20SafeDispatcher { contract_address };

    let sender = starknet::contract_address_const::<0x01>();
    let receiver = starknet::contract_address_const::<0x02>();
    let amount : felt252 = 10000000;

    //sets the caller of the function
    start_prank(contract_address, sender);
    safe_dispatcher.transfer(receiver.into(), amount.into());

    let balance_after_transfer = safe_dispatcher.balance_of(receiver).unwrap();
    assert(balance_after_transfer == 10000000, 'invalid amount');

    //stops ongoing prank
    stop_prank(contract_address);
 }

```

Run `snforge`, on the two test cases above, you should get an output like this:

```shell
    snforge

    Collected 2 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 2 test(s) from tests/
    [PASS] tests::test_erc20::tests::test_balance_of
    [PASS] tests::test_erc20::tests::test_transfer
    Tests: 2 passed, 0 failed, 0 skipped
```

`start_prank` in the above snippet, sets the caller of the transfer function and the `stop_prank` cancels the `start_prank` at the end of the function call.

<details>
<summary>Click to see full `ERC20 test example` test file</summary>

        #[cfg(test)]
        mod tests {
        use array::ArrayTrait;
        use result::ResultTrait;
        use option::OptionTrait;
        use traits::TryInto;
        use starknet::ContractAddress;
        use starknet::Felt252TryIntoContractAddress;

        use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};

        use erc20_contract::erc20::Ierc20SafeDispatcher;
        use erc20_contract::erc20::Ierc20SafeDispatcherTrait;



        fn deploy_contract(name: felt252) -> ContractAddress {
            let reciepient = starknet::contract_address_const::<0x01>();
            let supply : felt252 = 20000000;
            let contract = declare(name);
            let mut calldata = array![supply, reciepient.into()];
            contract.deploy(@calldata).unwrap()
        }

        #[test]
        #[available_gas(3000000000000000)]
        fn test_balance_of() {
            let contract_address = deploy_contract('erc20');
            let safe_dispatcher = Ierc20SafeDispatcher { contract_address };
            let reciepient = starknet::contract_address_const::<0x01>();
            let balance = safe_dispatcher.balance_of(reciepient).unwrap();
            assert (balance == 20000000, 'Invalid Balance');
        }

        #[test]
        #[available_gas(3000000000000000)]
        fn test_transfer() {
            let contract_address = deploy_contract('erc20');
            let safe_dispatcher = Ierc20SafeDispatcher { contract_address };

            let sender = starknet::contract_address_const::<0x01>();
            let receiver = starknet::contract_address_const::<0x02>();
            let amount : felt252 = 10000000;

            start_prank(contract_address, sender);
            safe_dispatcher.transfer(receiver.into(), amount.into());
            let balance_after_transfer = safe_dispatcher.balance_of(receiver).unwrap();
            assert(balance_after_transfer == 10000000, 'invalid amount');
            stop_prank(contract_address);
        }

        }

</details>

## Fuzz testing

What's fuzz testing? Fuzz testing for involves subjecting the code to random inputs and scenarios to discover vulnerabilities, security flaws, and unexpected behavior. Although you can decide to input these random values yourself, nonetheless, its not ideal most especially when you intend to test a wide range of possible values. Consider the below snippet in a test_fuzz.cairo file:

```rust
    fn mul(a: felt252, b: felt252) -> felt252{
            a * b
        }

    #[test]
    fn test_fuzz_sum (x: felt252, y: felt252){
        assert(mul(x, y) == x * y, 'incorrect');
    }
```

The output after running `snforge` should look like this:

```shell
    snforge

    Collected 1 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 1 test(s) from tests/
    [PASS] tests::test_fuzz::test_fuzz_sum (fuzzer runs = 256)
    Tests: 1 passed, 0 failed, 0 skipped
    Fuzzer seed: 6375310854403272271
```

At the moment, the fuzzer only supports generating values for the following types :

- u8
- u16
- u32
- u64
- u128
- u256
- felt252

## Configuring fuzzer

It is possible to configure the number of runs and also specified the seed for a test as below:

```rust
    #[test]
    #[fuzzer(runs: 100, seed: 38)]
    fn test_fuzz_sum (x: felt252, y: felt252){
        assert(mul(x, y) == x * y, 'incorrect');
    }
```

or configure using the command line :

```shell
    $ snforge --fuzzer-runs 500 --fuzzer-seed 4656
```

or in scarb.toml:

```shell
    # ...
    [tool.snforge]
    fuzzer_runs = 500
    fuzzer_seed = 4656
    # ...
```

## Filter tests

Run specific tests using a filter string after the `snforge` command. Tests matching the filter based on their absolute module tree path will be executed:. for example; with reference to the above test cases, if we run this

```rust,ignore
    $ snforge test_
```

we should get this output:

```shell
    Collected 3 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 3 test(s) from tests/
    [PASS] tests::test_erc20::tests::test_balance_of
    [PASS] tests::test_erc20::tests::test_transfer
    [PASS] tests::test_fuzz::test_fuzz_sum (fuzzer runs = 256)
    Tests: 3 passed, 0 failed, 0 skipped
    Fuzzer seed: 10426315620495146768
```

When you look closely, all the tests with the string 'test\_' in their test name when through. Now, consider this second example;
if we run this:

```shell
    $ snforge fuzz_sum
```

The output should look like this:

```shell

    Collected 1 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 1 test(s) from tests/
    [PASS] tests::test_fuzz::test_fuzz_sum (fuzzer runs = 256)
    Tests: 1 passed, 0 failed, 0 skipped
    Fuzzer seed: 12607758074950729376
```

What do you notice? Yes, that's right, only the `test_fuzz_sum` went through because we filtered which test to run with the string 'fuzz_sum'.

## Run a Specific Test

Use the `--exact` flag and a fully qualified test name to run a particular test. In order to run a specifc test with the --exact flag, run the following command:

```shell
    $ snforge package_name::<test_name> --exact
```

## Stop After First Test Failure

To stop test execution after the first failed test, include the `--exit-first` flag with the `snforge` command like this:

```shell
    $ snforge --exit-first
```

Peradventure there's a failing test, the output should look like this:

```shell
    Collected 3 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 3 test(s) from tests/
    [FAIL] tests::test_erc20::tests::test_balance_of

    Failure data:
    original value: [381278114803728420489684244530881381], converted to a string: [Invalid Balance]

    [SKIP] tests::test_erc20::tests::test_transfer
    [SKIP] tests::test_fuzz::test_fuzz_sum
    Tests: 0 passed, 1 failed, 2 skipped

    Failures:
        tests::test_erc20::tests::test_balance_of
```
