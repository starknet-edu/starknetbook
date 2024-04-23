# Starknet Devnet

Starknet Devnet is a development network (devnet) implemented in Rust, similar to the Python-based [`starknet-devnet-rs`](https://0xspaceshard.github.io/starknet-devnet/docs/intro).

## Installation

`starknet devnet rs` can be installed in two ways: using Docker or manually by cloning the repository and running it with Cargo.

### Using Docker

To install using Docker, follow the instructions provided [here](https://github.com/0xSpaceShard/starknet-devnet-rs#readme).

### Manual Installation (Cloning the Repo)

Prerequisites:

- Rust installation ([Rust Install Guide](https://www.rust-lang.org/tools/install))

Procedure:

1. Create a new folder for the project.
2. Clone the repository:

```shell
git clone https://github.com/0xSpaceShard/starknet-devnet-rs.git
```

## Running

After installation, run Starknet Devnet with the following command:

```shell
cargo run
```

On successful execution, you'll see outputs like predeployed contract addresses, account information, and seed details.

```shell
Predeployed FeeToken
Address: 0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7
Class Hash: 0x6A22BF63C7BC07EFFA39A25DFBD21523D211DB0100A0AFD054D172B81840EAF

Predeployed UDC
Address: 0x41A78E741E5AF2FEC34B695679BC6891742439F7AFB8484ECD7766661AD02BF
Class Hash: 0x7B3E05F48F0C69E4A65CE5E076A66271A527AFF2C34CE1083EC6E1526997A69

| Account address |  0x1d11***221c
| Private key     |  0xb7***8ee25
| Public key      |  0x5d46***76bf10

.
.
.

Predeployed accounts using class with hash: 0x4d07e40e93398ed3c76981e72dd1fd22557a78ce36c0515f679e27f0bb5bc5f
Initial balance of each account: 1000000000000000000000 WEI
Seed to replicate this account sequence: 912753742
```

## Running Options

### Using a Seed

The Starknet devnet provides a `Seed to replicate this account sequence` feature. This allows you to use a specific seed to access previously used accounts. This functionality is particularly useful when employing tools like [`sncast`](https://book.starknet.io/ch02-12-foundry-cast.html) or `starkli` for contract interactions, as it eliminates the need to change account information.

To load old accounts using a specific seed, execute the following command:

```shell
cargo run -- --seed <SEED>
```

Example (add any number you prefer):

```shell
cargo run -- --seed 912753742
```

### Dumping and Loading Data

The process of dumping and loading data facilitates resuming work from where you left off.

- **Dumping Data**:

* Data can be dumped either on `exit` or after a `transaction`.
* In this example, dumping is done on exit into a specified directory. Ensure the directory exists, but not the file.

```shell
cargo run -- --dump-on exit --dump-path ./dumps/contract_1
```

- **Loading Data**:
- To load data, use the command below. Note that both the directory and the file created by the `dump` command must exist. Also, pass in the seed to avoid issues like 'low account balance'.

```shell
cargo run -- --dump-path ./dumps/contract_1 --seed 912753742
```

##### Additional options

```shell
Options:
      --accounts <ACCOUNTS>
          Specify the number of accounts to be predeployed; [default: 10]
      --account-class <ACCOUNT_CLASS>
          Specify the class used by predeployed accounts; [default: cairo0] [possible values: cairo0, cairo1]
      --account-class-custom <PATH>
          Specify the path to a Cairo Sierra artifact to be used by predeployed accounts;
  -e, --initial-balance <DECIMAL_VALUE>
          Specify the initial balance in WEI of accounts to be predeployed; [default: 1000000000000000000000]
      --seed <SEED>
          Specify the seed for randomness of accounts to be predeployed; if not provided, it is randomly generated
      --host <HOST>
          Specify the address to listen at; [default: 127.0.0.1]
      --port <PORT>
          Specify the port to listen at; [default: 5050]
      --timeout <TIMEOUT>
          Specify the server timeout in seconds; [default: 120]
      --gas-price <GAS_PRICE>
          Specify the gas price in wei per gas unit; [default: 100000000000]
      --chain-id <CHAIN_ID>
          Specify the chain ID; [default: TESTNET] [possible values: MAINNET, TESTNET]
      --dump-on <WHEN>
          Specify when to dump the state of Devnet; [possible values: exit, transaction]
      --dump-path <DUMP_PATH>
          Specify the path to dump to;
  -h, --help
          Print help
  -V, --version
          Print version

```

> However, the main difference for the Rust version is the syntax for flags. For example, use `cargo run -- --port 5006` or `cargo run -- --dump-on exit ...` for the Rust Devnet. Other flags can be used in the standard format.

#### Cross-Version Disclaimer

Be aware that the dumping and loading functionality might not be compatible across different versions of the Devnet. In other words, data dumped from one version of Devnet may not be loadable with another version.

### Minting Tokens

To mint tokens, either to an existing address or a new one, use the following command:

```shell
curl -d '{"amount":8646000000000, "address":"0x6e...eadf"}' -H "Content-Type: application/json" -X POST http://localhost:5050/mint
```

> Commands compatible with the `sncast` and `starkli` subchapters are also applicable in the Rust Devnet.

## Next

In the next subchapter we will use the `sncast` tool to interact with the Starknet Devnet in a real world example.
