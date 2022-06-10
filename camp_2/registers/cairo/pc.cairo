# cairo-compile pc.cairo --output pc_compiled.json
# cairo-run --program pc_compiled.json --print_output --layout=small

# Run w/ Debug Info:
# cairo-run --program pc_compiled.json --print_memory --print_info --trace_file=pc_trace.bin --memory_file=pc_memory.bin --relocate_prints --no_end --step=16
func main():
    [ap] = 2; ap++

    my_loop:
    [ap] = [ap - 1] * [ap - 1]; ap++
    [ap] = [ap - 1] + 1; ap++
    jmp my_loop
end