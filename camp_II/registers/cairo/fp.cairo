# When a function starts the frame pointer register (fp) is initialized to the current value of ap. 
# During the entire scope of the function (excluding inner function calls) the value of fp remains constant

# cairo-compile fp.cairo --output fp_compiled.json
# cairo-run --program fp_compiled.json --print_output --layout=small

# Run w/ Debug Info:
# cairo-run --program fp_compiled.json --print_memory --print_info --trace_file=fp_trace.bin --memory_file=fp_memory.bin --relocate_prints
func main():
    # call “pushes” the current frame pointer and return-address to a (virtual) stack of pairs (fp, pc) and jumps to the given address.
    # |      ...     |
    # +--------------+
    # | old_fp       |
    # +--------------+
    # | return_pc    |
    # +--------------+
    # |              | <-- ap, fp
    # +--------------+
    # |      ...     |
    
    call foo
    call foo
    call foo

    ret
end

func foo():
    [ap] = 1000; ap++
    # ret “pops” the previous fp and jumps to return_pc that were pushed during the call.
    ret
end