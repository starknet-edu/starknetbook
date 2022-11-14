// cairo-compile recursion.cairo --output recursion_compiled.json
// cairo-run --program recursion_compiled.json --print_output --layout=small 

// Run w/ Debug Info:
// cairo-run --program recursion_compiled.json --print_memory --print_info --trace_file=recursion_trace.bin --memory_file=recursion_memory.bin --relocate_prints

from starkware.cairo.common.alloc import alloc

// init main function
func main(){

    alloc_locals;

    // Allocate memory and get a pointer to the start of the memory
    let (array : felt*) = alloc();

    // Filling initial array
    assert [array] = 10;
    assert [array + 1] = 11;
    assert [array + 2] = 12;
    assert [array + 3] = 13;
    assert [array + 4] = 14;
    assert [array + 5] = 15;

    // Copy using recursion and get array in reversed order
    // Will be usefull when copying arrays into storage mappings
    // See for instance https://github.com/starknet-edu/starknet-cairo-101/blob/47c8bd04e762f3c469d6d8d24b169b5145ba9acc/contracts/ex05.cairo#L171 
    // Indeed, for mappings of type
    // @storage_var
    // func values_mapped_storage(slot: felt) -> (values_mapped_storage: felt) {
    // }
    // One can follow the principles implemented here when populating values coming 
    // from an array. 
    // A storage mapping is not a pointer per se (and thus cannot be incremented) and 
    // it does not have a size per se. 
    // For the reverse order recursion, all the reasonning is performed on the 
    // "current" last element of the array : no need of some pointer arythmetics on where
    // the target array starts  
    let (arr) = copy_array_reverse_order(6, array);
    // Checking returned values
    assert arr[0] = 15;
    assert arr[1] = 14;
    assert arr[2] = 13;
    assert arr[3] = 12;
    assert arr[4] = 11;
    assert arr[5] = 10;

    // This is a regular copy like you could see in C or Python. 
    // Nevetheless, not usefull once you deal with actual contracts (and not 
    // only just cairo programs)
    let (arr_2) = copy_array_same_order(6, array);
    // Checking returned values
    assert arr_2[0] = 10;
    assert arr_2[1] = 11;
    assert arr_2[2] = 12;
    assert arr_2[3] = 13;
    assert arr_2[4] = 14;
    assert arr_2[5] = 15;
    
    return ();
}

///////////////////////////
// Reverse order functions
///////////////////////////
func copy_recursion_reverse_order(values_len: felt, values: felt*, array_res : felt*){
    if (values_len == 0) {
        return ();
    }
    // In the inner call, we just pass `array_res`
    copy_recursion_reverse_order(values_len-1, values = values+1, array_res = array_res);
    assert [array_res + values_len -1] = [values];

    return ();
}

func copy_array_reverse_order(values_len: felt, values: felt*) -> (array_res : felt*){
    // `alloc_locals` is required to use Local Variables.
    // See for instance https://cairo-by-example.org/cairo/variables
    alloc_locals;

    // Allocate target memory
    let (array_res : felt*) = alloc();

    copy_recursion_reverse_order(values_len = values_len, values = values, array_res = array_res);

    return (array_res,);
}

///////////////////////////
// Same order functions
///////////////////////////

func copy_recursion_same_order(values_len: felt, values: felt*, array_res : felt*){
    if (values_len == 0) {
        return ();
    }
    assert [array_res] = [values];
    // Since we are filling target memory in the same order, one has to 
    // "update" the start of the rest of the target array. Hence the `array_res = array_res+1`
    copy_recursion_same_order(values_len-1, values = values+1, array_res = array_res+1);

    return ();
}

func copy_array_same_order(values_len: felt, values: felt*) -> (array_res : felt*){
    // `alloc_locals` is required to use Local Variables.
    // See for instance https://cairo-by-example.org/cairo/variables
    alloc_locals;

    // Allocate target memory
    let (array_res : felt*) = alloc();

    copy_recursion_same_order(values_len = values_len, values = values, array_res = array_res);

    return (array_res,);
}
