%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Add two numbers and return the result
// @param num1 (felt): first number to add
// @param num2 (felt): second number to add
// @return sum (felt): value of the sum of the two numbers
func sum_two_nums(num1: felt, num2: felt) -> (sum: felt) {
    alloc_locals;
    local sum = num1 + num2;
    return (sum=sum);
}

func main{output_ptr: felt*}() {
    alloc_locals;

    const NUM1 = 1;
    const NUM2 = 10;

    let (sum) = sum_two_nums(num1=NUM1, num2=NUM2);
    serialize_word(sum);
    return ();
}
