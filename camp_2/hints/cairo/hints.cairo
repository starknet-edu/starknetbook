%builtins output

# Goal to prove the square root y of x is 961 is in the range of 0, 1, ..., 100
# - To the verifier it looks like the prover "guessed" the correct answer
# - Because the execution is not stored in the trace
# - BUT notice we still prove the validity of the statement

# cairo-compile hints.cairo --output hints_compiled.json
# cairo-run --program hints_compiled.json --print_output --layout=small --program_input=input.json
func main(output_ptr : felt*) -> (output_ptr : felt*):
    # hints are code run in cairo programs
    %{ print("Hello World!") %}

    # they can access the memory of the program
    %{
        import math
        memory[ap] = int(math.sqrt(program_input['value']))
    %}
    [ap] = [output_ptr]; ap++
    [ap] = output_ptr + 1; ap++

    ret
end