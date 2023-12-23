# Multi-Signature Accounts

Multisignature (multisig) technology is an integral part of the modern
blockchain landscape. It enhances security by requiring multiple
signatures to confirm a transaction, hence reducing the risk of
fraudulent transactions and increasing control over asset management.

In Starknet, the concept of multisig accounts is abstracted at the
protocol level, allowing developers to implement custom account
contracts that embody this concept. In this chapter, we’ll delve into
the workings of a multisig account and see how it’s created in Starknet
using an account contract.

Account Abstraction is a win for usability in web3 and on Starknet it has been supported from the beginning at the protocol level. For a smart contract to be considered an account contract it must at least implement the interface defined by SNIP-6. Additional methods might be required for advanced account functionality.

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

This multisig account contract is written in Cairo:

```use starknet::ContractAddress;

#[starknet::interface]

trait IMultisig<TContractState> {

    fn get_confirmations(self: @TContractState, tx_index: felt252) -> usize;

    fn get_num_owners(self: @TContractState) -> usize;

    fn get_owner_pub_key(self: @TContractState, _address: ContractAddress) -> felt252;


    fn set_pub_key(ref self: TContractState, public_key: felt252);

    fn submit_transaction(ref self: TContractState, contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>);

    fn confirm_transaction(ref self: TContractState, tx_index: felt252);

    fn __validate_declare__(self: @TContractState, class_hash: felt252) -> felt252;

    fn __validate_deploy__(self: @TContractState, class_hash: felt252, contract_address_salt: felt252, _public_key: felt252) -> felt252;

    fn __validate__(self: @TContractState, contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>) -> felt252;

    fn __execute__(ref self: TContractState, tx_index: felt252) -> Span<felt252>;

}

#[starknet::contract]
mod MultiSig {
    ////////////////////////////////
    // library imports
    ////////////////////////////////
    use starknet::{ContractAddress, get_tx_info, get_caller_address, contract_address_try_from_felt252, contract_address_to_felt252, VALIDATED, call_contract_syscall, StorageAccess, StorageBaseAddress, SyscallResult, storage_address_from_base_and_offset, storage_address_from_base, storage_base_address_from_felt252, storage_write_syscall, storage_read_syscall};
    use zeroable::Zeroable;
    use ecdsa::check_ecdsa_signature;
    use array::ArrayTrait;
    use array::SpanTrait;
    use option::OptionTrait;
    use traits::Into;
    use traits::TryInto;
    use box::BoxTrait;
    use serde::Serde;

    ////////////////////////////////
    // Call struct
    ////////////////////////////////
    #[derive(Serde, Drop)]
    struct Call {
        to: ContractAddress,
        selector: felt252,
        calldata: Array<felt252>,
        confirmations: usize,
        executed: bool,
    }

    ////////////////////////////////
    // Storage variables
    ////////////////////////////////
    #[storage]
    struct Storage {
        num_owners: usize,
        threshold: usize,
        prev_tx: felt252,
        ownership: LegacyMap<ContractAddress, bool>,
        owners_pub_keys: LegacyMap<ContractAddress, felt252>,
        tx_info: LegacyMap<felt252, Call>,
        has_confirmed: LegacyMap<(ContractAddress, felt252), bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SubmittedTransaction: SubmittedTransaction,
        ConfirmedTransaction: ConfirmedTransaction,
        ExecutedTransaction: ExecutedTransaction
    }

    ////////////////////////////////
    // SubmittedTransaction - emitted each time a new tx is submitted
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct SubmittedTransaction  {
        owner: ContractAddress,
        tx_index: felt252
    }

    ////////////////////////////////
    // ConfirmedTransaction - emitted each time a tx is confirmed
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct ConfirmedTransaction {
        owner: ContractAddress,
        tx_index: felt252
    }

    ////////////////////////////////
    // ExecutedTransaction - emitted each time a tx is executed
    ////////////////////////////////
    #[derive(Drop, starknet::Event)]
    struct ExecutedTransaction {
        owner: ContractAddress,
        tx_index: felt252
    }


    ////////////////////////////////
    // Constructor
    ////////////////////////////////
    #[constructor]
    fn constructor(ref self: ContractState, mut owners: Array<ContractAddress>, _threshold: usize) {
        // check that multisig has min of 2 owners
        assert(owners.len() >= 2_usize, 'mimimum of 2 keys!');
        // check that threshold is less than or equal to no. of owners
        assert(_threshold <= owners.len(), 'invalid threshold!');

        // store num owners and threshold
        self.num_owners.write(owners.len());
        self.threshold.write(_threshold);
        // call the _set_owners internal function
        self._set_owners(owners);
    }

    #[external(v0)]
    impl IMultisigImpl of super::IMultisig<ContractState> {
        ////////////////////////////////
        // get_confirmations - returns no. of confirmation a tx has
        ////////////////////////////////
        fn get_confirmations(self: @ContractState, tx_index: felt252) -> usize {
            let tx: Call = self.tx_info.read(tx_index);
            tx.confirmations
        }

        ////////////////////////////////
        // get_num_owners - returns no. of owners in the multisig
        ////////////////////////////////
        fn get_num_owners(self: @ContractState) -> usize {
            self.num_owners.read()
        }

        ////////////////////////////////
        // get_owner_pub_key - returns the pub key of an owner
        ////////////////////////////////
        fn get_owner_pub_key(self: @ContractState, _address: ContractAddress) -> felt252 {
            self.is_owner(_address);
            self.owners_pub_keys.read(_address)
        }


        ////////////////////////////////
        // set_pub_key - called by owners to set their public key
        ////////////////////////////////
        fn set_pub_key(ref self: ContractState, public_key: felt252) {
            let caller = get_caller_address();
            self.is_owner(caller);
            self.owners_pub_keys.write(caller, public_key);
        }

        ////////////////////////////////
        // submit transaction - called by any owner to submit a tx
        ////////////////////////////////
        fn submit_transaction(ref self: ContractState, contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>) {
            let caller = get_caller_address();
            // check that caller is owner and has set pub key
            self.is_owner(caller);
            self.has_set_pub_key();

            // create call
            let call = Call { to: contract_address, selector: entry_point_selector, calldata: calldata, confirmations: 0_usize, executed: false };
            // get the previous tx ID
            let tx_id = self.prev_tx.read() + 1;

            // store call in tx_info
            self.tx_info.write(tx_id, call);
            // update prev_tx to new tx ID
            self.prev_tx.write(tx_id);

            // emit SubmittedTransaction
            self.emit(
                SubmittedTransaction{ owner: caller, tx_index: tx_id }
            );
        }

        ////////////////////////////////
        // confirm_transaction - called by owners to confirm a tx
        ////////////////////////////////
        fn confirm_transaction(ref self: ContractState, tx_index: felt252) {
            let caller = get_caller_address();

            // check caller is owner, tx exists, caller has set pub key and he hasn't confirmed before
            self.is_owner(caller);
            self.tx_exists( tx_index);
            self.has_set_pub_key();
            self.has_not_confirmed(caller, tx_index);

            // get and deserialize call
            let Call { to, selector, calldata, confirmations, executed } = self.tx_info.read(tx_index);
            // update no of confirmations by 1
            let no_of_confirmation = confirmations + 1_usize;
            // create an updated call with the new no of confirmations
            let updated_call = Call { to: to, selector: selector, calldata: calldata, confirmations: no_of_confirmation, executed: executed };

            // update tx info and has_confirmed status to prevent caller from confirming twice
            self.tx_info.write(tx_index, updated_call);
            self.has_confirmed.write((caller, tx_index), true);

            // emit ConfirmedTransaction
            self.emit(
                ConfirmedTransaction{ owner: caller, tx_index: tx_index }
            );
        }

        ////////////////////////////////
        // __validate_declare__ validates account declare tx - enforces fee payment
        ////////////////////////////////
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            let caller = get_caller_address();
            let _public_key = self.owners_pub_keys.read(caller);
            // dedicate logic to an internal function
            self.validate_transaction(_public_key)
        }

        ////////////////////////////////
        // __validate_deploy__ validates account deployment tx
        ////////////////////////////////
        fn __validate_deploy__(self: @ContractState, class_hash: felt252, contract_address_salt: felt252, _public_key: felt252) -> felt252 {
            self.validate_transaction(_public_key)
        }

        ////////////////////////////////
        // __validate__ validates a tx before execution
        ////////////////////////////////
        fn __validate__(self: @ContractState, contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>) -> felt252 {
            let caller = get_caller_address();
            let _public_key = self.owners_pub_keys.read(caller);
            self.validate_transaction(_public_key)
        }

        ////////////////////////////////
        // __execute__ executes the tx if no. of confirmations is above or equal to threshold
        ////////////////////////////////
        #[raw_output]
        fn __execute__(ref self: ContractState, tx_index: felt252) -> Span<felt252> {
            let caller = get_caller_address();
            // check tx exists
            self.tx_exists(tx_index);
            // check tx has not been executed
            self.tx_not_executed(tx_index);
            // get and deserialize call
            let Call { to, selector, calldata, confirmations, executed } = self.tx_info.read(tx_index);
            // check no. of confirmations is greater than or equal to threshold
            assert(confirmations >= self.threshold.read(), 'min threshold not attained');

            // make contract call using the low-level call_contract_syscall
            let retdata: Span<felt252> = call_contract_syscall(
                address: to, entry_point_selector: selector, calldata: calldata.span()
            ).unwrap_syscall();

            // change tx status to executed
            let updated_call = Call { to: to, selector: selector, calldata: calldata, confirmations: confirmations, executed: true };
            // update tx info
            self.tx_info.write(tx_index, updated_call);

            // emit ExecutedTransaction
            self.emit(
                ExecutedTransaction{ owner: caller, tx_index: tx_index }
            );

            // return data
            retdata
        }
    }

    #[generate_trait]
    impl MultisigHelperImpl of MultisigHelperTrait {
        ////////////////////////////////
        // _set_owners - internal function that sets multisig owners on deployment
        ////////////////////////////////
        fn _set_owners(ref self: ContractState, _owners: Array<ContractAddress>) {
            let mut multisig_owners = _owners;

            loop {
                match multisig_owners.pop_front() {
                    Option::Some(owner) => {
                        self.ownership.write(owner, true);
                    },
                    Option::None(_) => {
                        break();
                    }
                };
            };
        }

        ////////////////////////////////
        // is_owner - internal function that checks that an address is a valid owner
        ////////////////////////////////
        fn is_owner(self: @ContractState, address: ContractAddress) {
            assert(self.ownership.read(address) == true, 'not a member of multisig');
        }

        ////////////////////////////////
        // has_set_pub_key - internal function that checks that an owner has set his pub key
        ////////////////////////////////
        fn has_set_pub_key(self: @ContractState) {
            let caller = get_caller_address();
            assert(self.owners_pub_keys.read(caller) != 0, 'set your pub key first');
        }

        ////////////////////////////////
        // tx_exists - internal function that checks if a tx exists
        ////////////////////////////////
        fn tx_exists(self: @ContractState, tx_index: felt252) {
            let prev: u8 = self.prev_tx.read().try_into().unwrap();
        assert(tx_index.try_into().unwrap() <= prev, 'tx does not exist!');
        }

        ////////////////////////////////
        // tx_not_executed - internal function that checks that a tx is not executed
        ////////////////////////////////
        fn tx_not_executed(self: @ContractState, tx_index: felt252) {
            let tx: Call = self.tx_info.read(tx_index);
            assert(tx.executed == false, 'tx already executed');
        }

        ////////////////////////////////
        // has_not_confirmed - internal function that checks that an owner has not confirmed tx before
        ////////////////////////////////
        fn has_not_confirmed(self: @ContractState, caller: ContractAddress, tx_index: felt252) {
            let status: bool = self.has_confirmed.read((caller, tx_index));
            assert(status != true, 'already confirmed tx');
        }

        ////////////////////////////////
        // validate_transaction internal function that checks transaction signature is valid
        ////////////////////////////////
        fn validate_transaction(self: @ContractState, _public_key: felt252) -> felt252 {
            let tx_info = get_tx_info().unbox();
            let signature = tx_info.signature;
            assert(signature.len() == 2_u32, 'invalid signature length!');

            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: _public_key,
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'invalid signature!',
            );
            VALIDATED
        }
    }


    ////////////////////////////////
    // Storage Access implementation for Call Struct - such a PITA, hopefully we won't need to do this in the future
    ////////////////////////////////
    impl CallStorageAccess of StorageAccess::<Call> {
        fn write(address_domain: u32, base: StorageBaseAddress, value: Call) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain,
                storage_address_from_base(base),
                contract_address_to_felt252(value.to)
            );
            storage_write_syscall(
                address_domain,
                storage_address_from_base(base),
                value.selector
            );
            let mut calldata_span = value.calldata.span();
            storage_write_syscall(
                address_domain,
                storage_address_from_base(base),
                Serde::deserialize(ref calldata_span).unwrap()
            );
            storage_write_syscall(
                address_domain,
                storage_address_from_base(base),
                value.confirmations.into()
            );
            let executed_base = storage_base_address_from_felt252(storage_address_from_base(base).into());
            StorageAccess::write(address_domain, executed_base, value.executed)
        }

        fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult::<Call> {
            let to_result = storage_read_syscall(
                address_domain,
                storage_address_from_base(base)
            )?;

            let selector_result = storage_read_syscall(
                address_domain,
                storage_address_from_base(base)
            )?;

            let calldata_result = storage_read_syscall(
                address_domain,
                storage_address_from_base(base)
            )?;

            let confirmations_result = storage_read_syscall(
                address_domain,
                storage_address_from_base(base)
            )?;

            let executed_base = storage_base_address_from_felt252(storage_address_from_base(base).into());
            let executed_result: bool = StorageAccess::read(address_domain, executed_base)?;

            let mut calldata_arr = ArrayTrait::new();
            calldata_result.serialize(ref calldata_arr);

            Result::Ok(
                Call {
                    to: contract_address_try_from_felt252(to_result).unwrap(),
                    selector: selector_result,
                    calldata: calldata_arr,
                    confirmations: confirmations_result.try_into().unwrap(),
                    executed: executed_result
                }
            )
        }

        fn write_at_offset_internal(address_domain: u32, base: StorageBaseAddress, offset: u8, value: Call) -> SyscallResult::<()> {
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset),
                contract_address_to_felt252(value.to)
            );
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 1_u8),
                value.selector
            );
            let mut calldata_span = value.calldata.span();
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 2_u8),
                Serde::deserialize(ref calldata_span).unwrap()
            );
            storage_write_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 3_u8),
                value.confirmations.into()
            );
            let executed_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, offset + 4_u8).into());
            StorageAccess::write(address_domain, executed_base, value.executed)
        }

        fn read_at_offset_internal(address_domain: u32, base: StorageBaseAddress, offset: u8) -> SyscallResult::<Call> {
            let to_result = storage_read_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset)
            )?;

            let selector_result = storage_read_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 1_u8)
            )?;

            let calldata_result = storage_read_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 2_u8)
            )?;

            let confirmations_result = storage_read_syscall(
                address_domain,
                storage_address_from_base_and_offset(base, offset + 3_u8)
            )?;

            let executed_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, offset + 4_u8).into());
            let executed_result: bool = StorageAccess::read(address_domain, executed_base)?;

            let mut calldata_arr = ArrayTrait::new();
            calldata_result.serialize(ref calldata_arr);

            Result::Ok(
                Call {
                    to: contract_address_try_from_felt252(to_result).unwrap(),
                    selector: selector_result,
                    calldata: calldata_arr,
                    confirmations: confirmations_result.try_into().unwrap(),
                    executed: executed_result
                }
            )
        }

        fn size_internal(value: Call) -> u8 {
            5_u8
        }
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

## Multisig Contract Deployment using Starkli

This will show how to use Starkli to deploy to testnet the Multisig account contract we created.

To follow along with this tutorial, make sure to have Starkli and Scarb installed.

```
# Cheatsheet: Steps to declare, deploy and use a custom account contract

