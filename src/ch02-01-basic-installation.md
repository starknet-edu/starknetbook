# Installation

This chapter walks you through setting up your Starknet development
tools.

Essential tools to install:

1.  [Starkli](https://github.com/xJonathanLEI/starkli) - A CLI tool for
    interacting with Starknet. More tools are discussed in Chapter 2.

2.  [Scarb](https://github.com/software-mansion/scarb) - Cairo’s package
    manager that compiles code to Sierra, a mid-level language between
    Cairo and CASM.

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

We will get deeper into Scarb later in this chapter. For now, we will go over the installation process.

For macOS and Linux:

```bash
    curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

For Windows, follow manual setup in the [Scarb
documentation](https://docs.swmansion.com/scarb/download.html#windows).

Restart the terminal and run:

```bash
    scarb --version
```

To upgrade Scarb, rerun the installation command.

You are now set to code in Cairo and deploy to Starknet.
