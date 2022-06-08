# Instruction = 4 trace cells
# Memory Access = 5 trace cells
# Instruction Decode = 16 trace cells

# cairo-compile ap.cairo --output ap_compiled.json
# cairo-run --program ap_compiled.json --print_output --layout=small

# Run w/ Debug Info:
# cairo-run --program ap_compiled.json --print_memory --print_info --trace_file=ap_trace.bin --memory_file=ap_memory.bin --relocate_prints

# init main function
func main():
    [ap] = 100
    [ap + 2] = 200
    # 2 memory accesses = 10 cells

    # Of the 3 values in an instruction, you can choose either an address of the form ap + off 
    # or fp + off where off is a constant offset in the range [−2^15, 2^15)
    [ap + 32767] = 400
    # [ap + 32768] = 400
    ret
end