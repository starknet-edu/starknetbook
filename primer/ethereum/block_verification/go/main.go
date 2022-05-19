
package main

import (
	"fmt"
	"bytes"
	"strings"

	"github.com/ethereum/go-ethereum/rlp"
)

func main() {
	// Trie keys for TransactionRoot are the RLP encoded transaction indeces
	spacer := strings.Repeat("-", 10)
	fmt.Printf("%s Yellowpaper Example %s\n", spacer, spacer)
	yellow := NewTrie()
	k0, _ := rlp.EncodeToBytes("a711355")
	yellow.Put(k0, []byte("45.0 ETH"))

	k1, _ := rlp.EncodeToBytes("a77d4337")
	yellow.Put(k1, []byte("1.00 WEI"))

	k2, _ := rlp.EncodeToBytes("a779365")
	yellow.Put(k2, []byte("1.1 ETH"))

	k3, _ := rlp.EncodeToBytes("a77d397")
	yellow.Put(k3, []byte("0.12 ETH"))

	proof, ok := yellow.Prove(k2)
	if !ok {
		panic(fmt.Errorf("could not prove valid key"))
	}
	val, err := Verify(yellow.Hash(), k2, proof)
	if err != nil {
		panic(err.Error())
	}

	yellow.Walk(4)
	fmt.Println("Key Proof length: ", len(proof))
	fmt.Printf("Key Proof Verified: true %v\n\n\n\n", val)

	/*
		---------------- To see other implementations of Ethereum Tries uncomment the following and run w/ your INFURA/NODE URL ------------------
		INFURA_URL=https://mainnet.infura.io/v3/<INFURA_ID> go run *.go
	*/ 
	// fmt.Printf("%s Transaction Walk %s\n", spacer, spacer)
	// walk := NewTrie()
	// _, txs, _ := pullBlock("0xA1A489")
	// for i, tx := range txs {
	// 	key, err := rlp.EncodeToBytes(uint(i))
	// 	if err != nil {
	// 		panic(err.Error())
	// 	}
	// 	walk.Put(key, tx)
	// }
	// walk.Walk(len(txs))
	// fmt.Printf("\n\n")

	// fmt.Printf("%s Transaction Hash %s\n", spacer, spacer)

	// trie := NewTrie()
	// header, txs, receipts := pullBlock("0xA1A48A")
	// for i, tx := range txs {
	// 	key, err := rlp.EncodeToBytes(uint(i))
	// 	if err != nil {
	// 		panic(err.Error())
	// 	}
	// 	trie.Put(key, tx)
	// }

	// fmt.Printf("Computed Transaction Hash: \t0x%x\n", trie.Hash())
	// fmt.Printf("Transaction Hash: \t0x%x\n\n", header.TxHash)

	// // Trie keys for ReceiptRoot are the RLP encoded transaction receipt indeces
	// receiptTrie := NewTrie()
	// fmt.Println("receipts: ", len(receipts))
	// for i, rec := range receipts {
	// 	key, err := rlp.EncodeToBytes(uint(i))
	// 	if err != nil {
	// 		panic(err.Error())
	// 	}
	// 	receiptTrie.Put(key, rec)
	// }
	// fmt.Printf("Computed Receipt Hash: \t0x%v\n", receiptTrie.Hash())
	// fmt.Printf("Receipt Hash: \t0x%x\n\n", header.ReceiptHash)
}

func (t *Trie) Put(key, val []byte) {
	node := &t.root
	nibbles := FromBytes(key)
	common := 0
	for {
		if IsEmptyNode(*node) {
			*node = &LeafNode{
				Rest:  nibbles,
				Value: val,
			}
			return
		}

		switch n := (*node).(type) {
		case *LeafNode:
			matched := PrefixMatchedLen(n.Rest, nibbles[common:])
			branch := &BranchNode{}
			idx := bytes.IndexByte(Indeces, byte(nibbles[common+matched]))
			if matched > 0 {
				ext := &ExtensionNode{
					Shared: n.Rest[:matched],
				}
				branch.Branches[idx] = &LeafNode{nibbles[common+matched+1:], val}
				branch.Branches[n.Rest[matched]] = &LeafNode{n.Rest[matched+1:], n.Value}
				ext.Next = branch
				*node = ext
				return
			}

			if len(nibbles[common:]) == 1 {
				branch.Branches[idx] = &LeafNode{[]Nibble{}, val}
			} else {
				branch.Branches[idx] = &LeafNode{nibbles[common+1:], val}
			}
			if len(n.Rest) == 1 {
				branch.Branches[n.Rest[0]] = &LeafNode{[]Nibble{}, n.Value}
			} else {
				branch.Branches[n.Rest[0]] = &LeafNode{n.Rest[1:], n.Value}
			}
			*node = branch
			return
		case *BranchNode:
			idx := bytes.IndexByte(Indeces, byte(nibbles[common]))
			if n.Branches[idx] == nil {
				if len(nibbles[common:]) == 1 {
					n.Branches[idx] = &LeafNode{[]Nibble{}, val}
					return
				}

				n.Branches[idx] = &LeafNode{nibbles[common+1:], val}
				return
			}
			common++
			node = &n.Branches[idx]
		case *ExtensionNode:
			matched := PrefixMatchedLen(n.Shared, nibbles[common:])
			if matched < len(n.Shared) {
				branch := &BranchNode{}
				branch.Branches[nibbles[common]] = &LeafNode{nibbles[common+1:], val}
				branch.Branches[n.Shared[matched]] = n.Next
				*node = branch
				return
			}
			common += len(n.Shared)

			node = &n.Next
		default:
			panic("unknown node type")
		}
	}
}

func (t *Trie) Prove(key []byte) (Proof, bool) {
	proof := make(map[string][]byte)
	node := t.root
	nibbles := FromBytes(key)

	for {
		proof[fmt.Sprintf("%x", Hash(node))] = Serialize(node)

		if IsEmptyNode(node) {
			return nil, false
		}

		switch n := node.(type) {
		case *LeafNode:
			matched := PrefixMatchedLen(n.Rest, nibbles)
			if matched != len(n.Rest) || matched != len(nibbles) {
				return nil, false
			}
			return proof, true

		case *BranchNode:
			if len(nibbles) == 0 {
				return proof, n.HasValue()
			}

			b, remaining := nibbles[0], nibbles[1:]
			nibbles = remaining
			node = n.Branches[b]

		case *ExtensionNode:
			matched := PrefixMatchedLen(n.Shared, nibbles)
			if matched < len(n.Shared) {
				return nil, false
			}

			nibbles = nibbles[matched:]
			node = n.Next

		}
	}
}

func Verify(rootHash, key []byte, proof Proof) ([]byte, error) {
	key = keybytesToHex(key)
	wantHash := rootHash
	
	for i := 0; ; i++ {
		val, ok := proof[fmt.Sprintf("%x", wantHash)]
		if !ok {
			return nil, fmt.Errorf("superman no home")
		}

		rawNode, err := decodeNode(wantHash[:], val)
		if err != nil {
			return nil, fmt.Errorf("superman no home")
		}

		rest, node := get(rawNode, key, true)

		switch n := node.(type) {
		case nil:
			return nil, nil
		case hashNode:
			key = rest
			copy(wantHash[:], n)
		case valueNode:
			return n, nil
		}
	}
}