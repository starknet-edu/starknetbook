// Import necessary modules and traits
use serde::Serde;
use starknet::ContractAddress;
use array::ArrayTrait;
use array::SpanTrait;
use option::OptionTrait;

// Define the Account contract
#[account_contract]
mod Account {
    use array::ArrayTrait;
    use array::SpanTrait;
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;
    use option::OptionTrait;
    use super::Call;
    use starknet::ContractAddress;
    use zeroable::Zeroable;
    use serde::ArraySerde;

    // Define the contract's storage variables
    struct Storage {
        public_key: felt252
    }

    // Constructor function for initializing the contract
    #[constructor]
    fn constructor(public_key_: felt252) {
        public_key::write(public_key_);
    }
    
    // Internal function to validate the transaction signature
    fn validate_transaction() -> felt252 {
        let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
        let signature = tx_info.signature; // Extract signature
        assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH'); // Check signature length

        // Verify ECDSA signature
        assert(
            check_ecdsa_signature(
                message_hash: tx_info.transaction_hash, 
                public_key: public_key::read(),
                signature_r: *signature[0_u32],
                signature_s: *signature[1_u32],
            ),
            'INVALID_SIGNATURE',
        );

        starknet::VALIDATED // Return validation status
    }

    // Validate contract deployment
    #[external]
    fn __validate_deploy__(
        class_hash: felt252, contract_address_salt: felt252, public_key_: felt252
    ) -> felt252 {
        validate_transaction()
    }

    // Validate contract declaration
    #[external]
    fn __validate_declare__(class_hash: felt252) -> felt252 {
        validate_transaction()
    }

    // Validate contract execution
    #[external]
    fn __validate__(
        contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>
    ) -> felt252 {
        validate_transaction()
    }

    // Execute a contract call
    #[external]
    #[raw_output]
    fn __execute__(mut calls: Array<Call>) -> Span<felt252> {
        // Validate caller
        assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

        let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
        assert(tx_info.version != 0, 'INVALID_TX_VERSION');

        assert(calls.len() == 1_u32, 'MULTI_CALL_NOT_SUPPORTED'); // Only single calls are supported
        let Call{to, selector, calldata } = calls.pop_front().unwrap();

        // Call the target contract
        starknet::call_contract_syscall(
            address: to, entry_point_selector: selector, calldata: calldata.span()
        ).unwrap_syscall()
    }
}

// Define the Call struct
#[derive(Drop, Serde)]
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}
