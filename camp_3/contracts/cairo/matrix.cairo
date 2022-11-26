%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

struct Vector {
    elements: felt*,
}

struct Matrix {
    x: Vector,
    y: Vector,
}

func main{output_ptr: felt*}() {
    // Defining an array, my_array, of felts.
    let (my_array: felt*) = alloc();

    // Assigning values ​​to three elements of my_array.
    assert my_array[0] = 1;
    assert my_array[1] = 2;
    assert my_array[2] = 3;

    // Creating the vectors Vector, by
    // simplicity we use the same my_array for both.
    let v1 = Vector(elements=my_array);
    let v2 = Vector(elements=my_array);

    // Defining an array of Matrix matrices
    let (matrix_array: Matrix*) = alloc();

    // Filling matrix_array with Matrix instances.
    // Each instance of Matrix contains as members
    // Vector instances.
    assert matrix_array[0] = Matrix(x=v1, y=v2);
    assert matrix_array[1] = Matrix(x=v1, y=v2);

    // We use assert to test some values ​​in
    // our matrix_array.
    assert matrix_array[0].x.elements[0] = 1;
    assert matrix_array[1].x.elements[1] = 2;

    // What value do you think it will print? Answer: 3
    serialize_word(matrix_array[1].x.elements[2]);

    return ();
}
