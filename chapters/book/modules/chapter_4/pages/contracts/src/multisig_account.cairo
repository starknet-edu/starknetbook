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
        //Mapping between tx_index and it's execution state
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
    fn get_confirmations(tx_index: felt252) -> usize {
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

        assert(confirmed == false, 'CALLER_ALREADY_CONFIRMED');
        tx_confirms::write(tx_index, num_confirmations + 1_usize);
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
    //Function to add the public keys of the multi sig in permanent storage
    fn _set_owners(owners_len: usize, public_keys: Array::<felt252>) {
        if owners_len == 0_usize {}

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
        contract_address: ContractAddress,
        entry_point_selector: felt252,
        calldata: Array::<felt252>,
        public_key_: felt252
    ) -> felt252 {
        validate_transaction(public_key_)
    }

    #[external]
    #[raw_output]
    fn __execute__(
        contract_address: ContractAddress,
        entry_point_selector: felt252,
        calldata: Array::<felt252>,
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

        starknet::call_contract_syscall(contract_address, entry_point_selector, calldata.span())
            .unwrap_syscall()
    }
}
