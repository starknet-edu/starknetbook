// This is a Starknet account contract in Cairo language. It serves as an example of
// how to create and manage an account on Starknet. The contract contains several
// external functions that handle validation and execution of transactions, as well
// as the necessary imports and declarations. 
// The declare contract has class hash: 0x07e813097812d58afbb4fb015e683f2b84e4f008cbecc60fa6dece7734a2cdfe
// The contract address is: 0x01e6d7698ca76788c8f9c1091ec3d6d3f7167a9effe520402d832ca9894eba4a

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
