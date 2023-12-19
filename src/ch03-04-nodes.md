# Nodes

This chapter will guide you through functionality of nodes, their 
relationship with sequencers and their significance within the Starknet 
ecosystem. Upon completion of this chapter, you would have been equipped 
with the skills and knowledge of what nodes are in the Starknet network 
and why they are crucial. Why are nodes and sequencers relevant to each 
other in Starknet, how do the nodes relate to the Clients and how do 
the nodes relate to the mempool. Lastly Importance of having a variety 
of node implementations and Implementation guides.

CONTRIBUTE:  This guide shows how to run a Starknet node. You can 
contribute to this guide by adding more options for hardware, 
as well as other ways to run a Starknet node. Feel free to [open a 
PR](https://github.com/starknet-edu/starknetbook).

## What is a Node in the Context of Starknet Ecosystem?

In the context of Starknet, a node is a computer that runs the Starknet
software and participates in the Starknet network. Nodes are responsible
for validating transactions, maintaining the Starknet state, and 
communicating with other nodes. There are two main types of nodes in the
Starknet network:

- **Full nodes**: Full nodes download a copy of the entire Starknet state 
and are responsible for validating all transactions.

- **Light nodes**: Light nodes do not download a copy of the entire 
Starknet state. Instead, they rely on full nodes to provide them with
information about the Starknet state. Light nodes are faster and more
efficient than full nodes, but they are also less secure. Nodes are 
an essential part of the Starknet ecosystems. They are responsible 
for maintaining the security and integrity of the networks. Without 
nodes, the Starknet networks would not be able to function.

## Node Functionality in the Starknet Network and why they are Crucial

Nodes play a critical role in maintaining the functionality and 
security of the Starknet network. They are responsible for a variety
of tasks, including:

- **Transaction validation**: Nodes validate transactions to ensure 
they comply with the rules of the Starknet network. This helps to 
prevent fraud and malicious activity. 

- **Block creation and propagation**: Nodes create blocks and propagate 
them to other nodes in the network. This helps to ensure that all nodes 
have a consistent view of the blockchain.

- **State maintenance**: Nodes maintain the current state of the Starknet
network, including user balances and smart contract code. This 
information is used to process transactions and execute smart contracts.

- **Provide API endpoints for developers**: Nodes can provide API 
endpoints that allow developers to interact with the Starknet network. 
This can be used to build applications, wallets, and other tools.

- **Relay transactions**: Nodes can relay transactions from users 
to other nodes in the network. This can help to improve the performance
of the network and reduce congestion.

## Relevance of Nodes and Sequencers in the Starknet Network

The relevance of nodes and sequencers to each other lies in 
their interdependent roles in the Starknet ecosystem:

Nodes rely on sequencers to produce blocks and update the network 
state. The transactions validated by nodes are incorporated into 
blocks by sequencers, ensuring that the Starknet state remains 
consistent and up-to-date.

Sequencers rely on nodes to validate transactions and maintain 
network consensus. Before executing transactions, sequencers 
consult with nodes to ensure the validity of transactions 
and prevent fraudulent activities. Nodes also participate 
in the consensus mechanism to ensure that all nodes agree 
on the state of the blockchain.

Together, nodes and sequencers ensure the efficient, 
secure, and decentralized operation of the Starknet network. 
Nodes provide the secure foundation for the network, while 
sequencers enable the timely processing of transactions. This 
collaboration fosters a robust and scalable ecosystem for 
decentralized applications.

## Relation of Nodes to the Clients in Starknet Ecosystem

The relationship between nodes and clients in the Starknet 
ecosystem is characterized by a client-server model:

Clients initiate interactions with nodes by sending requests,
such as transaction submissions or state queries.

Nodes process these requests, validating transactions, 
updating the network state, and providing the requested 
information to clients.

Clients receive responses from nodes, updating their local 
state with the latest network information and providing 
feedback to users.

This interaction loop allows users to seamlessly interact 
with Starknet DApps without needing to understand the 
underlying technical complexities of the network. 
Nodes handle the heavy lifting of maintaining the network's 
integrity and security, while clients provide a user-friendly 
interface for interacting with the network and its applications.

In essence, nodes and clients form a complementary duo, 
each playing a critical role in the Starknet ecosystem's 
operation and success. Nodes provide the secure foundation 
upon which the network operates, while clients facilitate 
user interaction and drive adoption of Starknet DApps. Together, 
they create a powerful and versatile environment for 
decentralized applications to thrive.

## Relation of Nodes to the Mempool in the Starknet Network

The mempool is a temporary storage area for transactions that have
been submitted to the network but have not yet been processed. 
When a node receives a transaction, it first checks to make sure 
that it is valid. If the transaction is valid, the node adds it 
to the mempool. The mempool is then broadcast to other nodes 
in the network.

Nodes periodically select transactions from the mempool 
to be processed. These transactions are then included in blocks, 
which are added to the blockchain.
The mempool plays an important role in the Starknet network 
by ensuring that transactions are processed in a timely manner. 
It also helps to prevent congestion on the network.

## Importance of Having a Variety of Node Implementations in the Starknet Ecosystem

Having a variety of node implementations in the StarkNet 
ecosystem, is important for several reasons:

- **Decentralization and Security**: Different implementations 
reduce the risk of systemic vulnerabilities. If all nodes run 
the same software and a critical bug or security flaw is 
discovered, it could potentially affect the entire network. 
Having diverse implementations mitigates this risk, as a bug 
in one implementation is less likely to be present in others.

- **Innovation and Evolution**: Different implementations can 
experiment with new features, optimizations, and upgrades. 
This diversity fosters innovation and allows the ecosystem 
to evolve more rapidly. If one implementation introduces a 
successful improvement, others can adopt similar strategies, 
leading to continuous improvement across the network.

- **Avoiding Centralization**: Depending on a single 
implementation can lead to centralization risks. 
If there's a dominant implementation, it could become 
a central point of control, potentially compromising 
the decentralization principles of blockchain technology. 
Multiple implementations contribute to a more distributed 
and resilient network.

- **Community Engagement and Governance**: Multiple implementations
encourage a healthy and engaged developer community. Different 
teams working on various implementations bring diverse 
perspectives and ideas to the table. This diversity is 
beneficial for governance processes, as decisions are less 
likely to be dominated by a single group or entity.

In summary, a variety of node implementations in the StarkNet 
ecosystem promotes decentralization, enhances security, 
fosters innovation, and ensures the long-term health and 
resilience of the network. It creates an environment where 
the community can adapt to challenges, iterate on improvements, 
and provide users with a diverse set of choices.

## Node Implementation in Starknet

Node implementations play a critical role in the Starknet ecosystem, 
providing the foundation for validating transactions, maintaining 
the network state, and ensuring the overall security and integrity 
of the network. Currently, there are several active node 
implementations in the Starknet ecosystem, each with its own strengths
and characteristics:

- **Pathfinder**: Developed by Equilibrium, Pathfinder is a 
full node implementation written in Rust. It is known for 
its high performance, scalability, and adherence to the 
Starknet Cairo specification.

- **Juno**: Developed by Nethermind, Juno is another full 
node implementation written in Golang. It is known for its 
user-friendliness, ease of deployment, and compatibility 
with existing Ethereum tools and infrastructure.

- **Papyrus**: Developed by StarkWare, Papyrus is a 
Rust-based full node implementation that emphasizes 
security and robustness. It is designed to be the 
foundation for the new Starknet Sequencer, which 
will significantly enhance the network's throughput.

These node implementations are constantly being improved 
and evolved, with new features and enhancements being 
added regularly. The choice of node implementation often 
depends on the specific requirements and preferences of 
the user or developer.

Here's a table summarizing the key characteristics of 
each node implementation:

| Node Implementation | Language | Strengths | GitHub Repository |
|:----------------------|:-----------------|:--------------|:--------------------|
| Pathfinder      | Rust        | High performance, scalability, adherence to Cairo specification | [Pathfinder GitHub](https://github.com/eqlabs/pathfinder) |
| Papyrus              | Rust   | Security, robustness, foundation for new Starknet Sequencer | [Papyrus GitHub](https://github.com/starkware-libs/papyrus) |
| Juno                 | Golang | User-friendliness, ease of deployment, Ethereum compatibility | [Juno GitHub](https://github.com/NethermindEth/juno) |


## Implementing/Creating Pathfinder Node

### Recommended Hardware

The recommended hardware for running a 
Pathfinder node is as follows:

- **CPU**: Intel Core i7-9700 or AMD Ryzen 7 3700X
- **Memory**: 32GB
- **Storage**: 1TB SSD
- **Network**: Gigabit Ethernet
  
This hardware will provide enough resources to run 
a Pathfinder node with a high level of
performance and reliability.

### Approximate Prices of Recommended Hardware

The approximate prices of the recommended hardware
for running a Pathfinder node are as follows:

- **CPU**: $300
- **Memory**: $100
- **Storage**: $100
- **Network**: $50

The total cost of the recommended hardware is 
approximately $550.

## Running with Docker

The `pathfinder` node can be run in the provided Docker image.
Using the Docker image is the easiest way to start `pathfinder`. If for any reason you're interested in how to set up all the
dependencies yourself please check the [Installation from source](doc/install-from-source.md) guide.

The following assumes you have [Docker installed](https://docs.docker.com/get-docker/) and ready to go.
(In case of Ubuntu installing docker is as easy as running `sudo snap install docker`.)

The example below uses `$HOME/pathfinder` as the data directory where persistent files used by `pathfinder` will be stored.
It is easiest to create the volume directory as the user who is running the docker command.
If the directory gets created by docker upon startup, it might be unusable for creating files.

The following commands start the node in the background, also making sure that it starts automatically after reboot:

```bash
# Ensure the directory has been created before invoking docker
mkdir -p $HOME/pathfinder
# Start the pathfinder container instance running in the background
sudo docker run \
  --name pathfinder \
  --restart unless-stopped \
  --detach \
  -p 9545:9545 \
  --user "$(id -u):$(id -g)" \
  -e RUST_LOG=info \
  -e PATHFINDER_ETHEREUM_API_URL="https://goerli.infura.io/v3/<project-id>" \
  -v $HOME/pathfinder:/usr/share/pathfinder/data \
  eqlabs/pathfinder
```

To check logs you can use:

```bash
sudo docker logs -f pathfinder
```

The node can be stopped using

```bash
sudo docker stop pathfinder
```


### Updating the Docker image

When pathfinder detects there has been a new release, it will log a message similar to:

```
WARN New pathfinder release available! Please consider updating your node! release=0.4.5
```

You can try pulling the latest docker image to update it:

```bash
sudo docker pull eqlabs/pathfinder
```

After pulling the updated image you should stop and remove the `pathfinder` container then re-create it with the exact same command
that was used above to start the node:

```bash
# This stops the running instance
sudo docker stop pathfinder
# This removes the current instance (using the old version of pathfinder)
sudo docker rm pathfinder
# This command re-creates the container instance with the latest version
sudo docker run \
  --name pathfinder \
  --restart unless-stopped \
  --detach \
  -p 9545:9545 \
  --user "$(id -u):$(id -g)" \
  -e RUST_LOG=info \
  -e PATHFINDER_ETHEREUM_API_URL="https://goerli.infura.io/v3/<project-id>" \
  -v $HOME/pathfinder:/usr/share/pathfinder/data \
  eqlabs/pathfinder
```

### Available images

Our images are updated on every `pathfinder` release. This means that the `:latest` docker image does not track our `main` branch here, but instead matches the latest `pathfinder` [release](https://github.com/eqlabs/pathfinder/releases).

### Docker compose

You can also use `docker-compose` if you prefer that to just using Docker.

Create the folder `pathfinder` where your `docker-compose.yaml` is

```bash
mkdir -p pathfinder

# replace the value by of PATHFINDER_ETHEREUM_API_URL by the HTTP(s) URL pointing to your Ethereum node's endpoint
cp example.pathfinder-var.env pathfinder-var.env

docker-compose up -d
```

To check if it's running well use `docker-compose logs -f`.

## Database Snapshots

Re-syncing the whole history for either the mainnet or testnet networks might take a long time. To speed up the process you can use database snapshot files that contain the full state and history of the network up to a specific block.

The database files are hosted on Cloudflare R2. There are two ways to download the files:

* Using the [Rclone](https://rclone.org/) tool
* Via the HTTPS URL: we've found this to be less reliable in general

### Rclone setup

We recommend using RClone. Add the following to your RClone configuration file (`$HOME/.config/rclone/rclone.conf`):

```ini
[pathfinder-snapshots]
type = s3
provider = Cloudflare
env_auth = false
access_key_id = 7635ce5752c94f802d97a28186e0c96d
secret_access_key = 529f8db483aae4df4e2a781b9db0c8a3a7c75c82ff70787ba2620310791c7821
endpoint = https://cbf011119e7864a873158d83f3304e27.r2.cloudflarestorage.com
acl = private
```

You can then download a compressed database using the command:

```shell
rclone copy -P pathfinder-snapshots:pathfinder-snapshots/testnet_0.9.0_880310.sqlite.zst .
```

### Uncompressing database snapshots

**To avoid issues please check that the SHA2-256 checksum of the compressed file you've downloaded matches the value we've published.**

We're storing database snapshots as SQLite database files compressed with [zstd](https://github.com/facebook/zstd). You can uncompress the files you've downloaded using the following command:

```shell
zstd -T0 -d testnet_0.9.0_880310.sqlite.zst -o goerli.sqlite
```

This produces uncompressed database file `goerli.sqlite` that can then be used by pathfinder.

### Available database snapshots

| Network     | Block  | Pathfinder version required | Filename                              | Download URL                                                                                        | Compressed size | SHA2-256 checksum of compressed file                               |
| ----------- | ------ | --------------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------ |
| testnet     | 880310 | >= 0.9.0                    | `testnet_0.9.0_880310.sqlite.zst`     | [Download](https://pub-1fac64c3c0334cda85b45bcc02635c32.r2.dev/testnet_0.9.0_880310.sqlite.zst)     | 102.36 GB       | `55f7e30e4cc3ba3fb0cd610487e5eb4a69428af1aacc340ba60cf1018b58b51c` |
| mainnet     | 309113 | >= 0.9.0                    | `mainnet_0.9.0_309113.sqlite.zst`     | [Download](https://pub-1fac64c3c0334cda85b45bcc02635c32.r2.dev/mainnet_0.9.0_309113.sqlite.zst)     | 279.85 GB       | `0430900a18cd6ae26465280bbe922ed5d37cfcc305babfc164e21d927b4644ce` |
| integration | 315152 | >= 0.9.1                    | `integration_0.9.1_315152.sqlite.zst` | [Download](https://pub-1fac64c3c0334cda85b45bcc02635c32.r2.dev/integration_0.9.1_315152.sqlite.zst) | 8.45 GB         | `2ad5ab46163624bd6d9aaa0dff3cdd5c7406e69ace78f1585f9d8f011b8b9526` |

## Configuration

The `pathfinder` node options can be configured via the command line as well as environment variables.

The command line options are passed in after the `docker run` options, as follows:

```bash
sudo docker run --name pathfinder [...] eqlabs/pathfinder:latest <pathfinder options>
```

Using `--help` will display the `pathfinder` options, including their environment variable names:

```bash
sudo docker run --rm eqlabs/pathfinder:latest --help
```

### Pending Support

Block times on `mainnet` can be prohibitively long for certain applications. As a workaround, Starknet added the concept of a `pending` block which is the block currently under construction. This is supported by pathfinder, and usage is documented in the [JSON-RPC API](#json-rpc-api) with various methods accepting `"block_id"="pending"`.

Note that `pending` support is disabled by default and must be enabled by setting `poll-pending=true` in the configuration options.

### Logging

Logging can be configured using the `RUST_LOG` environment variable.
We recommend setting it when you start the container:

```bash
sudo docker run --name pathfinder [...] -e RUST_LOG=<log level> eqlabs/pathfinder:latest
```

The following log levels are supported, from most to least verbose:

```bash
trace
debug
info  # default
warn
error
```

### Network Selection

The Starknet network can be selected with the `--network` configuration option.

If `--network` is not specified, network selection will default to match your Ethereum endpoint:

- Starknet mainnet for Ethereum mainnet,
- Starknet testnet for Ethereum Goerli

#### Custom networks & gateway proxies

You can specify a custom network with `--network custom` and specifying the `--gateway-url`, `feeder-gateway-url` and `chain-id` options. 
Note that `chain-id` should be specified as text e.g. `SN_GOERLI`.

This can be used to interact with a custom Starknet gateway, or to use a gateway proxy.

## JSON-RPC API

You can interact with Starknet using the JSON-RPC API. Pathfinder supports the official Starknet RPC API and in addition supplements this with its own pathfinder specific extensions such as `pathfinder_getProof`.

Currently pathfinder supports `v0.3`, `v0.4`, and `v0.5` versions of the Starknet JSON-RPC specification.
The `path` of the URL used to access the JSON-RPC server determines which version of the API is served:

- the `v0.3.0` API is exposed on the `/rpc/v0.3` and `/rpc/v0_3` path
- the `v0.4.0` API is exposed on the `/`, `/rpc/v0.4` and `/rpc/v0_4` path
- the `v0.5.1` API is exposed on the `/rpc/v0.5` and `/rpc/v0_5` path
- the pathfinder extension API is exposed on `/rpc/pathfinder/v0.1`

Note that the pathfinder extension is versioned separately from the Starknet specification itself.

### pathfinder extension API

You can find the API specification [here](doc/rpc/pathfinder_rpc_api.json).

## Monitoring API

Pathfinder has a monitoring API which can be enabled with the `--monitor-address` configuration option.

### Health

`/health` provides a method to check the health status of your `pathfinder` node, and is commonly useful in Kubernetes docker setups. It returns a `200 OK` status if the node is healthy.

### Readiness

`pathfinder` does several things before it is ready to respond to RPC queries. In most cases this startup time is less than a second, however there are certain scenarios where this can be considerably longer. For example, applying an expensive database migration after an upgrade could take several minutes (or even longer) on testnet. Or perhaps our startup network checks fail many times due to connection issues.

`/ready` provides a way of checking whether the node's JSON-RPC API is ready to be queried. It returns a `503 Service Unavailable` status until all startup tasks complete, and then `200 OK` from then on.

### Metrics

`/metrics` provides a [Prometheus](https://prometheus.io/) metrics scrape endpoint. Currently the following metrics are available:

#### RPC related counters

- `rpc_method_calls_total`,
- `rpc_method_calls_failed_total`,

You __must__ use the label key `method` to retrieve a counter for a particular RPC method, for example:
```
rpc_method_calls_total{method="starknet_getStateUpdate"}
rpc_method_calls_failed_total{method="starknet_chainId"}
```
You may also use the label key `version` to specify a particular version of the RPC API, for example:
```
rpc_method_calls_total{method="starknet_getEvents", version="v0.3"}
```

#### Feeder Gateway and Gateway related counters

- `gateway_requests_total`
- `gateway_requests_failed_total`

Labels:
- `method`, to retrieve a counter for a particular sequencer request type
- `tag`
    - works with: `get_block`, `get_state_update`
    - valid values:
        - `pending`
        - `latest`
- `reason`
    - works with: `gateway_requests_failed_total`
    - valid values:
        - `decode`
        - `starknet`
        - `rate_limiting`

Valid examples:
```
gateway_requests_total{method="get_block"}
gateway_requests_total{method="get_block", tag="latest"}
gateway_requests_failed_total{method="get_state_update"}
gateway_requests_failed_total{method="get_state_update", tag="pending"}
gateway_requests_failed_total{method="get_state_update", tag="pending", reason="starknet"}
gateway_requests_failed_total{method="get_state_update", reason="rate_limiting"}
```

These __will not work__:
- `gateway_requests_total{method="get_transaction", tag="latest"}`, `tag` is not supported for that `method`
- `gateway_requests_total{method="get_transaction", reason="decode"}`, `reason` is only supported for failures.

### Sync related metrics

- `current_block` currently sync'd block height of the node
- `highest_block` height of the block chain
- `block_time` timestamp difference between the current block and its parent
- `block_latency` delay between current block being published and sync'd locally
- `block_download` time taken to download current block's data excluding classes
- `block_processing` time taken to process and store the current block

### Build info metrics

- `pathfinder_build_info` reports curent version as a `version` property

## Build from source

See the [guide](https://github.com/eqlabs/pathfinder/blob/main/doc/install-from-source.md).

The above guide is inspired by [Pathfinder](https://github.com/eqlabs/pathfinder)



## Conclusion: 

This concludes our journey into running a Starknet node and traversing
its architecture. We hope that you now feel equipped to explore,
experiment with, and innovate within the Starknet ecosystem.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
