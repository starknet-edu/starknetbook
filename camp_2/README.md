<div align="center">
    <h1>Camp 2: BUIDL and tooling</h1>

|Presentation|Video|Try what you learned
|:----:|:----:|:----:|
|-|-|Test your debugging capabilities with [starknet-debug](https://github.com/starknet-edu/starknet-debug)|

</div>

### Topics

<ol>
    <li><a href="#devnet">Devnet</a></a>
    <li><a href="#protostar">Protostar</a></a>
    <li><a href="#hardhat">Hardhat</a></a>
    <li><a href="#nodes">Nodes</a></a>
    <li><a href="#testing">Testing</a></a>
    <li><a href="#libraries">Libraries</a></a>
</ol>

While this section is being built, we recommend reading the video session for this camp and the [community resources page](https://github.com/gakonst/awesome-starknet).

In this camp, we will learn how to use some of the existing toolings for Cairo and StarkNet. Please notice there is more tooling being developed each month; here, we will cover just a part.

We are currently able to operate with the StarkNet Alpha. The recommended steps for deploying contracts are:

1. Unit tests - You can use Protostar, Nile, or starknet.py.
2. Devnet - Deploy in the [Shard Lab’s](https://github.com/Shard-Labs/starknet-devnet) `starknet-devnet`.
3. Testnet - Deploy to the Goerli, `alpha-goerli`, or Goerli 2. You can use Protostar, Nile, Hardhat, and more.
4. Mainnet - Deploy to Alpha StarkNet, `alpha-mainnnet`. Similar to the testnet.


<hr>


<h2 align="center" id="devnet"><a href="https://shard-labs.github.io/starknet-devnet">Devnet</a></h2>

Transactions on the testnet take time to complete, so it's best to start developing and testing locally. We will use the [devnet developed by Shard Labs](https://github.com/Shard-Labs/starknet-devnet). We can think of this step as an equivalent of Ganache. That is, it emulates the testnet (alpha goerli) of StarkNet. 

Install using:

```Bash
pip install starknet-devnet`
```

Restart your terminal and run `starknet-devnet --version` to check that the installation was successful. Check that you have [the most up-to-date version](https://github.com/Shard-Labs/starknet-devnet/releases). If you don't have it, run `pip install --upgrade starknet-devnet`. [Here is the documentation](https://shard-labs.github.io/starknet-devnet/docs/intro).

Initialize the devnet in a separate shell (or tab) with `starknet-devnet --accounts 3 --gas-price 250 --seed 0 --port 5000`. You will get the following:

```Bash
Account #0
Address: 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a
Public key: 0x7e52885445756b313ea16849145363ccb73fb4ab0440dbac333cf9d13de82b9
Private key: 0xe3e70682c2094cac629f6fbed82c07cd

Account #1
Address: 0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79
Public key: 0x175666e92f540a19eb24fa299ce04c23f3b75cb2d2332e3ff2021bf6d615fa5
Private key: 0xf728b4fa42485e3a0a5d2f346baa9455

Account #2
Address: 0x7447084f620ba316a42c72ca5b8eefb3fe9a05ca5fe6430c65a69ecc4349b3b
Public key: 0x58100ffde2b924de16520921f6bfe13a8bdde9d296a338b9469dd7370ade6cb
Private key: 0xeb1167b367a9c3787c65c1e582e2e662

Initial balance of each account: 1000000000000000000000 WEI
Seed to replicate this account sequence: 0
WARNING: Use these accounts and their keys ONLY for local testing. DO NOT use them on the mainnet or live networks because you will LOSE FUNDS.

 * Listening on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 ```

We can run `curl http://127.0.0.1:5000/is_alive` to check if the devnet is active. You will receive `Alive!!!%` if it is active.

We created three accounts, with transaction costs of 250 wei per gas. The seed number will help us get the same accounts every time we activate our devnet and add that seed number. In other words, we can choose any seed number, but if we want to get the same accounts, we should select the same seed. We indicated we want to use port `5000`, however, feel free to add any convenient port. Our accounts are based on the code and standards developed by [Open Zepellin for Cairo](https://github.com/OpenZeppelin/cairo-contracts).

Please keep track of the address where our devnet is running. The example above is: `http://127.0.0.1:5000`. We will use it later.

The interaction with the devnet and the testnet is very similar. If you want to see all the arguments available in the `starknet-devnet` call, you can call `starknet-devnet --help` or go to the [documentation](https://shard-labs.github.io/starknet-devnet/docs/intro).


<h2 align="center" id="protostar"><a href="https://docs.swmansion.com/protostar">Protostar</a></h2>

[Protostar](https://github.com/software-mansion/protostar) is a tool inspired by [Foundry](https://github.com/foundry-rs/foundry) and key to compile, test and deploy. Its use is recommended by most of the StarkNet community.

### Installing Protostar

At this point, we already have `cairo-lang` installed.

On Ubuntu or macOS (not available for Windows), run the following command:

```Bash
curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash`
```

Restart your terminal and run `protostar -v` to see the version of your `protostar` and `cairo-lang`.

If you later want to upgrade your protostar, use `protostar upgrade`. If you run into installation problems, I recommend reviewing the [Protostar documentation](https://docs.swmansion.com/protostar/docs/tutorials/installation).

### First steps with Protostar

What does it mean to initialize a project with Protostar?

- **`protostar.toml`**. Here we will have the information necessary to configure our project.
- **Three directories will be created**. `src` (where the contracts will be), `lib` (for external dependencies), and `tests` (where we will store the tests).

We can initialize our project with the `protostar init` command, or you can indicate that an existing project will use Protostar with `protostar init --existing`. You must have a `protostar.toml` file with the project settings. We could even create the `protostar.toml` file ourselves; in the next section, we will understand better what this file contains.

Let's run `protostar init` to initialize a Protostar project. It asks us to indicate the following:

- `project directory name`: What is the directory's name where your project is located?

This is what the structure of our project looks like:

```
❯ tree -L 2
.
├── protostar.toml
├── src
│   └── voting.cairo
└── tests
    └── test_main.cairo
```


### Installing external dependencies (libraries)

Protostar uses git submodules to install external dependencies (similar to Foundry). Let's install a couple of dependencies.

First, let us install `OpenZeppelin/cairo-contracts`, Open Zeppelin's library for Cairo. We indicate where the repository is, that is, [github.com/OpenZeppelin/cairo-contracts](http://github.com/OpenZeppelin/cairo-contracts), and the version we want to install in this format:

```Bash
protostar install OpenZeppelin/cairo-contracts@v0.5.1
```

Let's install one more dependency, this time using the whole GitHub link and without the version:

```Bash
protostar install https://github.com/CairOpen/cairopen-contracts
```

Our new dependencies are stored in the newly created `lib` directory:

```
❯ tree -L 2
.
├── lib
│   ├── cairo_contracts
│   └── cairopen_contracts
├── protostar.toml
├── src
│   └── voting.cairo
└── tests
    └── test_main.cairo
```

Finally, we update our `protostar.toml` with the new paths and the installed libraries.

```
[project]
protostar-version = "0.9.1"
lib-path = "lib"
cairo-path = ["lib/cairo-contracts/src", "lib/cairopen_contracts/src"]

[contracts]
vote = ["src/voting.cairo"]
```

This allows Protostar to use those paths to find the libraries of interest. When you import, for example, `from openzeppelin.access.ownable.library import Ownable`, Protostar will look for `Ownable` in the path `lib/cairo_contracts/src/openzeppelin/access/ownable/library`. If you change the name of the directory where you store your external dependencies, then you will not use `lib` but the name of that directory.

We can update the libraries you imported with `protostar update cairo_contracts`. Also, we can remove a library. We will remove the cairopen library since we won't use it here.

```Bash
protostar remove cairopen_contracts
```

### Compiling

In the past, we have been compiling our contracts with `cairo-compile`. When we run `cairo-compile sum2Numbers.cairo --output x.json` to compile a Cairo `sum2Numbers.cairo` contract, the result is a new file in our working directory called `x.json`. The JSON file is used by `cairo-run` when we run our program.

We can simultaneously compile all our StarkNet contracts with `protostar build`. But first, we must indicate in the `[contracts]` section of `protostar.toml` the contracts we want to compile (or build). As we saw before, Protostar automatically creates a folder `src` where we can store our contracts. However, we can rename this folder or create our own. We write in `protostar.toml` that we want to compile the contract in `src/voting.cairo` and that we want to call it `vote` once it is compiled:

```Bash
[contracts]
vote = ["src/voting.cairo"]
```

We run `protostar build`. We will see a new `build` directory with a `vote.json` file. If you receive an error, e.g., "`Could not find module 'openzeppelin.access.ownable.library'.`", you can also indicate the path of the `build` call:

```Bash
protostar build \
    --cairo-path ./lib/cairo_contracts/src
```
If the compilation succeeds, we get the following:

```Bash
Building projects contracts                                                                                                                                                
Class hash for contract "vote": 0x67b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed
```

Moral: if your contract is not in the `[“protostar.contracts“]` section of `protostar.toml`, it will not be compiled.

> Note: You will not be able to compile pure Cairo code using `protostar build`. It is only for StarkNet contracts (they have the `%lang starknet` signal at the beginning). To compile and run pure Cairo applications, you need to use `cairo-compile` and `cairo-run` ([see Cairo tutorial](3_cairo_basics.md). In the following tutorials, we will learn how to create StarkNet contracts.

At this point, we can deploy StarkNet contracts with Protostar. But first, let us introduce the `devnet`.


### Deploying to the devnet

For deploying a contract using Protostar, we will follow the steps we learned in Camp 1, where we used Argent's UI and the `starknet CLI`. However, Protostar and the devnet will make it simpler.

1. Deploy an account. Notice the devnet already deployed accounts for us.
2. Compile the contract.
3. Declare the contract.
4. Invoke the function `deployContract` of the UDC. However, at the end of this section you will learn how not to invoke the UDC and simply use Protostar's `deploy`.

Let's use a real example. When we initialize a Protostar project, a `main.cairo` contract is automatically created in the `src` directory. You can use it as an example of a contract to deploy to the devnet and then to the testnet. You must ensure that you define what will be compiled in `protostar.toml`. This tutorial will deploy the voting contract we wrote in Camp 1. We initialize a new Protostar repo called [buidl/protostar-buidl](basecamp/camp_2/buidl/protostar-buidl). Our [voting contract is in the `src` directory](basecamp/camp_2/buidl/protostar-buidl/src/voting.cairo). The `protostar.toml` looks:

```
[project]
protostar-version = "0.9.1"
lib-path = "lib"

[contracts]
vote = ["src/voting.cairo"]
```

Run `protostar build` to compile and create the `build/vote_abi.json` we will use for deployment.

Following the recommended order for deploying a smart contract, we will first deploy to the devnet and then to the testnet. In a following tutorial, we will learn how to use Protostar to first code unit tests; that is the actual first step. 

To make deployment to the devnet simpler, we create a section `[profile.devnet.protostar.deploy]` in the `protostar.toml` where we add the url where we deploy our devnet locally: `gateway-url = "http://127.0.0.1:5000/"` and the `chain-id = 1536727068981429685321`. `chain-id` is a number that represents the different networks where we can deploy our contracts. The testnet and devnet id is `1536727068981429685321`.

```Bash
[profile.devnet.project]
gateway-url = "http://127.0.0.1:5000/"
chain-id = 1536727068981429685321
```

We declare our voting contract in the devnet. We need to sign our transactions, so we need to provide the account address and the private key of the account paying for the transactions. This information was already provided when we started the devnet. For the `--account-address` flag, we add one of the addresses created by the devnet. We can create a local environmental variable for the private key: `export PROTOSTAR_ACCOUNT_PRIVATE_KEY=[THE PRIVATE KEY CREATED BY THE DEVNET]`. We set it up for this case with: `export PROTOSTAR_ACCOUNT_PRIVATE_KEY=0xe3e70682c2094cac629f6fbed82c07cd`. Now let's declare:

```Bash
protostar -p devnet declare build/vote.json \
    --account-address 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a \
    --max-fee auto
```

We get: 

```Bash
Declare transaction was sent.                                                                                                             
Class hash: 0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed
Transaction hash: 0x0750ee15d7bf16252d94c08d61bf2c1bac3d15029c06e62314849e39fe1aec76
```

We invoke the `deployContract` of the UDC. Luckily, the devnet comes with a UDC deployed at the same address as the testnet and mainnet. We use the same account address as with the `declare` command. The `inputs` are the same as we sent in Camp 1; revisit it for more details on how to interact with the UDC. We will use dummy values for the voting contract's constructor.

```Bash
protostar -p devnet invoke \
    --contract-address 0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf \
    --function deployContract \
    --account-address 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a \
    --max-fee auto \
    --inputs 0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed 0 0 4 111 2 222 333
``` 

We get:

```Bash
Sending invoke transaction...                                                                                                             
Invoke transaction was sent.
Transaction hash: 0x036b82edb246b65e657ec7119ba32711cea86ff17abce961ac52faa7a294c350
```

Our voting contract is now live on the devnet. Let's get its address. The [StarkScan block explorer](https://devnet.starkscan.co/) allows us to interact with our local devnet (only using Chrome). In the field `localhost`, add the port where the devnet is running; in our case, it is `5000`.

<div align="center">
    <img src="../misc/devnet1.png">
</div>

We can search for our transaction hash (0x036b...). Then go to the `Events` tab, go to the `OwnershipTransferred` transaction, and expand its details. The contract address that appears will be the address of our deployed voting contract; in this case, 0x00a9b...

<div align="center">
    <img src="../misc/devnet2.png">
</div>

Now we can play with our voting contract directly in StarkScan or using Protostar. For example, we can invoke the admin `view` function:

```Bash
protostar -p devnet invoke \
    --contract-address 0x00a9b7d97058158b90aa835e5651948467f27ae48047ec9ae5646c6d6adb6926 \
    --function admin \
    --account-address 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a \
    --max-fee auto
``` 

This was the long way to deploy the voting contract, similar to what we did with Argent's UI and the `starknet` CLI. However, Protostar is a fantastic tool; we can use the `deploy` command to deploy our contract without invoking the UDC; Protostar does it in the background.

```Bash
protostar -p devnet deploy 0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed \
    --account-address 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a \
    --max-fee auto \
    --inputs 111 2 222 333
```

We simply needed the class hash obtained after declaring our contract. Notice that the inputs do not include some of the inputs to the `deployContract` of the UDC; including the class hash, salt, and unique address. Now we only provide the inputs of the voting contract's constructor (our dummy values: `111 2 222 333`), which is much simpler and cleaner.

We have successfully deployed a contract to the devnet. The advantage of deploying to the devnet first is that we can interact more quickly with our contracts. For the testnet, we will have to wait about a few minutes.

### Deploying to the testnet

For the devnet, we used the help of Protostar's profiles, so we do not have to write the whole chain Id and gateway URL; at the beginning of each command, we added `-p devnet`, e.g. `protostar -p devnet deploy`. We could write a profile in our Protostar configuration for the testnet too. However, for didactic purposes and because it is more straightforward, we will not create a profile for the testnet.

In order to sign our transactions (remember we need an account contract) on the testnet we can proceed on different ways:
1. Use an account linked to a Braavos or Argent wallet.
2. Deploy and use an account contract using starknet's CLI. It will be really similar to Open Zeppelin's standard. We would need to employ counterfactul deployment as we saw in Camp 1.
3. Deploy and use a customized account contract. We will review this in Camp 3.

Let us use here option 1. We can use the UI of either our Argent or Braavos wallet; I will show how to do it with Braavos here. Go the "Privacy & Security" option.

<div align="center">
    <img src="../misc/devnet2.png">
</div>

We export the private key and add it to the environmental variables with `export PROTOSTAR_ACCOUNT_PRIVATE_KEY=[THE EXPORTED PRIVATE KEY]`. 

Then we `declare` our contract adding to the `--account-address` flag the address of our wallet.


```Bash
protostar declare build/vote.json \
    --account-address 0x06dcb489c1a93069f469746ef35312d6a3b9e56ccad7f21f0b69eb799d6d2821 \
    --max-fee auto \
    --network testnet
```

We get:

```Bash
Declare transaction was sent.
Class hash: 0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed
StarkScan https://testnet.starkscan.co/class/0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed

Transaction hash: 0x05b6fa2f6019ee0f2053091b3d1965fb7de6422e85ca9db33b317caf5d7f626e
StarkScan https://testnet.starkscan.co/tx/0x05b6fa2f6019ee0f2053091b3d1965fb7de6422e85ca9db33b317caf5d7f626e
```

Before sending another transaction to the network, ensure the previous transaction (declare) is at least in the “Pending” state; otherwise, the second transaction will fail due to an incorrect nonce value. This happens because the network tracks the current nonce value of each user account, and this value is updated only after a transaction has entered the Pending state. 

Now that we have the class hash, we can deploy:

```Bash
protostar deploy 0x067b2b9d2a45c662edad93edf0c10bc3715f315cfa3a6e530f1cf1c5377989ed \
    --account-address 0x06dcb489c1a93069f469746ef35312d6a3b9e56ccad7f21f0b69eb799d6d2821 \
    --max-fee auto \
    --network testnet \
    --inputs 111 2 222 333
```

We get:

```Bash
Invoke transaction was sent to the Universal Deployer Contract.                                                                           
Contract address: 0x001c714a76bf7ff10abd26ee252651a2d408cbaaa33a6724be8309e1864fec34
StarkScan https://testnet.starkscan.co/contract/0x001c714a76bf7ff10abd26ee252651a2d408cbaaa33a6724be8309e1864fec34

Transaction hash: 905592899049432893918738658596217861692024670484195387505600892075940507664
StarkScan https://testnet.starkscan.co/tx/0x02008c238300be5965e05a5f69bb1034bd0ee3b0771d6a3b654f4e9951ebf010
```

Again, Protostar deployed using the UDC in the background. Remember, since we are deploying to the testnet, it might take some minutes for the transaction to pass. 

Great. We deployed our voting contract to both the devnet and the tesnet. This allows us to interact with our contract in a block explorer, with the CLI, or other tools.

<h2 align="center" id="nile"><a href="https://github.com/OpenZeppelin/nile">Nile</a></h2>

<h2 align="center" id="hardhat"><a href="https://github.com/Shard-Labs/starknet-hardhat-plugin">Hardhat</a></h2>

<h2 align="center" id="nodes">Nodes</h2>

### [Pathfinder](https://github.com/eqlabs/pathfinder)

### [Juno](https://github.com/NethermindEth/juno)

<h2 align="center" id="testing">Testing</h2>

<h2 align="center" id="libraries">Libraries</h2>

#### Sources

[<https://github.com/gakonst/awesome-starknet>]
