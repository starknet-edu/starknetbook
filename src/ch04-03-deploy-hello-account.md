## Deploying Account Contracts with Starkli

After building our account contract, we'll now deploy it using Starkli on the testnet and interact with other contracts.

Ensure you've installed [starkli](https://github.com/xJonathanLEI/starkli) and [scarb](https://docs.swmansion.com/scarb/download.html). Review the Basic Installation subchapter in Chapter 2 if you haven't.

## Account Contract Configuration Files

Starkli requires two key configuration files:

- `keystore.json`: A secure file that holds the private key.
- `account.json`: An open file with the account's public details like public key, class hash, and address.

Optionally, Starkli can use:

- `envars.sh`: A script to set environment variables for Starkli commands.

For multiple wallets, keep a clean directory structure. Each wallet should have its own folder with the three files inside. Group these under a `~/.starkli-wallets` directory.

Here's a suggested structure:

```bash
tree ~/.starkli-wallets

.starkli-wallets
├── wallet-a
│   ├── account.json
│   ├── envars.sh
│   └── keystore.json
└── wallet-b
    ├── account.json
    ├── envars.sh
    └── keystore.json
```

This setup promotes better organization.

We'll make a custom folder in `.starkli-wallets` for our contract wallet:

```bash
mkdir ~/.starkli-wallets/custom
```

Next, we use Starkli to create `keystore.json` and `account.json`, then write `envars.sh` by hand.

## Creating the Keystore File with Starkli

Starkli simplifies creating a `keystore.json` file. This encrypted file holds your private key and sits in the `custom` directory. You can create this with one command:

```bash
starkli signer keystore new ~/.starkli-wallets/custom/keystore.json
```

When you run this, you'll enter a password to secure the file. The resulting `keystore.json` is essential for setting up the `envars.sh` file, which stores environment variables.

Create `envars.sh` like this:

```bash
touch ~/.starkli-wallets/custom/envars.sh
```

Open the file and insert:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
```

Activate the variable by sourcing the file:

```bash
source ~/.starkli-wallets/custom/envars.sh
```

Now, your environment is ready for the next step: creating the `account.json` file.

## Generating the Account Configuration File

Our account contract's signature validation mirrors that in [Open Zeppelin's default account contract](https://github.com/OpenZeppelin/cairo-contracts/blob/release-v0.7.0-rc.0/src/account/account.cairo), using a single signer and a STARK-compatible elliptic curve. Despite building our contract independently, we'll use Starkli's command for Open Zeppelin accounts to create our configuration:

```bash
starkli account oz init ~/.starkli-wallets/custom/account.json
```

After entering your keystore password, `account.json` is created. This file includes a class hash for OpenZeppelin's contract, not ours. Since the class hash influences the deployment address, the shown address won't match our contract.

Here's what account.json looks like:

```json
{
  "version": 1,
  "variant": {
    "type": "open_zeppelin",
    "version": 1,
    "public_key": "0x1445385497364c73fabf223c55b7b323586b61c42942c99715d842c6f0a781c",
    "legacy": false
  },
  "deployment": {
    "status": "undeployed",
    "class_hash": "0x4c6d6cf894f8bc96bb9c525e6853e5483177841f7388f74a46cfda6f028c755",
    "salt": "0x36cb2427f99a75b7d4c4ceeca1e412cd94b1fc396e09fec8adca14f8dc33374"
  }
}
```

To deploy our unique contract, we must compile our project to obtain the correct class hash and update `account.json` accordingly.

## Finding the Class Hash

Previously, we set up a `aa` directory for our account contract's Cairo code. If you don't have it, clone the repository:

```bash
git clone git@github.com:starknet-edu/aa-workshop.git aa
```

To compile the contract with Scarb, enter the project directory:

```bash
cd aa
scarb build
```

The compiled contract lies in `target/dev`. Use Starkli to get the class hash:

```bash
starkli class-hash target/dev/aa_Account.sierra.json
```

Next, edit `account.json` to insert the correct class hash:

```bash
code ~/.starkli-wallets/custom/account.json
```

Ensure the `class_hash` is updated:

```json
{
  "version": 1,
  "variant": {
    "type": "open_zeppelin",
    "version": 1,
    "public_key": "0x1445385497364c73fabf223c55b7b323586b61c42942c99715d842c6f0a781c",
    "legacy": false
  },
  "deployment": {
    "status": "undeployed",
    "class_hash": "0x03480253c19b447b1d7e7a6422acf80b73866522de03126fa55796a712d9f092",
    "salt": "0x36cb2427f99a75b7d4c4ceeca1e412cd94b1fc396e09fec8adca14f8dc33374"
  }
}
```

To point to the updated `account.json`, modify `envars.sh`:

```bash
code ~/.starkli-wallets/custom/envars.sh
```

Add the account path:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
```