# [1] Set environment variables in envars.sh
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/V0WI...

# [2] Activate environment variables
source ~/.starkli-wallets/custom/envars.sh

# [3] Create keystore.json file
starkli signer keystore new ~/.starkli-wallets/custom/keystore.json

# [4] Create account.json file
starkli account oz init ~/.starkli-wallets/custom/account.json

# [5] Compile account contract
scarb build

# [6] Derive class hash
starkli class-hash target/dev/aa_Account.sierra.json

# [7] Update account.json file
{
  ...
  "deployment": {
    ...
    "class_hash": "<REAL_CLASS_HASH>",
    ...
  }
}

# [8] Activate deployer wallet
source ~/.starkli-wallets/deployer/envars.sh

# [9] Declare account contract with deployer
starkli declare target/dev/aa_Account.sierra.json

# [10] Activate custom wallet
source ~/.starkli-wallets/custom/envars.sh

# [11] Deploy account contract
starkli account deploy ~/.starkli-wallets/custom/account.json

# [12] Send ETH to given address

# [13] Use account contract for testing
starkli invoke eth transfer 0x1234 u256:100

# [bonus] Suggested folder structure
.
├── account.json
├── envars.sh
└── keystore.json
```

## Configuration Files

When dealing with an account contract, Starkli requires two configuration files: an encrypted file named keystore.json to store the associated private key and an unencrypted file called account.json that describes its public attributes like public key, class hash and address.

There’s an optional third file that can be created for each account contract to simplify all of Starkli’s commands and that is a shell file to source the environment variables expected by the tool. This is normally call this file envars.sh.

Because if we have multiple wallets associated with Starkli, and each one has three configuration files, let's create a folder for each wallet to store the aforementioned files and then group them all in a single hidden folder called starkli-wallets in your home directory.

The folder structure will look like this:

```
~ $ tree ~/.starkli-wallets
>>>
.starkli-wallets
├── wallet-a
│   ├── account.json
│   ├── envars.sh
│   └── keystore.json
└── wallet-b
    ├── account.json
    ├── envars.sh
    └── keystore.json
