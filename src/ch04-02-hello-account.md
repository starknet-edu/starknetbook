# Hello World Account Contract

**NOTE:**
**THIS CHAPTER NEEDS TO BE UPDATED TO REFLECT THE NEW SYNTAX FOR ACCOUNT CONTRACTS. PLEASE DO NOT USE THIS CHAPTER AS A REFERENCE UNTIL THIS NOTE IS REMOVED.**

**CONTRIBUTE: This subchapter is missing an example of declaration, deployment and interaction with the contract. We would love to see your contribution! Please submit a PR.**

In this chapter, we will explore the fundamentals of account contracts
in Starknet using an example "Hello World" account contract written in
Cairo language. You can find it in the contracts directory of this
chapter in the Book’s repository (TODO: add link).

```rust
    // Import necessary modules
    #[account_contract]
    mod HelloAccount {
        use starknet::ContractAddress;
        use core::felt252;
        use array::ArrayTrait;
        use array::SpanTrait;

        // Validate deployment of the contract.
        // Returns starknet::VALIDATED to confirm successful validation.
        #[external]
        fn __validate_deploy__(
            class_hash: felt252, contract_address_salt: felt252, public_key_: felt252
        ) -> felt252 {
            starknet::VALIDATED
        }

        // Validate declaration of transactions using this Account.
        // This function enforces that transactions now require accounts to pay fees.
        // Returns starknet::VALIDATED to confirm successful validation.
        #[external]
        fn __validate_declare__(class_hash: felt252) -> felt252 {
            starknet::VALIDATED
        }

        // Validate transaction before execution.
        // This function is called by the account contract upon receiving a transaction.
        // If the validation is successful, it returns starknet::VALIDATED.
        #[external]
        fn __validate__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>
        ) -> felt252 {
            starknet::VALIDATED
        }

        // Execute transaction.
        // If the '__validate__' function is successful, this '__execute__' function will be called.
        // It forwards the call to the target contract using starknet::call_contract_syscall.
        #[external]
        #[raw_output]
        fn __execute__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>
        ) -> Span::<felt252> {
            starknet::call_contract_syscall(
                address: contract_address,
                entry_point_selector: entry_point_selector,
                calldata: calldata.span()
            ).unwrap_syscall()
        }
    }
```

## External Functions

The account contract includes several external functions to handle the
validation and execution of transactions. These functions are:

1.  `__validate_deploy__`: Validates the deployment of the contract.

2.  `__validate_declare__`: Validates the declaration of transactions
    using the account.

3.  `__validate__`: Validates a transaction before execution.

4.  `__execute__`: Executes a transaction after successful validation.

### *validate\_deploy*

This function is responsible for validating the deployment of the
account contract. It returns `starknet::VALIDATED` to confirm successful
validation.

```rust
    #[external]
    fn __validate_deploy__(
        class_hash: felt252, contract_address_salt: felt252, public_key_: felt252
    ) -> felt252 {
        starknet::VALIDATED
    }
```

### *validate\_declare*

This function enforces that transactions now require accounts to pay
fees. It returns `starknet::VALIDATED` to confirm successful validation.

```rust
    #[external]
    fn __validate_declare__(class_hash: felt252) -> felt252 {
        starknet::VALIDATED
    }
```

### *validate*

This function is called by the account contract upon receiving a
transaction. If the validation is successful, it returns
`starknet::VALIDATED`.

```rust
    #[external]
    fn __validate__(
        contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>
    ) -> felt252 {
        starknet::VALIDATED
    }
```

### *execute*

If the `__validate__` function is successful, this `__execute__`
function will be called. It forwards the call to the target contract
using `starknet::call_contract_syscall`.

```rust
    #[external]
    #[raw_output]
    fn __execute__(
        contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>
    ) -> Span::<felt252> {
        starknet::call_contract_syscall(
            address: contract_address,
            entry_point_selector: entry_point_selector,
            calldata: calldata.span()
        ).unwrap_syscall()
    }
```

## Declaring and Deploying the Hello World Account Contract

The declaring and deploying process is the same as with other contracts.
Before declaring and deploying the Hello World account contract, you
must first have an account contract set up to manage the deployment
process. To learn more about deploying an account contract, refer to the
subchapter on deploying in Chapter 2 of the Book.

Remember to compile using `scarb build` (refer to the Scarb subchapter
in Chapter 2 of the Book). Then follow the steps below to declare and
deploy the Hello World account contract:

-   Export the required environment variables:

<!-- -->

    export STARKNET_NETWORK=alpha-goerli
    export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount

-   Declare the contract (since the contract is already declared, you
    can skip this step. If you want to declare it anyway, run the
    following command but you will receive an error):

<!-- -->

    starknet declare --contract target/release/starknetbook_chapter_7_HelloAccount.json --account my_account --max_fee 100000000000000000

The class hash is:
0x07e813097812d58afbb4fb015e683f2b84e4f008cbecc60fa6dece7734a2cdfe

-   Deploy the contract:

<!-- -->

    starknet deploy --class_hash 0x07e813097812d58afbb4fb015e683f2b84e4f008cbecc60fa6dece7734a2cdfe --account my_account --max_fee 100000000000000000

After completing these steps, you will have successfully declared and
deployed the Hello World account contract on Starknet. [Here is a
deployed
version](https://testnet.starkscan.co/contract/0x01e6d7698ca76788c8f9c1091ec3d6d3f7167a9effe520402d832ca9894eba4a#overview).

## Summary

In this subchapter, we delved into the details of a basic account
contract in Starknet using a "Hello World" example.

We also outlined the steps to declare and deploy the Hello World account
contract on the Starknet network. The deployment process involves
exporting the required environment variables, declaring the contract,
and deploying it using the class hash.

As we progress in our exploration of Starknet account contracts, the
next subchapter will introduce a standard account contract, drawing
parallels with the standard account contract defined by Open Zeppelin
and Starkware. This will further strengthen our understanding of how
account contracts operate within the Starknet ecosystem.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
