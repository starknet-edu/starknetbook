<div align="center">
    <h1>Camp 2: Cairo</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[Cairo](https://drive.google.com/file/d/1rYQ6VZGcqEkm2ZJ2vtGetEiyQ4VwoUE4/view?usp=sharing)|[Cairo Basecamp](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing)|[StarkNet Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)|

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

`Efficient`: Instruction set chosen so the corresponding AIR is efficient and optimized with `builtins`

`Turing Complete`: Can simulate any Turing machine, as such supports any feasible computation

`UNDER CONSTRUCTION`:

While this seciton is being built we recommend reading the video session for this camp and the [cairo-lang docs](https://www.cairo-lang.org/docs/how_cairo_works/index.html).

<hr>

<h2 align="center" id="computational_integrity">Computational Integrity</h2>
STARKs

<h2 align="center" id="syntax">Syntax</h2>

<h3>FELTs</h3>
<h3>Registers</h3>
<h3>Types/References</h3>
<h3>Builtins</h3>
<h3>Hints</h3>
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
