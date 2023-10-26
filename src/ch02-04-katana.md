# Katana: A Local Node

`Katana` is designed to aid in local development.
This creation by the [Dojo
team](https://github.com/dojoengine/dojo/blob/main/crates/katana/README.md)
enables you to perform all Starknet-related activities in a local
environment, thus serving as an efficient platform for development and
testing.

We suggest employing either `katana` or `starknet-devnet` for testing
your contracts, with the latter discussed in another
subchapter. The `starknet-devnet` is a public testnet, maintained by the
[Shard Labs team](https://github.com/0xSpaceShard/starknet-devnet-rs). Both
these tools offer an effective environment for development and testing.

For an example of how to use `katana` to deploy and interact with a
contract, see the introduction subchapter of this Chapter or a voting contract example in [The Cairo Book](https://book.cairo-lang.org/ch99-01-04-01-voting-contract.html).

## Understanding RPC in Starknet

Remote Procedure Call (RPC) establishes the communication between nodes
in the Starknet network. Essentially, it allows us to interact with a
node in the Starknet network. The RPC server is responsible for
receiving these calls.

RPC can be obtained from various sources: . To support the
decentralization of the Network, you can use your own local Starknet
node. For ease of access, consider using a provider such as
[Infura](https://docs.infura.io/networks/starknet/how-to) or
[Alchemy](https://www.alchemy.com/starknet) to get an RPC client. . For
development and testing, a temporary local node such as `katana` can be
used.

## Getting Started with Katana

To install Katana, use the `dojoup` installer from the command line:

```bash
curl -L https://install.dojoengine.org | bash
dojoup
```

After restarting your terminal, verify the installation with:

```bash
katana --version
```

To upgrade Katana, rerun the installation command.

To initialize a local Starknet node, execute the following command:

```bash
katana --accounts 3 --seed 0 --gas-price 250
```

The `--accounts` flag determines the number of accounts to be created,
while the `--seed` flag sets the seed for the private keys of these
accounts. This ensures that initializing the node with the same seed
will always yield the same accounts. Lastly, the `--gas-price` flag
specifies the transaction gas price.

Running the command produces output similar to this:

    ██╗  ██╗ █████╗ ████████╗ █████╗ ███╗   ██╗ █████╗
    ██║ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██╔══██╗
    █████╔╝ ███████║   ██║   ███████║██╔██╗ ██║███████║
    ██╔═██╗ ██╔══██║   ██║   ██╔══██║██║╚██╗██║██╔══██║
    ██║  ██╗██║  ██║   ██║   ██║  ██║██║ ╚████║██║  ██║
    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


    PREFUNDED ACCOUNTS
    ==================

    | Account address |  0x03ee9e18edc71a6df30ac3aca2e0b02a198fbce19b7480a63a0d71cbd76652e0
    | Private key     |  0x0300001800000000300000180000000000030000000000003006001800006600
    | Public key      |  0x01b7b37a580d91bc3ad4f9933ed61f3a395e0e51c9dd5553323b8ca3942bb44e

    | Account address |  0x033c627a3e5213790e246a917770ce23d7e562baa5b4d2917c23b1be6d91961c
    | Private key     |  0x0333803103001800039980190300d206608b0070db0012135bd1fb5f6282170b
    | Public key      |  0x04486e2308ef3513531042acb8ead377b887af16bd4cdd8149812dfef1ba924d

    | Account address |  0x01d98d835e43b032254ffbef0f150c5606fa9c5c9310b1fae370ab956a7919f5
    | Private key     |  0x07ca856005bee0329def368d34a6711b2d95b09ef9740ebf2c7c7e3b16c1ca9c
    | Public key      |  0x07006c42b1cfc8bd45710646a0bb3534b182e83c313c7bc88ecf33b53ba4bcbc


    ACCOUNTS SEED
    =============
    0


    🚀 JSON-RPC server started: http://0.0.0.0:5050

The output includes the addresses, private keys, and public keys of the
created accounts. It also contains the seed used to generate the
accounts. This seed can be reused to create identical accounts in future
runs. Additionally, the output provides the URL of the JSON-RPC server.
This URL can be used to establish a connection to the local Starknet
node.

To stop the local Starknet node, simply press `Ctrl+C`.

The local Starknet node does not persist data. Hence, once it’s stopped,
all data will be erased.

For a practical demonstration of `katana` to deploy and interact with a
contract, see [Chapter 2’s Voting contract
example](https://book.starknet.io/chapter_2/deploy_call_invoke.html).
