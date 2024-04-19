# Foundry Forge: Testing

Merely deploying contracts is not the end game. Many tools have offered this capability in the past. `Forge` sets itself apart by hosting a Cairo VM instance, enabling the sequential execution of tests. It employs Scarb for contract compilation.

To utilize Forge, define test functions and label them with test attributes. Users can either test standalone Cairo functions or integrate contracts, dispatchers, and test contract interactions on-chain.

## `snForge` Command-Line Usage

This section guides you through the [Starknet Foundry](https://github.com/foundry-rs/starknet-foundry) `snforge` command-line tool. Learn how to set up a new project, compile the code, and execute tests.

To start a new project with Starknet Foundry, use the `snforge init` command and replace `project_name` with your project's name.

```shell
snforge init project_name
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

Ensure the CASM and SIERRA code generation is active in the `Scarb.toml` file:

```shell
# ...
[[target.starknet-contract]]
casm = true
sierra = true
# ...
```

### Requirements for snforge

Before you run `snforge test` certain prerequisites must be addressed:

1. Install the latest [scarb version](#https://docs.swmansion.com/scarb/docs.html).
2. Install [starknet-foundry](#https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html) by running this command:

`curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh
`

Follow the instructions and then run:
`snfoundryup`

3. Check your `snforge` version, run :
   `snforge --version`

At the time of this tutorial, we used `snforge` version `snforge 0.21.0` which is the latest at this time.

### Test

Run tests using `snforge test`:

```shell
snforge test

Collected 2 test(s) from testing package
Running 0 test(s) from src/
Running 2 test(s) from tests/
[PASS] tests::test_contract::test_cannot_increase_balance_with_zero_value (gas: ~1839)
[PASS] tests::test_contract::test_increase_balance (gas: ~3065)
Tests: 2 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```

## Integrating `snforge` with Existing Scarb Projects

For those with an established Scarb project who wish to incorporate `snforge`, ensure the `snforge_std` package is declared as a dependency. Insert the line below in the [dependencies] section of your `Scarb.toml`:

```shell
# ...
[dependencies]
snforge_std = { git = "https://github.com/foundry-rs/starknet-foundry", tag = "v0.21.0" }
```

Ensure the tag version corresponds with your `snforge` version. To verify your `snforge` version:

```sh
snforge --version
```

Or, add this dependency using the `scarb` command:

```shell
scarb add snforge_std --git https://github.com/foundry-rs/starknet-foundry.git --tag v0.21.0
```

With these steps, your existing Scarb project is now **`snforge`**-ready.

## Testing with `snforge`

Utilize Starknet Foundry's `snforge test` command to efficiently run tests.

### Executing Tests

Navigate to the package directory and issue this command to run tests:

```shell
snforge test
```

Sample output might resemble:

```shell

Collected 2 test(s) from testing package
Running 0 test(s) from src/
Running 2 test(s) from tests/
[PASS] tests::test_contract::test_cannot_increase_balance_with_zero_value (gas: ~1839)
[PASS] tests::test_contract::test_increase_balance (gas: ~3065)
Tests: 2 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```

## Example: Testing a Simple Contract

The example provided below demonstrates how to test a Starknet contract using `snforge`.

```
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

    #[abi(embed_v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}

```

Remember, the identifier following `mod` signifies the contract name. Here, the contract name is `HelloStarknet`.

### Craft the Test

Below is a test for the **`HelloStarknet`** contract. This test deploys **`HelloStarknet`** and interacts with its functions:

```
use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use testing::IHelloStarknetSafeDispatcher;
use testing::IHelloStarknetSafeDispatcherTrait;
use testing::IHelloStarknetDispatcher;
use testing::IHelloStarknetDispatcherTrait;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::new()).unwrap()
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract('HelloStarknet');

    let dispatcher = IHelloStarknetDispatcher { contract_address };

    let balance_before = dispatcher.get_balance();
    assert(balance_before == 0, 'Invalid balance');

    dispatcher.increase_balance(42);

    let balance_after = dispatcher.get_balance();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract('HelloStarknet');

    let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

    #[feature("safe_dispatcher")]
    let balance_before = safe_dispatcher.get_balance().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    #[feature("safe_dispatcher")]
    match safe_dispatcher.increase_balance(0) {
        Result::Ok(_) => panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        }
    };
}
```

To run the test, execute the `snforge test` command. The expected output is:

```shell
Collected 2 test(s) from testing package
Running 0 test(s) from src/
Running 2 test(s) from tests/
[PASS] tests::test_contract::test_cannot_increase_balance_with_zero_value (gas: ~1839)
[PASS] tests::test_contract::test_increase_balance (gas: ~3065)
Tests: 2 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```

## Example: Testing ERC20 Contract

There are several methods to test smart contracts, such as unit tests, integration tests, fuzz tests, fork tests, E2E tests, and using foundry cheatcodes. This section discusses testing an ERC20 example contract from the `starknet-js` subchapter examples using unit and integration tests, filtering, foundry cheatcodes, and fuzz tests through the `snforge` CLI.

## ERC20 Contract Example

After setting up your foundry project, add the following dependency to your `Scarb.toml` (in this case we are using version 0.8.1 of the OpenZeppelin Cairo contracts, due to the fact that it uses components):

```shell
openzeppelin = { git = "https://github.com/OpenZeppelin/cairo-contracts.git", tag = "v0.8.1" }
```

Here's a basic ERC20 contract:

```
use starknet::ContractAddress;
#[starknet::interface]
trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: u256);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    );


    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::contract]
