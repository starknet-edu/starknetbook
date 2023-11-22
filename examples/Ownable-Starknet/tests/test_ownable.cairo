use starknet::{ContractAddress, Into, TryInto, OptionTrait};
use starknet::syscalls::deploy_syscall;
use result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use snforge_std::{declare, ContractClassTrait};
use snforge_std::io::{FileTrait, read_txt};
use snforge_std::{start_prank, stop_prank};
use snforge_std::{start_mock_call, stop_mock_call};

use ownable_starknet::{OwnableTraitDispatcher, OwnableTraitDispatcherTrait};
use ownable_starknet::{IDataSafeDispatcher, IDataSafeDispatcherTrait};

mod Errors {
    const INVALID_OWNER: felt252 = 'Caller is not the owner';
    const INVALID_DATA: felt252 = 'Invalid data';
}

mod Accounts {
    use traits::TryInto;
    use starknet::ContractAddress;

    fn admin() -> ContractAddress {
        'admin'.try_into().unwrap()
    }
    fn new_admin() -> ContractAddress {
        'new_admin'.try_into().unwrap()
    }
    fn bad_guy() -> ContractAddress {
        'bad_guy'.try_into().unwrap()
    }
}

fn deploy_contract(name: felt252) -> ContractAddress {
    // let account = Accounts::admin();
    let contract = declare(name);

    let file = FileTrait::new('data/calldata.txt');
    let calldata = read_txt(@file);
    //deploy contract
    contract.deploy(@calldata).unwrap()
}

#[test]
fn test_construct_with_admin() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address };
    let owner = dispatcher.owner();
    assert(owner == Accounts::admin(), Errors::INVALID_OWNER);
}

#[test]
fn test_transfer_ownership() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address };
    start_prank(contract_address, Accounts::admin());
    dispatcher.transfer_ownership(Accounts::new_admin());

    assert(dispatcher.owner() == Accounts::new_admin(), Errors::INVALID_OWNER);
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_transfer_ownership_bad_guy() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address };
    start_prank(contract_address, Accounts::bad_guy());
    dispatcher.transfer_ownership(Accounts::bad_guy());

    assert(dispatcher.owner() == Accounts::bad_guy(), Errors::INVALID_OWNER);
}

#[test]
fn test_data_mock_call_get_data() {
    let contract_address = deploy_contract('ownable');
    let safe_dispatcher = IDataSafeDispatcher { contract_address };
    let mock_ret_data = 100;
    start_mock_call(contract_address, 'get_data', mock_ret_data);
    start_prank(contract_address, Accounts::admin());
    safe_dispatcher.set_data(20);
    let data = safe_dispatcher.get_data().unwrap();
    assert(data == mock_ret_data, Errors::INVALID_DATA);
    stop_mock_call(contract_address, 'get_data');

    let data2 = safe_dispatcher.get_data().unwrap();
    assert(data2 == 20, Errors::INVALID_DATA);
    stop_prank(contract_address);
}
