# Nodes

This chapter will guide you through setting up and running a Starknet
node, illustrating the layered tech stack concept, and explaining how to
operate these protocols locally. Starknet, as a Layer 2 Validity Rollup,
operates on top of Ethereum Layer 1, creating a protocol stack that each
addresses different functionalities, similar to the OSI model for
internet connections. This chapter is an edit of
[drspacemn](https://medium.com/starknet-edu/the-starknet-stack-7b0d70a7e1d4)'s
blog.

CONTRIBUTE: This guide shows how to run a Starknet node locally with a
particular setup. You can contribute to this guide by adding more
options for hardware and software, as well as other ways to run a
Starknet nod (for example using
[Beerus](https://github.com/keep-starknet-strange/beerus)). You can also
contribute by adding more information about the Starknet stack and the
different layers. Feel free to [open a
PR](https://github.com/starknet-edu/starknetbook).

## What is a Node in the Context of Ethereum and Blockchain?

In the context of Ethereum and blockchain, a node is an integral part of
the network that validates and relays transactions. Nodes download a
copy of the entire blockchain and are interconnected with other nodes to
maintain and update the blockchain state. There are different types of
nodes, such as full nodes, light nodes, and mining nodes, each having
different roles and responsibilities within the network.

## Overview of Starknet Technology

Starknet is a permissionless, zk-STARK-based Layer-2 network, aiming for
full decentralization. It enables developers to build scalable
decentralized applications (dApps) and utilizes Ethereum’s Layer 1 for
proof verification and data availability. Key aspects of Starknet
include:

-   **Cairo execution environment**: Cairo, the execution environment of
    Starknet, facilitates writing and execution of complex smart
    contracts.

-   **Scalability**: Starknet achieves scalability through zk-STARK
    proofs, minimizing the data needed to be posted on-chain.

-   **Node network**: The Starknet network comprises nodes that
    synchronize and process transactions, contributing to the network’s
    overall security and decentralization.

## Starknet Stack

The Starknet stack can be divided into various layers, similar to OSI or
TCP/IP models. The most appropriate model depends on your understanding
and requirements. A simplified version of the modular blockchain stack
might look like this:

-   Layer 1: Data Layer

-   Layer 2: Execution Layer

-   Layer 3: Application Layer

-   Layer 4: Transport Layer

<img alt="Modular blockchain layers" src="img/ch03-modular-blockcahain-layers.png" class="center" style="width: 50%;" />

<span class="caption">Modular blockchain layers</span>

## Setup

There are various hardware specifications, including packaged options,
that will enable you to run an Ethereum node from home. The goal here is
to build the most cost-efficient Starknet stack possible ([see here more
options](https://github.com/rocket-pool/docs.rocketpool.net/blob/main/src/guides/node/local/hardware.md)).

**Minimum Requirements:**

-   CPU: 2+ cores

-   RAM: 4 GB

-   Disk: 600 GB

-   Connection Speed: 8 mbps/sec

**Recommended Specifications:**

-   CPU: 4+ cores

-   RAM: 16 GB+

-   Disk 2 TB

-   Connection Speed: 25+ mbps/sec

**You can refer to these links for the hardware:**

-   [CPU](https://a.co/d/iAWpTzQ) — $193

-   [Board](https://a.co/d/cTUk9Kd) (can attempt w/ Raspberry Pi) — $110

-   [Disk](https://a.co/d/0US61Y5) — $100

-   [RAM](https://a.co/d/br867sk) — $60

-   [PSU](https://a.co/d/2k3Gn40) — $40

-   [Case](https://a.co/d/apCBGwF) — $50

Total — $553

Recommended operating system and software: Ubuntu LTS,
[Docker](https://docs.docker.com/engine/install/ubuntu), and [Docker
Compose](https://docs.docker.com/compose/install/linux). Ensure you have
the necessary tools installed with:

    sudo apt install -y jq curl net-tools

## Layer 1: Data Layer

The bottom-most layer of the stack is the data layer. Here, Starknet’s
L2 leverages Ethereum’s L1 for proof verification and data availability.
Starknet utilizes Ethereum as its L1, so the first step is setting up an
Ethereum Full Node. As this is the data layer, the hardware bottleneck
is usually the disk storage. It’s crucial to have a high capacity I/O
SSD over an HDD because Ethereum Nodes require both an Execution Client
and a Consensus Client for communication.

Ethereum provides several options for Execution and Consensus clients.
Execution clients include Geth, Erigon, Besu (used here), Nethermind,
and Akula. Consensus clients include Prysm, Lighthouse (used here),
Lodestar, Nimbus, and Teku.

Your Besu/Lighthouse node will take approximately 600 GB of disk space.
Navigate to a partition on your machine with sufficient capacity and run
the following commands:

    git clone https://github.com/starknet-edu/starknet-stack.git
    cd starknet-stack
    docker-compose -f dc-l1.yaml up -d

This will begin the fairly long process of spinning up our Consensus
Client, Execution Client, and syncing them to the current state of the
Goerli Testnet. If you would like to see the logs from either process
you can run:

    # tail besu logs
    docker container logs -f $(docker ps | grep besu | awk '{print $1}')

    # tail lighthouse logs
    docker container logs -f $(docker ps | grep lighthouse | awk '{print $1}')

Lets make sure that everything that should be listening is listening:

    # should see all ports in command output

    # besu ports
    sudo netstat -lpnut | grep -E '30303|8551|8545'

    # lighthouse ports
    sudo netstat -lpnut | grep -E '5054|9000'

We’ve used docker to abstract a lot of the nuance of running an Eth L1
node, but the important things to note are how the two processes EL/CL
point to each other and communicate via JSON-RPC:

    services:
      lighthouse:
          image: sigp/lighthouse:latest
          container_name: lighthouse
          volumes:
            - ./l1_consensus/data:/root/.lighthouse
            - ./secret:/root/secret
          network_mode: "host"
          command:
            - lighthouse
            - beacon
            - --network=goerli
            - --metrics
            - --checkpoint-sync-url=https://goerli.beaconstate.info
            - --execution-endpoint=http://127.0.0.1:8551
            - --execution-jwt=/root/secret/jwt.hex

      besu:
        image: hyperledger/besu:latest
        container_name: besu
        volumes:
          - ./l1_execution/data:/var/lib/besu
          - ./secret:/var/lib/besu/secret
        network_mode: "host"
        command:
          - --network=goerli
          - --rpc-http-enabled=true
          - --data-path=/var/lib/besu
          - --data-storage-format=BONSAI
          - --sync-mode=X_SNAP
          - --engine-rpc-enabled=true
          - --engine-jwt-enabled=true
          - --engine-jwt-secret=/var/lib/besu/secret/jwt.hex

Once this is done, your Ethereum node should be up and running, and it
will start syncing with the Ethereum network.

## Layer 2: Execution Layer

The next layer in our Starknet stack is the Execution Layer. This layer
is responsible for running the Cairo VM, which executes Starknet smart
contracts. The Cairo VM is a deterministic virtual machine that allows
developers to write complex smart contracts in the Cairo language.
Starknet uses a similar [JSON-RPC
spec](https://github.com/starkware-libs/starknet-specs) as
[Ethereum](https://ethereum.org/en/developers/docs/apis/json-rpc) in
order to interact with the execution layer.

In order to stay current with the propagation of the Starknet blockchain
we need a client similar to Besu that we are using for L1. The efforts
to provide full nodes for the Starknet ecosystem are:
[Pathfinder](https://github.com/eqlabs/pathfinder) (used here),
[Papyrus](https://github.com/starkware-libs/papyrus), and
[Juno](https://github.com/NethermindEth/juno). However, different
implementations are still in development and not yet ready for
production.

Check that your L1 has completed its sync:

    # check goerli etherscan to make sure you have the latest block https://goerli.etherscan.io

    curl --location --request POST 'http://localhost:8545' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "jsonrpc":"2.0",
        "method":"eth_blockNumber",
        "params":[],
        "id":83
    }'

    # Convert the result, which is hex (remove 0x) to decimal. Example:
    echo $(( 16#246918 ))

Start your L2 Execution Client and note that we are syncing Starknet’s
state from our LOCAL ETH L1 NODE!

PATHFINDER\_ETHEREUM\_API\_URL=http://127.0.0.1:8545

    # from starknet-stack project root
    docker-compose -f dc-l2.yaml up -d

To follow the sync:

    docker container logs -f $(docker ps | grep pathfinder | awk '{print $1}')

Starknet [Testnet\_1](https://testnet.starkscan.co) currently comprises
800,000+ blocks so this will take some time (days) to sync fully. To
check L2 sync:

    # compare `current_block_num` with `highest_block_num`

    curl --location --request POST 'http://localhost:9545' \
    --header 'Content-Type: application/json' \
    --data-raw '{
     "jsonrpc":"2.0",
     "method":"starknet_syncing",
     "params":[],
     "id":1
    }'

To check data sizes:

    sudo du -sh ./* | sort -rh

## Layer 3: Application Layer

We see the same need for data refinement as we did in the OSI model. On
L1 packets come over the wire in a raw stream of bytes and are then
processed and filtered by higher-level protocols. When designing a
decentralized application Bob will need to be cognizant of interactions
with his contract on chain, but doesn’t need to be aware of all the
information occurring on Starknet.

This is the role of an indexer. To process and filter useful information
for an application. Information that an application MUST be opinionated
about and the underlying layer MUST NOT be opinionated about.

Indexers provide applications flexibility as they can be written in any
programming language and have any data layout that suits the
application.

To start our toy
[indexer](https://github.com/starknet-edu/starknet-stack/blob/main/indexer/indexer.sh)
run:

    ./indexer/indexer.sh

Again notice that we don’t need to leave our local setup for these
interactions (<http://localhost:9545>).

## Layer 4: Transport Layer

The transport layer comes into play when the application has parsed and
indexed critical information, often leading to some state change based
on this information. This is where the application communicates the
desired state change to the Layer 2 sequencer to get that change into a
block. This is achieved using the same full-node/RPC spec
implementation, in our case, Pathfinder.

When working with our local Starknet stack, invoking a transaction
locally might look like this:

    curl --location --request POST 'http://localhost:9545' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "jsonrpc": "2.0",
        "method": "starknet_addInvokeTransaction",
        "params": {
            "invoke_transaction": {
                "type": "INVOKE",
                "max_fee": "0x4f388496839",
                "version": "0x0",
                "signature": [
                    "0x7dd3a55d94a0de6f3d6c104d7e6c88ec719a82f4e2bbc12587c8c187584d3d5",
                    "0x71456dded17015d1234779889d78f3e7c763ddcfd2662b19e7843c7542614f8"
                ],
                "contract_address": "0x23371b227eaecd8e8920cd429d2cd0f3fee6abaacca08d3ab82a7cdd",
                "calldata": [
                    "0x1",
                    "0x677bb1cdc050e8d63855e8743ab6e09179138def390676cc03c484daf112ba1",
                    "0x362398bec32bc0ebb411203221a35a0301193a96f317ebe5e40be9f60d15320",
                    "0x0",
                    "0x1",
                    "0x1",
                    "0x2b",
                    "0x0"
                ],
                "entry_point_selector": "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad"
            }
        },
        "id": 0
    }'

However, this process involves setting up a local wallet and signing the
transaction. For simplicity, we will use a browser wallet and StarkScan.

Steps:

1.  Navigate to the contract on StarkScan and connect to your wallet.

2.  Enter a new value and write the transaction:

<img alt="Starkscan block explorer" src="img/ch03-starkscan-block-explorer.png" class="center" style="width: 50%;" />

<span class="caption">Starkscan block explorer</span>

Once the transaction is accepted on the Layer 2 execution layer, the
event data should come through our application layer indexer.

Example Indexer Output:

    Pulled Block #: 638703
    Found transaction: 0x2053ae75adfb4a28bf3a01009f36c38396c904012c5fc38419f4a7f3b7d75a5
    Events to Index:
    [
      {
        "from_address": "0x806778f9b06746fffd6ca567e0cfea9b3515432d9ba39928201d18c8dc9fdf",
        "keys": [
          "0x1fee98324df9b8703ae8de6de3068b8a8dce40c18752c3b550c933d6ac06765"
        ],
        "data": [
          "0xa"
        ]
      },
      {
        "from_address": "0x126dd900b82c7fc95e8851f9c64d0600992e82657388a48d3c466553d4d9246",
        "keys": [
          "0x5ad857f66a5b55f1301ff1ed7e098ac6d4433148f0b72ebc4a2945ab85ad53"
        ],
        "data": [
          "0x2053ae75adfb4a28bf3a01009f36c38396c904012c5fc38419f4a7f3b7d75a5",
          "0x0"
        ]
      },
      {
        "from_address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
        "keys": [
          "0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9"
        ],
        "data": [
          "0x126dd900b82c7fc95e8851f9c64d0600992e82657388a48d3c466553d4d9246",
          "0x46a89ae102987331d369645031b49c27738ed096f2789c24449966da4c6de6b",
          "0x17c1e31c270",
          "0x0"
        ]
      }
    ]

Once the transaction is accepted on Layer 1, we can query the Starknet
Core Contracts from our Layer 1 node to see the storage keys that have
been updated on our data layer!

You have successfully navigated through the entire Starknet stack, from
setting up your node, through executing and monitoring a transaction, to
inspecting its effects on the data layer. This journey has equipped you
with the understanding and the skills to interact with Starknet on a
deeper level.

## Conclusion: Understanding the Modular Nature of Starknet

Conceptual models, such as the ones used in this guide, are incredibly
useful in helping us understand complex systems. They can be refactored,
reformed, and nested to provide a clear and comprehensive view of how a
platform like Starknet operates. For instance, the OSI Model, a
foundational model for understanding network interactions, underpins our
modular stack.

A key concept to grasp is *Fractal Scaling.* This concept allows us to
extend our model to include additional layers beyond Layer 2, such as
Layer 3. In this extended model, the entire stack recurs above our
existing stack, as shown in the following diagram:

<img alt="Fractal scaling in a modular blockchain environment" src="img/ch03-fractal-scaling.png" class="center" style="width: 50%;" />

<span class="caption">Fractal scaling in a modular blockchain environment</span>

Just as Layer 2 compresses its transaction throughput into a proof and
state change that is written to Layer 1, we can apply the same
compression principle at Layer 3, proving and writing to Layer 2. This
not only gives us more control over the protocol rules but also allows
us to achieve higher compression ratios, enhancing the scalability of
our applications.

In essence, Starknet’s modular and layered design, combined with the
power of Fractal Scaling, offers a robust and scalable framework for
building decentralized applications. Understanding this structure is
fundamental to effectively leveraging Starknet’s capabilities and
contributing to its ecosystem.

This concludes our journey into running a Starknet node and traversing
its layered architecture. We hope that you now feel equipped to explore,
experiment with, and innovate within the Starknet ecosystem.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