mod ERC20Token {

    // Importing necessary libraries

    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const;

    // Similar to address(0) in Solidity

    use core::zeroable::Zeroable;
    use super::IERC20;

    //Stroge Variables
    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap<ContractAddress, u256>,
        allowances: LegacyMap<
            (ContractAddress, ContractAddress), u256
        >, //similar to mapping(address => mapping(address => uint256))
    }
    //  Event
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Approval: Approval,
        Transfer: Transfer
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
    }

    // The contract constructor is not part of the interface. Nor are internal functions part of the interface.

    // Constructor

    #[constructor]
    fn constructor(ref self: ContractState, // _name: felt252,

    recipient: ContractAddress) {
        // The .is_zero() method here is used to determine whether the address type recipient is a 0 address, similar to recipient == address(0) in Solidity.
        assert(!recipient.is_zero(), 'transfer to zero address');

        self.name.write('ERC20Token');
        self.symbol.write('ECT');
        self.decimals.write(18);
        self.total_supply.write(1000000);
        self.balances.write(recipient, 1000000);

        self
            .emit(
                Transfer { //Here, `contract_address_const::<0>()` is similar to address(0) in Solidity
                    from: contract_address_const::<0>(), to: recipient, value: 1000000
                }
            );
    }

    #[abi(embed_v0)]
    impl IERC20Impl of IERC20<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }
        fn get_symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn get_decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn get_total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }


        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.allowances.read((owner, spender))
        }

     fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let owner = self.owner.read();
            let caller = get_caller_address();
            assert(owner == caller, Errors::CALLER_NOT_OWNER);
            assert(!recipient.is_zero(), Errors::ADDRESS_ZERO);
            assert(self.balances.read(recipient) >= amount, Errors::INSUFFICIENT_FUND);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.total_supply.write(self.total_supply.read() - amount);
            // call transfer
            // Transfer(Zeroable::zero(), recipient, amount);

            true
        }


        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.transfer_helper(caller, recipient, amount);
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            let caller = get_caller_address();
            let my_allowance = self.allowances.read((sender, caller));

            assert(my_allowance > 0, 'You have no token approved');
            assert(amount <= my_allowance, 'Amount Not Allowed');
            // assert(my_allowance <= amount, 'Amount Not Allowed');

            self
                .spend_allowance(
                    sender, caller, amount
                ); //responsible for deduction of the amount allowed to spend
            self.transfer_helper(sender, recipient, amount);
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) + added_value
                );
        }

        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) - subtracted_value
                );
        }
    }

    #[generate_trait]
    impl HelperImpl of HelperTrait {
        fn transfer_helper(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            let sender_balance = self.balance_of(sender);

            assert(!sender.is_zero(), 'transfer from 0');
            assert(!recipient.is_zero(), 'transfer to 0');
            assert(sender_balance >= amount, 'Insufficient fund');
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            true;

            self.emit(Transfer { from: sender, to: recipient, value: amount, });
        }

        fn approve_helper(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!owner.is_zero(), 'approve from 0');
            assert(!spender.is_zero(), 'approve to 0');

            self.allowances.write((owner, spender), amount);

            self.emit(Approval { owner, spender, value: amount, })
        }

        fn spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            // First, read the amount authorized by owner to spender
            let current_allowance = self.allowances.read((owner, spender));

            // define a variable ONES_MASK of type u128
            let ONES_MASK = 0xfffffffffffffffffffffffffffffff_u128;

            // to determine whether the authorization is unlimited,

            let is_unlimited_allowance = current_allowance.low == ONES_MASK
                && current_allowance
                    .high == ONES_MASK; //equivalent to type(uint256).max in Solidity.

            // This is also a way to save gas, because if the authorized amount is the maximum value of u256, theoretically, this amount cannot be spent.
            if !is_unlimited_allowance {
                self.approve_helper(owner, spender, current_allowance - amount);
            }
        }
    }
}
```

This contract allows minting tokens to a recipient during deployment, checking balances, and transferring tokens, relying on the OpenZeppelin ERC20 library.

### Test Preparation

Organize your test file and include the required imports:

```
#[cfg(test)]
mod test {
    use core::serde::Serde;
    use super::{IERC20, ERC20Token, IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::ContractAddress;
    use starknet::contract_address::contract_address_const;
    use core::array::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait, fs::{FileTrait, read_txt}};
    use snforge_std::{start_prank, stop_prank, CheatTarget};
    use snforge_std::PrintTrait;
    use core::traits::{Into, TryInto};
}
```

For testing, you'll need a helper function to deploy the contract instance.

This function requires a `supply` amount and `recipient` address:

Before deploying a starknet contract, we need a contract_class.

Get it using the declare function from [Starknet Foundry](#https://foundry-rs.github.io/starknet-foundry/)

Supply values for the constructor arguments when deploying

```

    fn deploy_contract() -> ContractAddress {
        let erc20contract_class = declare('
        ERC20Token');
        let file = FileTrait::new('data/constructor_args.txt');
        let constructor_args = read_txt(@file);
        let contract_address = erc20contract_class.deploy(@constructor_args).unwrap();
        contract_address
    }

```

Generate an address

```

    mod Account {
        use starknet::ContractAddress;
        use core::traits::TryInto;

        fn User1() -> ContractAddress {
            'user1'.try_into().unwrap()
        }
        fn User2() -> ContractAddress {
            'user2'.try_into().unwrap()
        }

        fn admin() -> ContractAddress {
            'admin'.try_into().unwrap()
        }
    }

```

Use `declare` and `ContractClassTrait` from `snforge_std`. Then, initialize the `supply` and `recipient`, declare the contract, compute the calldata, and deploy.

### Writing the Test Cases

### Verifying the contract details After Deployment using Fuzz testing

To begin, test the deployment helper function to confirm the details provided:

```
#[test]
    fn test_constructor() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        // let name = dispatcher.get_name();
        let name = dispatcher.get_name();

        assert(name == 'ERC20Token', 'name is not correct');
    }

    #[test]
    fn test_decimal_is_correct() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let decimal = dispatcher.get_decimals();

        assert(decimal == 18, 'Decimal is not correct');
    }

    #[test]
    fn test_total_supply() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let total_supply = dispatcher.get_total_supply();

        assert(total_supply == 1000000, 'Total supply is wrong');
    }

    #[test]
    fn test_address_balance() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let balance = dispatcher.get_total_supply();
        let admin_balance = dispatcher.balance_of(Account::admin());
        assert(admin_balance == balance, Errors::INVALID_BALANCE);

        start_prank(CheatTarget::One(contract_address), Account::admin());

        dispatcher.transfer(Account::user1(), 10);
        let new_admin_balance = dispatcher.balance_of(Account::admin());
        assert(new_admin_balance == balance - 10, Errors::INVALID_BALANCE);
        stop_prank(CheatTarget::One(contract_address));

        let user1_balance = dispatcher.balance_of(Account::user1());
        assert(user1_balance == 10, Errors::INVALID_BALANCE);
    }

    #[test]
    #[fuzzer(runs: 22, seed: 38)]
    fn test_allowance(amount: u256) {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(contract_address, 20);

        let currentAllowance = dispatcher.allowance(Account::admin(), contract_address);

        assert(currentAllowance == 20, Errors::NOT_ALLOWED);
        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    fn test_transfer() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        // Get original balances
        let original_sender_balance = dispatcher.balance_of(Account::admin());
        let original_recipient_balance = dispatcher.balance_of(Account::user1());

        start_prank(CheatTarget::One(contract_address), Account::admin());

        dispatcher.transfer(Account::user1(), 50);

        // Confirm that the funds have been sent!
        assert(
            dispatcher.balance_of(Account::admin()) == original_sender_balance - 50,
            Errors::FUNDS_NOT_SENT
        );

        // Confirm that the funds have been recieved!
        assert(
            dispatcher.balance_of(Account::user1()) == original_recipient_balance + 50,
            Errors::FUNDS_NOT_RECIEVED
        );

        stop_prank(CheatTarget::One(contract_address));
    }


    #[test]
    fn test_transfer_from() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(Account::user1(), 20);
        stop_prank(CheatTarget::One(contract_address));

        assert(dispatcher.allowance(Account::admin(), Account::user1()) == 20, Errors::NOT_ALLOWED);

        start_prank(CheatTarget::One(contract_address), Account::user1());
        dispatcher.transfer_from(Account::admin(), Account::user2(), 10);
        assert(
            dispatcher.allowance(Account::admin(), Account::user1()) == 10, Errors::FUNDS_NOT_SENT
        );
        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    #[should_panic(expected: ('Amount Not Allowed',))]
    fn test_transfer_from_should_fail() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(Account::user1(), 20);
        stop_prank(CheatTarget::One(contract_address));

        start_prank(CheatTarget::One(contract_address), Account::user1());
        dispatcher.transfer_from(Account::admin(), Account::user2(), 40);
    }

    #[test]
    #[should_panic(expected: ('You have no token approved',))]
    fn test_transfer_from_failed_when_not_approved() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        start_prank(CheatTarget::One(contract_address), Account::user1());
        dispatcher.transfer_from(Account::admin(), Account::user2(), 5);
    }

    #[test]
    fn test_approve() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(Account::user1(), 50);
        assert(dispatcher.allowance(Account::admin(), Account::user1()) == 50, Errors::NOT_ALLOWED);
    }

    #[test]
    fn test_increase_allowance() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(Account::user1(), 30);
        assert(dispatcher.allowance(Account::admin(), Account::user1()) == 30, Errors::NOT_ALLOWED);

        dispatcher.increase_allowance(Account::user1(), 20);

        assert(
            dispatcher.allowance(Account::admin(), Account::user1()) == 50,
            Errors::ERROR_INCREASING_ALLOWANCE
        );
    }

    #[test]
    fn test_decrease_allowance() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(Account::user1(), 30);
        assert(dispatcher.allowance(Account::admin(), Account::user1()) == 30, Errors::NOT_ALLOWED);

        dispatcher.decrease_allowance(Account::user1(), 5);

        assert(
            dispatcher.allowance(Account::admin(), Account::user1()) == 25,
            Errors::ERROR_DECREASING_ALLOWANCE
        );
    }
