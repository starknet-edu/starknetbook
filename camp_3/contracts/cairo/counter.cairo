//
// explicitly declare cairo for starknet
//
%lang starknet

//
// instructs the compiler to compile the file with the declared libraries
//
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.math import assert_not_zero

//
// '@' symbols denote decorators
// storage variable declaring a storage variable that points to a felt(feild element)
//
@storage_var
func counter() -> (count: felt) {
}

//
// '@view' decorator declaring a function that only queries the state
//
// name the function, declare zero function arguments, include the required implicit arguments
// declare function return type
@view
func get_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt) {
    let (count) = counter.read();

    return (count,);
}

//
// '@external' decorator declaring function user calls that can update the state
//
@external
func increment{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt) {
    let (count) = counter.read();
    counter.write(count + 1);

    let (new_count) = counter.read();

    return (count=new_count);
}

@external
func decrement{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt) {
    let (count) = counter.read();
    assert_not_zero(count);

    counter.write(count - 1);

    let (new_count) = counter.read();

    return (count=new_count);
}
