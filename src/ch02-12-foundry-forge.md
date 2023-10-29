# Foundry Forge: Testing

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

Ensure the CASM code generation is active in the `Scarb.toml` file:

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

## Example: Testing a Simple Contract

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

## Example: Testing ERC20 Contract

There are several methods to test smart contracts, such as unit tests, integration tests, fuzz tests, fork tests, E2E tests, and using foundry cheatcodes. This section discusses testing an ERC20 example contract from the `starknet-js` subchapter examples using unit and integration tests, filtering, foundry cheatcodes, and fuzz tests through the `snforge` CLI.

## ERC20 Contract Example

After setting up your foundry project, add the following dependency to your `Scarb.toml` (in this case we are using version 0.7.0 of the OpenZeppelin Cairo contracts, but you can use any version you want):

```shell
openzeppelin = { git = "https://github.com/OpenZeppelin/cairo-contracts.git", tag = "v0.7.0" }
```

Here's a basic ERC20 contract:

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

This contract allows minting tokens to a recipient during deployment, checking balances, and transferring tokens, relying on the openzeppelin ERC20 library.

### Test Preparation

Organize your test file and include the required imports:

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
    // Additional code here.
}
```

For testing, you'll need a helper function to deploy the contract instance. This function requires a `supply` amount and `recipient` address:

```rust
use snforge_std::{declare, ContractClassTrait};

fn deploy_contract(name: felt252) -> ContractAddress {
    let recipient = starknet::contract_address_const::<0x01>();
    let supply: felt252 = 20000000;
    let contract = declare(name);
    let mut calldata = array![supply, recipient.into()];
    contract.deploy(@calldata).unwrap()
}
// Additional code here.
```

Use `declare` and `ContractClassTrait` from `snforge_std`. Then, initialize the `supply` and `recipient`, declare the contract, compute the calldata, and deploy.

### Writing the Test Cases

#### Verifying the Balance After Deployment

To begin, test the deployment helper function to confirm the recipient's balance:

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
        assert(balance == 20000000, 'Invalid Balance');
    }
```

Execute `snforge` to verify:

```shell
Collected 1 test from erc20_contract package
[PASS] tests::test_erc20::test_balance_of
```

#### Utilizing Foundry Cheat Codes

When testing smart contracts, simulating different conditions is essential. `Foundry Cheat Codes` from the `snforge_std` library offer these simulation capabilities for Starknet smart contracts.

These cheat codes consist of helper functions that adjust the smart contract's environment. They allow developers to modify parameters or conditions to examine contract behavior in specific scenarios.

Using `snforge_std`'s cheat codes, you can change elements like block numbers, timestamps, or even the caller of a function. This guide focuses on `start_prank` and `stop_prank`. You can find a reference to available cheat codes [here](https://foundry-rs.github.io/starknet-foundry/appendix/cheatcodes.html)

Below is a transfer test example:

```rust
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};

    #[test]
    #[available_gas(3000000000000000)]
    fn test_transfer() {
        let contract_address = deploy_contract('erc20');
        let safe_dispatcher = Ierc20SafeDispatcher { contract_address };

        let sender = starknet::contract_address_const::<0x01>();
        let receiver = starknet::contract_address_const::<0x02>();
        let amount : felt252 = 10000000;

        // Set the function's caller
        start_prank(contract_address, sender);
        safe_dispatcher.transfer(receiver.into(), amount.into());

        let balance_after_transfer = safe_dispatcher.balance_of(receiver).unwrap();
        assert(balance_after_transfer == 10000000, 'Incorrect Amount');

        // End the prank
        stop_prank(contract_address);
    }
```

Executing `snforge` for the tests displays:

```shell
Collected 2 tests from erc20_contract package
[PASS] tests::test_erc20::test_balance_of
[PASS] tests::test_erc20::test_transfer
```

In this example, `start_prank` determines the transfer function's caller, while `stop_prank` concludes the prank.