```

Running `snforge test` produces:

```shell
   Collected 12 test(s) from testing package
Running 12 test(s) from src/
[PASS] testing::ERC20Token::test::test_total_supply (gas: ~1839)
[PASS] testing::ERC20Token::test::test_decimal_is_correct (gas: ~3065)
[PASS] testing::ERC20Token::test::test_approve (gas: ~3165)
[PASS] testing::ERC20Token::test::test_decrease_allowance (gas: ~1015)
[PASS] testing::ERC20Token::test::test_constructor (gas: ~3067)
[PASS] testing::ERC20Token::test::test_transfer_from (gas: ~6130)
[PASS] testing::ERC20Token::test::test_transfer_from_should_fail (gas: ~3145)
[PASS] testing::ERC20Token::test::test_allowance (gas: ~5123)
[PASS] testing::ERC20Token::test::test_transfer (gas: ~3065)
[PASS] testing::ERC20Token::test::test_transfer_from_failed_when_not_approved (gas: ~3165)
[PASS] testing::ERC20Token::test::test_address_balance (gas: ~7335)
[PASS] testing::ERC20Token::test::test_increase_allowance(gas: ~3125)
Tests: 12 passed, 0 failed, 0 skipped, 0 ignored, 0 filtered out
```

# Fuzz Testing

Fuzz testing introduces random inputs to the code to identify vulnerabilities, security issues, and unforeseen behaviors. While you can manually provide these inputs, automation is preferable when testing a broad set of values.

Let discuss Random Fuzz Testing as a type of Fuzz testing:

## Random Fuzz testing

To convert a test to a random fuzz test, simply add arguments to the test function. These arguments can then be used in the test body. The test will be run many times against different randomly generated values.
See the example below in `test_fuzz.cairo`:

```
fn sum(a: felt252, b: felt252) -> felt252 {
    return a + b;
}

