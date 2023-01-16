<h1 align="center">Bitcoin</h1>

### [Proof of Work](./proof_of_work)

In `GO`:

```bash
cd proof_of_work/go
go run main.go
```

In `Python`:

```bash
# proof of work example
cd proof_of_work/python
python main.py
```

### [Block Verification](./block_verification)

In `GO`:

Run verify benchmark

```bash
cd block_verification/go/
GO111MODULE=off go test ./... -bench=. -count 5
```

In `Rust`:

```bash
cd block_verification/rust/
cargo run
# or run the tests with
cargo test
```

In `Elixir`:

```bash
cd block_verification/elixir/
elixir bitcoin_validator.exs
```

#### Sources

- <https://github.com/bitcoin/bitcoin>
- <https://bitcoin.org/bitcoin.pdf>
- <https://developer.bitcoin.org/reference/block_chain.html>

---
upper_tags: [protocol, peer_to_peer, network, ledger, database, cryptocurrency]

lower_tags: [merkle_tree, transaction, node, client, miner, block, hash, secure_hashing_algorithm_256, application_specific_integrated_circuit, timestamp, consensus, proof_of_work, unspent_transaction_output]