```

For this tutorial, let's create a new folder for the smart wallet called custom inside the starkli-wallets folder.

```
~ $ mkdir ~/.starkli-wallets/custom
```

We can now use Starkli to generate the two mandatory configuration files while we will manually create the environment variables file.

## Creating a Keystore File

Starkli allows you to auto generate a private key, store it in a keystore.json file inside our custom folder and encrypt the file with a password all with a single command. The only argument expected by the command is the location to create the configuration file.

```
~ $ starkli signer keystore new ~/.starkli-wallets/custom/keystore.json
>>>

Enter password:
Created new encrypted keystore file: /Users/david/.starkli-wallets/custom/keystore.json
Public key: 0x01ad...
```

The command first asks you for an encryption password and then it creates the file. The location of our keystore.json file will be the first environment variable to set in our envars.sh file.

```
~ $ touch ~/.starkli-wallets/custom/envars.sh
```

```
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
```

To activate the environment variable in our terminal we can source it.

```
~ $ source ~/.starkli-wallets/custom/envars.sh
```

We can now create the other mandatory configuration file for our account contract: account.json.

Creating an Account File

Our account contract validates signatures in exactly the same way as OpenZeppelin’s (OZ) default account contract. Both account contracts expect a single signer and use the STARK-friendly elliptic curve. For this reason we are going to use a Starkli command that’s normally reserved for an OZ account even though we have created ours from scratch.

```
~ $ starkli account oz init ~/.starkli-wallets/custom/account.json
>>>

