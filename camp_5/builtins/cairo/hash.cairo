%builtins output pedersen range_check

// To compile and run:
// cairo-compile builtins/cairo/hash.cairo --output hash_compiled.json  
// cairo-run --program hash_compiled.json --print_output --layout=small

from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2{hash_ptr: HashBuiltin*}(x, y) -> (result: felt) {
    hash_ptr.x = x;
    hash_ptr.y = y;
    let result = hash_ptr.result;
    let hash_ptr = hash_ptr + HashBuiltin.SIZE;
    return (result=result);
}

func serialize_word{output_ptr: felt*}(word) {
    assert [output_ptr] = word;
    let output_ptr = output_ptr + 1;
    return ();
}

func assert_nn{range_check_ptr}(a) {
    %{
        from starkware.cairo.common.math_utils import assert_integer
        assert_integer(ids.a)
        assert 0 <= ids.a % PRIME < range_check_builtin.bound, f'a = {ids.a} is out of range.'
    %}
    a = [range_check_ptr];
    let range_check_ptr = range_check_ptr + 1;
    return ();
}

func main{output_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}(){
    let a: felt = 1;
    let b: felt = 2;
    
    // Use the range_check builtin
    assert_nn(a);
    assert_nn(b);

    // Use the pedersen builtin
    let (res) = hash2{hash_ptr=pedersen_ptr}(1, 2);

    // Use the output builtin
    serialize_word(res);

    return();
}