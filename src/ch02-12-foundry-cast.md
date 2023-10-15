# Foundry Cast: Interacting with Starknet

While Forge handles testing, Cast focuses on the Command Line Interface (CLI) for StarkNet. This straightforward tool, written in Rust, leverages StarkNet Rust for its operations and is also integrated with Scarb. This integration permits the specification of arguments in Scarb Toml, simplifying the overall process.

`sncast` is one of the best tools to help you interact with smart contracts as it eliminates alot of commands along the way if you were to just use `starkli`

Here, we are going to cover `sncast` extensively.


## Step 1: A sample smart contract

The code example below is taken from `starknet foundry`, [here](https://foundry-rs.github.io/starknet-foundry/testing/contracts.html)

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

Now we have a sample smart contract that we would like to interact with, but before that, its best that we test the code using `snforge` to make sure that on the code level, the contract works as expected.

Below are the tests

```rust

#[cfg(test)]
mod tests {
    use learnsncast::IHelloStarknetDispatcherTrait;
    use snforge_std::{declare, ContractClassTrait};
    use super::{IHelloStarknetDispatcher};

    #[test]
    fn call_and_invoke() {
        // First declare and deploy a contract
        let contract = declare('HelloStarknet');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

        // Create a Dispatcher object that will allow interacting with the deployed contract
        let dispatcher = IHelloStarknetDispatcher { contract_address };

        // Call a view function of the contract
        let balance = dispatcher.get_balance();
        assert(balance == 0, 'balance == 0');

        // Call a function of the contract
        // Here we mutate the state of the storage
        dispatcher.increase_balance(100);

        // Check that transaction took effect
        let balance = dispatcher.get_balance();
        assert(balance == 100, 'balance == 100');
    }
}
```

Copy the above snippets to your new scarb project into `lib.cairo` file if you don't have some contract at hand.

#### Testing

To run the tests, use the command below. To use `snforge` successfully, add it a dependency in `Scarb.toml` file just below the `starknet` dependency.

```txt
starknet = "2.1.0-rc2"
snforge_std = { git = "https://github.com/foundry-rs/starknet-foundry.git", tag = "v0.7.1" }
```


That is how your dependencies should look like.

Then run;

```sh
snforge
```

In this case you will notice we are using `snforge` for testing rather than `scarb test` command, reason being, our tests are configured to use some functions from `snforge_std`. Running `scarb test` will result to errors.

## Step 2: Starting up starknet devnet

We shall be using `starknet-devnet` in this testing, so if you are using `katana` things might go south. If you don't have `devnet` set, kindly follow [here](https://livesoftwaredeveloper.com/articles/9/how-to-set-up-starknet-devnet-and-frontend-for-smart-contract-development) to set it up quickly.

First, run `starknet devnet` with the command below:

```sh
starknet-devnet
```

If it is up correctly you shall get such a response: 


```sh
Predeployed FeeToken
Address: 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
Class Hash: 0x6a22bf63c7bc07effa39a25dfbd21523d211db0100a0afd054d172b81840eaf
Symbol: ETH

Account #0:
Address: 0x5fd5ef7f4b0e23a44a3670bd84f802f6cc37983c7766d562a8d4d72bb8360ba
Public key: 0x6bd5d1d46a7f603f1106824a3b276fdb52168f55b595ba7ff6b2ded390161cd
Private key: 0xc12927df61303656b3c066e65eda0acc

Account #1:
Address: 0xa0a0e72fd896289bfd8cc5f5533f059715ec8b47446ffeca8912d2da87dd36
Public key: 0x31ea12e860dc71fac28c4f0485d070334f7dcb21d38bca40650ad2cdf745fe3
Private key: 0x9059b5705e2cd296c71c7c248e301357

Account #2:
Address: 0x1a5d498e3b31163333054d70d4ac7e2863278b14c639d5b4f7eef5f76859371
Public key: 0x3d35a02907b00a724c471d6ec07cb4f533e70c2efe5e6f2e04a8fe0b85d18ae
Private key: 0xefdec2c89a30d129890f8b398187f23e

Account #3:
Address: 0x1f848a8d6465f93de4904efd4e78f1044fb952917b0308fe71ded6ca9d4ee6
Public key: 0x131a9b0d22ff22af61705ad9e5f2073fc4e038a18a75d061749f850504c08a6
Private key: 0x2421f890bcea0766b33d9735dab99953

Account #4:
Address: 0x72208d05c43677547663fd099c1cec695abac327daaa45dea2e449baf806755
Public key: 0x22aa53a1c9f8d97ccb8dc7cb11932f4abe09d2ca2f53fae6bbdf7bcdecd65fb
Private key: 0x790f46c5f17dbb188906bcd24611ca67

Account #5:
Address: 0x344ec5f5743f06abe2e261f5ad0f37e22231f822f70827958ee9bd435388366
Public key: 0x5930c681487150c851e4dc112f8b983412034e9be830a588e10fe1a93f5666c
Private key: 0xacaa430b735c41b1782e0051072d57d7

Account #6:
Address: 0x7093f1e5ce0f64a1918a742781f1438c0739ab7e0fe471985214d9bde7aed27
Public key: 0x2710678b257b83c64fb777a5a08fcab848ecdd41c5c25e25aea54571c981d3
Private key: 0x49d1b0e55d1e2183977bc6561e58c0b3

Account #7:
Address: 0x234d58fcafea2d95892f84e740540f243d421a7782ebcb374d69613c031125c
Public key: 0x49bd622af0755cfeee48e480e02c10adc41f80aa95d11b1f42c892a5a19c3b1
Private key: 0xdee5b1aea25ad7395fd3d07c6e146678

Account #8:
Address: 0x6ed3739962aec0188283e1528f2b060ea070adaee0bebe7d5239a93622bd0c9
Public key: 0x49056273c66679def07b022d50d56d70e83089c89805fdcc7148b50d464f71
Private key: 0xcaa7374c46b51d1c4d08925cf0dc161b

Account #9:
Address: 0x7f44bf70f9557e5b04bbb389d434fbb7c4f30f48a2fbae65eb667a8d8d0e5b2
Public key: 0x40ea5bf16e1e60d84e21a1505b7bb525d5a927035cf773d849023323c28f19
Private key: 0x7a96713b5b2e9ae610d313e477f15c7f

Initial balance of each account: 1000000000000000000000 WEI
Seed to replicate this account sequence: 3524316090
WARNING: Use these accounts and their keys ONLY for local testing. DO NOT use them on mainnet or other live networks because you will LOSE FUNDS.

Predeclared Starknet CLI account: 
Class hash: 0x195c984a44ae2b8ad5d49f48c0aaa0132c42521dcfc66513530203feca48dd6

Predeployed UDC
Address: 0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf
Class Hash: 0x7b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69

 * Listening on http://127.0.0.1:5050/ (Press CTRL+C to quit)
```


So far so good, we have been able to write a smart contract, test it and start starknet devnet successfully.


## Introduction to `sncast`

Lets have a brief introduction to `sncast`.

As a tool, it has a number of functions and the fastest way to see all the functions it can do is to run the command below.


```sh
sncast --help
```

The result should look like this

```sh
Cast - a Starknet Foundry CLI

Usage: sncast [OPTIONS] <COMMAND>

Commands:
  declare    Declare a contract
  deploy     Deploy a contract
  call       Call a contract
  invoke     Invoke a contract
  multicall  Execute multiple calls
  account    Create and deploy an account
  help       Print this message or the help of the given subcommand(s)

Options:
  -p, --profile <PROFILE>
          Profile name in Scarb.toml config file
  -s, --path-to-scarb-toml <PATH_TO_SCARB_TOML>
          Path to Scarb.toml that is to be used; overrides default behaviour of searching for scarb.toml in current or parent directories
  -u, --url <RPC_URL>
          RPC provider url address; overrides url from Scarb.toml
  -a, --account <ACCOUNT>
          Account to be used for contract declaration; When using keystore (`--keystore`), this should be a path to account file When using accounts file, this should be an account name
  -f, --accounts-file <ACCOUNTS_FILE_PATH>
          Path to the file holding accounts info
  -k, --keystore <KEYSTORE>
          Path to keystore file; if specified, --account should be a path to starkli JSON account file
  -i, --int-format
          If passed, values will be displayed as integers, otherwise as hexes
  -j, --json
          If passed, output will be displayed in json format
  -w, --wait
          If passed, command will wait until transaction is accepted or rejected
  -h, --help
          Print help
  -V, --version
          Print version
```

Given the above result, you can notice that there are `commands` and `options`. And for thos options, you have the `long` form and the `short` form. 

> N/B: **Learn through the options both long and short forms as we will be using the long form most of the time to avoid having the 'Math simples' in our commands (complex commands).**

Also, you can learn more about the specific command ie the `account` command how it works by simply:

```sh
sncast account help
```

This will give you

```sh
Create and deploy an account

Usage: sncast account <COMMAND>

Commands:
  add     Add an account to the accounts file
  create  Create an account with all important secrets
  deploy  Deploy an account to the Starknet
  help    Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help
```

You will learn that it gives you more information. ***You can say you have docs on the fly***

Now you have more `subcommands` under account like `add, create and deploy` how can you learn more? That is easier than never before, just run

```sh
sncast account add --help
```

You will get such a result

```sh
Add an account to the accounts file

Usage: sncast account add [OPTIONS] --name <NAME> --address <ADDRESS> --private-key <PRIVATE_KEY>

Options:
  -n, --name <NAME>                Name of the account to be added
  -a, --address <ADDRESS>          Address of the account
  -c, --class-hash <CLASS_HASH>    Class hash of the account
  -d, --deployed                   Account deployment status If not passed, sncast will check whether the account is deployed or not
      --private-key <PRIVATE_KEY>  Account private key
      --public-key <PUBLIC_KEY>    Account public key
  -s, --salt <SALT>                Salt for the address
      --add-profile                If passed, a profile with corresponding data will be created in Scarb.toml
  -h, --help                       Print help
```

> From the above, the more you go through each command and subcommand, the more the information you have. So why not use that to your advantage?

## Step 3: Using `sncast` to add, create & deploy new accounts

Now we go to the task of the day, how do we use `sncast` to interact with the contract?

You will notice that both `starknet devnet` always provides you with some accounts. This accounts are called `predeployed accounts`. `Predeployed accounts` are those accounts that are already added to the node, fully funded with test tokens (for use as gas fees and other kind of transactions) and you can directly use them to interact with any `contract` deployed on the `local node` ie starknet devnet.

> **But first things first, how can you use the predeployed accounts?** You are right, here we go

### Using a preexisting account

When we want to use a preexisting account to deploy and interact with the smart contract, we simply use the `account add` command. This is how we use it.

```sh
Usage: sncast [SNCAST_MAIN_OPTIONS] account add [SUBCOMMAND_OPTIONS] --name <NAME> --address <ADDRESS> --private-key <PRIVATE_KEY>
```

You will notice that we have already seen all the options that we may pass in to the `add` command such as `--name, --address, --class-hash, --deployed, --private-key, --public-key, --salt, --add-profile, --help`. In this case, we are not going to use all the options, but some as below.

So pick an account from `starknet-devnet` server that you will add, for my case, I choose account `#0`

Then run the command below

```sh
sncast --url http://localhost:5050/rpc account add  --name account1 --address 0x5fd5ef7f4b0e23a44a3670bd84f802f6cc37983c7766d562a8d4d72bb8360ba --private-key 0xc12927df61303656b3c066e65eda0acc --add-profile
```

From the above, take this into note:

1. `--name` - This is required
2. `--address`- The account address is required
3. `--private-key` - The account private key is required
4. `--add-profile` - Optional but very critical. The reason as to why this is critical, is because, this option allows sncast to add the account into you `Scarb.toml` file, this way, you can have several accounts ie transacting between each other since when interacting with you smart contract using sncast, you can pass in the profile you want to use to make the call/invoke.

We can say that we have an account to use. But lets learn how to add a new one first.

### Creating a new account and deploying it to starknet devnet

To create an account, it has more steps as compared to using an existing account but it is worth knowing about it. In this case, we shall break it into 3 easy steps:

1. Creating the account

```sh
sncast account create --help
```

The above command will give you the `create` options as `--name, --salt, --class-hash and --add-profile`

So lets use the command and options to create a new account

```sh
sncast --url http://localhost:5050/rpc account create --name new_account --class-hash  0x195c984a44ae2b8ad5d49f48c0aaa0132c42521dcfc66513530203feca48dd6 --add-profile
```

I have a question, where do you get the `--class-hash from`? Right question, if you look at the output you got when running the `starknet-devnet` command, you will see something like **`Predeclared Starknet CLI account`** and below `Class hash` as below. Use that: 

```sh
Predeclared Starknet CLI account: 
Class hash: 0x195c984a44ae2b8ad5d49f48c0aaa0132c42521dcfc66513530203feca48dd6
```

You will get this result:

```sh
Account successfully created. Prefund generated address with at least 432300000000 tokens. It is good to send more in the case of higher demand, max_fee * 2 = 864600000000
command: account create
add_profile: Profile successfully added to Scarb.toml
address: 0x6e1b440ff100036b1c31c9c1633041e253e2e373cc9becfa7a7f5955110eadf
max_fee: 0x64a7168300
```

2. Adding some funds to the account 

To add some funds to the new address, simply run the command below replacing the address with your new address.

```curl
    curl -d '{"amount":8646000000000, "address":"0x6e1b440ff100036b1c31c9c1633041e253e2e373cc9becfa7a7f5955110eadf"}' -H "Content-Type: application/json" -X POST http://127.0.0.1:5050/mint
```

- The **amount** you pass in is already given by the previous command

Result:

```sh
{"new_balance":8646000000000,"tx_hash":"0x48152205d65778d2c383e7170b56cb6a2ceb3aab8a51b83974aa1ca521cb919","unit":"wei"}
```

This will show that your new address has been funded.

3. Deploying the account

Finally, you need to deploy your account to `starknet devnet` local node so that it can be known by the chain that it is a registered account that one can interact with.

To deploy, at `--name` you need to pass in the name of the account you created, just check in scarb toml file, and `--max-fee` is given when you ran the `account create` command

```sh
sncast --url http://localhost:5050/rpc account deploy --name new_account --max-fee 0x64a7168300 
```

Successful result:

```sh
command: account deploy
transaction_hash: 0x6cad0cfad468bc6ba6fe7bd726e7915483086eeaae8f8fbcadd6cb4ea358224
```

On a successful result, you get a transaction hash back. If it fails, just recheck your steps.

4. Setting up a default profile 

Did you know you can set default profile for your `sncast` calls? It is extremely easy, go to `Scarb.toml` file and update the profile you want to be default ie `new_account`, you will see it is written like this `[tool.sncast.new_account]` deleting `new_account` from this line to be with `[tool.sncast]`, the profile will be considered default. Hence, you can just make calls without specifying the profile unless you want to use another one.


## Step 4: Declaring and Deploying our contract

We have successfully reached step 4 where we learn how to use `sncast` to declare and deploy our smart contracts.

### Declaring the contract.

At this step, we start by building our contract. Remember, we wrote and tested the contract at #Step 1.

We shall also break this to 2 step, `building & declaring`

1. To build the contract, run the following command:

```sh
scarb build
```

Since you were able to run tests correctly using `snforge`, `scarb build` will run without problems. Once scarb build runs, you will see a new folder called `target` in t the root of your project.

In the folder, you should see a `dev` folder with `3 files`, that is `*.casm.json, *.sierra.json & *.starknet_artifacts.json`.

In an event you don't see the three files, you are just missing some configurations in your `Scarb.toml` file. so just add this lines after `dependencies` in your `Scarb.toml` file

```txt
[[target.starknet-contract]]
sierra = true
casm = true
```

So this will tell the compiler to compile and output both `sierra` and `casm`


2. Now we have something to declare

If you recall well, we had already seem some of the commands provided by `sncast`, quickly get to them by 

```sh
sncast --help
```

Amont them is declare. So if you run 

```sh
sncast declare help
```

You will get an error with the usage;

```sh
Usage: sncast declare [OPTIONS] --contract-name <CONTRACT>
```

So we just run; Remember to add `--url` option to the call

```sh
sncast --profile account1 declare --contract-name HelloStarknet
```

You will notice something else here, we have dropped the `--url` sncast option here, do you know why? Here is the reason. We are now passing in `--profile` and we have used `account1` in this case, if you recall, in the first parts of this document, we covered how to add or create new accounts. We added `account1` and created `new_account`. You could use either of them and everything will work out well as expected.

> Hint: Did you know you can set default profile for your `sncast` calls? It is extremely easy, go to `Scarb.toml` file and update the profile you want to be default ie `new_account`, you will see it is written like this `[tool.sncast.new_account]` deleting `new_account` from this line to be with `[tool.sncast]`, the profile will be considered default. Hence, you can just make calls without specifying the profile unless you want to use another one.
>> So your call could have been
>>> `sncast declare --contract-name HelloStarknet`
>>>
>>> And remain to be a happy developer!

Output:

```txt
command: declare
class_hash: 0x20fe30f3990ecfb673d723944f28202db5acf107a359bfeef861b578c00f2a0
transaction_hash: 0x7fbdcca80e7c666f1b5c4522fdad986ad3b731107001f7d8df5f3cb1ce8fd11
```

**Take note** of the `class hash`, we shall use it in the next phase.

> **What if I get this error:** *Class hash already declared?* Just proceed with the next step since you can't redeclare a declared contract. Use the `class hash` in the next step of deploying.


### Deploying the contract

Since we have successfully declare the contract and gotten a `class hash` at the result, the next phase will be to deploy the contract. Its just easy, just run the command below replacing it with your `<class-hash>`

```sh
sncast deploy --class-hash 0x20fe30f3990ecfb673d723944f28202db5acf107a359bfeef861b578c00f2a0
```

Quick and easy, you should get:

```sh
command: deploy
contract_address: 0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9
transaction_hash: 0x6bdf6cfc8080336d9315f9b4df7bca5fb90135817aba4412ade6f942e9dbe60
```

Possible errors:

1. **Error: RPC url not passed nor found in Scarb.toml** - This means you have not set a default profile in your `Scarb.toml` file, solution, either add `--profile` option with the profile name you want to use according to those you created, or set a default profile as illustrated above at `Declaring the contract -> 2: Hint` or according to `Adding, creating and deploying account section part 4`

> Hooray! You have successfully deployed your contract using `sncast`! Wait a moment, what next? **Just Interact with it!**


## How to interact with the contract

At this step, we shall learn how to interact with the contract in order to be able to write and read the information stored.

### Writing to the contract/Invoking Functions

In this case, when writing to the contract, we `invoke` it. Since the contract functions are not so complicated, we shall quickly write and see how it works.

if you run the command below, you get

```sh
Usage: sncast invoke [OPTIONS] --contract-address <CONTRACT_ADDRESS> --function <FUNCTION>

Options:
  -a, --contract-address <CONTRACT_ADDRESS>
          Address of contract to invoke
  -f, --function <FUNCTION>
          Name of the function to invoke
  -c, --calldata <CALLDATA>
          Calldata for the invoked function
  -m, --max-fee <MAX_FEE>
          Max fee for the transaction. If not provided, max fee will be automatically estimated
  -h, --help
          Print help
```

We are going to invoke the `increase_balance` method, using the above given format since we have now set a `default profile`.

You will notice, I have not used all the `options` given above below, some times you may need to add the `--max-fee` to make some of your function invocations work.


```sh
sncast invoke --contract-address 0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9 --function increase_balance --calldata 4
```

On a successful result, you will get a transaction hash back.

```sh
command: invoke
transaction_hash: 0x33248e393d985a28826e9fbb143d2cf0bb3342f1da85483cf253b450973b638
```

### Reading from the contract/Calling Functions

Finally, we have been able to write how can we read?

So, when getting(calling) data from the contract, we use `sncast call` command, lets see how it looks like

```sh
sncast call --help
```

With the above command, you get this:

```sh
Usage: sncast call [OPTIONS] --contract-address <CONTRACT_ADDRESS> --function <FUNCTION>

Options:
  -a, --contract-address <CONTRACT_ADDRESS>
          Address of the called contract (hex)
  -f, --function <FUNCTION>
          Name of the contract function to be called
  -c, --calldata <CALLDATA>
          Arguments of the called function (list of hex)
  -b, --block-id <BLOCK_ID>
          Block identifier on which call should be performed. Possible values: pending, latest, block hash (0x prefixed string) and block number (u64) [default: pending]
  -h, --help
          Print help
```

How to use it now:

```sh
sncast call --contract-address 0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9 --function get_balance
```

In the above calll, we also did not use all the options, but you might be forced to add some like `--calldata` to make your function call, the calldata should be a `list or array` when calling using it.

The result would be:

```sh
command: call
response: [0x4]
```

Meaning, we successfully executed a Read and a Write to our contract!!


So far so good, `one command` to go, that is a `multicall` command.


### sncast Multicall

To perform a multicall, ie in our case here, we can do a write and a read at the same time. Lets see what it takes to make a successfull multicall



```sh
sncast multicall --help
```

This is what we get

```sh
Execute multiple calls

Usage: sncast multicall <COMMAND>

Commands:
  run   Execute a multicall from a .toml file
  new   Generate a template for the multicall .toml file
  help  Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help
```

You can learn more about the subcommands there but lets start by calling the `new` subcommand.

```sh
sncast multicall new --help
```

You get

```sh
Generate a template for the multicall .toml file

Usage: sncast multicall new [OPTIONS]

Options:
  -p, --output-path <OUTPUT_PATH>  Output path to the file where the template is going to be saved
  -o, --overwrite                  If the file specified in output-path exists, this flag decides if it is going to be overwritten
  -h, --help                       Print help
```

Running it like:

```sh
sncast multicall new --output-path ./call1.toml --overwrite
```

If you run the above command, you will get a template like this one here

```sh
command: multicall new
content: [[call]]
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

path: ./call1.toml
```

We update `call1.toml` to this. 

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

In multicalls, we can only do `2 actions` that is' `deploy` & `invoke` call types, about their details, look at how to perform them at the first output.

> Hint: The inputs here are in `hexadecimal` don't miss that one out, otherwise, numbers will be problematic to you. For strings, **all is well.**

We need to find a way of executing the multicall, so lets get some help here

```sh
sncast mutlicall run --help
```

Output: 

```sh
Execute a multicall from a .toml file

Usage: sncast multicall run [OPTIONS] --path <PATH>

Options:
  -p, --path <PATH>        Path to the toml file with declared operations
  -m, --max-fee <MAX_FEE>  Max fee for the transaction. If not provided, max fee will be automatically estimated
  -h, --help  
```

We make the call

```sh
sncast multicall run --path call1.toml
```

Successful call:

```sh
command: multicall run
transaction_hash: 0x1ae4122266f99a5ede495ff50fdbd927c31db27ec601eb9f3eaa938273d4d61
```

So we expect `0x9`, lets see

```sh
sncast call --contract-address 0x7e3fc427c2f085e7f8adeaec7501cacdfe6b350daef18d76755ddaa68b3b3f9 --function get_balance
```

Result:

```sh
command: call
response: [0x9]
```

We get `0x9` as expected.

## In Conclusion

This comprehensive guide explores the usage of `sncast`, a powerful command-line tool for interacting with StarkNet smart contracts. `sncast` is designed to simplify the process of interacting with smart contracts written for the StarkNet platform, and it provides an array of features to streamline contract deployment, function invocation, and function calling.