Enter keystore password:
Created new account config file: /Users/david/.starkli-wallets/custom/account.json

Once deployed, this account will be available at:
    0x07c4...

Deploy this account by running:
    starkli account deploy /Users/david/.starkli-wallets/custom/account.json
```

Our account contract is similar to OZ but it’s not the same. This means that our account contract will have a different class hash than OZ’s implementation and because the class hash is used to calculate the deployment address, the value shown by the tool (0x07c4…) is not correct.

Let’s take a look at the content of the generated file account.json.

```
~ $ cat ~/.starkli-wallets/custom/account.json
>>>

{
  "version": 1,
  "variant": {
    "type": "open_zeppelin",
    "version": 1,
    "public_key": "0x01ad...",
    "legacy": true
  },
  "deployment": {
    "status": "undeployed",
    "class_hash": "0x48dd...",
    "salt": "0x238a..."
  }
}
```

First, notice that the property legacy is set to true by default. Starkli is assuming that we want to deploy the Cairo 0 version of OZ’s account contract (legacy) instead of its more modern counterpart written in Cairo. We need to manually set this flag to false so Starkli uses the right serialization mechanism when sending transactions to Starknet. If we leave this property with its default value, we will be able to deploy our account contract but we won’t be able to use it.

Second, and as mentioned before, the class hash defined in this configuration is OZ’s class hash, not ours. To find our class hash we will need to compile our project and use Starkli once again to find the real class hash.

Finding the Class Hash

If you have been following this tutorial series in order, you should already have a folder called aa (for Account Abstraction) inside your home folder where the Cairo code for our account contract is defined. If not, you can always clone the repository and continue from there.

```
~ $ git clone git@github.com:starknet-edu/aa-workshop.git aa
```

In order to compile our account contract to Sierra we need to first get into the project folder and then use Scarb.

```
~ $ cd aa
aa $ scarb build
>>>

