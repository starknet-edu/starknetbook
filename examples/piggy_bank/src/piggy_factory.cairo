use starknet::{ContractAddress, ClassHash};
use piggy_bank::piggy_bank::piggyBank::targetOption;


#[starknet::interface]
trait IPiggyBankFactory<TContractState> {
    fn createPiggyBank(ref self: TContractState, savingsTarget: targetOption, targetDetails: u128) -> ContractAddress;
    fn updatePiggyBankHash(ref self: TContractState, newClasHash: ClassHash);
    fn getAllPiggyBank(self: @TContractState) -> Array<ContractAddress>;
    fn getPiggyBanksNumber(self: @TContractState) -> u128;
    fn getPiggyBankAddr(self: @TContractState, userAddress: ContractAddress) -> ContractAddress;
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn get_childClassHash(self: @TContractState) -> ClassHash;
}

#[starknet::contract]
mod piggyFactory{
    use core::starknet::event::EventEmitter;
use piggy_bank::ownership_component::IOwnable;
    use core::serde::Serde;
    use starknet::{ContractAddress, ClassHash, get_caller_address, Zeroable};
    use starknet::syscalls::deploy_syscall;
    use super::targetOption;
    use piggy_bank::ownership_component::ownable_component;
    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;
    impl OwnableInternalImpl = ownable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        piggyBankHash: ClassHash,
        totalPiggyBanksNo: u128,
        AllBanksRecords: LegacyMap<u128, ContractAddress>,
        piggyBankOwner: LegacyMap::<ContractAddress, ContractAddress>,
        TokenAddr: ContractAddress,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BankCreated: BankCreated,
        HashUpdated: HashUpdated,
        OwnableEvent: ownable_component::Event
    }

    #[derive(Drop, starknet::Event)]
    struct BankCreated {
        #[key]
        for: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct HashUpdated {
        #[key]
        by: ContractAddress,
        #[key]
        oldHash: ClassHash,
        #[key]
        newHash: ClassHash,
    }

    mod Errors {
        const Address_Zero_Owner: felt252 = 'Invalid owner';
    }

    #[constructor]
    fn constructor(ref self: ContractState, piggyBankClassHash: ClassHash, tokenAddr: ContractAddress,  _owner: ContractAddress) {
        self.piggyBankHash.write(piggyBankClassHash);
        self.ownable.owner.write(_owner);
        self.TokenAddr.write(tokenAddr);
    }

    #[external(v0)]
    impl piggyFactoryImpl of super::IPiggyBankFactory<ContractState> {
        fn createPiggyBank(ref self: ContractState, savingsTarget: targetOption, targetDetails: u128) -> ContractAddress {
            // Contructor arguments
            let mut constructor_calldata = ArrayTrait::new();
            get_caller_address().serialize(ref constructor_calldata);
            self.TokenAddr.read().serialize(ref constructor_calldata);
            self.ownable.owner().serialize(ref constructor_calldata);
            savingsTarget.serialize(ref constructor_calldata);
            targetDetails.serialize(ref constructor_calldata);

            // Contract deployment
            let (deployed_address, _) = deploy_syscall(
                self.piggyBankHash.read(), 0, constructor_calldata.span(), false
            )
                .expect('failed to deploy counter');
            self.totalPiggyBanksNo.write(self.totalPiggyBanksNo.read() + 1);
            self.AllBanksRecords.write(self.totalPiggyBanksNo.read(), deployed_address);
            self.piggyBankOwner.write(get_caller_address(), deployed_address);
            self.emit(BankCreated{for: get_caller_address()});

            deployed_address
        }

        fn updatePiggyBankHash(ref self: ContractState, newClasHash: ClassHash) {
            self.ownable.assert_only_owner();
            self.piggyBankHash.write(newClasHash);
            self.emit(HashUpdated{by: self.ownable.owner(), oldHash: self.piggyBankHash.read(), newHash: newClasHash});
        }

        fn getAllPiggyBank(self: @ContractState) -> Array<ContractAddress> {
            let mut piggyBanksAddress = ArrayTrait::new();
            let mut i: u128  = 1;
            loop {
                if i > self.totalPiggyBanksNo.read() {
                    break;
                }
                piggyBanksAddress.append(self.AllBanksRecords.read(i));
                i += 1;
            };
            piggyBanksAddress
        }

        fn getPiggyBanksNumber(self: @ContractState) -> u128 {
            self.totalPiggyBanksNo.read()
        }
        fn getPiggyBankAddr(self: @ContractState, userAddress: ContractAddress) -> ContractAddress {
            assert(!userAddress.is_zero(), Errors::Address_Zero_Owner);
            self.piggyBankOwner.read(userAddress)
        }
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.ownable.owner()
        }
        
        fn get_childClassHash(self: @ContractState) -> ClassHash {
            self.piggyBankHash.read()
        }

    }

}