# Introduction to Starkli, Scarb and Katana

In this chapter, you’ll learn how to compile, deploy, and interact with
a Starknet smart contract written in Cairo using starkli, scarb and katana.

First, confirm that the following commands work on your system. If they
don’t, refer to Basic Installation in this chapter.

```bash
    scarb --version  # For Cairo code compilation
    starkli --version  # To interact with Starknet
    katana --version # To declare and deploy on local development
```

## [OPTIONAL] Checking Supported Compiler Versions

If issues arise during the declare or deploy process, ensure that the Starkli compiler version aligns with the Scarb compiler version.

To check the compiler versions Starkli supports, run:

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

Be aware: Scarb's compiler version may not match Starkli’s. To verify Scarb's version:

```bash
    scarb --version
```

The output displays the versions for scarb, cairo, and sierra:

```bash
    scarb <SCARB VERSION>
    cairo: <COMPILER VERSION>
    sierra: <SIERRA VERSION>
```

If the versions don't match, consider installing a version of Scarb compatible with Starkli. Browse [Scarb's GitHub](https://github.com/software-mansion/scarb/releases) repo for earlier releases.

To install a specific version, such as `2.3.0`, run:

```bash
    curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v 2.3.0
```

## Crafting a Starknet Smart Contract

Begin by initiating a Scarb project:

```bash
scarb new my_contract
```

## Configure Environment Variables and the `Scarb.toml` File

Review the `my_contract` project. Its structure appears as:

```bash
    src/
      lib.cairo
    .gitignore
    Scarb.toml
```

Amend the `Scarb.toml` file to integrate the `starknet` dependency and introduce the `starknet-contract` target:

```toml
    [dependencies]
    starknet = ">=2.3.0"

    [[target.starknet-contract]]
```

For streamlined Starkli command execution, establish environment variables. Two primary variables are essential:

- One for your account, a pre-funded account on the local development network
- Another for designating the network, specifically the local katana devnet

In the `src/` directory, create a `.env` file with the following:

```bash
export STARKNET_ACCOUNT=katana-0
export STARKNET_RPC=http://0.0.0.0:5050
```

These settings streamline Starkli command operations.

## Declaring Smart Contracts in Starknet

Deploying a Starknet smart contract requires two primary steps:

- Declare the contract's code.
- Deploy an instance of that declared code.

Begin with the `src/lib.cairo` file, which provides a foundational template. Remove its contents and insert the following:

```rust
#[starknet::contract]
mod hello {
    #[storage]
    struct Storage {
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, name: felt252) {
        self.name.write(name);
    }

    #[external(v0)]
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }
    #[external(v0)]
        fn set_name(ref self: ContractState, name: felt252) {
            let previous = self.name.read();
            self.name.write(name);
        }
}
```

This rudimentary smart contract serves as a starting point.

Compile the contract with the Scarb compiler. If Scarb isn't installed, consult the [Installation](ch02-01-basic-installation.md) section.

```bash
scarb build
```

The above command results in a compiled contract under `target/dev/`, named "`my_contract_hello.contract_class.json`" (check Scarb's subchapter for more details).

Having compiled the smart contract, it's time to declare it with Starkli and katana. First, ensure your project acknowledges the environmental variables:

```bash
source .env
```

Next, launch Katana. In a separate terminal, run (more details in the Katan subchapter):

```bash
katana
```

To declare your contract, execute:

```bash
starkli declare target/dev/my_contract_hello.contract_class.json
```

Facing an "Error: Invalid contract class"? It indicates a version mismatch between Scarb's compiler and Starkli. Refer to the earlier steps to sync the versions. Typically, Starkli supports compiler versions approved by mainnet, even if the most recent Scarb version isn't compatible.

Upon successful command execution, you'll obtain a contract class hash: This
unique hash serves as the identifier for your contract class within
Starknet. For example:

```bash
Class hash declared: 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

Consider this hash as the contract class's _address_.

If you try to declare an already existing contract class, don't fret. Just proceed. You might see:

```bash
Not declaring class as its already declared. Class hash:
0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

## Deploying Starknet Smart Contracts

To deploy a smart contract on the katana local devnet, use the following command. It primarily requires:

1. Your contract's class hash.
2. Constructor arguments your contract needs (in our example, a _name_ of type `felt252`).

Here's the command structure:

```bash
    starkli deploy \
        <CLASS_HASH> \
        <CONSTRUCTOR_INPUTS>
```

Notice the constructor inputs are in felt format. So we need to convert a short string to a felt252 format. We can use the `to-cairo-string` command for this:

```bash
    starkli to-cairo-string <STRING>
```

In this case, we'll use the string "starknetbook" as the name:

```bash
    starkli to-cairo-string starknetbook
```

The output:

```bash
    0x737461726b6e6574626f6f6b
```

Now deploy using a class hash and constructor input:

```bash
    starkli deploy \
        0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 \
        0x737461726b6e6574626f6f6b
```

After running, expect an output similar to:

```bash
    Deploying class 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 with salt 0x054645c0d1e766ddd927b3bde150c0a3dc0081af7fb82160c1582e05f6018794...
    The contract will be deployed at address 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44
    Contract deployment transaction: 0x00413d9638fecb75eb07593b5c76d13a68e4af7962c368c5c2e810e7a310d54c
    Contract deployed: 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44
```

## Interacting with Starknet Contracts

Using Starkli, you can interact with smart contracts through two primary methods:

- `call`: For read-only functions.
- `invoke`: For functions that alter the state.

### Reading Data with `call`

The `call` command let's you query contract functions without transacting. For instance, if you want to determine the current contract owner using the `get_name` function, which
requires no arguments:

```bash
    starkli call \
        <CONTRACT_ADDRESS> \
        get_name
```

Replace `<CONTRACT_ADDRESS>` with the address of your contract. The
command will return the owner’s address, which was initially set during
the contract’s deployment:

```bash
    [
        "0x0000000000000000000000000000000000000000737461726b6e6574626f6f6b"
    ]
```

But what is this lengthy output? In Starknet, we use the `felt252` data type to represent strings. This can be decoded into its string representation:

```bash
starkli parse-cairo-string 0x737461726b6e6574626f6f6b
```

The result:

```bash
starknetbook
```

## Modifying Contract State with `invoke`

To alter the contract's state, use the `invoke` command. For instance, if you want to update the name field in the storage, utilize the `set_name` function:

```bash
    starkli invoke \
        <CONTRACT_ADDRESS> \
        set_name \
        <felt252>
```

Where:

- **`<CONTRACT_ADDRESS>`** is the address of your contract.
- **`<felt252>`** is the new value for the **`name`** field, in felt252 format.

For example, to update the name to "Omar", first convert the string "Omar" to its felt252 representation:

```bash
    starkli to-cairo-string Omar
```

This will return:

```bash
    0x4f6d6172
```

Now, proceed with the `invoke` command:

```bash
    starkli invoke 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44 set_name 0x4f6d6172
```

Bravo! You've adeptly modified and interfaced with your Starknet contract.
