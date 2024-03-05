# Introduction to Starkli, Scarb and Devnet-rs

In this chapter, you’ll learn how to compile, deploy, and interact with
a Starknet smart contract written in Cairo using starkli, scarb and [Starknet-Devnet-rs](#https://github.com/0xSpaceShard/starknet-devnet-rs).

Starknet-devnet-rs is a Rust-based Devnet, presenting it as an alternative to Katana. Devnet is a local node that will help you deploy and test your contract in real time which is more faster for development.

First, confirm that the following commands work on your system. If they
don’t, refer to Basic Installation in this chapter.

```bash
    scarb --version  # For Cairo code compilation
    starkli --version  # To interact with Starknet
    rustc --version
    Devnet # To declare, deploy and test on local
    development

```

## How to set up Starknet-Devnet-rs

### Requirements

- Install [rust](#https://www.rust-lang.org/tools/install)
- The required Rust version is specified in [rust-toolchain.toml](#https://github.com/0xSpaceShard/starknet-devnet-rs/blob/main/rust-toolchain.toml) and handled automatically by cargo.
- Run `rustc --version  ` to comfirm the rust version.

## Run as a binary

### Installing from crates.io

```
$ cargo install starknet-devnet

```

### Installing from github

Installing and running as a binary is achievable via `cargo install`. The project can be installed from crates.io and github.com.

- Clone
  `https://github.com/0xSpaceShard/starknet-devnet-rs.git`
- Navigate into the folder ` cd starknet-devnet-rs`
- Run Devnet
  `cargo run`

You should have the result below in your terminal. It generates accounts locally for testing and contract interaction locally, just like `katana`

```
Compiling starknet-devnet v0.0.2 (/Users/mac/Desktop/devnet/starknet-devnet-rs/crates/starknet-devnet)
Finished dev [unoptimized + debuginfo] target(s) in 3m 15s
Running `target/debug/starknet-devnet`
Predeployed FeeToken
ETH Address: 0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7
STRK Address: 0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d
Class Hash: 0x046ded64ae2dead6448e247234bab192a9c483644395b66f2155f2614e5804b0

Predeployed UDC
Address: 0x41A78E741E5AF2FEC34B695679BC6891742439F7AFB8484ECD7766661AD02BF
Class Hash: 0x7B3E05F48F0C69E4A65CE5E076A66271A527AFF2C34CE1083EC6E1526997A69

Chain ID: SN_GOERLI (0x534e5f474f45524c49)

| Account address | 0x15936516d5d1145ba1997fba038afc61b58c653e4afcc1380a049201fe02049
| Private key | 0x887b1599eaa02a4e47d5cbeb71166287
| Public key | 0x700df4cb7401878d4c7229ec30cfbc63f1f7bd3e63dfe611b10ea95d7c0a934

| Account address | 0x54be1f8f816ae05097a468eaf6bc3077e92c4795135f0b4b6817f66a000d313
| Private key | 0x3c91c4aa92551a9cbe3787972cb3e9b5
| Public key | 0x54cebcb3fffe1427b2bf22438443380965f1c8b2dd8874062e6c817eb34dd48

| Account address | 0x42c93fd9dbb2b943341752c6289bbb79050028146b08c6ef193fc6196852e19
| Private key | 0xbc7a73821619a17b4163d7ec1ba7c77b
| Public key | 0x464919a6c3e82fde52dbdaf647851c98a383b26139fbe4963d4495e1295ad4

| Account address | 0x8dc4c8db1770e27d643ba7afebab2788b21cb5f82fa78d4a2a34f5ec062fe6
| Private key | 0x3ec7437ddbe2ae79b35cd2ada14603e9
| Public key | 0x2e5440d5ec97ef60b62299852ddc8850ce21b97e58287c0187ed393719a1d8d

| Account address | 0x177116cf8f576774e62dd2525cd74f1ee2bd395805812f21cdb6b34884bc56
| Private key | 0x7e187acbe3d88dc0c1a0ac983b9a5f8d
| Public key | 0x419b331604b8a4f7b8a588951419b9d797625fdfd490b81d87a6a34de5f23c9

| Account address | 0x2bef82fb62abd667ee56dbc752033bd86ec7e40cdc56d6263f50bccb5c21a19
| Private key | 0xc550cc6c1196edb35fe1f8b5ece1ad13
| Public key | 0x4629cce9836abb945a5fc14f1d8cf01fbc7de1b1e101bea8c05be07b8c061d3

| Account address | 0x4b016dbad4c706afb5b8591e8e2894526581ad7e47b539e73279629d51bbcf1
| Private key | 0x4c8995c72b8f08e8b309f334fdea7543
| Public key | 0x2a78370841df60acbe0f6f7e3a614cdd479bcb366a279422b1894fbc7aab424

| Account address | 0x7170678de4ee6b56e3ff1ca8d2d20360d822b5bd485743a0c80dd06d44a3882
| Private key | 0x2749bb7c72c988b035b1ef312cf3d7ef
| Public key | 0xb7fe32817253d389251e80c1611b639e5e1cceb5761d1127d93ddd7a651304

| Account address | 0x3a77277569bb8225f7aa3d7dc4e467296c9143f4f778d63ff6189d359f0c409
| Private key | 0x87a4ed16fad5dac9988d1b2e6cd8872d
| Public key | 0x29cb629b8d79f1efb928f553a781518ae1389c55fb61443e6087945b35fef4c

| Account address | 0x49f78b29f6eee314a6c297f7a2f943a0c93dc4ec2c8f3c2089c05f351d0660b
| Private key | 0x94de45f28d52b5808ef42bd8e5261f90
| Public key | 0x5c7f51e81c5d1770201f6ef31e46fed058b10322478f4f1d57ae4c542a5d60e

Predeployed accounts using class with hash: 0x61dac032f228abef9c6626f995015233097ae253a7f72d68552db02f2971b8f
Initial balance of each account: 1000000000000000000000 WEI and FRI
Seed to replicate this account sequence: 534956567
```

## Crafting a Starknet Smart Contract

**Important:** Before we proceed with this example, please ensure that the versions of both `Scarb` and `starkli` match the specified versions provided below.
You can install the latest [scarb](#https://docs.swmansion.com/scarb/download.html) version.

```console
    rustc --version  #1.73.0 (cc66ad468)
    scarb 2.6.0 (850b9386a 2024-03-04)
     cairo: 2.6.0 (https://crates.io/crates/cairo-lang-compiler/2.6.0)
     sierra: 1.5.0
```

For a more optimized and faster performance (though with a longer compilation time), run with:

```
$ cargo run --release
```

Now begin by initiating a Scarb project:

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
    starknet = ">=2.5.4"

    [[target.starknet-contract]]
     casm = true

```

For streamlined Starkli command execution, establish environment variables. Two primary variables are essential:

- One for your account, a pre-funded account on the local development network
- Another for designating the network, specifically the local Starknet-devnet-rs

In the `src/` directory, create a `.env` file with the following:

```bash
export RPC_SPEC_VERSION="0.5.1"
export STARKNET_VERSION="0.13.0"
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
 #[abi(embed_v0)]
```

This rudimentary smart contract serves as a starting point.

Compile the contract with the Scarb compiler. If Scarb isn't installed, consult the [Installation](ch02-01-basic-installation.md) section.

```bash
scarb build
```

The above command results in a compiled contract under `target/dev/`, named "`my_contract_hello.contract_class.json`" (check Scarb's subchapter for more details).

Having compiled the smart contract, it's time to declare it with Starkli and Starknet-devnet-rs. First, ensure your project acknowledges the environmental variables:

```bash
source .env
```

Next, launch Devnet. In a separate terminal:

```bash
cargo run
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

To deploy a smart contract on the local devnet, use the following command. It primarily requires:

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
