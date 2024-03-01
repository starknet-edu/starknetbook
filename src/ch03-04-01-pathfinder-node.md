# Implementing a Pathfinder Node

### Hardware Recommendations for Pathfinder Node

To ensure optimal performance and reliability, the following hardware is recommended for running a Pathfinder node:

- **CPU**: Intel Core i7-9700 or AMD Ryzen 7 3700X
- **Memory**: 32GB
- **Storage**: 1TB SSD
- **Network**: Gigabit Ethernet

### Estimated Costs for Recommended Hardware

The approximate pricing in USD for the recommended hardware is:

- **CPU**: $300
- **Memory**: $100
- **Storage**: $100
- **Network Hardware**: $50

Total estimated cost: Approximately $550.

## Running Pathfinder Node Using Docker

For those who prefer a self-managed setup of all dependencies, refer to the comprehensive [Installation from Source](https://github.com/eqlabs/pathfinder/blob/main/doc/install-from-source.md) guide.

### Prerequisites

- Ensure [Docker is installed](https://docs.docker.com/get-docker/). For Ubuntu, use `sudo snap install docker`.

### Setup and Execution

1. **Prepare Data Directory**:

Create a data directory, `$HOME/pathfinder`, to store persistent files used by `pathfinder`:

```bash
mkdir -p $HOME/pathfinder
```

2. **Start Pathfinder Node**:

Run the `pathfinder` node using Docker with the following command:

```bash
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

3. **Monitoring Logs**:

To view the node logs, use:

```bash
sudo docker logs -f pathfinder
```

4. **Stopping Pathfinder Node**:

To stop the node, use:

```bash
sudo docker stop pathfinder
```

This setup ensures the Pathfinder node operates efficiently with automatic restarts and background running capabilities.

### Updating the Pathfinder Docker Image

When a new Pathfinder release is available, the node will log a message like:

```
WARN New pathfinder release available! Please consider updating your node! release=0.4.5
```

#### Update Steps

1. Pull the Latest Docker Image:

```bash
sudo docker pull eqlabs/pathfinder
```

2. Stop and Remove the Current Container:

```bash
sudo docker stop pathfinder
sudo docker rm pathfinder
```

3. Re-create the Container with the New Image:

Use the same command as before to start the node

```bash
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

### Docker Image Availability

The `:latest` docker image corresponds with the latest [Pathfinder release](https://github.com/eqlabs/pathfinder/releases), not the `main` branch.

### Using Docker Compose

Alternatively, **`docker-compose`** can be used.

1. Setup:

Create the folder `pathfinder` where your `docker-compose.yaml` is.

```bash
mkdir -p pathfinder
# replace the value by of PATHFINDER_ETHEREUM_API_URL by the HTTP(s) URL pointing to your Ethereum node's endpoint
cp example.pathfinder-var.env pathfinder-var.env
docker-compose up -d
```

2. Check logs:

```bash
docker-compose logs -f
```

## Database Snapshots

Re-syncing the whole history for either the mainnet or testnet networks might take a long time. To speed up the process you can use database snapshot files that contain the full state and history of the network up to a specific block.

The database files are hosted on Cloudflare R2. There are two ways to download the files:

- Using the [Rclone](https://rclone.org/) tool
- Via the HTTPS URL: we've found this to be less reliable in general

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

### Pathfinder extension API

You can find the API specification [here](https://github.com/eqlabs/pathfinder/blob/main/doc/rpc/pathfinder_rpc_api.json).

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

You **must** use the label key `method` to retrieve a counter for a particular RPC method, for example:

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

These **will not work**:

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