Compiling aa v0.1.0 (/Users/david/aa/Scarb.toml)
Finished release target(s) in 2 seconds

```

The compiled version of our account contract now lives inside the target/dev folder of our project.

We can derive the class hash of our account contract using Starkli.

```
aa $ starkli class-hash target/dev/aa_Account.sierra.json
>>>
0x056bd...
```

Let’s now modify the account.json file of our account contract using the real class hash.

```dotnetcli
aa $ code ~/.starkli-wallets/custom/account.json
```

```dotnetcli
{
  "version": 1,
  "variant": {
    "type": "open_zeppelin",
    "version": 1,
    "public_key": "0x01ad...",
    "legacy": false
  },
  "deployment": {
    "status": "undeployed",
    "class_hash": "0x056bd...",
    "salt": "0x238a..."
  }
}
```

At this point our account.json file has all the correct information and we can proceed to create a new environment variable with its path.

```dotnetcli
aa $ code ~/.starkli-wallets/custom/envars.sh
```

```dotnetcli
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
```

To activate the new environment variable in our terminal we can source the file.

```dotnetcli
aa $ source ~/.starkli-wallets/custom/envars.sh
```

Next step is to declare the account contract on testnet.

## Configuring an RPC

Declaring an account contract means sending a transaction to Starknet and we can only do so through an RPC provider. I’ll be using Alchemy but you can use Infura or even your own node.

If you decide to use Alchemy or Infura, you’ll need to first create an account with them, create a project for Starknet Goerli, copy the RPC’s URL created for you and place it in the envars.sh file as an environment variable.

```
aa $ code ~/.starkli-wallets/custom/envars.sh

