// builtins = predefined optimized low-level execution units added to the Cairo CPU
//   - when we pass the 'layout' flag we specify which builtins and how many instances can be used
//   - requires main to take one argument and must return the value after writing specifying where it is
%builtins output

// cairo-compile builtins.cairo --output builtins_compiled.json
// cairo-run --program builtins_compiled.json --print_output --layout=small

// Run w/ Debug Info:
// cairo-run --program builtins_compiled.json --print_memory --print_info --trace_file=builtins_trace.bin --memory_file=ap_memory.bin --relocate_prints --layout=small
func main(output_ptr: felt*) -> (output_ptr: felt*) {
    // assign 100 to the first unused memory cell and advance ap
    [ap] = 100;
    [ap] = [output_ptr], ap++;

    [ap] = 200;
    [ap] = [output_ptr + 1], ap++;

    [ap] = 300;
    [ap] = [output_ptr + 2], ap++;

    // return the new value of the output_ptr
    // which was advanced by 3
    let output_ptr = output_ptr + 3;

    return(output_ptr = output_ptr);
}
