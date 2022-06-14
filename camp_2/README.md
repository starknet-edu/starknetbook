<div align="center">
    <h1>Camp 2: Cairo</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[Cairo](https://drive.google.com/file/d/1rYQ6VZGcqEkm2ZJ2vtGetEiyQ4VwoUE4/view?usp=sharing)|[Cairo Basecamp](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing)|[StarkNet Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)

</div>

### Topics

<ol>
    <li>CLI</li>
    <li>Computational Integrity</li>
    <li>C(pu)AIR(o)</li>
    <li>Cairo VM</li>
</ol>

<h2 align="center" id="cairo_cli">CLI Cheatsheet</h2>

| Command        | Description           |
| ------------- |:-------------:|
| cairo-compile <span style="color:orange;">*.cairo*</span> --output <span style="color:orange;">*_compiled.json*</span> | compile cairo program |
| cairo-run --program <span style="color:orange;">*_compiled.json*</span> --print_output --layout=small | run cairo program and output results |
| cairo-hash-program --program <span style="color:orange;">*_compiled.json*</span> | output the KECCAK Fact of the cairo program |
| cairo-format -i <span style="color:orange;">*.cairo*</span> | format/lint your cairo program |
| cairo-sharp submit --source <span style="color:orange;">*.cairo*</span> --program_input input.json | compile cairo program and submit the fact to the SHARP |

<h2 align="center" id="computational_integrity">Computational Integrity</h2>

<h2 align="center" id="cairolang">C(pu)AIR(o)</h2>

<h3>FELTs</h3>
<h3>Registers</h3>
<h3>Types/References</h3>
<h3>Builtins</h3>
<h3>Hints</h3>
<h3>SHARP</h3>

<h2 align="center" id="cairo_vm">Cairo VM</h2>

<hr>

#### Sources

[<https://eprint.iacr.org/2021/1063.pdf>
, <https://arxiv.org/pdf/2109.14534.pdf>
, <https://www.cairo-lang.org/cairo-for-blockchain-developers>
, <https://www.cairo-lang.org/docs/how_cairo_works/index.html>]
