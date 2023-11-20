# Multi-Signature Accounts

**NOTE:**
**THIS CHAPTER NEEDS TO BE UPDATED TO REFLECT THE NEW SYNTAX FOR ACCOUNT CONTRACTS. PLEASE DO NOT USE THIS CHAPTER AS A REFERENCE UNTIL THIS NOTE IS REMOVED.**

**CONTRIBUTE: This subchapter is missing an example of declaration, deployment and interaction with the contract. We would love to see your contribution! Please submit a PR.**

Multisignature (multisig) technology is an integral part of the modern
blockchain landscape. It enhances security by requiring multiple
signatures to confirm a transaction, hence reducing the risk of
fraudulent transactions and increasing control over asset management.

In Starknet, the concept of multisig accounts is abstracted at the
protocol level, allowing developers to implement custom account
contracts that embody this concept. In this chapter, we’ll delve into
the workings of a multisig account and see how it’s created in Starknet
using an account contract.

## What is a Multisig Account?

A multisig account is an account that requires more than one signature
to authorize transactions. This significantly enhances security,
requiring multiple entities' consent to transact funds or perform
critical actions.

Key specifications of a multisig account include:

- Public keys that form the account

- Threshold number of signatures required

A transaction signed by a multisig account must be individually signed
by the different keys specified for the account. If fewer than the
threshold number of signatures needed are present, the resultant
multisignature is considered invalid.

In Starknet, accounts are abstractions provided at the protocol level.
Therefore, to create a multisig account, one needs to code the logic
into an account contract and deploy it.

The contract below serves as an example of a multisig account contract.
When deployed, it can create a native multisig account using the concept
of account abstraction. Please note that this is a simplified example
and lacks comprehensive checks and validations found in a
production-grade multisig contract.

## Multisig Account Contract

This is the Rust code for a multisig account contract:

