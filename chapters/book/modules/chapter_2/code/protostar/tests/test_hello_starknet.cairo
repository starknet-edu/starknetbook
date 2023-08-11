use array::ArrayTrait;
use result::ResultTrait;

#[test]
#[available_gas(2000000)]
fn test_increase_balance() {
    let contract_address = deploy_contract('hello_starknet', ArrayTrait::new()).unwrap();

    let result_before = call(contract_address, 'get_balance', ArrayTrait::new()).unwrap();
    assert(*result_before.at(0_u32) == 0, 'Invalid balance');

    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(42);
    invoke(contract_address, 'increase_balance', invoke_calldata).unwrap();

    let result_after = call(contract_address, 'get_balance', ArrayTrait::new()).unwrap();
    assert(*result_after.at(0_u32) == 42, 'Invalid balance');
}

#[test]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract('hello_starknet', ArrayTrait::new()).unwrap();

    let result_before = call(contract_address, 'get_balance', ArrayTrait::new()).unwrap();
    assert(*result_before.at(0_u32) == 0, 'Invalid balance');

    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(0);
    let invoke_result = invoke(contract_address, 'increase_balance', invoke_calldata);

    assert(invoke_result.is_err(), 'Invoke should fail');
}
