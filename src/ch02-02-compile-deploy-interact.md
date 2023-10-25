# Compile, Deploy and Interact with a Contract

In this chapter, you’ll learn how to compile, deploy, and interact with
a Starknet smart contract written in Cairo.

First, confirm that the following commands work on your system. If they
don’t, refer to Basic Installation in this chapter.

```bash
    scarb --version  # For Cairo code compilation
    starkli --version  # To interact with Starknet
```

## Find the compiler versions supported

We have to make sure that our Starkli compiler version match Scarb
compiler version

To find the compiler versions supported by Starkli, execute:

```bash
    starkli declare --help
```

You’ll see a list of possible compiler versions under the
`--compiler-version` flag.

```bash
    ...
    --compiler-version <COMPILER_VERSION>
              Statically-linked Sierra compiler version [possible values: [COMPILER VERSIONS]]]
    ...
```

Note that the Scarb compiler version might not align with Starkli’s
supported versions. To check Scarb’s version:

```bash
    scarb --version
```

You’ll see a list that contains scarb, cairo and sierra version.

```bash
    scarb <SCARB VERSION>
    cairo: <COMPILER VERSION>
    sierra: <SIERRA VERSION>
```

If there’s a mismatch, it is suggested that you install the version of
Scarb that uses the compiler version that Starkli supports. You can find
previous releases on
[Scarb](https://github.com/software-mansion/scarb/releases)'s GitHub
repo.

To install a specific version, such as `2.3.0`, run:

```bash
    curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v 2.3.0
```

## Smart Wallet Setup

A smart wallet comprises a Signer and an Account Descriptor. The Signer
is a smart contract with a private key for signing transactions, while
the Account Descriptor is a JSON file detailing the wallet’s address and
public key.

For an account to be used as a signer it must be deployed to the appropriate network (Starknet Goerli or mainnet) and funded.

Steps for deploying and funding an account: 

1. Install Braavos or Argent X browser extensions.

2. Fund your account with ETH. Click on "Deposit" on Braavos or "Add funds" on Argent X, then select 
    "Starknet token faucet" to get testnet tokens. You can also use [Starknet Goerli
    Faucet](https://faucet.goerli.starknet.io/).

3. For Braavos, on the account page click on "set up your account on-chain" to deploy your account. 
    For Argent X, fund your account using the faucet (for testnet) or fund using Ether, then make an 
    outgoing transaction from the account (you can just send some tokens to account2 in your wallet).
    This will automatically deploy your account.

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
    mkdir ~/.starkli-wallets/deployer -p
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

### Creating an Account Descriptor

An Account Descriptor informs Starkli about your smart wallet’s unique
features, such as its signing mechanism. You can generate this
descriptor using Starkli’s `fetch` subcommand under the `account`
command. The `fetch` subcommand takes your on-chain wallet address as
input and generates the account descriptor file. The account descriptor
file is a JSON file that contains the details of your smart wallet.

```bash
    starkli account fetch <SMART_WALLET_ADDRESS> --output ~/.starkli-wallets/deployer/my_account_1.json
```

After running the command, you’ll see a message like the one below.
We’re using a Braavos wallet as an example, but the steps are the same
for an Argent wallet.

```bash
    Account contract type identified as: Braavos
    Description: Braavos official proxy account
    Downloaded new account config file: ~/.starkli-wallets/deployer/my_account_1.json
```

To see the details of your Account Descriptor, run:

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
```

Setting these variables makes running Starkli commands easier and more
efficient.

## Declaring Smart Contracts in Starknet

Deploying a smart contract on Starknet involves two steps:

- Declare your contract’s code.

- Deploy an instance of the declared code.

To get started, navigate to the `contracts/` directory in the [first
chapter](https://github.com/starknet-edu/starknetbook/tree/main/chapters/book/modules/chapter_1/pages/contracts)
of the Starknet Book repo. The `src/lib.cairo` file contains a basic
contract to practice with.

First, compile the contract using the Scarb compiler. If you haven’t
installed Scarb, follow the installation guide in the [Setting up your
Environment](https://book.starknet.io/chapter_1/environment_setup.html)
section.

```bash
    scarb build
```

This creates a compiled contract in `target/dev/` as
"contracts_Ownable.sierra.json" (in Chapter 2 of the book we will learn
more details about Scarb).

With the smart contract compiled, we’re ready to declare it using
Starkli. Before declaring your contract, decide on an RPC provider.

### Choosing an RPC Provider

There are three main options for RPC providers, sorted by ease of use:

1.  **Starknet Sequencer’s Gateway**: The quickest option and it’s the
    default for Starkli for now. The sequencer gateway is deprecated and
    will be disabled by StarkWare soon. You’re strongly recommended to
    use a third-party JSON-RPC API provider like Infura, Alchemy, or
    Chainstack.

2.  **Infura or Alchemy**: A step up in complexity. You’ll need to set
    up an API key and choose an endpoint. For Infura, it would look like
    `https://starknet-goerli.infura.io/v3/<API_KEY>`. Learn more in the
    [Infura
    documentation](https://docs.infura.io/networks/starknet/how-to/choose-a-network).

3.  **Your Own Node**: For those who want full control. It’s the most
    complex but offers the most freedom. Check out [Chapter 4 of the
    Starknet Book](https://book.starknet.io/chapter_4/node.html) or
    [Kasar](https://www.kasar.io/) for setup guides.

In this tutorial, we will use Alchemy. We can set the STARKNET_RPC
environment variable to make command invocations easier:

```bash
    export STARKNET_RPC="https://starknet-goerli.g.alchemy.com/v2/<API_KEY>"
```

### Declaring Your Contract

Run this command to declare your contract using the default Starknet
Sequencer’s Gateway:

```bash
    starkli declare target/dev/contracts_Ownable.sierra.json
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
learn more about constructors in \[Chapter 12 of The Cairo
Book\](<https://book.cairo-lang.org/ch99-01-03-02-contract-functions.html?highlight=constructor#1-constructors>).

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
        get_owner
```

Replace `<CONTRACT_ADDRESS>` with the address of your contract. The
command will return the owner’s address, which was initially set during
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
        get_owner
```

If the function returns the new owner’s address, the transfer was
successful.

Congratulations! You’ve successfully deployed and interacted with a
Starknet contract.
