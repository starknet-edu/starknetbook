## Deployment of Account Contracts using Starkli

In the previous chapter we went through the process of creating an
account contract from scratch. We will now walk through deployment
of the account contract using Starkli to the testnet, and interaction
with other smart contracts.

To follow along, make sure you have [starkli](https://github.com/xJonathanLEI/starkli)
and [scarb](https://docs.swmansion.com/scarb/download.html) installed.

## Configuration files for Account Contracts

For effective management of account contracts, Starkli mandates the use of two
essential configuration files:

- `keystore.json`: An encrypted file responsible for securely storing the
  associated private key.

- `account.json`: An unencrypted file detailing the public attributes of the account
  contract, such as the public key, class hash and address.

Additionally, Starkli supports an optional configuration file:

- `envars.sh`: This shell file is used to source the environment variables expected
  by Starkli, streamlining its command operations.

For users managing multiple wallets with Starkli, it is recommended to maintain an
organized directory structure. Each wallet should have its dedicated folder
containing the three configuration files. All these individual wallet folders
can be grouped under a centralized hidden directory, typically named `starkli-wallets`,
located in user's home directory.

The suggested directory structure is illustrated below:

```bash
~ $ tree ~/.starkli-wallets
>>>
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

This structure ensures easy accessibility and organization, especially when dealing with
multiple wallets.

For the purpose of this guide, we will establish a new directory called `custom` within
the `.starkli-wallets` directory to represent our smart contract wallet.

Execute the following command to create the directory:

```bash
~ $ mkdir ~/.starkli-wallets/custom
```

Subsequently, Starkli will be employed to generate `keystore.json` and `account.json`.
`envars.sh` file will be crafted manually.

## Generating the Keystore File

Starkli provides a streamlined process to automatically generate a private key, save it
in a `keystore.json` file within the `custom` directory, and secure the file using
encryption. This can be achieved through a single command, which requires the destination
path for the configuration file as its argument.

Execute the following command:

```bash
~ $ starkli signer keystore new ~/.starkli-wallets/custom/keystore.json
>>>

Enter password:
Created new encrypted keystore file: /Users/david/.starkli-wallets/custom/keystore.json
Public key: 0x01445385497364c73fabf223c55b7b323586b61c42942c99715d842c6f0a781c
```

Upon execution, you will be prompted to input an encryption password. Once provided, the
`keystore.json` file will be generated. The path to this file will serve as the primary
environment variable in our `envars.sh` file.

To create the `envars.sh` file, use:

```bash
~ $ touch ~/.starkli-wallets/custom/envars.sh
```

Then, add the following content to the file:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
```

To ensure the environment variable is active in your terminal session, source the file:

```bash
~ $ source ~/.starkli-wallets/custom/envars.sh
```

With the environment set up, we can proceed to generate the second essential configuration
file for our account contract: `account.json`.

## Generating the Account Configuration file

The signature validation process in our account contract aligns with the methodology used in
[Open Zeppelin's default account contract.](https://github.com/OpenZeppelin/cairo-contracts/blob/release-v0.7.0-rc.0/src/account/account.cairo)
Both these account contracts anticipate a singular signer and employ the STARK-compatible
elliptic curve. Given this similarity, we will utilize a Starkli command typically designed for
an Open Zeppelin account, even though our account contract has been independently developed from the
ground up.

Execute the following command:

```bash
$ starkli account oz init ~/.starkli-wallets/custom/account.json
>>>

Enter keystore password:
Created new account config file: /Users/david/.starkli-wallets/custom/account.json

Once deployed, this account will be available at:
    0x020746ecae88e0eea0da05770eddee1165515180acb35efeb27d1daad0aed418

Deploy this account by running:
    starkli account deploy /Users/david/.starkli-wallets/custom/account.json
```

You will be prompted to enter the keystore password. Upon successful verification, an `account.json`
file will be generated.

However, its crucial to note that while our account contract shares similarities with OpenZeppelin's,
they are distinct entities. As a result, our account contract will have a different class hash
compared to OpenZeppelin's version. Since the hash class plays a pivotal role in determining the
deployment address, the address ` 0x020746ecae88e0eea0da05770eddee1165515180acb35efeb27d1daad0aed418` is
not accurate.

Let's take a look at the generated `account.json` file:

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

The class hash defined in this configuration is OpenZeppelin's. To find our account contract's
class hash we'll compile our project and use Starkli to derive the class hash.

## Determining the Class Hash

In the previous subchapter, we had created a directory called `aa` (abbreviation for account abstraction)
containing the Cairo code defining our account contract. If this directory is absent, you can clone
the repository to proceed:

```bash
~ $ git clone git@github.com:starknet-edu/aa-workshop.git aa
```

To compile our account contract to Sierra, navigate to the project directory and use Scarb:

```bash
~ $ cd aa
aa $ scarb build
>>>

Compiling aa v0.1.0 (/Users/david/aa/Scarb.toml)
Finished release target(s) in 2 seconds
```

Upon successful compilation, the resultant version of our account contract will be located within
the `target/dev` directory of our project.

To derive the class hash of our account contract, utilize Starkli:

```bash
aa $ starkli class-hash target/dev/aa_Account.sierra.json
>>>
0x03480253c19b447b1d7e7a6422acf80b73866522de03126fa55796a712d9f092
```

We'll update the `account.json` file of our account contract with the accurate class hash:

```bash
aa $ code ~/.starkli-wallets/custom/account.json
```

The updated content should resemble:

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

With `account.json` file now containing the correct details, we can establish a new environment variable
pointing to its path:

```bash
aa $ code ~/.starkli-wallets/custom/envars.sh
```

Add the following lines:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json

```

To activate this new environment variable, source the file:

```bash
aa $ source ~/.starkli-wallets/custom/envars.sh
```

Next step is to declare the account contract on testnet.

## Setting up an RPC provider

To declare an account contract, a transaction must be sent to Starknet through an RPC
provider. While this guide utilizes [Alchemy](https://www.alchemy.com/), alternatives
such as [Infura](https://www.infura.io/) or even a personal Starknet node can be employed.

For those opting on Alchemy or Infura:

- Register an account with the chosen provider

- Initiate a project specifically for Starknet Goerli

- Retrieve the generated RPC's URL

- Incorporate this URL into the `envars.sh` file as an environment variable

```bash
aa $ code ~/.starkli-wallets/custom/envars.sh
```

The file should contain:

```bash
#!/bin/bash
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/V0WI...
```

Note: The full RPC endpoint URL is abbreviated here to protect the API key.

## Declaring the Account Contract

To declare the account contract, a pre-existing, funded account contract is essential
to cover the gas fees. The steps needed to configure Starkli to use either [Braavos](https://braavos.app/)
or [Argent X](https://www.argent.xyz/argent-x/) wallet as `deployer`
are outlined [here.](https://medium.com/starknet-edu/starkli-the-new-starknet-cli-86ea914a2933)

After configuring either Braavos or Argent X's smart wallet address in Starkli as the deployer,
Starkli's wallet structure is as follows:

```bash
~/.starkli-wallets$ tree .
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

To use the smart wallet with Starkli for our account declaration, source its `envars.sh` file within
the `aa` directory:

```bash
aa $ source ~/.starkli-wallets/deployer/envars.sh
```

Subsequently, declare the account contract, with the deployer account covering the gas fees:

```bash
aa $ starkli declare target/dev/aa_Account.sierra.json
>>>

Enter keystore password:
Sierra compiler version not specified. Attempting to automatically decide version to use...
Network detected: goerli-1. Using the default compiler version for this network: 2.2.0. Use the --compiler-version flag to choose a different version.
Declaring Cairo 1 class: 0x03480...
Compiling Sierra class to CASM with compiler version 2.1.0...
CASM class hash: 0x05f587...
Contract declaration transaction: 0x0699f...
Class hash declared: 0x0348025...
```

After the declaration transaction reaches the "Accepted on L2" status, reactivate the environment
variables of the account contract, still within the `aa` directory, to initiate the counterfactual deployment:

```bash
aa $ source ~/.starkli-wallets/custom/envars.sh
```

```bash
aa $ starkli account deploy ~/.starkli-wallets/custom/account.json
>>>

Enter keystore password:
The estimated account deployment fee is 0.000004330000051960 ETH. However, to avoid failure, fund at least:
    0.000006495000077940 ETH
to the following address:
    0x71d8...
Press [ENTER] once you've funded the address.

```

Starkli will pause, awaiting the transfer of sufficient funds to the designated address `0x71d8..` where the
account contract will be deployed. This is a pre-requisite for transmitting the `deploy_account` transaction.
Starknet's [faucet](https://faucet.goerli.starknet.io/) facilitates this transfer.

Once the funds arrive at your specified address, press `ENTER` to proceed with deployment:

```bash
...
Account deployment transaction: 0x00b9...
Waiting for transaction 0x00b9... to confirm. If this process is interrupted, you will need to run `starkli account fetch` to update the account file.
Transaction 0x04b7... confirmed
```

The account contract is now successfully deployed to Starknet's testnet.

## Interacting with the Account Contract

To validate the functionality of our account contract, one can initiate a transaction to transfer 100 gwei to
another wallet, e.g address `0x070a0122733c00716cb9f4ab5a77b8bcfc04b707756bbc27dc90973844a752d1`.
This is achieved by invoking the `transfer` function on the WETH smart contract within
[Starknet's testnet](https://starkscan.co/contract/0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7)

Starkli offers concise commands for common operations, such as interacting with the WETH smart contract:

```bash
aa $ starkli invoke eth transfer 0x070a012... u256:100
>>>

Enter keystore password:
Invoke transaction: 0x0321...
```

A successful transaction indicates that the account contract has verified the transaction signature, executed
the transfer action, and managed the associated gas fees.

Below is a cheatsheet showing all the steps to declare, deploy and interact with the custom account contract created:

```bash
# Cheatsheet: Steps to declare, deploy and use a custom account contract

# [1] Set environment variables in envars.sh
export STARKNET_KEYSTORE=~/.starkli-wallets/custom/keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/custom/account.json
export STARKNET_RPC=https://starknet-goerli.g.alchemy.com/v2/V0WI...

# [2] Create keystore.json file
starkli signer keystore new ~/.starkli-wallets/custom/keystore.json

# [3] Create account.json file
starkli account oz init ~/.starkli-wallets/custom/account.json

# [4] Compile account contract
scarb build

# [5] Derive class hash
starkli class-hash target/dev/aa_Account.sierra.json

# [6] Update account.json file
{
  "version": 1,
  ...
  "deployment": {
    ...
    "class_hash": "<REAL_CLASS_HASH>",
    ...
  },
  "variant": {
    ...
    "legacy": false
  }
}

# [7] Activate deployer wallet
source ~/.starkli-wallets/deployer/envars.sh

# [8] Declare account contract with deployer
starkli declare target/dev/aa_Account.sierra.json

# [9] Activate custom wallet
source ~/.starkli-wallets/custom/envars.sh

# [10] Deploy account contract
starkli account deploy ~/.starkli-wallets/custom/account.json

# [11] Send ETH to given address

# [12] Use account contract for testing
starkli invoke eth transfer 0x1234 u256:100

# [bonus] Suggested folder structure
.
├── account.json
├── envars.sh
└── keystore.json
```

## Recap

We have successfully deployed and interacted with the custom account contract using Starkli! We first setup the
environment variables using the `envars.sh` shell file, generated the `keystore.json` file used to store the
private key, initialized the account descriptor file `account.json` , activated the deployer wallet environment
using Braavos smart wallet, declared our account contract before deploying it to the Starknet testnet, and initiated
a transfer operation with another wallet address.

It's important to note that we utilized Starkli for the account contract using the Open Zeppelin setting because we
utilized the same signature for the `constructor` and `__declare_deploy__` functions as Open Zeppelin uses.
Modifying either of the signatures requires you to use the [Starknet JS](https://www.starknetjs.com/) SDK.
