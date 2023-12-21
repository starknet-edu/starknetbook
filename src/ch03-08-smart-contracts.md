# Smart Contracts

Starknet contracts, are programs written in cairo and can run on the starknet virtual machine, they have access to the starknet state, and can interact with other contracts.

This Chapter will introduce you to starknet smart contracts, their components, smart contract declaration, deployment and interaction using starkli.

## Smart Contract Example

Having explained what starknet smart contracts are, we'll be writing a moderately simple contract called a Piggy Bank contract, this example will demonstrate how to write a smart contract using the factory pattern and also how to integrate the starknet component system into your smart contracts.

The piggy bank contract is a factory contract model that allows users to create their own personalized savings contract. At the point of creation, users are to specify their savings target, which could be towards a specific time or a specific amount, and a child contract is created and personalized to their savings target.

The factory contract keeps tabs on all the child contracts created and also maps a user to his personalized contract. The user, after creating a personalized savings contract, can then deposit and save towards his target. But if, for any reason, the user has to withdraw from his savings contract before meeting the savings target, then a fine worth 10% of the withdrawal amount would be paid by the user.

The contract uses a combination of functions and an ownership component to track and maintain the above explained functionality. Event’s are also emitted on each function call that modifies the contract's state. So a good understanding of the logic and implementation of this contract example would give you mastery of the components system in Cairo, the factory standard model, emitting events, and a whole lot of other methods useful in writing smart contracts on starknet.

Please note that during the course of this journey, I’ll be using interchangeably the terms child contract and personalized contract. Please note that the term child contract in this case refers to a personalized piggy bank contract created from the factory contract.

### Piggy Bank Child Contract:

```rust
use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
enum target {
    blockTime: u128,
    amount: u128,
}

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait piggyBankTrait<TContractState> {
    fn deposit(ref self: TContractState, _amount: u128);
    fn withdraw(ref self: TContractState, _amount: u128);
    fn get_balance(self: @TContractState) -> u128;
    fn get_Target(self: @TContractState) -> (u128 , piggyBank::targetOption) ;
    // fn get_owner(self: @TContractState) -> ContractAddress;
    fn viewTarget(self: @TContractState) -> target;
}

#[starknet::contract]
mod piggyBank {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{get_caller_address, ContractAddress, get_contract_address, Zeroable, get_block_timestamp};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait, target};
    use core::traits::Into;
    use piggy_bank::ownership_component::ownable_component;
    component!(path: ownable_component, storage: ownable, event: OwnableEvent);


    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;
    impl OwnableInternalImpl = ownable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        manager: ContractAddress,
        balance: u128,
        withdrawalCondition: target,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    #[derive(Drop, Serde)]
    enum targetOption {
        targetTime,
        targetAmount,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Deposit: Deposit,
        Withdraw: Withdraw,
        PaidProcessingFee: PaidProcessingFee,
        OwnableEvent: ownable_component::Event
    }

    #[derive(Drop, starknet::Event)]
    struct Deposit {
        #[key]
        from: ContractAddress,
        #[key]
        Amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct Withdraw {
        #[key]
        to: ContractAddress,
        #[key]
        Amount: u128,
        #[key]
        ActualAmount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct PaidProcessingFee {
        #[key]
        from: ContractAddress,
        #[key]
        Amount: u128,
    }

    mod Errors {
        const Address_Zero_Owner: felt252 = 'Invalid owner';
        const Address_Zero_Token: felt252 = 'Invalid Token';
        const UnAuthorized_Caller: felt252 = 'UnAuthorized caller';
        const Insufficient_Balance: felt252 = 'Insufficient balance';
    }

    #[constructor]
    fn constructor(ref self: ContractState, _owner: ContractAddress, _token: ContractAddress, _manager: ContractAddress, target: targetOption, targetDetails: u128) {
        assert(!_owner.is_zero(), Errors::Address_Zero_Owner);
        assert(!_token.is_zero(), Errors::Address_Zero_Token);
        self.ownable.owner.write(_owner);
        self.token.write(super::IERC20Dispatcher{contract_address: _token});
        self.manager.write(_manager);
        match target {
            targetOption::targetTime => self.withdrawalCondition.write(target::blockTime(targetDetails.into())),
            targetOption::targetAmount => self.withdrawalCondition.write(target::amount(targetDetails)),
        }
    }

    #[external(v0)]
    impl piggyBankImpl of super::piggyBankTrait<ContractState> {
        fn deposit(ref self: ContractState, _amount: u128) {
            let (caller, this, currentBalance) = self.getImportantAddresses();
            self.balance.write(currentBalance + _amount);

            self.token.read().transferFrom(caller, this, _amount.into());

            self.emit(Deposit { from: caller, Amount: _amount});
        }

        fn withdraw(ref self: ContractState, _amount: u128) {
            self.ownable.assert_only_owner();
            let (caller, this, currentBalance) = self.getImportantAddresses();
            assert(self.balance.read() >= _amount, Errors::Insufficient_Balance);

            let mut new_amount: u128 = 0;
            match self.withdrawalCondition.read() {
                target::blockTime(x) => new_amount = self.verifyBlockTime(x, _amount),
                target::amount(x) => new_amount = self.verifyTargetAmount(x, _amount),
            };

            self.balance.write(currentBalance - _amount);
            self.token.read().transfer(caller, new_amount.into());

            self.emit(Withdraw { to: caller, Amount: _amount, ActualAmount: new_amount});
        }

        fn get_balance(self: @ContractState) -> u128 {
            self.balance.read()
        }

        fn get_Target(self: @ContractState) -> (u128 , targetOption) {
            let condition = self.withdrawalCondition.read();
            match condition {
                target::blockTime(x) => {return (x, targetOption::targetTime);},
                target::amount(x) => {return (x, targetOption::targetAmount);},
            }
        }

        fn viewTarget(self: @ContractState) -> target {
            self.withdrawalCondition.read()
        }

    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn verifyBlockTime(ref self: ContractState, blockTime: u128, withdrawalAmount: u128) -> u128 {
            if (blockTime <= get_block_timestamp().into()) {
                return withdrawalAmount;
            } else {
                return self.processWithdrawalFee(withdrawalAmount);
            }
        }

        fn verifyTargetAmount(ref self: ContractState, targetAmount: u128, withdrawalAmount: u128) -> u128 {
            if (self.balance.read() < targetAmount) {
                return self.processWithdrawalFee(withdrawalAmount);
            } else {
                return withdrawalAmount;
            }
        }

        fn processWithdrawalFee(ref self: ContractState, withdrawalAmount: u128) -> u128 {
            let withdrawalCharge: u128 = ((withdrawalAmount * 10) / 100);
            self.balance.write(self.balance.read() - withdrawalCharge);
            self.token.read().transfer(self.manager.read(), withdrawalCharge.into());
            self.emit(PaidProcessingFee{from: get_caller_address(), Amount: withdrawalCharge});
            return withdrawalAmount - withdrawalCharge;
        }

        fn getImportantAddresses(self: @ContractState) -> (ContractAddress, ContractAddress, u128) {
            let caller: ContractAddress = get_caller_address();
            let this: ContractAddress = get_contract_address();
            let currentBalance: u128 = self.balance.read();
            (caller, this, currentBalance)
        }
    }
}
```

### Piggy Bank Factory

```rust
use starknet::{ContractAddress, ClassHash};
use piggy_bank::piggy_bank::piggyBank::targetOption;
use array::ArrayTrait;

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
    use dict::Felt252DictTrait;
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
```
