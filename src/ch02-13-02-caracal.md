# Caracal

[Caracal](https://github.com/crytic/caracal) is a static analyzer tool over the SIERRA representation for Starknet smart contracts.

## Features

- Detectors to detect vulnerable Cairo code
- Printers to report information
- Taint analysis
- Data flow analysis framework
- Easy to run in Scarb projects

## Installation

Precompiled binaries

Precompiled binaries are available on our releases page. If you are using Cairo compiler 1.x.x uses the binary v0.1.x otherwise if you are using the Cairo compiler 2.x.x uses v0.2.x.

### Building from source

You need the Rust compiler and Cargo. Building from git:

```bash
cargo install --git https://github.com/crytic/caracal --profile release --force
```

### Building from a local copy:

```bash
git clone https://github.com/crytic/caracal
cd caracal
cargo install --path . --profile release --force
```
