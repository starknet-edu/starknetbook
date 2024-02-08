# Madara 🚧



Madara is a Starknet sequencer that operates on the Substrate framework, executing Cairo programs and Starknet smart contracts with the Cairo VM. Madara enables the launch and control of Starknet Appchains or L3s.

## Get Started with Madara

<!-- Visit the [GitHub repository](https://github.com/keep-starknet-strange/madara) for detailed instructions on installing and configuring Madara, including practical examples.



# Building on Madara -->

<br></br>In this section, we will guide you through the building process so you can start hacking on the Madara stack.
We will go from running your chain locally to changing the consensus algorithm and interacting with smart contracts on your own chain!

## Let's start

<Steps>

### Install dependencies
<a id="dependencies"></a>
We first need to make sure you have everything needed to complete this tutorial.

| Dependency  |  Version | Installation |
|---|---|---|
| Rust  | rustc 1.69.0-nightly  | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` <br></br>`rustup toolchain install nightly` |
| nvm  | latest  | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh \| bash` |
| Cairo  | 1.0  | `curl -L https://github.com/franalgaba/cairo-installer/raw/main/bin/cairo-installer \| bash` |

for macos ensure you have protobuf to avoid build time errors
```
brew install protobuf
```



### Build the chain

We will spin up a CairoVM Rollup from the Madara Stack source code. 
You could use docker images, but this way we keep the option to modify component behavior if you need to do so. 
The Madara stack source code is a monorepo which can be found [here](https://github.com/keep-starknet-strange/madara)

```bash
cd ~
git clone https://github.com/keep-starknet-strange/madara.git
```

Then let's build the chain in `release` mode

```bash
cd madara
cargo build --release
```
<br></br>

**Single-Node Development Chain**

This command will start the single-node development chain with non-persistent
state:

```bash
./target/release/madara --dev
```

Purge the development chain's state:

```bash
./target/release/madara purge-chain --dev
```

Start the development chain with detailed logging:

```bash
RUST_BACKTRACE=1 ./target/release/madara -ldebug --dev
```
### Node example

![running madara node example](./img/ch03-02-01-madara-1.png)
If everything works correctly, we can go to the next step and create our own genesis state!

### Create your chain specification

First, run this command to create a plain chain spec

```bash
./target/release/madara build-spec > ./infra/chain-sepcs/chain-spec-plain.json
```



By default, the chain will run with the following config :
- [GRANDPA & AURA](https://docs.substrate.io/learn/consensus/#default-consensus-models)
- An `admin` account contract at address `0x0000000000000000000000000000000000000000000000000000000000000001`
- A test contract at address `0x0000000000000000000000000000000000000000000000000000000000001111`
- A fee token (ETH) at address `0x040e59c2c182a58fb0a74349bfa4769cbbcba32547591dd3fb1def8623997d00`
- The `admin` account address has a `MAX` balance of fee token
- An ERC20 contract at address `0x040e59c2c182a58fb0a74349bfa4769cbbcba32547591dd3fb1def8623997d00`

This chain specification can be thought of as the main source of information that will be used when connecting to the chain. 

### *(Not available yet) Deploy your settlement smart contracts*

### Connect with Polkadot-JS Apps Front-end

Once the node template is running locally, you can connect it with **Polkadot-JS
Apps** front-end to interact with your chain. use 
[polkadat frontend](https://polkadot.js.org/apps/#/explorer?rpc=ws://localhost:9944) or  [madara zone frontend](https://explorer.madara.zone/?rpc=ws%3A%2F%2F127.0.0.1%3A9944#/accounts)
 connecting the Apps to your local node template.



### ui connection 
![running madara node example](./img/ch03-02-01-madara-2.png)

### Start your chain

Now that we are all setup, we can finally run the chain! 

There are a lot of ways you can run the chain depending on which role you want to take :
- **Full node**<br></br>
Synchronizes with the chain to store the most recent block state and block headers for older blocks.
When developing your chain, you can simply run it in developer mode :

```bash
./target/release/madara --dev --execution=native
```

- **Archive node**<br></br>
Maintains all blocks starting from the genesis block with complete state available for every block.
<br></br>
If you want to keep the whole state of the chain in a `/tmp/ folder :
```bash
./target/release/madara --base-path /tmp/
```

In this case, note that you can purge the chain's state whenever you like by running : 
```bash
./target/release/madara purge-chain --base-path /tmp
```
- **RPC node**<br></br>
Exposes an RPC interface over HTTP or WebSocket ports for the chain so that users can read the blockchain state and submit transactions. 
There are often multiple RPC nodes behind a load balancer.
If you only care about exposing the RPC you can run the following : 

```bash
./target/release/madara setup --chain dev --from-local ./configs
```
run Madara app rpc :

```bash
./target/release/madara --dev --unsafe-rpc-external --rpc-methods Safe   --rpc-max-connections 5000
```
you can now interact with madara rpc  
Eg you can get the chain using the rpc 

``` bash
curl -X POST http://localhost:9944 \
     -H 'Content-Type: application/json' \
     -d '{
       "jsonrpc": "2.0",
       "method": "starknet_chainId",
       "params": [],
       "id": 1
     }'
```
Madara rpc [examples](https://github.com/keep-starknet-strange/madara/tree/main/examples/rpc/starknet)
#### output example 
![running madara node example](./img/ch03-02-01-madara-3.png)

- **Validator node**<br></br>
Secures the chain by staking some chosen asset and votes on consensus along with other validators.





### Deploy an account on your chain

Ooook, now your chain is finally running. It's time to deploy your own account!



### Make some transactions

<br></br>

# building Madara App Chain Your Using madara appchain Template 
clone the  Madara appchain Template  
```
git clone https://github.com/keep-starknet-strange/madara-app-chain-template.git
```

## Getting Started

Ensure you have[ Required dependancies  ](#dependencies)To run madara AppChain
<br></br>
Depending on your operating system and Rust version, there might be additional packages required to compile this template.
Check the [Install](https://docs.substrate.io/install/) instructions for your platform for the most common dependencies.
Alternatively, you can use one of the [alternative installation](#alternatives-installations) options.

### Build

Use the following command to build the node without launching it:

```sh
cargo build --release
```

### Embedded Docs

After you build the project, you can use the following command to explore its parameters and subcommands:

```sh
./target/release/app-chain-node -h
```

You can generate and view the [Rust Docs](https://doc.rust-lang.org/cargo/commands/cargo-doc.html) for this template with this command:

```sh
cargo +nightly doc --open
```

### Single-Node Development Chain

Set up the chain with the genesis config. More about defining the genesis state is mentioned below.

```sh
./target/release/app-chain-node setup --chain dev --from-local ./configs
```

The following command starts a single-node development chain.

```sh
./target/release/app-chain-node --dev
```

You can specify the folder where you want to store the genesis state as follows

```sh
./target/release/app-chain-node setup --chain dev --from-local ./configs --base-path=<path>
```

If you used a custom folder to store the genesis state, you need to specify it when running

```sh
./target/release/app-chain-node --base-path=<path>
```

Please note, Madara overrides the default `dev` flag in substrate to meet its requirements. The following flags are automatically enabled with the `--dev` argument:

`--chain=dev`, `--force-authoring`, `--alice`, `--tmp`, `--rpc-external`, `--rpc-methods=unsafe`

To store the chain state in the same folder as the genesis state, run the following command. You cannot combine the `base-path` command
with `--dev` as `--dev` enforces `--tmp` which will store the db at a temporary folder. You can, however, manually specify all flags that
the dev flag adds automatically. Keep in mind, the path must be the same as the one you used in the setup command.

```sh
./target/release/app-chain-node --base-path <path>
```

To start the development chain with detailed logging, run the following command:

```sh
RUST_BACKTRACE=1 ./target/release/app-chain-node -ldebug --dev
```

### Connect with Polkadot-JS Apps Front-End

After you start the app chain locally, you can interact with it using the hosted version of the [Polkadot/Substrate Portal](https://polkadot.js.org/apps/#/explorer?rpc=ws://localhost:9944) front-end by connecting to the local node endpoint.
A hosted version is also available on [IPFS (redirect) here](https://dotapps.io/) or [IPNS (direct) here](ipns://dotapps.io/?rpc=ws%3A%2F%2F127.0.0.1%3A9944#/explorer).
You can also find the source code and instructions for hosting your own instance on the [polkadot-js/apps](https://github.com/polkadot-js/apps) repository.

### Multi-Node Local Testnet

If you want to see the multi-node consensus algorithm in action, see [Simulate a network](https://docs.substrate.io/tutorials/get-started/simulate-network/).

## Template Structure

The app chain template gives you complete flexibility to modify exiting features of Madara and add new features as well.

### Existing Pallets

Madara comes with only one pallet - `pallet_starknet`. This pallet allows app chains to execute Cairo contracts and have 100% RPC compatabiltiy with Starknet mainnet. This means all Cairo tooling should work out of the box with the app chain. At the same time, the pallet also allows the app chain to fine tune specific parameters to meet their own needs.

- `DisableTransactionFee`: If true, calculate and store the Starknet state commitments
- `DisableNonceValidation`: If true, check and increment nonce after a transaction
- `InvokeTxMaxNSteps`: Maximum number of Cairo steps for an invoke transaction
- `ValidateMaxNSteps`: Maximum number of Cairo steps when validating a transaction
- `MaxRecursionDepth`: Maximum recursion depth for transactions
- `ChainId`: The chain id of the app chain

All these options can be configured inside `crates/runtime/src/pallets.rs`

### Genesis

The genesis state of the app chain is defined via a JSON file. It lives inside the `config` folder but can also be fetch from a url. You can read in more detail about how to setup the config from these two docs in the Madara repo.
- [Genesis](https://github.com/keep-starknet-strange/madara/blob/main/docs/genesis.md)
- [Configs](https://github.com/d-roak/madara/blob/feat/configs-index/docs/configs.md)

### How to add New Pallets

<!-- Adding a new pallet is the same as adding a pallet in any substrate based chain. An an example, `pallet-template` has been added on this madara appchain template. 
Add the Nicks pallet dependencies -->

Before you can use a new pallet, you must add some information about it to the configuration file that the compiler uses to build the runtime binary.

For Rust programs, you use the Cargo.toml file to define the configuration settings and dependencies that determine what gets compiled in the resulting binary. Because the Substrate runtime compiles to both a native platform binary that includes standard library Rust functions and a WebAssembly (Wasm) binary that does not include the standard Rust library, the Cargo.toml file controls two important pieces of information:

- The pallets to be imported as dependencies for the runtime, including the location and version of the pallets to import.
- The features in each pallet that should be enabled when compiling the native Rust binary. By enabling the standard (std) feature set from each pallet, you can compile the runtime to include functions, types, and primitives that would otherwise be missing when you build the WebAssembly binary.

For information about adding dependencies in Cargo.toml files, see Dependencies in the Cargo documentation. For information about enabling and managing features from dependent packages, see Features in the Cargo documentation.

To add the dependencies for the Nicks pallet to the runtime:

- Open a terminal shell and change to the root directory for the Madara Appchain template.
- Open the runtime/Cargo.toml configuration file in a text editor.
- Locate the [dependencies] section and note how other pallets are imported.

- Copy an existing pallet dependency description and replace the pallet name with pallet-nicks to make the pallet available to the node template runtime.
 For example, add a line similar to the following:
```
    pallet-nicks = { version = "4.0.0-dev", default-features = false, git = "https://github.com/paritytech/polkadot-sdk.git", branch = "polkadot-v1.0.0" }
```
This line imports the pallet-nicks crate as a dependency and specifies the following:

- Version to identify which version of the crate you want to import.
- The default behavior for including pallet features when compiling the runtime with the standard Rust libraries.
- Repository location for retrieving the pallet-nicks crate.
- Branch to use for retrieving the crate. Be sure to use the same version and branch information for the Nicks pallet as you see used for the other pallets included in the runtime.

These details should be the same for every pallet in any given version of the node template.

Add the pallet-nicks/std features to the list of features to enable when compiling the runtime.
```
[features]
default = ["std"]
std = [
  ...
  "pallet-aura/std",
  "pallet-balances/std",
  "pallet-nicks/std",
  ...
]
```

If you forget to update the features section in the Cargo.toml file, you might see cannot find function errors when you compile the runtime binary.

You can read more about it [here](https://docs.substrate.io/tutorials/build-application-logic/add-a-pallet/).

### Runtime configuration

Similar to new pallets, runtime configurations can be just like they're done in Substrate. You can edit all the available parameters inside `crates/runtime/src/config.rs`.

For example, to change the block time, you can edit the `MILLISECS_PER_BLOCK` variable.

## Alternatives Installations

Instead of installing dependencies and building this source directly, consider the following alternatives.

### Nix

Install [nix](https://nixos.org/), and optionally [direnv](https://github.com/direnv/direnv) and [lorri](https://github.com/nix-community/lorri) for a fully plug-and-play experience for setting up the development environment.
To get all the correct dependencies, activate direnv `direnv allow` and lorri `lorri shell`.

### Docker

Please use the [Madara Dockerfile](https://github.com/keep-starknet-strange/madara/blob/main/Dockerfile) as a reference to build the Docker container with your App Chain node as a binary.