<details>
<summary>Full `ERC20 test example` file</summary>
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
            let recipient = starknet::contract_address_const::<0x01>();
            let supply : felt252 = 20000000;
            let contract = declare(name);
            let mut calldata = array![supply, recipient.into()];
            contract.deploy(@calldata).unwrap()
        }

        #[test]
        #[available_gas(3000000000000000)]
        fn test_balance_of() {
            let contract_address = deploy_contract('erc20');
            let safe_dispatcher = Ierc20SafeDispatcher { contract_address };
            let recipient = starknet::contract_address_const::<0x01>();
            let balance = safe_dispatcher.balance_of(recipient).unwrap();
            assert(balance == 20000000, 'Invalid Balance');
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
            assert(balance_after_transfer == 10000000, 'Incorrect Amount');
            stop_prank(contract_address);
        }
        }

</details>

## Fuzz Testing

Fuzz testing introduces random inputs to the code to identify vulnerabilities, security issues, and unforeseen behaviors. While you can manually provide these inputs, automation is preferable when testing a broad set of values. See the example below in `test_fuzz.cairo`:

```rust
    fn mul(a: felt252, b: felt252) -> felt252 {
        return a * b;
    }

    #[test]
    fn test_fuzz_sum(x: felt252, y: felt252) {
        assert(mul(x, y) == x * y, 'incorrect');
    }
```

Running `snforge` produces:

```shell
    Collected 1 test(s) from erc20_contract package
    Running 0 test(s) from src/
    Running 1 test(s) from tests/
    [PASS] tests::test_fuzz::test_fuzz_sum (fuzzer runs = 256)
    Tests: 1 passed, 0 failed, 0 skipped
    Fuzzer seed: 6375310854403272271
```

The fuzzer supports these types by November 2023:

- u8
- u16
- u32
- u64
- u128
- u256
- felt252

`Fuzzer Configuration`

You can set the number of runs and the seed for a test:

```rust
    #[test]
    #[fuzzer(runs: 100, seed: 38)]
    fn test_fuzz_sum(x: felt252, y: felt252) {
        assert(mul(x, y) == x * y, 'incorrect');
    }
```

Or, use the command line:

```shell
    $ snforge --fuzzer-runs 500 --fuzzer-seed 4656
```

Or in `scarb.toml`:

```shell
    # ...
    [tool.snforge]
    fuzzer_runs = 500
    fuzzer_seed = 4656
    # ...
```

For more insight on fuzz tests, you can view it [here](https://foundry-rs.github.io/starknet-foundry/testing/fuzz-testing.html#fuzz-testing)

## Filter Tests

To execute specific tests, use a filter string with the `snforge` command. Tests matching the filter based on their absolute module tree path will be executed.

For instance, to run all tests with the string 'test\_' in their name:

```shell
snforge test_
```

Expected output:

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

All the tests with the string 'test\_' in their test name went through.

Another example: To filter and run `test_fuzz_sum` we can partially match the test name with the string 'fuzz_sum' like this:

```shell
snforge test_fuzz_sum
```

To execute an exact test, combine the `--exact` flag with a fully qualified test name:

```shell
snforge package_name::test_name --exact
```

To halt the test suite upon the first test failure, use the `--exit-first` flag:

```shell
snforge --exit-first
```

If a test fails, the output will resemble:

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

### Conclusion

Starknet Foundry offers a notable step forward in Starknet contract development and testing. This toolset sharpens the process of creating, deploying, and testing Cairo contracts. Its main components, Forge and Cast, provide developers with robust tools for Cairo contract work.

Forge shines with its dual functionality: deploying and thoroughly testing Cairo contracts. It directly supports test writing in Cairo, removing the need for other languages and simplifying the task. Moreover, Forge seamlessly integrates with Scarb, emphasizing its adaptability, especially with existing Scarb projects.

The `snforge` command-line tool makes initializing, setting up, and testing Starknet contracts straightforward.
