# Testnet Deployment

This chapter guides developers through the process of compiling, deploying, and interacting with a Starknet smart contract written in Cairo on the testnet. Earlier, the focus was on deploying contracts using a local node, Katana. This time, the deployment and interaction target the Starknet testnet.

Ensure the following commands run successfully on your system. If not, see the [Basic Installation](ch02-01-basic-installation.md) section:

```bash
    scarb --version  # For Cairo code compilation
    starkli --version  # To interact with Starknet
```

## Smart Wallet Setup

A smart wallet comprises a Signer and an Account Descriptor. The Signer
is a smart contract with a private key for signing transactions, while
the Account Descriptor is a JSON file detailing the wallet’s address and
public key.

In order for an account to be used as a signer it must be deployed to the appropriate network,
Starknet Goerli, Sepolia or mainnet, and funded. For this example we are going to use Goerli Testnet. To deploy your wallet, visit [Smart Wallet Setup](https://book.starknet.io/ch01-00-getting-started.html#smart-wallet-setup).
Now you’re ready to interact with Starknet smart contracts.

### Creating a Signer

The Signer is an essential smart contract capable of signing
transactions in Starknet. You’ll need the private key from your smart
wallet to create one, from which the public key can be derived.

Starkli enables secure storage of your private key through a keystore
file. This encrypted file can be accessed using a password and is
generally stored in the default Starkli directory.

First, create the default directory:

```bash
    mkdir -p ~/.starkli-wallets/deployer
```

Then generate the keystore file. The signer command contains subcommands
for creating a keystore file from a private key or completely create a
new one. In this tutorial, we’ll use the private key option which is the
most common use case. You need to provide the path to the keystore file
you want to create. You can give any name to the keystore file, you will
likely have several wallets. In this tutorial, we will use the name
`my_keystore_ 1.json`.

```bash
    starkli signer keystore from-key ~/.starkli-wallets/deployer/my_keystore_1.json
    Enter private key:
    Enter password:
```

In the private key prompt, paste the private key of your smart wallet.
In the password prompt, enter a password of your choice. You will need
this password to sign transactions using Starkli.

### How to get the private key?

Export the private key from your Braavos or Argent wallet. For Argent X,
you can find it in the "Settings" section → Select your Account →
"Export Private Key". For Braavos, you can find it in the "Settings"
section → "Privacy and Security" → "Export Private Key".

While knowing the private key of a smart wallet is necessary to sign
transactions, it’s not sufficient. We also need to inform Starkli about
the signing mechanism employed by our smart wallet created by Braavos or
Argent X. Does it use an elliptic curve? If yes, which one? This is the
reason why we need an account descriptor file.

#### [OPTIONAL] The Architecture of the Starknet Signer

This section is optional and is intended for those who want to learn more about the Starknet Signer. If you are not interested in the details, you can skip it.

The Starknet Signer plays an instrumental role in securing your
transactions. Let’s demystify what goes on under the hood.

Key Components:

1.  **Private Key**: A 256-bit/32-byte/64-character (ignoring the _0x_
    prefix) hexadecimal key that is the cornerstone of your wallet’s
    security.

2.  **Public Key**: Derived from the private key, it’s also a
    256-bit/32-byte/64-character hexadecimal key.

3.  **Smart Wallet Address**: Unlike Ethereum, the address here is
    influenced by the public key, class hash, and a salt. **[Learn more
    in Starknet
    Documentation](https://docs.starknet.io/documentation/architecture_and_concepts/Smart_Contracts/contract-address/)**.

To view the details of the previously created keystore file:

```bash
    cat ~/.starkli-wallets/deployer/my_keystore_1.json
```

Anatomy of the `keystore.json` File:

```json
{
  "crypto": {
    "cipher": "aes-128-ctr",
    "cipherparams": {
      "iv": "dba5f9a67456b121f3f486aa18e24db7"
    },
    "ciphertext": "b3cda3df39563e3dd61064149d6ed8c9ab5f07fbcd6347625e081fb695ddf36c",
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 8192,
      "p": 1,
      "r": 8,
      "salt": "6dd5b06b1077ba25a7bf511510ea0c608424c6657dd3ab51b93029244537dffb"
    },
    "mac": "55e1616d9ddd052864a1ae4207824baac58a6c88798bf28585167a5986585ce6"
  },
  "id": "afbb9007-8f61-4e62-bf14-e491c30fd09a",
  "version": 3
}
```

- **`version`**: The version of the smart wallet implementation.

- **`id`**: A randomly generated identification string.

- **`crypto`**: Houses all encryption details.

Inside **`crypto`**:

- **`cipher`**: Specifies the encryption algorithm used, which in this
  case is AES-128-CTR.

  - **AES (Advanced Encryption Standard)**: A globally accepted
    encryption standard.

  - **128**: Refers to the key size in bits, making it a 128-bit
    key.

  - **CTR (Counter Mode)**: A specific mode of operation for the AES
    cipher.

- **`cipherparams`**: Contains an Initialization Vector (IV), which
  ensures that encrypting the same plaintext with the same key will
  produce different ciphertexts.

  - **`iv` (Initialization Vector)**: A 16-byte hex string that
    serves as a random and unique starting point for each encryption
    operation.

- **`ciphertext`**: This is the private key after encryption, securely
  stored so that only the correct password can reveal it.

- **`kdf` and `kdfparams`**: KDF stands for Key Derivation Function.
  This adds a layer of security by requiring computational work,
  making brute-force attacks harder.

  - **`dklen`**: The length (in bytes) of the derived key. Typically
    32 bytes.

  - **`n`**: A cost factor representing CPU/memory usage. A higher
    value means more computational work is needed, thus increasing
    security.

  - **`p`**: Parallelization factor, affecting the computational
    complexity.

  - **`r`**: Block size for the hash function, again affecting
    computational requirements.

  - **`salt`**: A random value that is combined with the password to
    deter dictionary attacks.

- **`mac` (Message Authentication Code)**: This is a cryptographic
  code that ensures the integrity of the message (the encrypted
  private key in this case). It is generated using a hash of both the
  ciphertext and a portion of the derived key.

Before to continue, we have to choose a rpc provider

### Choosing an RPC Provider

There are three main options for RPC providers, sorted by ease of use:

1.  **Infura or Alchemy**: A step up in complexity. You’ll need to set
    up an API key and choose an endpoint. For Infura, it would look like
    `https://starknet-sepolia.infura.io/v3/<API_KEY>`. Learn more in the
    [Infura
    documentation](https://docs.infura.io/networks/starknet/how-to/choose-a-network).

2.  **Your Own Node**: For those who want full control. It’s the most
    complex but offers the most freedom. Check out [Chapter 4 of the
    Starknet Book](https://book.starknet.io/chapter_4/node.html) or
    [Kasar](https://www.kasar.io/) for setup guides.

3.  **Free RPC vendor**: These 3 networks are eligible for free RPC vendors: mainet, goerli, sepolia.
    You can choose [Blast](https://blastapi.io/public-api/starknet) or [Nethermind](https://data.voyager.online/)

### Creating an Account Descriptor

An Account Descriptor informs Starkli about your smart wallet’s unique
features, such as its signing mechanism. You can generate this
descriptor using Starkli’s `fetch` subcommand under the `account`
command. The `fetch` subcommand takes your on-chain wallet address as
input and generates the account descriptor file. The account descriptor
file is a JSON file that contains the details of your smart wallet. We also have to pass the rpc provider here.

```bash
    starkli account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/my_account_1.json --rpc https://starknet-testnet.public.blastapi.io/rpc/v0_6
```

Note: Here we used the Public RPC Endpoint v0.6 Starknet (Goerli) Testnet from **Blast**. If you don't specify the rpc provider, Starkli will use Goerli, which will be deprecated in the upcoming months. Thus you can check the rpc url for Sepolia network on [Blast](https://blastapi.io/public-api/starknet).

> ⚠️ **Contract not found?**
>
> In case you face an error like this:
>
> ```bash
>     Error: ContractNotFound
> ```
>
> #### 🟩 Solution:
>
> It means you probably just created a new wallet and it has **not been deployed yet**. To accomplish this you have to fund your wallet with tokens and **transfer tokens** to a **different** wallet address. For goerli tokens you can check this [faucet](https://faucet.goerli.starknet.io/). For Sepolia tokens detailed intructons can be found in the [Get Sepolia Tokens](./ch02-05-01-start-with-sepolia.md) section.
>
> **Still doesn't work?**
>
> Check if your wallet's testnet network isn't yet set with Goerli or Sepolia, try again with your blast rpc url.
>
> ```bash
> starknet account fetch ... --rpc https://starknet-testnet.public.blastapi.io/rpc/
> ```
>
> ⚠️ And if you use Goerli, make sure you use it in subsequent commands as well.

After this process, search your wallet address on the Starknet explorer. To see the details, go back to [Smart Wallet Setup](https://book.starknet.io/ch01-00-getting-started.html#smart-wallet-setup).

After running the command, you’ll see a message like the one below.
We’re using a Braavos wallet as an example, but the steps are the same
for an Argent wallet.

```bash
    Account contract type identified as: Braavos
    Description: Braavos official proxy account
    Downloaded new account config file: ~/.starkli-wallets/deployer/my_account_1.json
```

After the acount descriptor file is generated, you can see its details, run:

```bash
    cat ~/.starkli-wallets/deployer/my_account_1.json
```

Here’s what a typical descriptor might look like:

```json
{
  "version": 1,
  "variant": {
    "type": "braavos",
    "version": 1,
    "implementation": "0x5dec330eebf36c8672b60db4a718d44762d3ae6d1333e553197acb47ee5a062",
    "multisig": {
      "status": "off"
    },
    "signers": [
      {
        "type": "stark",
        "public_key": "0x49759ed6197d0d385a96f9d8e7af350848b07777e901f5570b3dc2d9744a25e"
      }
    ]
  },
  "deployment": {
    "status": "deployed",
    "class_hash": "0x3131fa018d520a037686ce3efddeab8f28895662f019ca3ca18a626650f7d1e",
    "address": "0x6dcb489c1a93069f469746ef35312d6a3b9e56ccad7f21f0b69eb799d6d2821"
  }
}
```

Note: The structure will differ if you use an Argent wallet.

## Setting up Environment Variables

To simplify Starkli commands, you can set environment variables. Two key
variables are crucial: one for the Signer’s keystore file location and
another for the Account Descriptor file.

```bash
    export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/my_account_1.json
    export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/my_keystore_1.json
    export STARKNET_RPC=https://starknet-testnet.public.blastapi.io/rpc/v0_6
```

Setting these variables makes running Starkli commands easier and more
efficient.

## Declaring Smart Contracts in Starknet

Deploying a smart contract on Starknet involves two steps:

- Declare your contract’s code.
- Deploy an instance of the declared code.

To get started, navigate to the `src/` directory in the [examples/Ownable-Starknet](https://github.com/starknet-edu/starknetbook/tree/main/examples/Ownable-Starknet) directory
of the Starknet Book repo. The `src/lib.cairo` file contains a basic
contract to practice with.

First, compile the contract using the Scarb compiler. If you haven’t
installed Scarb, follow the installation guide in the [basic installation](./ch02-01-basic-installation)
section.

```bash
    scarb build
```

This creates a compiled contract in `target/dev/` as
`ownable_starknet_ownable.compiled_contract_class.json` (in Chapter 2 of the book we will learn
more details about Scarb).

### Declaring Your Contract

Run this command to declare your contract using the default Starknet
Sequencer’s Gateway:

```bash
    starkli declare ./target/dev/ownable_starknet_ownable.contract_class.json
```

According to the `STARKNET_RPC` url, starkli can recognize the target
blockchain network, in this case "goerli", so it is not necessary
explicitly specify it.

Unless you’re working with custom networks where it’s infeasible for
Starkli to detect the right compiler version, you shouldn’t need to
manually choose a version with `--network` and `--compiler-version`.

If you encounter an "Error: Invalid contract class," it likely means
your Scarb’s compiler version is incompatible with Starkli. Follow the
steps above to align the versions. Starkli usually supports compiler
versions accepted by mainnet, even if Scarb’s latest version is not yet
compatible.

After running the command, you’ll receive a contract class hash. This
unique hash serves as the identifier for your contract class within
Starknet. For example:

```bash
    Class hash declared: 0x04c70a75f0246e572aa2e1e1ec4fffbe95fa196c60db8d5677a5c3a3b5b6a1a8
```

You can think of this hash as the contract class’s _address._ Use a
block explorer like
[StarkScan](https://testnet.starkscan.co/class/0x04c70a75f0246e572aa2e1e1ec4fffbe95fa196c60db8d5677a5c3a3b5b6a1a8)
to verify this hash on the blockchain.

If the contract class you’re attempting to declare already exists, it is
ok we can continue. You’ll receive a message like:

```bash
    Not declaring class as its already declared. Class hash:
    0x04c70a75f0246e572aa2e1e1ec4fffbe95fa196c60db8d5677a5c3a3b5b6a1a8
```

## Deploying Smart Contracts on Starknet

To deploy a smart contract, you’ll need to instantiate it on Starknet’s
testnet. This process involves executing a command that requires two
main components:

1.  The class hash of your smart contract.

2.  Any constructor arguments that the contract expects.

In our example, the constructor expects an _owner_ address. You can
learn more about constructors in [Chapter 12 of The Cairo
Book](https://book.cairo-lang.org/ch99-01-03-02-contract-functions.html?highlight=constructor#1-constructors).

The command would look like this:

```bash
    starkli deploy \
        <CLASS_HASH> \
        <CONSTRUCTOR_INPUTS>
```

Here’s a specific example with an actual class hash and constructor
inputs (as the owner address use the address of your smart wallet so you
can invoke the transfer_ownership function later):

```bash
    starkli deploy \
        0x04c70a75f0246e572aa2e1e1ec4fffbe95fa196c60db8d5677a5c3a3b5b6a1a8 \
        0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510
```

After executing the command and entering your password, you should see
output like the following:

```bash
    Deploying class 0x04c70a75f0246e572aa2e1e1ec4fffbe95fa196c60db8d5677a5c3a3b5b6a1a8 with salt 0x065034b27a199cbb2a5b97b78a8a6a6c6edd027c7e398b18e5c0e5c0c65246b7...
    The contract will be deployed at address 0x02a83c32d4b417d3c22f665acbc10e9a1062033b9ab5b2c3358952541bc6c012
    Contract deployment transaction: 0x0743de1e233d38c4f3e9fb13f1794276f7d4bf44af9eac66e22944ad1fa85f14
    Contract deployed:
    0x02a83c32d4b417d3c22f665acbc10e9a1062033b9ab5b2c3358952541bc6c012
```

The contract is now live on the Starknet testnet. You can verify its
status using a block explorer like
[StarkScan](https://testnet.starkscan.co/contract/0x02a83c32d4b417d3c22f665acbc10e9a1062033b9ab5b2c3358952541bc6c012).
On the "Read/Write Contract" tab, you’ll see the contract’s external
functions.

## Interacting with the Starknet Contract

Starkli enables interaction with smart contracts via two primary
methods: `call` for read-only functions and `invoke` for write functions
that modify the state.

### Calling a Read Function

The `call` command enables you to query a smart contract function
without sending a transaction. For instance, to find out who the current
owner of the contract is, you can use the `get_owner` function, which
requires no arguments.

```bash
    starkli call \
        <CONTRACT_ADDRESS> \
        owner
```

Replace `<CONTRACT_ADDRESS>` with the address of your recently deployed contract. The command will return the owner’s address, which was initially set during
the contract’s deployment:

```bash
    [
        "0x02cdab749380950e7a7c0deff5ea8edd716feb3a2952add4e5659655077b8510"
    ]
```

## Invoking a Write Function

You can modify the contract’s state using the `invoke` command. For
example, let’s transfer the contract’s ownership with the
`transfer_ownership` function.

```bash
    starkli invoke \
        <CONTRACT_ADDRESS> \
        transfer_ownership \
        <NEW_OWNER_ADDRESS>
```

Replace `<CONTRACT_ADDRESS>` with the address of the contract and
`<NEW_OWNER_ADDRESS>` with the address you want to transfer ownership
to. If the smart wallet you’re using isn’t the contract’s owner, an
error will appear. Note that the initial owner was set when deploying
the contract:

```bash
    Execution was reverted; failure reason: [0x43616c6c6572206973206e6f7420746865206f776e6572].
```

The failure reason is encoded as a felt. o decode it, use the starkli’s
`parse-cairo-string` command.

```bash
    starkli parse-cairo-string <ENCODED_ERROR>
```

For example, if you see
`0x43616c6c6572206973206e6f7420746865206f776e6572`, decoding it will
yield "Caller is not the owner."

After a successful transaction on L2, use a block explorer like
StarkScan or Voyager to confirm the transaction status using the hash
provided by the `invoke` command.

To verify that the ownership has successfully transferred, you can call
the `get_owner` function again:

```bash
    starkli call \
        <CONTRACT_ADDRESS> \
        owner
```

If the function returns the new owner’s address, the transfer was
successful.

Congratulations! You’ve successfully deployed and interacted with a
Starknet contract.
