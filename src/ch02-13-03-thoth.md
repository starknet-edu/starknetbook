# Thoth

[Thoth](https://github.com/FuzzingLabs/thoth) (pronounced "taut" or "toss") is a Cairo/Starknet security toolkit including analyzers, disassemblers & decompilers written in Python 3. Thoth's features include the generation of the call graph, the control-flow graph (CFG) and the data-flow graph for a given Sierra file or Cairo/Starknet compilation artifact. It also includes some really advanced tools like a Symbolic execution engine and Symbolic bounded model checker.

## Features

- Remote & Local: Thoth can both analyze contracts deployed on Mainnet/Goerli and compiled locally on your machine.
- Decompiler: Thoth can convert assembly into decompiled code with SSA (Static Single Assignment)
- Call Flow analysis: Thoth can generate a Call Flow Graph
- Static analysis: Thoth can run various analyzers of different types (security/optimization/analytics) on the contract
- Symbolic execution: Thoth can use the symbolic execution to find the right variables values to get through a specific path in a function and also automatically generate test cases for a function.
- Data Flow analysis: Thoth can generate a Data Flow Graph (DFG) for each function
- Disassembler: Thoth can translate bytecode into assembly representation
- Control Flow analysis: Thoth can generate a Control Flow Graph (CFG)
- Cairo Fuzzer inputs generation: Thoth can generate inputs for the Cairo fuzzer
- Sierra files analysis : Thoth can analyze Sierra files
- Sierra files symbolic execution : Thoth allows symbolic execution on sierra files
- Symbolic bounded model checker : Thoth can be used as a Symbolic bounded model checker
  <img alt="thoth" src="img/ch02-13-thoth.png" class="center" style="width: 75%;" />

## Installation

```bash
sudo apt install graphviz
git clone https://github.com/FuzzingLabs/thoth && cd thoth
pip install .
thoth -h
```
