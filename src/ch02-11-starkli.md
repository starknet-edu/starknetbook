# Starkli: A CLI interface 🚧

[Starkli](https://book.starkli.rs/) is a CLI tool for interacting with Starknet, powered by [starknet-rs](https://github.com/xJonathanLEI/starknet-rs).
Starkli allows you to query Starknet and make transactions with ease. It's fast, easy to install, and intuitive to use.

## Basic setup

Ensure the following commands run successfully on your system. If not, see the [Basic Installation](ch02-01-basic-installation.md) section:

```bash
    starkli --version  # To interact with Starknet
```

## Connect to Starknet with Providers

Starkli is centric around JSON-RPC provider. There are a few options to obtain access to a JSON-RPC endpoint:

- For ease of access, consider using a provider such as
[Infura](https://docs.infura.io/networks/starknet/how-to) or
[Alchemy](https://www.alchemy.com/starknet) to get an RPC client. 
- For development and testing, a temporary local node such as `katana` can be
used.

### Interact with Katana

Launch Katana. In a terminal, run:

```bash
    katana
```

Now let's retrieve the latest block number on Katana. To accomplish this we have to pass the URL to the katana JSON-RPC endpoint via the --rpc <URL>. For example, in a new terminal:

```bash
    starkli block-number --rpc http://0.0.0.0:5050
```

You will get the following output

```bash
    0
```

Remember, `katana` is a temporary local node, Katana state right now is ephemeral. We have not changeg the state of katana yet, thus, it makes sense the block-number is 0. You can check our previous example [Introduction to Starkli, Scarb and Katana](ch02-02-starkli-scarb-katana.md) and retrieve the block number after we input `starkli deploy` or `starkli invoke` and you will realize it is not zero anymore

### Interact with Testnet

For this, we have to use a third-party JSON-RPC API provider like Infura, Alchemy. Once you have a URL, you can input the following command:
```bash
    starkli block-number --rpchttps://starknet-goerli.g.alchemy.com/v2/V0WI...
```
You will get the something like this

```bash
    895360
```

At the same time you can verify this result on [Starkscan](https://testnet.starkscan.co/). And You will realize they are the same
