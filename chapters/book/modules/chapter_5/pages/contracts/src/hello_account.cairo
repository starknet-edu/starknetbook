// This is a Starknet account contract in Cairo language. It serves as an example of
// how to create and manage an account on Starknet. The contract contains several
// external functions that handle validation and execution of transactions, as well
// as the necessary imports and declarations. 
// The declare contract has class hash: 0x07e813097812d58afbb4fb015e683f2b84e4f008cbecc60fa6dece7734a2cdfe
// The contract address is: 0x01e6d7698ca76788c8f9c1091ec3d6d3f7167a9effe520402d832ca9894eba4a

use starknet::ContractAddress;

trait ISRC6<T> {
    fn __validate__(self: @T, calls: Array<Call>) -> felt252;
    fn _is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
    fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
}

trait ISRC5<T> {
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[derive(Drop, Serde)]
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

#[starknet::contract]
mod HelloAccount {
    use super::{ISRC6, ISRC5, Call};
    use array::{ArrayTrait, SpanTrait};
    use ecdsa::check_ecdsa_signature;
    use box::BoxTrait;

    const SRC6_TRAIT_ID: felt252 =
        1270010605630597976495846281167968799381097569185364931397797212080166453709;

    #[storage]
    struct Storage {
        public_key: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.public_key.write(public_key);
    }

    #[external(v0)]
    impl SRC6Impl of ISRC6<ContractState> {
        fn _is_valid_signature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');
            assert(
                check_ecdsa_signature(
                    message_hash: hash,
                    public_key: self.public_key.read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED
        }

        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
            let tx_info = starknet::get_tx_info().unbox();
            let transaction_hash = tx_info.transaction_hash;
            let signature_span = tx_info.signature;
            // Convert signature from span to array
            let signature_r = *signature_span[0_u32];
            let signature_s = *signature_span[1_u32];
            let mut signature_array = ArrayTrait::new();
            signature_array.append(signature_r);
            signature_array.append(signature_s);
            return self._is_valid_signature(hash: transaction_hash, signature: signature_array);
        }

        fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
            let mut result = ArrayTrait::new();
            // Get first call in the array
            let call = calls.at(0_usize);
            let mut res = starknet::call_contract_syscall(
                address: *call.to,
                entry_point_selector: *call.selector,
                calldata: call.calldata.span()
            )
                .unwrap_syscall();

            result.append(res);
            result
        }
    }

    #[external(v0)]
    impl SRC5Impl of ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            interface_id == SRC6_TRAIT_ID
        }
    }
}

