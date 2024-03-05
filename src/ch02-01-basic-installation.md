# Installation

This chapter walks you through setting up your Starknet development
tools.

Essential tools to install:

1.  [Starkli](https://github.com/xJonathanLEI/starkli) - A CLI tool for
    interacting with Starknet. More tools are discussed in Chapter 2.

2.  [Scarb](https://github.com/software-mansion/scarb) - Cairo’s package
    manager that compiles code to [Sierra](https://docs.starknet.io/documentation/architecture_and_concepts/Smart_Contracts/cairo-and-sierra), a mid-level language between
    Cairo and CASM.

3.  [Katana](https://github.com/dojoengine/dojo) - Katana is a Starknet node, built for local development.

For support or queries, visit our [GitHub
Issues](https://github.com/starknet-edu/starknetbook/issues) or contact
espejelomar on Telegram.

## Starkli Installation

Easily install Starkli using Starkliup, an installer invoked through the
command line.

```bash
curl https://get.starkli.sh | sh
starkliup
```

Restart your terminal and confirm installation:

```bash
starkli --version
```

To upgrade Starkli, simply repeat the steps.

## Scarb Package Manager Installation

Scarb is also Cairo's package manager and is heavily inspired by [Cargo](https://doc.rust-lang.org/cargo/),
Rust’s build system and package manager.

Scarb handles a lot of tasks for you, such as building your code (either pure Cairo or Starknet contracts),
downloading the libraries your code depends on, building those libraries.

### Requirements

Scarb requires a Git executable to be available in the `PATH` environment variable.

### Installation

To install Scarb, please refer to the [installation instructions](https://docs.swmansion.com/scarb/download).
We strongly recommend that you install
Scarb [via asdf](https://docs.swmansion.com/scarb/download.html#install-via-asdf), a CLI tool that can manage
multiple language runtime versions on a per-project basis.
This will ensure that the version of Scarb you use to work on a project always matches the one defined in the
project settings, avoiding problems related to version mismatches.

Please refer to the [asdf documentation](https://asdf-vm.com/guide/getting-started.html) to install all
prerequisites.

Once you have asdf installed locally, you can download Scarb plugin with the following command:

```bash
asdf plugin add scarb
```

This will allow you to download specific versions:

```bash
asdf install scarb 2.5.4
```

and set a global version:

```bash
asdf global scarb 2.5.4
```

Otherwise, you can simply run the following command in your terminal, and follow the onscreen instructions. This
will install the latest stable release of Scarb.

```bash
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

- In both cases, you can verify installation by running the following command in a new terminal session, it should print both Scarb and Cairo language versions, e.g:

```bash
scarb --version
scarb 2.5.4 (28dee92c8 2024-02-14)
cairo: 2.5.4 (https://crates.io/crates/cairo-lang-compiler/2.5.4)
sierra: 1.4.0
```

For Windows, follow manual setup in the [Scarb
documentation](https://docs.swmansion.com/scarb/download.html#windows).

## Katana Node Installation

To install Katana, use the `dojoup` installer from the command line:

```bash
curl -L https://install.dojoengine.org | bash
dojoup
```

After restarting your terminal, verify the installation with:

```bash
katana --version
```

To upgrade Katana, rerun the installation command.

You are now set to code in Cairo and deploy to Starknet.
