# Example - Starknet Connection Script

This section provides step-by-step instructions to create and run custom bash scripts for Starknet interactions.

## Katana Local Node

**Description:** This script connects to the local StarkNet devnet through Katana, retrieves the current chain ID, the latest block number, and the balance of a specified account.

First, ensure that Katana is running (in terminal 1):

```bash
katana
```

Then, create a file named `script_devnet` (in terminal 2):

```bash
touch script_devnet
```

Edit this file with your preferred text editor and insert the following script:

```bash
#!/bin/bash
chain=$(starkli chain-id --rpc http://0.0.0.0:5050)
echo "Connected to the Starknet local devnet with chain id: $chain"

block=$(starkli block-number --rpc http://0.0.0.0:5050)
echo "The latest block number on Katana is: $block"

account1="0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"
balance=$(starkli balance $account1 --rpc http://0.0.0.0:5050)
echo "The balance of account $account1 is: $balance ETH"
```

Execute the script with:

```bash
bash script_devnet
```

You will see output details from the devnet.

## Goerli Testnet

**Description**: This script connects to the Goerli testnet, reads the latest block number, and retrieves the transaction receipt for a specific transaction hash.

For Goerli testnet interactions, create a file named `script_testnet`:

```bash
touch script_testnet
```

Edit the file and paste in this script:

```bash
echo "Input your testnet API URL: "
read url
chain=$(starkli chain-id --rpc $url)
echo "Connected to the Starknet testnet with chain id: $chain"

block=$(starkli block-number --rpc $url)
echo "The latest block number on Goerli is: $block"

echo "Input your transaction hash: "
read hash
receipt=$(starkli receipt $hash --rpc $url)
echo "The receipt of transaction $hash is: $receipt"
```

Run the script:

```bash
bash script_testnet
```

You will need to input a `testnet API URL` and a `transaction hash`. Example hash: 0x2dd73eb1802aef84e8d73334ce0e5856b18df6626fe1a67bb247fcaaccaac8c.

These are brief examples but you get the idea. You can create custom Bash scripts to customize your interactions with Starknet.
