use core::{traits::Into, debug::PrintTrait};
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use starknet::{ContractAddress, get_contract_address, ClassHash};
use starknet::Felt252TryIntoContractAddress;
use piggy_bank::piggy_bank::{piggyBankTraitDispatcher, piggyBankTraitDispatcherTrait, IERC20Dispatcher, IERC20DispatcherTrait, };
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, start_warp, stop_warp, env::var, ContractClass, get_class_hash, CheatTarget};
use snforge_std::BlockId;

mod testStorage {
    const contract_address: felt252 = 0;
}


fn deploy_contract_forked(name: felt252, owner: ContractAddress, token: ContractAddress, manager: ContractAddress, target: u8, targetDetails: u128) -> ContractAddress {
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);
    token.serialize(ref calldata);
    manager.serialize(ref calldata);
    target.serialize(ref calldata);
    targetDetails.serialize(ref calldata);
    let deployed_contract_address: ContractAddress = 0x042f0284511fb30a93defacad0c7d2a8968bfe0700fb54785337753e3b12720a.try_into().unwrap();
    // Precalculate the address to obtain the contract address before the constructor call (deploy) itself
    let contract_address = ContractClass{class_hash: get_class_hash(deployed_contract_address)}.precalculate_address(@calldata);
    start_prank(CheatTarget::One(contract_address), owner.try_into().unwrap());
    let deployedContract = ContractClass{class_hash: get_class_hash(deployed_contract_address)}.deploy(@calldata).unwrap();
    stop_prank(CheatTarget::One(contract_address));

    deployedContract
}


fn deploy_contract(name: felt252, owner: ContractAddress, token: ContractAddress, manager: ContractAddress, target: u8, targetDetails: u128) -> ContractAddress {
    let contract = declare(name);
    let mut calldata = ArrayTrait::new();
    owner.serialize(ref calldata);
    token.serialize(ref calldata);
    manager.serialize(ref calldata);
    target.serialize(ref calldata);
    targetDetails.serialize(ref calldata);

    // Precalculate the address to obtain the contract address before the constructor call (deploy) itself
    let contract_address = contract.precalculate_address(@calldata);

    start_prank(CheatTarget::One(contract_address), owner.try_into().unwrap());
    let deployedContract = contract.deploy(@calldata).unwrap();
    stop_prank(CheatTarget::One(contract_address));

    deployedContract
}


fn get_important_addresses() ->(ContractAddress, ContractAddress, ContractAddress,) {
    let caller: ContractAddress = 0x032e0bbab381cdc21c523699add33f9df9c80444ae174f81413f3122f4ed7b1f.try_into().unwrap();
    let EthToken: ContractAddress = 0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7.try_into().unwrap();
    let this: ContractAddress = get_contract_address();
    return (caller, EthToken, this);
}


#[test]
fn test_initial_balance() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address }; 
    let initial_balance: u128 = piggy_dispatcher.get_balance();
   
    assert(initial_balance == 0, 'Invalid balance');
}


#[test]
fn test_expected_owner() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let owner: ContractAddress = piggy_dispatcher.get_owner();

    assert(owner == caller, 'Unexpected owner');
}


#[test]
#[fork("SepoliaFork")]
fn test_deposit_into_Account() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 1000000000000000000;

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    piggy_dispatcher.deposit(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let newBalance: u128 = eth_dispatcher.balanceOf(contract_address).try_into().unwrap();
    let currentBalance = piggy_dispatcher.get_balance();
    assert(currentBalance == depositAmount, 'WRONG CONTRACT BALANCE');
    assert(newBalance == depositAmount, 'CONTRACT BALANCE SHOULD TALLY');
}


#[test]
#[fork("SepoliaFork")]
fn test_withdraw_without_meeting_target_amount() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 1000000000000000000;

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    piggy_dispatcher.deposit(depositAmount);
    let managerBlanceBefore = eth_dispatcher.balanceOf(this);
    piggy_dispatcher.withdraw(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlance = eth_dispatcher.balanceOf(this);
    let expectedManagerBlance = (depositAmount * 10) / 100;
    let piggyBalanceAfter = piggy_dispatcher.get_balance();
    let expectedPiggyBalanceAfter = 0;
    
    assert(managerBlance == expectedManagerBlance.into(), 'WRONG MANAGER BALANCE');
    assert(managerBlance != managerBlanceBefore, 'MANAGER BALANCE DOES NOT TALLY');
    assert(piggyBalanceAfter == expectedPiggyBalanceAfter, 'WRONG PIGGY BALANCE CALC');
}


