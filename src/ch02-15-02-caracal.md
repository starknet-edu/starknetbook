# Caracal

[Caracal](https://github.com/crytic/caracal) is a static analysis tool for Starknet smart contracts, specifically analyzing their SIERRA representation.

## Features

- Vulnerability detectors for Cairo code.
- Report printers.
- Taint analysis.
- Data flow analysis framework.
- Compatibility with Scarb projects.

## Installation

### Precompiled Binaries

Download precompiled binaries from the [releases page](https://github.com/crytic/caracal/releases). Use binary version v0.1.x for Cairo compiler 1.x.x, and v0.2.x for Cairo compiler 2.x.x.

### Building from Source

#### Requirements

- Rust compiler
- Cargo

#### Installation Steps

Clone and build from the repository:

```bash
cargo install --git https://github.com/crytic/caracal --profile release --force
```

### Building from a Local Copy:

If you prefer to build from a local copy:

```bash
git clone https://github.com/crytic/caracal
cd caracal
cargo install --path . --profile release --force
```
