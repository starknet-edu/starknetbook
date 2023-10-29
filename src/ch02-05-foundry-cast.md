# Foundry Cast: Starknet CLI Interaction

[Starknet Foundry](https://github.com/foundry-rs/starknet-foundry) is a tool designed for testing and developing Starknet contracts. It is an adaptation of the Ethereum Foundry for Starknet, aiming to expedite the development process.

The project consists of two primary components:

- **Forge**: A testing tool specifically for Cairo contracts. This tool acts as a test runner and boasts features designed to enhance your testing process. Tests are written directly in Cairo, eliminating the need for other programming languages. Additionally, the Forge implementation uses Rust, mirroring Ethereum Foundry's choice of language.
- **Cast**: This serves as a DevOps tool for Starknet, initially supporting a series of commands to interface with Starknet. In the future, Cast aims to offer deployment scripts for contracts and other DevOps functions.

## Cast

Cast provides the Command Line Interface (CLI) for starknet, while Forge addresses testing. Written in Rust, Cast utilizes starknet Rust and integrates with Scarb. This integration allows for argument specification in `Scarb.toml`, streamlining the process.

`sncast` simplifies interaction with smart contracts, reducing the number of necessary commands compared to using `starkli` alone.

In this section, we'll delve into `sncast`.

## Step 1: Sample Smart Contract

The following code sample is sourced from `starknet foundry`. You can find the original [here](https://foundry-rs.github.io/starknet-foundry/testing/contracts.html).

```rust
#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[external(v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }
        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
```

Before interacting with this sample smart contract, it's crucial to test its functionality using **`snforge`** to ensure its integrity.

Here are the associated tests:

```rust
#[cfg(test)]
mod tests {
    use learnsncast::IHelloStarknetDispatcherTrait;
    use snforge_std::{declare, ContractClassTrait};
    use super::{IHelloStarknetDispatcher};

    #[test]
    fn call_and_invoke() {
        // Declare and deploy a contract
        let contract = declare('HelloStarknet');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

        // Create a Dispatcher object for interaction with the deployed contract
        let dispatcher = IHelloStarknetDispatcher { contract_address };

        // Query a contract view function
        let balance = dispatcher.get_balance();
        assert(balance == 0, 'balance == 0');

        // Invoke a contract function to mutate state
        dispatcher.increase_balance(100);

        // Verify the transaction's effect
        let balance = dispatcher.get_balance();
        assert(balance == 100, 'balance == 100');
    }
}
```

If needed, copy the provided code snippets into the `lib.cairo` file of your new scarb project.

To execute tests, follow the steps below:

1. Ensure `snforge` is listed as a dependency in your `Scarb.toml` file, positioned beneath the `starknet` dependency. Your dependencies section should appear as (make sure to use the latest version of `snforge` and `starknet`):

```txt
starknet = "2.1.0-rc2"
snforge_std = { git = "https://github.com/foundry-rs/starknet-foundry.git", tag = "v0.7.1" }
```

2. Run the command:

```sh
snforge
```

Note: Use `snforge` for testing instead of the `scarb test` command. The tests are set up to utilize functions from `snforge_std`. Running `scarb test` would cause errors.

## Step 2: Setting Up Starknet Devnet

For this guide, the focus is on using `starknet-devnet`. If you've been using `katana`, please be cautious as there might be inconsistencies. If you haven't configured `devnet`, consider following this [guide](https://livesoftwaredeveloper.com/articles/9/how-to-set-up-starknet-devnet-and-frontend-for-smart-contract-development) for a quick setup.

To launch `starknet devnet`, use the command:

```sh
starknet-devnet
```

Upon successful startup, you should receive a response similar to:

```sh
Predeployed FeeToken
Address: 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
Class Hash: 0x6a22bf63c7bc07effa39a25dfbd21523d211db0100a0afd054d172b81840eaf
Symbol: ETH

Account #0:
Address: 0x5fd5ef7f4b0e23a44a3670bd84f802f6cc37983c7766d562a8d4d72bb8360ba
Public key: 0x6bd5d1d46a7f603f1106824a3b276fdb52168f55b595ba7ff6b2ded390161cd
Private key: 0xc12927df61303656b3c066e65eda0acc
...
...
...
 * Listening on http://127.0.0.1:5050/ (Press CTRL+C to quit)
```

(Note: The abbreviated ... is just a placeholder for the detailed response. In your actual output, you'll see the full details.)

Now, you have written a smart contract, tested it, and successfully initiated starknet devnet.

## Dive into `sncast`

Let's unpack **`sncast`**.

As a multifunctional tool, the quickest way to discover its capabilities is via the command:

```sh
sncast --help
```

In the output, you'll notice distinct categories: `commands` and `options`. Each option offers both a concise (`short`) and a descriptive (`long`) variant.

> Tip: While both option variants are useful, we'll prioritize the long form in this guide. This choice aids clarity, especially when constructing intricate commands.

Delving deeper, to understand specific commands such as **`account`**, you can run:

```sh
sncast account help
```

Each account subcommand like `add`, `create`, and `deploy` can be further explored. For instance:

```sh
sncast account add --help
```

The layered structure of `sncast` provides a wealth of information right at your fingertips. It's like having dynamic documentation. Make it a habit to explore, and you'll always stay informed.

## Step 3: Using `sncast` for Account Management

Let's delve into how to use `sncast` for interacting with the contract.

By default, `starknet devnet` offers several `predeployed accounts`. These are accounts already registered with the node, loaded with test tokens (for gas fees and various transactions). Developers can use them directly with any `contract` on the `local node` (i.e., starknet devnet).

### How to Utilize Predeployed Accounts

To employ a predeployed account with the smart contract, execute the `account add` command as shown below:

```sh
sncast [SNCAST_MAIN_OPTIONS] account add [SUBCOMMAND_OPTIONS] --name <NAME> --address <ADDRESS> --private-key <PRIVATE_KEY>
```

Although several options can accompany the `add` command (e.g., `--name, --address, --class-hash, --deployed, --private-key, --public-key, --salt, --add-profile`), we'll focus on a select few for this illustration.

Choose an account from the **`starknet-devnet`**, for demonstration, we'll select account **`#0`**, and execute:

```sh
sncast --url http://localhost:5050/rpc account add  --name account1 --address 0x5f...60ba --private-key 0xc...0acc --add-profile
```

Points to remember:

1. **`-name`** - Mandatory field.
2. **`-address`** - Necessary account address.
3. **`-private-key`** - Private key of the account.
4. **`-add-profile`** - Though optional, it's pivotal. By enabling **`sncast`** to include the account in your **`Scarb.toml`** file, you can manage multiple accounts, facilitating transactions among them when working with your smart contract using sncast.

Now that we have familiarized ourselves with using a predeployed account, let's proceed to adding a new account.

### Creating and Deploying a New Account to Starknet Devnet

Creating a new account involves a few more steps than using an existing one, but it's straightforward when broken down. Here are the steps:

1. Account Creation

To create a new account, use (you can use `sncast account create --help` to see the available options):

```sh
sncast --url http://localhost:5050/rpc account create --name new_account --class-hash  0x19...8dd6 --add-profile
```

Wondering where the `--class-hash` comes from? It's visible in the output from the `starknet-devnet` command under the Predeclared Starknet CLI account section. For example:

```sh
Predeclared Starknet CLI account:
Class hash: 0x195c984a44ae2b8ad5d49f48c0aaa0132c42521dcfc66513530203feca48dd6
```

2. Funding the Account

To fund the new account, replace the address in the following command with your new one:

```sh
curl -d '{"amount":8646000000000, "address":"0x6e...eadf"}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5050/mint
```

Note: The **amount** is specified in the previous command's output.

A successful fund addition will return:

```sh
{"new_balance":8646000000000,"tx_hash":"0x48...1919","unit":"wei"}
```

3. Account Deployment

Deploy the account to the **`starknet devnet`** local node to register it with the chain:

```sh
sncast --url http://localhost:5050/rpc account deploy --name new_account --max-fee 0x64a7168300
```

A successful deployment provides a transaction hash. If it doesn't work, revisit your previous steps.

4. Setting a Default Profile

You can define a default profile for your **`sncast`** actions. To set one, edit the **`Scarb.toml`** file. To make the **`new_account`** the default profile, find the section **`[tool.sncast.new_account]`** and change it to **`[tool.sncast]`**. This means **`sncast`** will default to using this profile unless instructed otherwise.

## Step 4: Declaring and Deploying our Contract

By now, we've arrived at the crucial step of using `sncast` to declare and deploy our smart contracts.

### Declaring the Contract

Recall that we drafted and tested the contract in **Step 1**. Here, we'll focus on two actions: building and declaring.

1. **Building the Contract**

Execute the following to build the contract:

```sh
scarb build
```

If you've successfully run tests using **`snforge`**, the **`scarb build`** should operate without issues. After the build completes, a new **`target`** folder will appear at the root of your project.

Within the **`target`** folder, you'll find a **`dev`** sub-folder containing three files: **`*.casm.json`**, **`*.sierra.json`**, and **`*.starknet_artifacts.json`**.

If these files aren't present, it's likely due to missing configurations in your **`Scarb.toml`** file. To address this, append the following lines after **`dependencies`**:

```toml
[[target.starknet-contract]]
sierra = true
casm = true
```

These lines instruct the compiler to produce both `sierra` and `casm` outputs.

2. Declaring the Contract

We will use the `sncast declare` command to declare the contract. Here's the format:

```shell
sncast declare [OPTIONS] --contract-name <CONTRACT>
```

Given this, the correct command would be:

```
sncast --profile account1 declare --contract-name HelloStarknet
```

Note that we've omitted the **`--url`** option. Why? When using **`--profile`**, as seen here with **`account1`**, it's not necessary. Remember, earlier in this guide, we discussed adding and creating new accounts. You can use either **`account1`** or **`new_account`** and achieve the desired result.

> Hint: You can define a default profile for sncast actions. Modify the `Scarb.toml` file to set a default. For example, to make `new_account` the default, find `[tool.sncast.new_account]` and change it to `[tool.sncast]`. Then, there's no need to specify the profile for each call, simplifying your command to:

```sh
sncast declare --contract-name HelloStarknet
```

The output will resemble:

```sh
command: declare
class_hash: 0x20fe30f3990ecfb673d723944f28202db5acf107a359bfeef861b578c00f2a0
transaction_hash: 0x7fbdcca80e7c666f1b5c4522fdad986ad3b731107001f7d8df5f3cb1ce8fd11
```

Make sure to note the \*\*`class hash` as it will be essential in the subsequent step.

> Note: If you encounter an error stating Class hash already declared, simply move to the next step. Redeclaring an already-declared contract isn't permissible. Use the mentioned class hash for deployment.

### Deploying the Contract

With the contract successfully declared and a `class hash` obtained, we're ready to proceed to contract deployment. This step is straightforward. Replace `<class-hash>` in the command below with your obtained class hash:

```sh
sncast deploy --class-hash 0x20fe30f3990ecfb673d723944f28202db5acf107a359bfeef861b578c00f2a0
```

Executing this will likely yield:

```sh
command: deploy
contract_address: 0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9
transaction_hash: 0x6bdf6cfc8080336d9315f9b4df7bca5fb90135817aba4412ade6f942e9dbe60
```

However, you may encounter some issues, such as:

**Error: RPC url not passed nor found in Scarb.toml**. This indicates the absence of a default profile in the **`Scarb.toml`** file. To remedy this:

- Add the **`-profile`** option, followed by the desired profile name, as per the ones you've established.
- Alternatively, set a default profile as previously discussed in the "Declaring the Contract" section under "Hint" or as detailed in the "Adding, Creating, and Deploying Account" subsection.

You've successfully deployed your contract with `sncast`! Now, let's explore how to interact with it.

## Interacting with the Contract

This section explains how to read and write information to the contract.

### Invoking Contract Functions

To write to the contract, invoke its functions. Here's a basic overview of the command:

```sh
Usage: sncast invoke [OPTIONS] --contract-address <CONTRACT_ADDRESS> --function <FUNCTION>

Options:
  -a, --contract-address <CONTRACT_ADDRESS>  Address of the contract
  -f, --function <FUNCTION>                  Name of the function
  -c, --calldata <CALLDATA>                  Data for the function
  -m, --max-fee <MAX_FEE>                    Maximum transaction fee (auto-estimated if absent)
  -h, --help                                 Show help
```

To demonstrate, let's invoke the `increase_balance` method of our smart contract with a preset default profile. Not every option is always necessary; for instance, sometimes, including the `--max-fee` might be essential.

```sh
sncast invoke --contract-address 0x7e...b3f9 --function increase_balance --calldata 4
```

If successful, you'll receive a transaction hash like this:

```sh
command: invoke
transaction_hash: 0x33248e393d985a28826e9fbb143d2cf0bb3342f1da85483cf253b450973b638
```

### Reading from the Contract

To retrieve data from the contract, use the `sncast call` command. Here's how it works:

```sh
sncast call --help
```

Executing the command displays:

```sh
Usage: sncast call [OPTIONS] --contract-address <CONTRACT_ADDRESS> --function <FUNCTION>

Options:
  -a, --contract-address <CONTRACT_ADDRESS>  Address of the contract (hex format)
  -f, --function <FUNCTION>                  Name of the function to call
  -c, --calldata <CALLDATA>                  Function arguments (list of hex values)
  -b, --block-id <BLOCK_ID>                  Block identifier for the call. Accepts: pending, latest, block hash (with a 0x prefix), or block number (u64). Default is 'pending'.
  -h, --help                                 Show help
```

For instance:

```sh
sncast call --contract-address 0x7e...b3f9 --function get_balance
```

While not all options are used in the example, you might need to include options like `--calldata`, specifying it as a list or array.

A successful call returns:

```sh
command: call
response: [0x4]
```

This indicates successful read and write operations on the contract.

### sncast Multicall Guide

Use `sncast multicall` to simultaneously read and write to the contract. Let's explore how to effectively use this feature.

First, understand its basic usage:

```sh
sncast multicall --help
```

This command displays:

```sh
Execute multiple calls

Usage: sncast multicall <COMMAND>

Commands:
  run   Execute multicall using a .toml file
  new   Create a template for the multicall .toml file
  help  Display help for subcommand(s)

Options:
  -h, --help  Show help
```

To delve deeper, initiate the `new` subcommand:

```sh
Generate a template for the multicall .toml file

Usage: sncast multicall new [OPTIONS]

Options:
  -p, --output-path <OUTPUT_PATH>  File path for saving the template
  -o, --overwrite                  Overwrite file if it already exists at specified path
  -h, --help                       Display help
```

Generate a template called `call1.toml`:

```sh
sncast multicall new --output-path ./call1.toml --overwrite
```

This provides a basic template:

```toml
[[call]]
call_type = "deploy"
class_hash = ""
inputs = []
id = ""
unique = false

[[call]]
call_type = "invoke"
contract_address = ""
function = ""
inputs = []
```

Modify `call1.toml` to:

```toml
[[call]]
call_type = "invoke"
contract_address = "0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9"
function = "increase_balance"
inputs = ['0x4']

[[call]]
call_type = "invoke"
contract_address = "0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9"
function = "increase_balance"
inputs = ['0x1']
```

In multicalls, only `deploy` and `invoke` actions are allowed. For a detailed guide on these, refer to the earlier section.

> Note: Ensure inputs are in hexadecimal format. Strings work normally, but numbers require this format for accurate results.

To execute the multicall, use:

```sh
sncast multicall run --path call1.toml
```

Upon success:

```sh
command: multicall run
transaction_hash: 0x1ae4122266f99a5ede495ff50fdbd927c31db27ec601eb9f3eaa938273d4d61
```

Check the balance:

```sh
sncast call --contract-address 0x7e...b3f9 --function get_balance
```

The response:

```shell
command: call
response: [0x9]
```

The expected balance, `0x9`, is confirmed.

## Conclusion

This guide detailed the use of `sncast`, a robust command-line tool tailored for starknet smart contracts. Its purpose is to make interactions with starknet's smart contracts effortless. Key functionalities include contract deployment, function invocation, and function calling.