```rust
    #[account_contract]
    mod MultisigAccount {
        use ecdsa::check_ecdsa_signature;
        use starknet::ContractAddress;
        use zeroable::Zeroable;
        use array::ArrayTrait;
        use starknet::get_caller_address;
        use box::BoxTrait;
        use array::SpanTrait;

        struct Storage {
            index_to_owner: LegacyMap::<u32, felt252>,
            owner_to_index: LegacyMap::<felt252, u32>,
            num_owners: usize,
            threshold: usize,
            curr_tx_index: felt252,
            //Mapping between tx_index and num of confirmations
            tx_confirms: LegacyMap<felt252, usize>,
            //Mapping between tx_index and its execution state
            tx_is_executed: LegacyMap<felt252, bool>,
            //Mapping between a transaction index and its hash
            transactions: LegacyMap<felt252, felt252>,
            has_confirmed: LegacyMap::<(ContractAddress, felt252), bool>,
        }

        #[constructor]
        fn constructor(public_keys: Array::<felt252>, _threshold: usize) {
            assert(public_keys.len() <= 3_usize, 'public_keys.len <= 3');
            num_owners::write(public_keys.len());
            threshold::write(_threshold);
            _set_owners(public_keys.len(), public_keys);
        }

        //GETTERS
        //Get number of confirmations for a given transaction index
        #[view]
        fn get_confirmations(tx_index : felt252) -> usize {
            tx_confirms::read(tx_index)
        }

        //Get the number of owners of this account
        #[view]
        fn get_num_owners() -> usize {
            num_owners::read()
        }


        //Get the public key of the owners
        //TODO - Recursively add the owners into an array and return, maybe wait for loops to be enabled


        //EXTERNAL FUNCTIONS

        #[external]
        fn submit_tx(public_key: felt252) {

            //Need to check if caller is one of the owners.
            let tx_info = starknet::get_tx_info().unbox();
            let signature: Span<felt252> = tx_info.signature;
            let caller = get_caller_address();
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');

            //Updating the transaction index
            let tx_index = curr_tx_index::read();

            //`true` if a signature is valid and `false` otherwise.
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key,
                    signature_r: *signature.at(0_u32),
                    signature_s: *signature.at(1_u32),
                ),
                'INVALID_SIGNATURE',
            );

            transactions::write(tx_index, tx_info.transaction_hash);
            curr_tx_index::write(tx_index + 1);

        }

        #[external]
        fn confirm_tx(tx_index: felt252, public_key: felt252) {

            let transaction_hash = transactions::read(tx_index);
            //TBD: Assert that tx_hash is not null

            let num_confirmations = tx_confirms::read(tx_index);
            let executed = tx_is_executed::read(tx_index);

            assert(executed == false, 'TX_ALREADY_EXECUTED');

            let caller = get_caller_address();
            let tx_info = starknet::get_tx_info().unbox();
            let signature: Span<felt252> = tx_info.signature;

             assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key,
                    signature_r: *signature.at(0_u32),
                    signature_s: *signature.at(1_u32),
                ),
                'INVALID_SIGNATURE',
            );

            let confirmed = has_confirmed::read((caller, tx_index));

            assert (confirmed == false, 'CALLER_ALREADY_CONFIRMED');
            tx_confirms::write(tx_index, num_confirmations+1_usize);
            has_confirmed::write((caller, tx_index), true);


        }

        //An example function to validate that there are at least two signatures
        fn validate_transaction(public_key: felt252) -> felt252 {
            let tx_info = starknet::get_tx_info().unbox();
            let signature: Span<felt252> = tx_info.signature;
            let caller = get_caller_address();
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');

            //`true` if a signature is valid and `false` otherwise.
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key,
                    signature_r: *signature.at(0_u32),
                    signature_s: *signature.at(1_u32),
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED
        }

        //INTERNAL FUNCTION
        //Function to add the public keys of the multisig in permanent storage
        fn _set_owners(owners_len: usize, public_keys: Array::<felt252>) {
            if owners_len == 0_usize {
            }

            index_to_owner::write(owners_len, *public_keys.at(owners_len - 1_usize));
            owner_to_index::write(*public_keys.at(owners_len - 1_usize), owners_len);
            _set_owners(owners_len - 1_u32, public_keys);
        }


        #[external]
        fn __validate_deploy__(
            class_hash: felt252, contract_address_salt: felt252, public_key_: felt252
        ) -> felt252 {
            validate_transaction(public_key_)
        }

        #[external]
        fn __validate_declare__(class_hash: felt252, public_key_: felt252) -> felt252 {
            validate_transaction(public_key_)
        }

        #[external]
        fn __validate__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>, public_key_: felt252
        ) -> felt252 {
            validate_transaction(public_key_)
        }

        #[external]
        #[raw_output]
        fn __execute__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>,
            tx_index: felt252
        ) -> Span::<felt252> {
            // Validate caller.
            assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

            // Check the tx version here, since version 0 transaction skip the __validate__ function.
            let tx_info = starknet::get_tx_info().unbox();
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            //Multisig check here
            let num_confirmations = tx_confirms::read(tx_index);
            let owners_len = num_owners::read();
            //Subtracting one for the submitter
            let required_confirmations = threshold::read() - 1_usize;
            assert(num_confirmations >= required_confirmations, 'MINIMUM_50%_CONFIRMATIONS');

            tx_is_executed::write(tx_index, true);

            starknet::call_contract_syscall(
                contract_address, entry_point_selector, calldata.span()
            ).unwrap_syscall()
        }
    }
```

## Multisig Transaction Flow

The flow of a multisig transaction includes the following steps:

1.  Submitting a transaction: Any of the owners can submit a transaction
    from the account.

2.  Confirming the transaction: The owner who hasn’t submitted a
    transaction can confirm the transaction.

The transaction will be successfully executed if the number of
confirmations (including the submitter’s signature) is greater than or
equal to the threshold number of signatures, else it fails. This
mechanism of confirmation ensures that no single party can unilaterally
perform critical actions, thereby enhancing the security of the account.

## Exploring Multisig Functions

Let’s take a closer look at the various functions associated with
multisig functionality in the provided contract.

### `_set_owners` Function

This is an internal function designed to add the public keys of the
account owners to a permanent storage. Ideally, a multisig account
structure should permit adding and deleting owners as per the agreement
of the account owners. However, each change should be a transaction
requiring the threshold number of signatures.

