# Starkli: Querying Starknet

[Starkli](https://book.starkli.rs/) is a Command Line Interface (CLI) tool designed for Starknet interaction, utilizing the capabilities of [starknet-rs](https://github.com/xJonathanLEI/starknet-rs). This tool simplifies querying and executing transactions on Starknet.

> NOTE: Before continuing with this chapter, make sure you have completed the Basic Installation subchapter of Chapter 2. This includes the installation of Starkli.

In the next subchapter we will create a short Bash script using Starkli to query Starknet. It's just an example, however, creating your own Bash scripts to interact with Starknet would be very useful in practice.

## Basic Setup

To ensure a smooth start with Starkli, execute the following command on your system. If you encounter any issues, refer to the [Basic Installation](ch02-01-basic-installation.md) guide for assistance:

```bash
starkli --version  # Verifies Starkli installation and interacts with Starknet
```

## Connect to Starknet with Providers

Starkli primarily operates with a JSON-RPC provider. To access a JSON-RPC endpoint, you have several options:

- Use services like [Infura](https://docs.infura.io/networks/starknet/how-to) or [Alchemy](https://www.alchemy.com/starknet) for an RPC client.
- Employ a temporary local node like `katana` for development and testing purposes.
- Setup your own node.

### Interacting with Katana

To start Katana, open a terminal and execute:

```bash
katana
```

To retrieve the chain id from the Katana JSON-RPC endpoint, use the following command:

```bash
starkli chain-id --rpc http://0.0.0.0:5050
```

This command will output:

```bash
0x4b4154414e41 (KATANA)
```

To obtain the latest block number on Katana, run:

```bash
    starkli block-number --rpc http://0.0.0.0:5050
```

The output will be:

```bash
    0
```

Since katana is a temporary local node and its state is ephemeral, the block number is initially 0. Refer to [Introduction to Starkli, Scarb and Katana](ch02-02-starkli-scarb-katana.md) for further details on changing the state of Katana and observing the block number after commands like starkli declare and starkli deploy.

To declare a contract, execute:

```bash
starkli declare target/dev/my_contract_hello.contract_class.json
```

After declaring, the output will be:

```bash
Class hash declared: 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

Retrieving the latest block number on Katana again:

```bash
starkli block-number
```

Will result in:

```bash
1
```

Katana logs also reflect these changes:

```bash
2023-11-03T04:38:48.712332Z DEBUG server: method="starknet_chainId"
2023-11-03T04:38:48.725133Z DEBUG server: method="starknet_getClass"
2023-11-03T04:38:48.726668Z DEBUG server: method="starknet_chainId"
2023-11-03T04:38:48.741588Z DEBUG server: method="starknet_getNonce"
2023-11-03T04:38:48.744718Z DEBUG server: method="starknet_estimateFee"
2023-11-03T04:38:48.766843Z DEBUG server: method="starknet_getNonce"
2023-11-03T04:38:48.770236Z DEBUG server: method="starknet_addDeclareTransaction"
2023-11-03T04:38:48.779714Z  INFO txpool: Transaction received | Hash: 0x352f04ad496761c73806f92c64c267746afcbc16406bd0041ac6efa70b01a51
2023-11-03T04:38:48.782100Z TRACE executor: Transaction resource usage: Steps: 2854 | ECDSA: 1 | L1 Gas: 3672 | Pedersen: 15 | Range Checks: 63
2023-11-03T04:38:48.782112Z TRACE executor: Event emitted keys=[0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9]
2023-11-03T04:38:48.782399Z  INFO backend: ⛏️ Block 1 mined with 1 transactions
```

These logs indicate the receipt of a transaction, gas usage, and the mining of a new block, explaining the increment in block number to `1`.

Before deploying a contract, note that Starkli supports argument resolution, simplifying the input process. For instance, constructor inputs in felt format can be easily passed as `str:<String-value>`:

```bash
    starkli deploy \
        0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 \
        str:starknet-book
```

This command deploys the contract without requiring `to-cairo-string`, and a new block is mined as a result.

### Interacting with Testnet

To interact with the Testnet, use a third-party JSON-RPC API provider like Infura or Alchemy. With your provider URL, execute the following command to get the latest block number:

```bash
starkli block-number --rpc https://starknet-goerli.g.alchemy.com/v2/V0WI...
```

This command will return a response like:

```bash
896360
```

You can confirm this result by checking [Starkscan](https://testnet.starkscan.co/), where you'll find matching data.

Starkli also streamlines the process of invoking commands. For instance, to transfer 1000 Wei of ETH to address 0x1234, first set up your environment variables:

```bash
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/my_account_1.json
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/my_keystore_1.json
```

Then, use the following command for the transfer:

```bash
starkli invoke eth transfer <YOUR-ACCOUNT-ADDRESS> u256:1000
```

You can create your own script to connect to Starknet using Starkli. In the next subchapter we will create a short Bash script.
