%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import call_contract

//
// __validate__: upon receiving a tx the account contract will first call '__validate__'
//
@external
func __validate__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    contract_address: felt, selector: felt, calldata_len: felt, calldata: felt*
) {
    return ();
}

//
// __validate_declare__: declare transactions now require accounts to pay fees
//
@external
func __validate_declare__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    class_hash: felt
) {
    return ();
}

//
// __execute__: if '__validate__' is successful '__execute__' will be called
//
@external
func __execute__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    contract_address: felt, selector: felt, calldata_len: felt, calldata: felt*
) -> (retdata_len: felt, retdata: felt*) {
    let (retdata_len: felt, retdata: felt*) = call_contract(
        contract_address=contract_address,
        function_selector=selector,
        calldata_size=calldata_len,
        calldata=calldata,
    );
    return (retdata_len=retdata_len, retdata=retdata);
}