Source `envars.sh` to apply the changes:

```bash
source ~/.starkli-wallets/custom/envars.sh
```

Now, we're ready to declare the contract on the testnet.

## Establishing an RPC Provider

For transactions on Starknet, an RPC provider is essential. This guide uses [Alchemy](https://www.alchemy.com/), but [Infura](https://www.infura.io/) or a personal node are viable alternatives.

Steps for Alchemy or Infura:

- Create an account.
- Start a new project for Starknet Goerli.
- Obtain the RPC URL.
- Add this URL to `envars.sh`:

```bash
aa $ code ~/.starkli-wallets/custom/envars.sh
```

The file should now include:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/your-api-key
```

Replace `your-api-key` with the actual API key provided by Alchemy.

## Declaring the Account Contract

You'll need a funded account to pay gas fees. Configure Starkli with a [Braavos](https://braavos.app/) or [Argent X](https://www.argent.xyz/argent-x/) wallet as the deployer. Instructions are available [here](https://medium.com/starknet-edu/starkli-the-new-starknet-cli-86ea914a2933).

After setting up, your Starkli wallet structure will be:

```bash
tree .

.
├── custom
│   ├── account.json
│   ├── envars.sh
│   └── keystore.json
└── deployer
    ├── account.json
    ├── envars.sh
    └── keystore.json
```

Source the deployer's environment file in the `aa` directory to use it:

```bash
source ~/.starkli-wallets/deployer/envars.sh
```

Declare the contract with the deployer covering gas:

```bash
starkli declare target/dev/aa_Account.sierra.json
```

After reaching "Accepted on L2," status (less than a minute) switch back to the account's environment:

```bash
source ~/.starkli-wallets/custom/envars.sh
```

Deploy the account with Starkli:

```bash
starkli account deploy ~/.starkli-wallets/custom/account.json
```

Starkli will wait for you to fund the address displayed with at least the estimated fee from Starknet's [faucet](https://faucet.goerli.starknet.io/).

Once funded, press **`ENTER`** to deploy:

```bash
...
Deployment transaction confirmed
```

Your account contract is now live on the Starknet testnet.

## Using the Account Contract

To test our account contract, we can send 100 gwei to the wallet `0x070a...52d1` by calling the `transfer` function of the WETH smart contract on Starknet's testnet.

Invoke the transfer with Starkli (more details on Starkli's in Chapter 2):

```bash
starkli invoke eth transfer 0x070a012... u256:100
```

A successful invoke confirms that our account contract has authenticated the signature, executed the transfer, and managed the gas fees.

Here's a summary of all the steps from declaration to interaction:

```bash
# Quick Guide: Declare, Deploy, and Interact with a Custom Account Contract

# [1] Set up environment variables in envars.sh
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/your-api-key

# [2] Generate keystore.json
starkli signer keystore new ~/.starkli-wallets/custom/keystore.json

# [3] Initialize account.json
starkli account oz init ~/.starkli-wallets/custom/account.json

# [4] Build the contract with Scarb
scarb build

# [5] Get the class hash
starkli class-hash target/dev/aa_Account.sierra.json

# [6] Update account.json with the real class hash
code ~/.starkli-wallets/custom/account.json

# [7] Set deployer wallet environment
source ~/.starkli-wallets/deployer/envars.sh

# [8] Declare the contract using the deployer
starkli declare target/dev/aa_Account.sierra.json

# [9] Switch to the custom wallet
source ~/.starkli-wallets/custom/envars.sh

# [10] Deploy the contract
starkli account deploy ~/.starkli-wallets/custom/account.json

# [11] Test the contract by transferring ETH
starkli invoke eth transfer 0x070a012... u256:100

# [bonus] Recommended directory structure
.
├── account.json
├── envars.sh
└── keystore.json
```

## Summary

We've successfully deployed and used our custom account contract on Starknet with Starkli. Here's what we accomplished:

- Set environment variables in `envars.sh`.
- Created `keystore.json` to securely store the private key.
- Initialized `account.json` as the account descriptor file.
- Used Braavos smart wallet to set up the deployer environment.
- Declared and deployed our account contract to the Starknet testnet.
- Conducted a transfer to another wallet.

We matched the Open Zeppelin's contract in terms of signature methods for the `constructor` and `__declare_deploy__` functions, which allowed us to use Starkli's Open Zeppelin preset. Should there be a need for signature modification, Starknet JS SDK would be the tool of choice.
