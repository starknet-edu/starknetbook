<div align="center">
    <h1>Camp 2: Cairo</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[Cairo](https://drive.google.com/file/d/1nXi1ZLPM-19kXpCxwOMLQU_GMzlNYMNZ/view?usp=sharing)|[Cairo Basecamp](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing)|[StarkNet Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)|

</div>

### Topics

<ol>
    <li>CLI</li>
    <li>C(pu)AIR(o)</li>
    <li>Syntax</li>
    <li>Cairo VM</li>
</ol>

<div align="center">
    <h2 id="cairo_cli">CLI Cheatsheet</h2>
</div>

```bash
# compile cairo program
cairo-compile example.cairo --output example_compiled.json

# run cairo program and output results
cairo-run --program=example_compiled.json --print_output --layout=small

# output the KECCAK Fact of the cairo program
cairo-hash-program --program=example_compiled.json

# format/lint your cairo program
cairo-format -i example.cairo

# compile cairo program and submit the fact to the SHARP
cairo-sharp submit --source example.cairo --program_input input.json
```

<h2 align="center" id="cairolang">C(pu)AIR(o)</h2>

As we saw in [Camp 1](../camp_1) the STARK Proof system is based on `AIR` or Algebraic Intermediate Representation of computation. The AIR is a list of polynomial constraints operating on a trace of finite field elements and the STARK Proof verifies there exists a trace that satisfies those constraints.

Cairo stands for CPU AIR and consists of a single set of polynomial constraints such that the execution of a program on this architecture is valid. Cairo is a programming language for writing provable programs.

***A practically-efficient Turing-complete STARK-Friendly CPU Architecture***

`Practical`: Cairo supports conditional branches, memory, function calls, and recursion

`Efficient`: Instruction Set chosen so the corresponding AIR is efficient and optimized with `builtins`

`Turing Complete`: Can simulate any Turing machine, as such supports any feasible computation

`UNDER CONSTRUCTION`:

While this section is being built we recommend reading the video session for this camp and the [cairo-lang docs](https://www.cairo-lang.org/docs/how_cairo_works/index.html).

<hr>

<h2 align="center" id="computational_integrity">Computational Integrity</h2>
STARKs

<h2 align="center" id="syntax">Syntax</h2>

<h3>FELTs</h3>

`UNDER CONSTRUCTION`

In most of your code (unless you intend to write very algebraic code), you won't have to deal with the fact that the values in Cairo are felts and you can treat them as if they were normal integers ([Cairo documentation](https://www.cairo-lang.org/docs/hello_cairo/intro.html#the-primitive-type-field-element-felt)). The field element (felt) is the only data type that exists in Cairo, you can even omit its explicit declaration; when the type of a variable or argument is not specified, it is automatically assigned the type felt. Addresses are also stored as felts.

A felt can be negative or zero, and can be a large integer: specifically, it can be in the range $-X < felt < X$, where $X = 2^{251} + 17* 2^{192} + 1$ . Any value that is not within its range will cause an “overflow”: an error that occurs when a program, Cairo, receives a number or value outside the scope of its ability to handle. Thus, when we add, subtract or multiply and the result is outside the felt's range, there is an overflow.

Compile and run [felt.cairo](./felts/cairo/felt.cairo) with:

```bash
cairo-compile felts/cairo/felt.cairo --output felt_compiled.json
cairo-run --program felt_compiled.json --print_output --layout=small
```

You will get:   

```bash
Program output:
  0
  -1
  1
  2
  1206167596222043737899107594365023368541035738443865566657697352045290673496
  7
```

`FELT_SIZE = 2**251 + 17 * 2**192 + 1` is just outside the range of values a felt can take, then it will overflow to `0` as evidenced when running `serialize_word(FELT_SIZE)`. 

The most important difference between integers and field elements is division: Division of felts is not the integer division in many programming languages; the integral part of the quotient is returned (so you get $(7 / 3 = 2)$. As long as the numerator is a multiple of the denominator, it will behave as you expect $(6 / 3 = 2)$. If this is not the case, for example when we divide $7/3$, it will result in a felt $x$ that satisfies $(3 * x = 7)$; specifically, $x=1206167596222043737899107594365023368541035738443865566657697352045290673496$. It won’t be $2.3333$ because $x$ has to be an integer and since $3 * x$ is larger than $2^{251} + 17 * 2^{192} + 1$ it will overflow to exactly $7$. In other words, when we are using modular arithmetic, unless the denominator is zero, there will always be an integer $x$ satisfying $denominator * x = numerator$.


<h3>The Cairo Intruction Set (Algebraic RISC)</h3>

Here is a nice mental model by [@liamzebedee](https://twitter.com/liamzebedee/status/1516298353080152064) to think about Cairo:
* AIR = Assembly for STARK's
* Cairo Language = Java for STARK's

Java code turns into JVM bytecode which is interpreted into assembly; similarly, Cairo (the language) code is interpreted into CairoVM bytecode which is interpreted into AIR. The JVM executes on an x86 processor (e.g. java.exe), and the CairoVM executes on a STARK prover. STARK provers will eventually be embedded in hardware, just like other cryptographic coprocessors (TPM's, enclaves).

Unlike ordinary Instruction Sets, which are executed on a physical chip built of transistors, Cairo is executed in an AIR (the execution trace is verified using an AIR). Roughly speaking, the most important constraint when designing an AIR (and, therefore, when designing an Instruction Set that will be executed by an AIR) is to minimize the number of trace cells used.  

The Instruction Set is the set of operations the Cairo CPU can perform in a single step. Cairo uses a small and simple, yet relatively expressive, Instruction Set; it was chosen so that the corresponding AIR will be as efficient as possible. It is a balance between:
1.  A minimal set of simple instructions that require a very small number of trace cells; and
2.  Powerful enough instructions that will reduce the number of required steps.

Particularly:

1. Addition and multiplication are supported.
2. Checking whether two values are equal is supported, but there is no instruction for checking whether a certain value is less than another value (such an instruction would have required many more trace cells since a finite field does not support an algebraic-friendly linear ordering of its elements).

This minimalistic set of instructions is called an Algebraic RISC (Reduced Instruction Set Computer); “Algebraic” refers to the fact that the supported operations are field operations. Using an Algebraic RISC allows us to construct an AIR for Cairo with only 51 trace cells per step. 


<h3>Builtins</h3>

The Algebraic RISC can simulate any Turing Machine and hence is Turing-complete (supports any feasible computation). However, implementing some basic operations, such as the comparison of elements, using only Cairo instructions would result in a lot of steps which damages the goal of minimizing the number of trace cells used. Consider that adding a new instruction to the Instruction Set has a cost even if this instruction is not used. To mitigate this without increasing the number of trace cells per instruction, Cairo introduces the notion of builtins.

> Builtins are predefined optimized low-level execution units which are added to the Cairo CPU board to perform predefined computations which are expensive to perform in vanilla Cairo (e.g., range-checks, Pedersen hash, ECDSA, …).

The communication between the CPU and the builtins is done through memory: each builtin is assigned a continuous area in the memory and applies some constraints (depending on the builtin definition) on the memory cells in that area. In terms of building the AIR, it means that adding builtins does not affect the CPU constraints. It just means that the same memory is shared between the CPU and the builtins. To “invoke” a builtin, the Cairo program “communicates” with certain memory cells, and the builtin enforces some constraints on those memory cells. 

For example, the `range-check` builtin enforces that all the values for the memory cells in some fixed address range are within the range $[0, 2^{128})$. The memory cells constrained by the `range-check` builtin are called "range-checked" cells.

In practical terms, a builtin is utilized by writing (and reading) the inputs to a dedicated memory segment accessed via the "builtin pointer": each builtin has its pointer to access the builtin's memory segment. Builtin pointers follow the name convention `<builtin name>_ptr`; e.g., `range_check_ptr`. In the Cairo case, the builtin directive adds the builtin pointers as parameters to main which can then be passed to any function making use of them. Builtin declarations appear at the top of the Cairo code file. They are declared with the `%builtins` directive, followed by the name of the builtins; e.g., `%builtin range_check`. In StarkNet contracts, it is not necessary to add them. 

Builtin pointers can be of different types. The following table summarizes the available builtins, what they are for, their pointer names, and their pointer types.

| **Builtin** | For...                                                                                           | **Pointer name** |   **Pointer type**   |
|:-----------:|--------------------------------------------------------------------------------------------------|:----------------:|:--------------------:|
| output      | Writing program output which appears explicitly in an execution proof                            | output_ptr       | felt*                |
| pedersen    | Computing the Pedersen hash function                                                             | pedersen_ptr     | HashBuiltin*         |
| range_check | Checking that a field element is within a range $[0,2^{128})$, and for doing various comparisons | range_check_ptr  | felt (not a pointer) |
| ecdsa       | Verifying ECDSA signatures                                                                       | ecdsa_ptr        | SignatureBuiltin*    |
| bitwise     | Performing bitwise operations on felts                                                           | bitwise_ptr      | BitwiseBuiltin*      |

The details of each type are in the [common library](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo). Each type, that is not directly a `felt*`, is nothing more than a struct. For example, the [`HashBuiltin`](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo#L5):

```Rust
struct HashBuiltin {
    x: felt,
    y: felt,
    result: felt,
}
```

Note the following implementation of the [hash2 function](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/hash.cairo) to compute the hash of two given field elements:

```Rust
from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2(hash_ptr: HashBuiltin*, x, y) -> (
    hash_ptr: HashBuiltin*, z: felt
) {
    let hash = hash_ptr;
    // Invoke the hash function.
    hash.x = x;
    hash.y = y;
    // Return the updated pointer (increased by 3 memory cells)
    // and the result of the hash.
    return (hash_ptr=hash_ptr + HashBuiltin.SIZE, z=hash.result);
}
```

`hash_ptr` was added as an explicit argument and explicitly returned updated (`hash_ptr + HashBuiltin.SIZE`). We have to keep track of a pointer to the next unused builtin memory cell. The convention is that functions that use the builtin should get that pointer as an argument and return an updated pointer to the next unused builtin memory cell.

It is easier to use implicit arguments: a Cairo syntactic sugar that automatically returns the implicit argument. The common library implementation of the [hash2 function](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/hash.cairo) is:

```Rust
%builtins pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2{hash_ptr: HashBuiltin*}(x, y) -> (result: felt) {
    // Invoke the hash function
    hash_ptr.x = x;
    hash_ptr.y = y;
    let result = hash_ptr.result;
    // Update hash_ptr (increased by 3 memory cells)    
    let hash_ptr = hash_ptr + HashBuiltin.SIZE;
    return (result=result);
}
```

`hash_ptr` is updated but this time it was returned implicitly. As another example, this is the implementation of the [serialize_word function](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/serialize.cairo#L1) which will output a felt into your terminal:


```Rust
func serialize_word{output_ptr: felt*}(word) {
    // Invoke the output function
    assert [output_ptr] = word;
    // Update output_ptr (increased by 1 memory cell)
    let output_ptr = output_ptr + 1;
    return ();
}
```

Refer to the implemetation in [builtins/cairo/hash.cairo](./builtins/cairo/hash.cairo) for an example using the `output`, `pedersen`, and `range_check` builtins. 

At what moment did the `hash2` and `serialize_word` functions invoked the properties of their builtins?

1. When we called `%builtins output pedersen` at the start of the Cairo program, the Cairo VM prepares to use the `output_ptr` and `pedersen_ptr` pointers, and their respective memory segments: usually 2 and 3 (segment 1 is commonly the execution segment, more on the next section).

2. Second, the Cairo code reads or writes to the memory cells in the segments assigned to the `output` and `pedersen`.

3. Finally, when a value is written in a memory cell inside a builtin segment, the builtin properties are invoked. For example, when a `struct HashBuiltin` is defined (you have to indicate `x` and `y`, see the structure of [`HashBuiltin`](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo#L5)) then the Pedersen builtin enforces that $result == hash(x, y)$. We can then retrieve the value of `result` with `let result = hash_ptr.result;` as in the `hash2` function. Whenever the program wishes to communicate information to the verifier, it can do so by writing it to a designated memory segment which can be accessed by using the `output` builtin (see more in [the docs](https://starknet.io/docs/how_cairo_works/program_input_and_output.html#id2)).


<h3>Memory and segments</h3>

**Continous**. Memory addresses accessed by a program must be continuous. For example, if addresses 7 and 9 are accessed, then 8 must also be accessed before the end of the program. The prover will automatically fill the empty memory cells with arbitrary values. Having such gaps is inefficient, as it means memory is being consumed without being used. Introducing too many holes could make the generation of a proof too expensive. However, this still does not violate the soundness guarantee – a false proof cannot be generated regardless. In practice we can store values in memory cells while skipping memory cells (see [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo)), the prover will fill the empty cells to keep the memory continous.

**Write-once, read-only**. We can think of the memory of Cairo as a write-once memory (it can only be written once). If we assign that `assert [d] = 7;` then the address `d` in memory will always contain the value `7` until the execution of our program is finished. We won't be able to change what address `d` stores at run time, we could only write it once and then read it.

**Relative addresses**. The absolute address of each memory cell can only be determined at the end of the execution of the Cairo program. That is, we are dealing with addresses relative to other addresses. I cannot say that I want the felt equivalent to `“I rule here”` to be found in memory cell number 32. I can say, for example, I want the felt equivalent to `Cairo rule”` to be found in the next empty cell or in three cells from the current one being used. Do you notice how we are not talking about absolute addresses but relative addresses? We will review registers, which are very useful for this, in a the next section.

**Segments**. When accessing memory in Cairo we use segments. The segments are memory areas. These segments will then be concatenated to create a list of segments: our memory. As we mentioned before, addresses in Cairo are relative: they are not inly reltive to each other but also to the segment to which they belong. Therefore, an address in Cairo is represented like this: `<segment>:<offset>`. Where `<segment>` is the segment number (we don't know it when writing the program, it is assigned when running our program); and `<offset>` is the position of the address relative to the segment. This way of representing addresses is called "relocatable": in the end, when we run our program, these memory cells will be relocated so that the memory ends up being continuous.

The two segments that any Cairo program require are:

* **Segment 0** - Program segment. Cairo programs are themselves kept in the program segment. This segment is of fixed length and contains the numeric representation of the Cairo program. The register `pc` starts here.
* **Segment 1** - Execution segment. This is where the registers `ap` and `fp` start, and where data generated during the run of a Cairo program (variables, return addresses for function calls, etc.) is stored. The length of the execution segment is variable, as it depends, for example, on the program input.

As we saw before, we can use builtins which would have their own memory segment. Compile [builtins/cairo/hash.cairo](./builtins/cairo/hash.cairo) (`cairo-compile builtins/cairo/hash.cairo --output hash_compiled.json`) and run it with the `--print-memory` flag (`cairo-run --program hash_compiled.json --print_output --layout=small --print_memory`). Notice we have values in the Program (0), Execution (1), Output (2), Pedersen (3), and Range Check (4) segments.


<h3>Registers</h3>

We know that the Algebraic RISC operates on memory cells (there are no general purpose registers). One Cairo instruction may deal with up to 3 values from the memory: it can perform one arithmetic operation (either addition or multiplication) on two of them, and store the result in the third. In total, each instruction uses 4 memory accesses since it first uses one for fetching the instruction ([Cairo Whitepaper](https://eprint.iacr.org/2021/1063.pdf)).

The Cairo CPU operates on 3 registers (`pc`, `ap`, and `fp`) that are used for specifying which memory cells the instruction operates on. For each of the 3 values in an instruction, you can choose either an address of the form $ap + off$ or $fp + off$ where $off$ is a constant offset in the range $[−215, 215)$. Thus, an instruction may involve any 3 memory cells out of $2 · 216 = 131072$. In many aspects, this is similar to having this many registers (implemented in a much cheaper way). An offset is an addition or substraction to a cell in the memory, e.g., $[fp - 1] = [ap - 2] + [fp + 4]$ where $-1$, $-2$ and $+4$ are offsets. Offsets allow us to have relative memory positions.

* The "allocation pointer" (ap) points to the first memory cell that has not been used by the program so far. Many instructions may increase the value `ap` by one to indicate that another memory cell has been used by the instruction; similar to what `serialize_word` does when it uses the output builtin memory at  `output_ptr` and then updates its value.

* When a function starts the "frame pointer" register (fp) is initialized to the current value of ap. During the entire scope of the function (excluding inner function calls) the value of `fp` remains constant. In particular, when a function, foo, calls an inner function, bar, the value of `fp` changes when bar starts but is restored when bar ends. The idea is that `ap` may change in an unknown way when an inner function is called, so it cannot reliably be used to access the original function’s local variables and arguments anymore after that. Thus, `fp` serves as an anchor to access these values.

* The “program counter” (pc) register points to the address in memory of the current Cairo instruction to be executed. The `pc` starts at the beginning of the program segment; segment 0. The CPU (1) fetches the value of that memory cell, (2) performs the instruction expressed by that value (which may affect memory cells or change the flow of the program by assigning a different value to PC), (3) moves `pc` to the next instruction and (4) repeats this process. In other words, The program counter (pc) keeps the address of the current instruction. Usually it advances by 1 or 2 per instruction according to the size of the instruction (when the current instruction occupies two field elements, the program counter advances by 2 for the next instruction).

Compile and the run [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo). The example will print:

```Bash
1. ap address: 1:3; fp address: 1:3
2. ap address: 1:4; fp address: 1:3; value at address [AP - 1] is 100.
3. ap address: 1:5; fp address: 1:3; value at address [AP - 1] is 200.
4. ap address: 1:6; fp address: 1:3; value at address [AP - 1] is 2:0 (WITH OUPUT_PTR).
5. ap address: 1:9; fp address: 1:8; value at address [AP - 1] is 300 (FOO() FUNCTION).
6. ap address: 1:9; fp address: 1:8; value at address [AP + 2] is 500; we can not get the value at [AP + 1] since it is unknown.
7. ap address: 1:10; fp address: 1:3; value at address [AP - 1] is 600.
```
Note:
1. `fp` is initialized to the same value that `ap` takes at the start of a function's scope: during scope of `main` it is `1:3`, during scope of `foo` it is `1:8`. When the scope of `foo` ends and the program returns to the `main`, `fp` is `1:3` again.
2. You can skip memory cells. During instruction 6. we set the value in `[ap+2]` without defining `[ap+1]`.
3. `[ap]` can store felts but also relocatable addresses as in instruction 4. where we store the value of `output_ptr`.
4. `ap` advances one by one except when a function is called and at the beginning. Our `ap` starts pointing at 1:3, because the first three memory cells of the execution segment (1:0, 1:1, 1:2) indicate the other segments that will be used, in this case segments 2, 3 and 4. Segment 2 is used for the output builtin, and segments 3 and 4 are empty segments used for the return values of `fp` an pc.

Run [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo) with the flags `--print_info` and `--print_segments`. Note:

5. Thanks to `--print_info` we can see the register values after execution. 

```Bash
Register values after execution:
pc = 4:0
ap = 1:11
fp = 3:0
```

The final values of the registers are also relocatable. `ap` remains in the execution segment (1), while the return values of `fp` and `pc` are given their own segments for technical reasons.

6. Thanks to `--print_segments` we can see the segment relocation table; 

```Bash
Segment relocation table:
0     1
1     29
2     339
3     340
4     340
```

The table shows the actual (not relative) addresses of the memory cells used by each segment after relocation. Segments 3-4 are empty segments used to return values ​​from `fp` and `pc`. As you can see, the memory ends up being continuous: for example segment 1 starts at cell 29, when segment 0 ends and continues to cell 338, remember we set the value to `[ap+300]` so that the cells 40-337 were automatically filled by the prover. Then segment 2 starts at the next address, 339.


<h3>Types/References</h3>


<h3>Hints</h3>

`UNDER CONSTRUCTION`

Python code can be invoked with the %{ %} block called a hint, which is executed right before the next Cairo instruction. The hint can interact with the program’s variables/memory as shown in the following code sample. Note that the hint is not actually part of the Cairo program, and can thus be replaced by a malicious prover. We can run a Cairo program with the --program_input flag, which allows providing a json input file that can be referenced inside a hint ([Cairo documentation](https://starknet.io/docs/reference/syntax.html#hints)).

```Rust
alloc_locals;
%{ memory[ap] = 100 %}  // Assign to memory.
[ap] = [ap], ap++;  // Increment `ap` after using it in the hint.
assert [ap - 1] = 100;  // Assert the value has some property.

local a;
let b = 7;
%{
    # Assigns the value '9' to the local variable 'a'.
    ids.a = 3 ** 2
    c = ids.b * 2  # Read a reference inside a hint.
%}
```
Note that you can access the address of a pointer to a struct using ids.struct_ptr.address_ and you can use memory[addr] for the value of the memory cell at address addr.

<h3>SHARP</h3>

<h2 align="center" id="cairo_vm">Cairo VM</h2>
<h3><a href="https://github.com/FuzzingLabs/thoth">Disassembler(Thoth)</a></h3>
<h3><a href="https://github.com/crytic/amarna">Amarna</a></h3>

<hr>

#### Sources

[<https://eprint.iacr.org/2021/1063.pdf>
, <https://arxiv.org/pdf/2109.14534.pdf>
, <https://www.cairo-lang.org/cairo-for-blockchain-developers>
, <https://www.cairo-lang.org/docs/how_cairo_works/index.html>
, <https://github.com/FuzzingLabs/thoth>
, <https://github.com/crytic/amarna>]
