<h1 align="center">Camp II: Cairo</h1>

### Topics

<ol>
    <!-- <li><a>Zero Knowledge Proofs</a></a> -->
</ol>

### Workshop

<h2 align="center">
    Overview
    <br>
    <a href="https://docs.google.com/presentation/d/1h6-u_OmTq37EAywzNaMb9v2gV847JVcY96wYLAM-HX8/edit?usp=sharing">
    (slides,
    </a>
    <a href="">
    video,
    </a>
    <a href="">
    definitions)
    </a>
</h2>

### Cairo CLI Cheatsheet
| Command        | Description           |
| ------------- |:-------------:|
| cairo-compile <span style="color:orange;">*.cairo*</span> --output <span style="color:orange;">*_compiled.json*</span> | compile cairo program |
| cairo-run --program <span style="color:orange;">*_compiled.json*</span> --print_output --layout=small | run cairo program and output results |
| cairo-hash-program --program <span style="color:orange;">*_compiled.json*</span> | output the KECCAK Fact of the cairo program |
| cairo-format -i <span style="color:orange;">*.cairo*</span> | format/lint your cairo program |
| cairo-sharp submit --source <span style="color:orange;">*.cairo*</span> --program_input input.json | compile cairo program and submit the fact to the SHARP |

#### Sources

- <https://eprint.iacr.org/2021/1063.pdf>
- <https://arxiv.org/pdf/2109.14534.pdf>
- <https://www.cairo-lang.org/cairo-for-blockchain-developers>
- <https://www.cairo-lang.org/docs/how_cairo_works/index.html>