```

```
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/V0WI...
```

Note: I’m not showing the full URL of my RPC endpoint to protect my API key.

## Declaring an Account Contract

To declare our account contract we are going to need a different account contract that is already deployed and funded to pay for the associated gas fees.

In another article called “Starkli: The New Starknet CLI” [8] I showed how to configure Starkli to use either a Braavos or Argent X wallet as a deployer. To use this wallet with Starkli to declare our account contract, I’m going to source its envars.sh file.

```
aa $ source ~/.starkli-wallets/deployer/envars.sh
```

We can now declare our account contract by paying the gas fees with the deployer account.

```
aa $ starkli declare target/dev/aa_Account.sierra.json
>>>

Enter keystore password:
Sierra compiler version not specified. Attempting to automatically decide version to use...
Network detected: goerli-1. Using the default compiler version for this network: 2.2.0. Use the --compiler-version flag to choose a different version.
Declaring Cairo 1 class: 0x056bd...
Compiling Sierra class to CASM with compiler version 2.1.0...
CASM class hash: 0x05f5...
Contract declaration transaction: 0x07f1...
Class hash declared: 0x056bd...
```

Once the declare transaction gets to the state “Accepted on L2” we can reactivate the environment variables of our account contract to perform the counter factual deployment.

```
aa $ source ~/.starkli-wallets/custom/envars.sh
aa $ starkli account deploy ~/.starkli-wallets/custom/account.json
>>>

