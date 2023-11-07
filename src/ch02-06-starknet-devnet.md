# Starknet Devnet Rust

Starknet Devnet Rust is devnet in rust similar to the [`pythonic devnet`](https://0xspaceshard.github.io/starknet-devnet/docs/intro).

## Installation

There are two ways to install `starknet devnet rs`. You can either use `docker` or clone the repository and `cargo run`.

### Using docker

To use docker, use the procedures highlighted [here](https://github.com/0xSpaceShard/starknet-devnet-rs#readme)

### Using manual procedure (Cloning the repo)

Prerequisites:

- [Rust](https://www.rust-lang.org/tools/install)

Procedure

1. Create a folder where you want to place it.

2. Then run this command

```shell
git clone git@github.com:0xSpaceShard/starknet-devnet-rs.git
```

## Running

To run starknet devnet rs after installation run

```rust
cargo run
```

Successfull Result

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

### Running Options

1. Using a seed

When you run starknet devnet it gives you a `Seed to replicate this account sequence` meaning you can use the given seed to get the accounts you have used previously making your work easier when using other tools like [`sncast`](https://book.starknet.io/ch02-12-foundry-cast.html) or `starkli` to interact with your contract because you are not going to change the accounts.

To load the old accounts based on a given `seed` run

```shell
cargo run -- --seed <SEED>
```

Example

```shell
cargo run -- --seed 912753742
```

2. Dumping and loading data

Dumping and loading data will help you to continue working from where you left off.

- To `dump` use the following command

Dumping can be done on `exit` or `transaction`. For our case we have done it on exit.

I have done the dumping into a given `directory` remember to have the directory but not the file.

```shell
cargo run -- --dump-on exit --dump-path ./dumps/contract_1
```

- To `load` use the following command and pass in the seed otherwise you will get an error `low account balance`.

On loading, have both the directory and the file existing, the file was automatically created by the `dump` command.

```shell
cargo run -- --dump-path ./dumps/contract_1 --seed 912753742
```

> > For more options check [here](https://0xspaceshard.github.io/starknet-devnet/docs/guide/run) though this is the `pythonic devnet`. Only difference is before the first flag have two extra dashes ie `cargo run -- --port 5006` or `cargo run -- -- dump-on exit ...`. The rest of the flags can be passed in normally.

#### Cross-version disclaimer

Dumping and loading is not guaranteed to work cross-version. I.e. if you dumped one version of Devnet, do not expect it to be loadable with a different version.

### Minting

You can mint tokens to an address or a new address using the command below

```shell
curl -d '{"amount":8646000000000, "address":"0x6e...eadf"}' -H "Content-Type: application/json" -X POST http://localhost:5050/mint
```

> All commands that work in the [`sncast section`](https://book.starknet.io/ch02-12-foundry-cast.html) and `starkli` work here as well.

## Conclusion

Rust Devnet is faster starting from powering on to handling transactions as compared to pythonic devnet making testing locally much smoother.
