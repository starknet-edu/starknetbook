%builtins output

func serialize_word{output_ptr: felt*}(word: felt) {
    assert [output_ptr] = word;
    let output_ptr = output_ptr + 1;
    // El nuevo valor de output_ptr es implícitamente añadido en return.
    return ();
}
