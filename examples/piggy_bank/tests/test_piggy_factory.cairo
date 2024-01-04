use core::option::OptionTrait;
use core::{traits::Into, debug::PrintTrait};
use array::ArrayTrait;
use serde::Serde;
use traits::TryInto;
use starknet::{ContractAddress, get_contract_address, ClassHash};
use starknet::Felt252TryIntoContractAddress;
use piggy_bank::piggy_bank::{piggyBankTraitDispatcher, piggyBankTraitDispatcherTrait, IERC20Dispatcher, IERC20DispatcherTrait, };
use piggy_bank::piggy_bank::piggyBank::targetOption;
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, start_warp, stop_warp, env::var, CheatTarget};
use piggy_bank::piggy_factory::{IPiggyBankFactoryDispatcher, IPiggyBankFactoryDispatcherTrait};
use snforge_std::cheatcodes::contract_class::get_class_hash;

fn deploy_contract(name: felt252, owner: ContractAddress) -> ContractAddress {
    let piggy_bank_class = declare('piggyBank');
    let piggy_class_hash: ClassHash = piggy_bank_class.class_hash;
    let EthToken: ContractAddress = 0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7.try_into().unwrap();

    let contract = declare(name);
    let mut calldata = ArrayTrait::new();
    piggy_class_hash.serialize(ref calldata);
    EthToken.serialize(ref calldata);
    owner.serialize(ref calldata);

    // Precalculate the address to obtain the contract address before the constructor call (deploy) itself
    let contract_address = contract.precalculate_address(@calldata);

    // Change the caller address to 123 before the call to contract.deploy
    start_prank(CheatTarget::One(contract_address), owner.try_into().unwrap());
    let deployedContract = contract.deploy(@calldata).unwrap();
    stop_prank(CheatTarget::One(contract_address));

    deployedContract
}

fn get_important_addresses() ->(ContractAddress, ContractAddress, ContractAddress,) {
    let caller: ContractAddress = 0x048242eca329a05af1909fa79cb1f9a4275ff89b987d405ec7de08f73b85588f.try_into().unwrap();
    let EthToken: ContractAddress = 0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7.try_into().unwrap();
    let this: ContractAddress = get_contract_address();
    return (caller, EthToken, this);
}

#[test]
fn test_deploy_contract() {
    let (caller, EthToken, this) = get_important_addresses();
    let contract_address = deploy_contract('piggyFactory', this);
    let factory_dispatcher = IPiggyBankFactoryDispatcher{contract_address};
    let owner = factory_dispatcher.get_owner();
    assert (owner == this, 'WRONG CONTRACT OWNERSHIP');
}

#[test]
fn test_create_piggy_bank() {
    let (caller, EthToken, this) = get_important_addresses();
    let contract_address = deploy_contract('piggyFactory', this);
    let factory_dispatcher = IPiggyBankFactoryDispatcher{contract_address};
    let targetAmount = 10_000000000000000000;

    start_prank(CheatTarget::One(contract_address), caller);
    let user_piggy_1 = factory_dispatcher.createPiggyBank(targetOption::targetAmount, targetAmount);
    let piggy_dispatcher = piggyBankTraitDispatcher{contract_address:user_piggy_1};
    let piggyOwner = piggy_dispatcher.get_owner();
    stop_prank(CheatTarget::One(contract_address));

    assert(piggyOwner == caller, 'INCORECT PIGGYBANK OWNER');
}

#[test]
fn test_getAllPiggyBank() {
    let (caller, EthToken, this) = get_important_addresses();
    let contract_address = deploy_contract('piggyFactory', this);
    let factory_dispatcher = IPiggyBankFactoryDispatcher{contract_address};
    let targetAmount = 10_000000000000000000;

    start_prank(CheatTarget::One(contract_address), caller);
    let user_piggy_1 = factory_dispatcher.createPiggyBank(targetOption::targetAmount, targetAmount);
    let piggy_dispatcher = piggyBankTraitDispatcher{contract_address:user_piggy_1};
    let piggyOwner = piggy_dispatcher.get_owner();
    stop_prank(CheatTarget::One(contract_address));

    let piggy_bank_number = factory_dispatcher.getPiggyBanksNumber();
    let piggyAddr: ContractAddress = *factory_dispatcher.getAllPiggyBank().at(0);

    let piggyBanksLen = factory_dispatcher.getAllPiggyBank().len();
    let expectedPiggyBanksLen: u32 = 1;

    assert(piggyBanksLen == expectedPiggyBanksLen, 'INCORRECT BANK ARRAY LENGTH');
    assert(piggy_bank_number == expectedPiggyBanksLen.into(), 'INCORRECT PIGGYBANK NUMBER');
}

#[test]
fn test_track_user_piggy_bank() {
    let (caller, EthToken, this) = get_important_addresses();
    let contract_address = deploy_contract('piggyFactory', this);
    let factory_dispatcher = IPiggyBankFactoryDispatcher{contract_address};
    let targetAmount = 10_000000000000000000;

    start_prank(CheatTarget::One(contract_address), caller);
    let user_piggy_1 = factory_dispatcher.createPiggyBank(targetOption::targetAmount, targetAmount);
    let piggy_dispatcher = piggyBankTraitDispatcher{contract_address:user_piggy_1};
    let piggyOwner = piggy_dispatcher.get_owner();
    stop_prank(CheatTarget::One(contract_address));

    let piggyAddr: ContractAddress = *factory_dispatcher.getAllPiggyBank().at(0);
    let usersBank: ContractAddress = factory_dispatcher.getPiggyBankAddr(caller);

    assert (usersBank == piggyAddr, 'FAULTY BANK ADDR TRACKING');
}

