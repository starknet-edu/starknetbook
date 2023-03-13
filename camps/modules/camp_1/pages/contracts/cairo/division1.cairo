%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}() {
    tempvar x = 9 / 3;
    assert x = 3;
    serialize_word(x);

    return ();
}