```rust
    //INTERNAL FUNCTION
    //Function to add the public keys of the multisig in permanent storage
    fn _set_owners(owners_len: usize, public_keys: Array::<felt252>) {
        if owners_len == 0_usize {
        }

        index_to_owner::write(owners_len, *public_keys.at(owners_len - 1_usize));
        owner_to_index::write(*public_keys.at(owners_len - 1_usize), owners_len);
        _set_owners(owners_len - 1_u32, public_keys);
    }
```

### `submit_tx` Function

This external function allows the owners of the account to submit
transactions. Upon submission, the function checks the validity of the
transaction, ensures the caller is one of the account owners, and adds
the transaction to the transactions map. It also increments the current
transaction index.

```rust
    #[external]
    fn submit_tx(public_key: felt252) {

        //Need to check if caller is one of the owners.
        let tx_info = starknet::get_tx_info().unbox();
        let signature: Span<felt252> = tx_info.signature;
        let caller = get_caller_address();
        assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');

        //Updating the transaction index
        let tx_index = curr_tx_index::read();

        //`true` if a signature is valid and `false` otherwise.
        assert(
            check_ecdsa_signature(
                message_hash: tx_info.transaction_hash,
                public_key: public_key,
                signature_r: *signature.at(0_u32),
                signature_s: *signature.at(1_u32),
            ),
            'INVALID_SIGNATURE',
        );

        transactions::write(tx_index, tx_info.transaction_hash);
        curr_tx_index::write(tx_index + 1);

    }
```

### `confirm_tx` Function

Similarly, the **_`confirm_tx`_** function provides a way to record
confirmations for each transaction. An account owner, who did not submit
the transaction, can confirm it, increasing its confirmation count.

```rust
        #[external]
        fn confirm_tx(tx_index: felt252, public_key: felt252) {

            let transaction_hash = transactions::read(tx_index);
            //TBD: Assert that tx_hash is not null

            let num_confirmations = tx_confirms::read(tx_index);
            let executed = tx_is_executed::read(tx_index);

            assert(executed == false, 'TX_ALREADY_EXECUTED');

            let caller = get_caller_address();
            let tx_info = starknet::get_tx_info().unbox();
            let signature: Span<felt252> = tx_info.signature;

             assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key,
                    signature_r: *signature.at(0_u32),
                    signature_s: *signature.at(1_u32),
                ),
                'INVALID_SIGNATURE',
            );

            let confirmed = has_confirmed::read((caller, tx_index));

            assert (confirmed == false, 'CALLER_ALREADY_CONFIRMED');
            tx_confirms::write(tx_index, num_confirmations+1_usize);
            has_confirmed::write((caller, tx_index), true);
        }
```

### _`execute`_ Function

The _execute_ function serves as the final step in the transaction
process. It checks the validity of the transaction, whether it has been
previously executed, and if the threshold number of signatures has been
reached. The transaction is executed if all the checks pass.

```rust
    #[external]
        #[raw_output]
        fn __execute__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array::<felt252>,
            tx_index: felt252
        ) -> Span::<felt252> {
            // Validate caller.
            assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

            // Check the tx version here, since version 0 transaction skip the __validate__ function.
            let tx_info = starknet::get_tx_info().unbox();
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            //Multisig check here
            let num_confirmations = tx_confirms::read(tx_index);
            let owners_len = num_owners::read();
            //Subtracting one for the submitter
            let required_confirmations = threshold::read() - 1_usize;
            assert(num_confirmations >= required_confirmations, 'MINIMUM_50%_CONFIRMATIONS');

            tx_is_executed::write(tx_index, true);

            starknet::call_contract_syscall(
                contract_address, entry_point_selector, calldata.span()
            ).unwrap_syscall()
        }
```

## Closing Thoughts

This chapter has introduced you to the concept of multisig accounts in
Starknet and illustrated how they can be implemented using an account
contract. However, it’s important to note that this is a simplified
example, and a production-grade multisig contract should contain
additional checks and validations for robustness and security.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
