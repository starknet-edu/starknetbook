%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}() {
    tempvar x = 10 / 3;
    assert x = 10 / 3;
    serialize_word(x);

    return ();
}
