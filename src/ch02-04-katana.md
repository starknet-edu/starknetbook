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
contract, see the introduction subchapter of this Chapter or a voting contract example in [The Cairo Book](https://book.cairo-lang.org/ch16-06-01-deploying-and-interacting-with-a-voting-contract.html).

## Understanding RPC in Starknet

Remote Procedure Call (RPC) establishes the communication between nodes
in the Starknet network. Essentially, it allows us to interact with a
node in the Starknet network. The RPC server is responsible for
receiving these calls.

RPC can be obtained from various sources: . To support the
decentralization of the Network, you can use your own local Starknet
node. For ease of access, consider using a provider such as
[Infura](https://docs.infura.io/networks/starknet/how-to) or
[Alchemy](https://www.alchemy.com/starknet) to get an RPC client. For
development and testing, a temporary local node such as `katana` can be
used.

## Getting Started with Katana

To install Katana refer to [this chapter](/ch02-01-basic-installation.html#katana-node-installation).

To initialize a local Starknet node, execute the following command:

```bash
katana --accounts 3 --seed 0
```

The `--accounts` flag determines the number of accounts to be created,
while the `--seed` flag sets the seed for the private keys of these
accounts. This ensures that initializing the node with the same seed
will always yield the same accounts.

Running the command produces output similar to this:

    ██╗  ██╗ █████╗ ████████╗ █████╗ ███╗   ██╗ █████╗
    ██║ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██╔══██╗
    █████╔╝ ███████║   ██║   ███████║██╔██╗ ██║███████║
    ██╔═██╗ ██╔══██║   ██║   ██╔══██║██║╚██╗██║██╔══██║
    ██║  ██╗██║  ██║   ██║   ██║  ██║██║ ╚████║██║  ██║
    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

    PREDEPLOYED CONTRACTS
    ==================

    | Contract        | Fee Token
    | Address         | 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
    | Class Hash      | 0x02a8846878b6ad1f54f6ba46f5f40e11cee755c677f130b2c4b60566c9003f1f

    | Contract        | Universal Deployer
    | Address         | 0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf
    | Class Hash      | 0x07b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69

    | Contract        | Account Contract
    | Class Hash      | 0x05400e90f7e0ae78bd02c77cd75527280470e2fe19c54970dd79dc37a9d3645c

    PREFUNDED ACCOUNTS
    ==================

    | Account address |  0x2d71e9c974539bb3ffb4b115e66a23d0f62a641ea66c4016e903454c8753bbc
    | Private key     |  0x33003003001800009900180300d206308b0070db00121318d17b5e6262150b
    | Public key      |  0x4c0f884b8e5b4f00d97a3aad26b2e5de0c0c76a555060c837da2e287403c01d

    | Account address |  0x6162896d1d7ab204c7ccac6dd5f8e9e7c25ecd5ae4fcb4ad32e57786bb46e03
    | Private key     |  0x1800000000300000180000000000030000000000003006001800006600
    | Public key      |  0x2b191c2f3ecf685a91af7cf72a43e7b90e2e41220175de5c4f7498981b10053

    | Account address |  0x6b86e40118f29ebe393a75469b4d926c7a44c2e2681b6d319520b7c1156d114
    | Private key     |  0x1c9053c053edf324aec366a34c6901b1095b07af69495bffec7d7fe21effb1b
    | Public key      |  0x4c339f18b9d1b95b64a6d378abd1480b2e0d5d5bd33cd0828cbce4d65c27284

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
contract, see [Introduction: Starkli, Scarb and Katana](ch02-02-starkli-scarb-katana.md).
