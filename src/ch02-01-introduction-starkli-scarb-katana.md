# Introduction to Scarb, Katana and Scarb

In this chapter, you’ll learn how to compile, deploy, and interact with
a Starknet smart contract written in Cairo using starkli, scarb and katana.

First, confirm that the following commands work on your system. If they
don’t, refer to Basic Installation in this chapter.

```bash
    scarb --version  # For Cairo code compilation
    starkli --version  # To interact with Starknet
    katana --version # To declare and deploy on local development
```
## [OPTIONAL] Find the compiler versions supported

In case you face problems during declare or deploy procees, You have to make sure that Starkli compiler version match Scarb compiler version

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

To install a specific version, such as `0.6.1`, run:

```bash
    curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh -s -- -v 0.6.1
```

## Create a Smart Contract in Starknet

First, create a Scrab project:
```bash
    scarb new my_contract
    code my_contract
```
In case you are using an IDE different than VS code, just open `my_contract` project.


## Setting up Environment Variables and Scarb.toml file

Inspect the contents of the `my_contract` project, and you'll notice the following structure:

```bash
    src/
      lib.cairo
    .gitignore
    Scarb.toml
```

Update the Scarb.toml file to include the starknet dependency and add the starknet-contract target:

```toml
    [dependencies]
    starknet = ">=2.3.0"

    [[target.starknet-contract]]
```

To simplify Starkli commands, you can set environment variables. Two key
variables are crucial: one for your account, this is a pre-funded account in local development network and another to setup the network, in this case local katana devnet. Thus, inside the `src/` directory, create a `.env` file and paste the below content.
```bash
    export STARKNET_ACCOUNT=katana-0
    export STARKNET_RPC=http://0.0.0.0:5050
```

Setting these variables makes running Starkli commands easier and more
efficient.

## Declaring Smart Contracts in Starknet

Deploying a smart contract on Starknet involves two steps:

- Declare your contract’s code.

- Deploy an instance of the declared code.

To get started, navigate to the `src/lib.cairo` file, it contains a basic
template code to practice with. Let's remove all the content and paste the below code 

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

This a very basic smart contract, on the following chapters we will include interfaces, events, best practices and more.

First, compile the contract using the Scarb compiler. If you haven’t
installed Scarb, follow the installation guide in the [Setting up your
Environment](https://book.starknet.io/chapter_1/environment_setup.html)
section.

```bash
    scarb build
```

This creates a compiled contract in `target/dev/` as
"my_contract_hello.contract_class.json" (in Chapter 2 of the book we will learn
more details about Scarb).

With the smart contract compiled, we’re ready to declare it using Starkli and katana. Before declaring your contract make sure your project recognize the environmental variables
```bash
    source .env
```

Then, we need to get Katana running. Open a second terminal and execute:
```bash
    katana
```

### Declaring Your Contract

Run this command to declare your contract:

```bash
    starkli declare target/dev/my_contract_hello.contract_class.json
```

If you encounter an "Error: Invalid contract class," it likely means
your Scarb’s compiler version is incompatible with Starkli. Follow the
steps above to align the versions. Starkli usually supports compiler
versions accepted by mainnet, even if Scarb’s latest version is not yet
compatible.

After running the command, you’ll receive a contract class hash. This
unique hash serves as the identifier for your contract class within
Starknet. For example:

```bash
    Class hash declared: 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

You can think of this hash as the contract class’s _address._ 

If the contract class you’re attempting to declare already exists, it is
ok we can continue. You’ll receive a message like:

```bash
    Not declaring class as its already declared. Class hash:
    0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418
```

## Deploying Smart Contracts on Starknet

Deploying a smart contract on katana local devnet involves executing a command that requires two main components:

1.  The class hash of your smart contract.

2.  Any constructor arguments that the contract expects.

In our example, the constructor expects an _name_ felt252.

The command would look like this:

```bash
    starkli deploy \
        <CLASS_HASH> \
        <CONSTRUCTOR_INPUTS>
```

Here’s a specific example with an actual class hash and constructor
input:

```bash
    starkli deploy \
        0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 \
        0x737461726b6e6574626f6f6b
```

After executing the command, you should see output like the following:

```bash
    Deploying class 0x00bfb49ff80fd7ef5e84662d6d256d49daf75e0c5bd279b20a786f058ca21418 with salt 0x054645c0d1e766ddd927b3bde150c0a3dc0081af7fb82160c1582e05f6018794...
    The contract will be deployed at address 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44
    Contract deployment transaction: 0x00413d9638fecb75eb07593b5c76d13a68e4af7962c368c5c2e810e7a310d54c
    Contract deployed: 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44
```

## Interacting with the Starknet Contract

Starkli enables interaction with smart contracts via two primary
methods: `call` for read-only functions and `invoke` for write functions
that modify the state.

### Calling a Read Function

The `call` command enables you to query a smart contract function
without sending a transaction. For instance, to find out who the current
owner of the contract is, you can use the `get_name` function, which
requires no arguments.

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

Awesome, but wait, what is `0x0000000000000000000000000000000000000000737461726b6e6574626f6f6b` after all?
In Starknet we use felt252 data type to represent String values. We can decode the above output the see the String representation of felt252

```bash
starkli parse-cairo-string 0x737461726b6e6574626f6f6b
```
You will get the following output
```bash
starknetbook
```
## Invoking a Write Function

You can modify the contract’s state using the `invoke` command. For example, let’s change the field name of the storage with the
`set_name` function.

```bash
    starkli invoke \
        <CONTRACT_ADDRESS> \
        set_name \
        <felt252>
```

Replace `<CONTRACT_ADDRESS>` with the address of the contract and
`<felt252>` with the new value you want to setup to the `name` field. Let's say we want to store the `Omar` String value. To accomplish this we can decode this String value to felt252 value and then store it.

```bash
    starkli to-cairo-string Omar
```
You will get the following output
```bash
    0x4f6d6172
```
Then you invoke `set_name`
```bash
    starkli invoke 0x07cdd583619462c2b14532eddb2b169b8f8d94b63bfb5271dae6090f95147a44 set_name 0x4f6d6172
```

Congratulations! You’ve successfully deployed and interacted with a
Starknet contract.
