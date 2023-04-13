%builtins output

// To compile and run (print memory without output):
// cairo-compile registers/cairo/ap_fp_example.cairo --output ap_fp_compiled.json
// cairo-run --program ap_fp_compiled.json --layout=small --print_memory --print_info --print_segments

func foo() {
    [ap] = 300, ap++;
    assert 300 = [ap-1];
    %{
        print(f"5. ap address: {ap}; fp address: {fp}; value at address [AP - 1] is {memory[ap - 1]} (FOO() FUNCTION).")
    %}
    // Do not store any value in the cells between ap and ap+300, leaving these cells empty
    [ap+300] = 500000;
    assert 500000 = [ap+300];
    %{
        print(f"6. ap address: {ap}; fp address: {fp}; value at address [AP + 300] is {memory[ap + 300]}; we can not get the values between ap and ap+300 since they are unknown.")
    %}
    return();
}

func main(output_ptr: felt*) -> (output_ptr: felt*) {
    %{
        print(f"1. ap address: {ap}; fp address: {fp}")
    %}
    // Store the felt 100 in [ap] and increase the value of ap by one; to the next empty memory cell
    [ap] = 100, ap++;
    // Assert that [ap-1] contains 100
    assert 100 = [ap-1];
    %{
        print(f"2. ap address: {ap}; fp address: {fp}; value at address [AP - 1] is {memory[ap - 1]}.")
    %}
    // Store the felt 200 in [ap] and increase the value of ap by one
    [ap] = 200, ap++;
    assert 200 = [ap-1];
    %{
        print(f"3. ap address: {ap}; fp address: {fp}; value at address [AP - 1] is {memory[ap - 1]}.")
    %}
    // Store the relocatable address of output_ptr in [ap] and increase the value of ap by one
    [ap] = output_ptr, ap++;
    // We need to update output_ptr
    let update_output_ptr = output_ptr + 1;
    assert [output_ptr] = [ap-1];
    %{
        print(f"4. ap address: {ap}; fp address: {fp}; value at address [AP - 1] is {memory[ap - 1]} (WITH OUTPUT_PTR).")
    %}
    // Call function foo() to understand how ap and fp work
    foo();
    // Store the felt 600 in [ap] and increase the value of ap by one
    [ap] = 600, ap++;
    assert 600 = [ap-1];
    %{
        print(f"7. ap address: {ap}; fp address: {fp}; value at address [AP - 1] is {memory[ap - 1]}.")
    %}
    // Since output_ptr was included as an explicit argument then we have to explicitly return it
    return(output_ptr=update_output_ptr);
}