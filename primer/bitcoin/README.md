<h1 align="center">Bitcoin</h1>

### [Proof of Work](./proof_of_work)
```
cd proof_of_work/go
go run main.go
```

### [Block Verification](./block_verification)
```
cd block_verification/
curl https://blockchain.info/rawblock/0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947 > rawBTCBlock.json
cd go/
go run *.go
```

Run verify benchmark
```
cd verify/go/
go test -bench=. -count 5
```


#### Sources:
- https://github.com/bitcoin/bitcoin
- https://bitcoin.org/bitcoin.pdf
- https://developer.bitcoin.org/reference/block_chain.html

---
upper_tags: [protocol, peer_to_peer, network, ledger, database, cryptocurrency]

lower_tags: [merkle_tree, transaction, node, client, miner, block, hash, secure_hashing_algorithm_256, application_specific_integrated_circuit, timestamp, consensus, proof_of_work, unspent_transaction_output]