#[test]
fn test_sum(x: felt252, y: felt252) {
    assert(sum(x, y) == x + y, 'sum incorrect');
}
```

Then run `snforge test`

```
Running 0 test(s) from tests/
Tests: 0 passed, 1 failed, 0 skipped, 0 ignored, 0 filtered out


    Running 0 test(s) from src/
    Running 1 test(s) from tests/
    [PASS] tests::test_fuzz::test_fuzz_sum (fuzzer runs = 256)
    Tests: 1 passed, 0 failed, 0 skipped
Fuzzer seed: 214510115079707873

```

The fuzzer supports these types by February 2024:

- u8
- u16
- u32
- u64
- u128
- u256
- felt252

# Fuzzer Configuration

It is possible to configure the number of runs of the random fuzzer as well as its seed for a specific test case:

```
#[test]
#[fuzzer(runs: 22, seed: 38)]
fn test_sum(x: felt252, y: felt252) {
    assert(sum(x, y) == x + y, 'sum incorrect');
}
```

It can also be configured globally, via command line arguments:

```shell
$ snforge test --fuzzer-runs 1234 --fuzzer-seed 1111
```

Or in `scarb.toml`:

```shell
# ...
[tool.snforge]
fuzzer_runs = 1234
fuzzer_seed = 1111
# ...

```

For more insight on fuzz tests, you can view it [here](https://foundry-rs.github.io/starknet-foundry/testing/fuzz-testing.html)

## Filter Tests

To execute specific tests, use a filter string with the `snforge` command. Tests matching the filter based on their absolute module tree path will be executed.

For instance, to run all tests with the string 'test\_' in their name:

```shell
snforge test test_
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
snforge test test_fuzz_sum
```

To execute an exact test, combine the `--exact` flag with a fully qualified test name:

```shell
snforge test package_name::test_name --exact
```

To halt the test suite upon the first test failure, use the `--exit-first` flag:

```shell
snforge test --exit-first
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