#[test]
#[fork("SepoliaFork")]
fn test_withdraw_after_meeting_target_amount() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 10000000000000000000;

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    piggy_dispatcher.deposit(depositAmount);

    let managerBlanceBefore = eth_dispatcher.balanceOf(this);

    piggy_dispatcher.withdraw(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlance = eth_dispatcher.balanceOf(this);
    let expectedManagerBlance = 0;
    let piggyBalanceAfter = piggy_dispatcher.get_balance();
    let expectedPiggyBalanceAfter = 0;
    
    assert(managerBlance == expectedManagerBlance.into(), 'WRONG MANAGER BALANCE');
    assert(managerBlance == managerBlanceBefore, 'MANAGER BALANCE DOES NOT TALLY');
    assert(piggyBalanceAfter == expectedPiggyBalanceAfter, 'WRONG PIGGY BALANCE CALC');
}


#[test]
#[fork("SepoliaFork")]
#[should_panic(expected: ('Caller is not the owner', ))]
fn test_UnAuthorized_user_withdrawal_Attempt() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetSavings = 10_000000000000000000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 1, targetSavings);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 10000000000000000000;
    let unAuthorizedUser: ContractAddress = 123.try_into().unwrap();

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    piggy_dispatcher.deposit(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlanceBefore = eth_dispatcher.balanceOf(this);
    let UUBlanceBefore = eth_dispatcher.balanceOf(unAuthorizedUser);
    let piggyBalanceBefore = piggy_dispatcher.get_balance();

    start_prank(CheatTarget::One(contract_address), unAuthorizedUser);
    piggy_dispatcher.withdraw(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlance = eth_dispatcher.balanceOf(this);
    let UUBlanceAfter = eth_dispatcher.balanceOf(unAuthorizedUser);
    let piggyBalanceAfter = piggy_dispatcher.get_balance();

    assert(UUBlanceBefore == UUBlanceAfter, 'UNAUTHORIZED USER WITHDRAWAL');
    assert(piggyBalanceBefore == piggyBalanceAfter, 'UNAUTHORIZED LOSS OF FUNDS');
}


#[test]
#[fork("SepoliaFork")]
fn test_withdraw_after_meeting_target_time() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetTime = 1000;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 0, targetTime);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 10000000000000000000;
    let unAuthorizedUser: ContractAddress = 123.try_into().unwrap();

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    start_warp(CheatTarget::One(contract_address), 100);
    piggy_dispatcher.deposit(depositAmount);
    let managerBlanceBefore = eth_dispatcher.balanceOf(this);

    start_warp(CheatTarget::One(contract_address), 2100);
    piggy_dispatcher.withdraw(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlance = eth_dispatcher.balanceOf(this);
    let expectedManagerBlance = 0;
    let piggyBalanceAfter = piggy_dispatcher.get_balance();
    let expectedPiggyBalanceAfter = 0;
    
    assert(managerBlance == expectedManagerBlance.into(), 'WRONG MANAGER BALANCE');
    assert(managerBlance == managerBlanceBefore, 'MANAGER BALANCE DOES NOT TALLY');
    assert(piggyBalanceAfter == expectedPiggyBalanceAfter, 'WRONG PIGGY BALANCE CALC');
}

#[test]
#[fork("SepoliaFork")]
fn test_withdraw_without_meeting_target_time() {
    let (caller, EthToken, this) = get_important_addresses();
    let targetTime = 2000170827;
    let contract_address = deploy_contract('piggyBank', caller, EthToken, this, 0, targetTime);
    let piggy_dispatcher = piggyBankTraitDispatcher { contract_address };
    let eth_dispatcher = IERC20Dispatcher{ contract_address: EthToken};
    let depositAmount: u128 = 10000000000000000000;
    let unAuthorizedUser: ContractAddress = 123.try_into().unwrap();

    start_prank(CheatTarget::One(EthToken), caller);
    eth_dispatcher.approve(contract_address, depositAmount.into());
    stop_prank(CheatTarget::One(EthToken));

    start_prank(CheatTarget::One(contract_address), caller);
    piggy_dispatcher.deposit(depositAmount);
    let managerBlanceBefore = eth_dispatcher.balanceOf(this);
    piggy_dispatcher.withdraw(depositAmount);
    stop_prank(CheatTarget::One(contract_address));

    let managerBlance = eth_dispatcher.balanceOf(this);
    let expectedManagerBlance = (depositAmount * 10) / 100;
    let piggyBalanceAfter = piggy_dispatcher.get_balance();
    let expectedPiggyBalanceAfter = 0;
    
    assert(managerBlance == expectedManagerBlance.into(), 'WRONG MANAGER BALANCE');
    assert(managerBlance != managerBlanceBefore, 'MANAGER BALANCE DOES NOT TALLY');
    assert(piggyBalanceAfter == expectedPiggyBalanceAfter, 'WRONG PIGGY BALANCE CALC');
}




