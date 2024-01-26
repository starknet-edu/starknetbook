use core::traits::TryInto;
use starknet::ContractAddress;

#[starknet::interface]
trait IData<T> {
    fn get_data(self: @T) -> felt252;
    fn set_data(ref self: T, new_value: felt252);
    fn other_func(self: @T, other_contract: ContractAddress) -> felt252;
}

#[starknet::interface]
trait OwnableTrait<T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn owner(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod ownable {
    use starknet::get_caller_address;
    use super::{ContractAddress, IData, IDataDispatcherTrait, IDataDispatcher, OwnableTrait};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        data: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
        self.data.write(1);
    // Any variable of the storage that is not initialized
    // will have default value -> data = 0.
    }

    #[abi(embed_v0)]
    impl OwnableDataImpl of IData<ContractState> {
        fn other_func(self: @ContractState, other_contract: ContractAddress) -> felt252 {
            IDataDispatcher { contract_address: other_contract }.get_data()
        }

        fn get_data(self: @ContractState) -> felt252 {
            self.data.read()
        }

        fn set_data(ref self: ContractState, new_value: felt252) {
            self.only_owner();
            self.data.write(new_value);
        }
    }

    #[abi(embed_v0)]
    impl OwnableTraitImpl of OwnableTrait<ContractState> {
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            self.only_owner();
            let prev_owner = self.owner.read();
            self.owner.write(new_owner);

            self.emit(OwnershipTransferred { prev_owner, new_owner });
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }
}

#[cfg(test)]
mod tests {
    use ownable_starknet::ownable;
    use ownable_starknet::{OwnableTraitDispatcher, OwnableTraitDispatcherTrait};
    use starknet::{ContractAddress, Into, TryInto, OptionTrait};
    use starknet::syscalls::deploy_syscall;
    use result::ResultTrait;
    use array::{ArrayTrait, SpanTrait};

    #[test]
    #[available_gas(10_000_000)]
    fn unit_test() {
        let admin_address: ContractAddress = 'admin'.try_into().unwrap();
        let mut calldata = array![admin_address.into()];
        let (address0, _) = deploy_syscall(
            ownable::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();
        let mut contract0 = OwnableTraitDispatcher { contract_address: address0 };

        assert(contract0.owner() == admin_address, 'Wrong owner');
    }
}

