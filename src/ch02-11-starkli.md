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
Let's retrieve the chain id. To accomplish this we have to pass the URL to the katana JSON-RPC endpoint via the --rpc <URL>. For example, in a new terminal:

```bash
    starkli chain-id --rpc http://0.0.0.0:5050
```
You will get the following output

```bash
    0x4b4154414e41 (KATANA)
```

Now let's retrieve the latest block number on Katana. 

```bash
    starkli block-number --rpc http://0.0.0.0:5050
```

You will get the following output

```bash
    0
```


Remember, `katana` is a temporary local node, Katana state right now is ephemeral. We have not changed the state of katana yet, thus, it makes sense the block-number is 0. Let's recap our previous example [Introduction to Starkli, Scarb and Katana](ch02-02-starkli-scarb-katana.md) and retrieve the block number after we input `starkli declare` and `starkli deploy`

Again, to declare your contract, execute:

```bash
    starkli declare target/dev/my_contract_hello.contract_class.json
```
```bash
    Class hash declared: 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

Now let's retrieve the latest block number on Katana.

```bash
    starkli block-number
```
```bash
    1
```
You aso can check the logs on Katana 
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
We can see a transaction has been received, we used gas and a new block has been mined. That's why the latest block number is `1`.

Before to deploy, we have to mention that Starkli supports argument resolution, the process of expanding simple, human-readable input into actual field element arguments expected by the network. Remember the constructor inputs are in felt format, but argument resolution makes argument input easier, we can pass `str:<String-value>`

```bash
    starkli deploy \
        0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 \
        str:starknet-book
```
After this we mined a new block, we deployed our contract and we did not use `to-cairo-string` this time.

### Interact with Testnet

For this, we have to use a third-party JSON-RPC API provider like Infura, Alchemy. Once you have a URL, you can input the following command:
```bash
    starkli block-number --rpc https://starknet-goerli.g.alchemy.com/v2/V0WI...
```
You will get the something like this

```bash
    896360
```

At the same time you can verify this result on [Starkscan](https://testnet.starkscan.co/). And You will realize they are the same

Starkli also offers simplified invoke commands. For example, we can transfer 1000 Wei of the ETH token to the address 0x1234. Before to do this, make sure you to setup your environment variables.

```bash
    export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/my_account_1.json
    export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/my_keystore_1.json
```

Starkli makes this process a lot easier, you have to input the following command

```bash
    starkli invoke eth transfer 0x1234 u256:1000
```

Make sure the `0x1234` address this different than your account in the `my_account_1.json` file

### Execute your own bash file

In this section, we are going to execute a bash file in order to connect with the blockchain

#### Katana

Make sure katana is running. We are going to show a simple way to retrieve information from katana using starkli.

In terminal 1
```bash
    katana
```

Now create a file called `script_devnet`, using touch command

In terminal 2
```bash
    touch script_devnet
```

Edit the file with the program of your choice. Within the file, paste the following content

```bash
#!/bin/bash
chain="$(starkli chain-id --rpc http://0.0.0.0:5050)"
echo "Where are connected to the starknet local devnet with chain id: $chain"

block="$(starkli block-number --rpc http://0.0.0.0:5050)"
echo "The latest block number on Katana is: $block"

account1="0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"
balance="$(starkli balance $account1 --rpc http://0.0.0.0:5050)"
echo "The balance of account $account1 is: $balance eth"
```

Now from the command line, run the script using the bash interpreter:

```bash
    bash script_devnet
```

Awesome, you get your output from devnet.

#### Goerli

In this example we are going to connect with Goerli testnet, read the latest block number of the network and search for the transaction receipt of and specific transaction hash.

Create a file called `script_testnet`, using touch command

In a new terminal
```bash
    touch script_devnet
```

Edit the file. Within the file, paste the following content

```bash
echo "input your testnet API URL: " 
read url
chain="$(starkli chain-id --rpc $url)"
echo "Where are connected to the starknet testnet with chain id: $chain"

block="$(starkli block-number --rpc $url)"
echo "The latest block number on Goerli is: $block"

echo "input your transaction hash: " 
read hash
receipt="$(starkli receipt $hash --rpc $url)"
echo "The receipt of transaction $hash is: $receipt"
```
Now from the command line, run the script using the bash interpreter:

```bash
    bash script_testnet
```
This time you have to input first a `testnet API URL`, and then you have to provide a `transaction hash`. You can use this transaction hash: 0x2dd73eb1802aef84e8d73334ce0e5856b18df6626fe1a67bb247fcaaccaac8c

Great, now you can create your own bash file according to your interest.