Enter keystore password:
The estimated account deployment fee is 0.000004330000051960 ETH. However, to avoid failure, fund at least:
    0.000006495000077940 ETH
to the following address:
    0x71d8...
Press [ENTER] once you've funded the address.
```

Starkli will wait for us until we send enough funds to the specified address where our account contract will be deployed so it can send the deploy_account transaction. We can use the faucet for that purpose .

Once the funds arrive at the address, we can click “Enter” to continue with the deployment process.

```
...
Account deployment transaction: 0x00b9...
Waiting for transaction 0x00b9... to confirm. If this process is interrupted, you will need to run `starkli account fetch` to update the account file.
Transaction 0x04b7... confirmed
```

Our account contract is now deployed to Starknet’s testnet and it’s ready to be used.

## Using the Account Contract

An easy way to verify that our account contract is working is to use it to send 100 gwei to another wallet (0x1234) by sending an invoke transaction to execute the transfer function on the WETH smart contract on Starknet’s testnet .

Because interacting with the WETH smart contract is such a common operation, Starkli provides shorthands to make the command more compact as you can see below.

```
aa $ starkli invoke eth transfer 0x1234 u256:100
>>>

Enter keystore password:
Invoke transaction: 0x0321...

```

The transaction is executed successfully proving that our account contract was able to verify the transaction signature, execute our transfer action and pay for the associated gas fees.

## Conclusion

This chapter has introduced you to the concept of multisig accounts in
Starknet and illustrated how they can be implemented using an account
contract. However, it’s important to note that this is a simplified
example, and a production-grade multisig contract should contain
additional checks and validations for robustness and security.

Account Abstraction is a win for usability in web3 and on Starknet it has been supported from the beginning at the protocol level. For a smart contract to be considered an account contract it must at least implement the interface defined by SNIP-6. Additional methods might be required for advanced account functionality.

An account contract can be deployed using another account contract to pay for gas fees or doing a counterfactual deployment for a pristine start.

We used Starkli for my account contract using the Open Zeppelin setting because we used the same signature for the constructor and **declare_deploy** functions as OZ uses. If we had modified either of those function signatures we would not have been able to use Starkli to deploy my account contract. If that’s your case, you’ll need to use an SDK like starknet.js instead of Starkli as those tools are more flexible but at the same time more complex to use.

Very soon we should see Argent and Braavos replacing their current account contracts written in Cairo 0 with a newer version using modern Cairo. This will of course require the user to upgrade their wallets once again in preparation for Regenesis

The Book is a community-driven effort created for the community.

## References

[1] Account Abstraction on Starknet, Part I

[2] Account Abstraction on Starknet, Part II

[3] Starkli’s Github Repo

[4] Scarb’s Installation Instructions

[5] Open Zeppelin Cairo Account Contract

[6] Alchemy’s Website

[7] Infura’s Website

[8] Starkli: The New Starknet CLI

[9] Starknet’s Faucet

[10] WETH Address on Starkscan

[11] Starkli book: Simplifying invoke commands

[12] Starknet.js Website

[13] Starknet Regenesis — The Plan
