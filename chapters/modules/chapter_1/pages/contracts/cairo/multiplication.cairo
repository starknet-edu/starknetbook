%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Multiply two numbers and return the result
// @param num1 (felt): first number to multiply
// @param num2 (felt): second number to multiply
// @return prod (felt): value of the multiplication of the two numbers
func mult_two_nums(num1, num2) -> (prod: felt) {
    return (prod=num1 * num2);
}

func main{output_ptr: felt*}() {
    let (prod) = mult_two_nums(2, 2);
    serialize_word(prod);
    return ();
}
