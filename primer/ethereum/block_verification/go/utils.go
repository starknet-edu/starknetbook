package main

import (
	"os"
	"fmt"
	"bytes"
	"strconv"
	"strings"

	"github.com/ethereum/go-ethereum/rpc"
	"github.com/ethereum/go-ethereum/core/types"
)

func (t *Trie) Walk(nLeaves int) {
	node := t.root
	leaf := [][]Nibble{}
	leaves := 0
	for {
		if leaves >= nLeaves {
			return
		}
		if IsEmptyNode(node) {
			fmt.Println("Empty Node")
			return
		}

		switch n := node.(type) {
		case *LeafNode:
			fmt.Println("TRIE HAS ONE VALUE: ", n)

		case *BranchNode:
			fmt.Printf("Branch(%v):\n[", leaf)
			for i, elem := range n.Branches {
				if elem != nil {
					if _, ok := elem.(*BranchNode); ok {
						fmt.Printf("%x:   BRANCH   | ", Indeces[i])
					} 
					if _, ok := elem.(*LeafNode); ok {
						fmt.Printf("%x:   LEAF   | ", Indeces[i])
					}
					if _, ok := elem.(*ExtensionNode); ok {
						fmt.Printf("%x:   EXT   | ", Indeces[i])
					}
				} else {
					fmt.Printf("%x: - | ", Indeces[i])
				}
			}
			fmt.Println("]")
			for j, elem := range n.Branches {
				if elem != nil {
					if ileaf, ok := elem.(*LeafNode); ok {
						raw := leaf
						raw = append(raw, []Nibble{Nibble(Indeces[j])})
						if len(ileaf.Rest) > 0 {
							raw = append(raw, ileaf.Rest)
						}
						spacer := fmt.Sprintf("%s%s", strings.Repeat("\t", j), strings.Repeat(" ", j/2))
						fmt.Printf("%sLeaf(%x):\n%s%v\n%s--> %x\n\n", spacer, j, spacer, raw, spacer, ileaf.Value[:4])
						leaves++
					}
				}
			}
			for j, elem := range n.Branches {
				if elem != nil {
					if ext, ok := elem.(*ExtensionNode); ok {
						node = ext.Next
						break
					}
					if _, ok := elem.(*BranchNode); ok {
						leaf = append(leaf, []Nibble{Nibble(Indeces[j])})
						node = elem
						break
					}
				}
			}

		case *ExtensionNode:
			fmt.Printf("%sExtension: nibbles %v\n", strings.Repeat("\t\t\t\t\t", (nLeaves - leaves)/2), n.Shared)
			leaf = append(leaf, n.Shared)
			node = n.Next
		}
	}
}

func pullBlock(blockNum string) (header types.Header, txs [][]byte, receipts [][]byte) {
	if os.Getenv("INFURA_URL") == "" {
		panic("Please provide valid url and set via: 'export INFURA_URL=<URL>'")
	}
	client, err := rpc.DialHTTP(os.Getenv("INFURA_URL"))
	if err != nil {
		panic(err.Error())
	}
	defer client.Close()

	var txNumStr string
	if err := client.Call(&txNumStr, "eth_getBlockTransactionCountByNumber", blockNum); err != nil {
		panic(err.Error())
	}
	txNum, _ := strconv.ParseInt(txNumStr[2:], 16, 64)

	for i := 0; i < int(txNum); i++ {
		var tx *types.Transaction
		if err := client.Call(&tx, "eth_getTransactionByBlockNumberAndIndex", blockNum, fmt.Sprintf("0x%x", i)); err != nil {
			panic(err.Error())
		}
		var buf bytes.Buffer
		err = tx.EncodeRLP(&buf)
		txs = append(txs, buf.Bytes())

		var receipt *types.Receipt
		if err := client.Call(&receipt, "eth_getTransactionReceipt", tx.Hash()); err != nil {
			panic(err.Error())
		}

		var buf2 bytes.Buffer
		err = receipt.EncodeRLP(&buf2)
		receipts = append(receipts, buf2.Bytes())
	}

	if err := client.Call(&header, "eth_getBlockByNumber", blockNum, false); err != nil {
		panic(err.Error())
	}
	var parent types.Header
	if err := client.Call(&parent, "eth_getBlockByHash", header.ParentHash, false); err != nil {
		panic(err.Error())
	}
	fmt.Printf("PARENT: %v\n", parent.Root)
	panic("just testing")

	return header, txs, receipts
}


func FromByte(b byte) []Nibble {
	return []Nibble{
		Nibble(byte(b >> 4)),
		Nibble(byte(b % 16)),
	}
}

func FromBytes(bs []byte) []Nibble {
	ns := make([]Nibble, 0, len(bs)*2)
	for _, b := range bs {
		ns = append(ns, FromByte(b)...)
	}
	return ns
}

func ToPrefixed(ns []Nibble, isLeafNode bool) []Nibble {
	// create prefix
	var prefixBytes []Nibble
	// odd number of nibbles
	if len(ns)%2 > 0 {
		prefixBytes = []Nibble{1}
	} else {
		// even number of nibbles
		prefixBytes = []Nibble{0, 0}
	}

	// append prefix to all nibble bytes
	prefixed := make([]Nibble, 0, len(prefixBytes)+len(ns))
	prefixed = append(prefixed, prefixBytes...)
	for _, n := range ns {
		prefixed = append(prefixed, Nibble(n))
	}

	// update prefix if is leaf node
	if isLeafNode {
		prefixed[0] += 2
	}

	return prefixed
}

func ToBytes(ns []Nibble) []byte {
	buf := make([]byte, 0, len(ns)/2)

	for i := 0; i < len(ns); i += 2 {
		b := byte(ns[i]<<4) + byte(ns[i+1])
		buf = append(buf, b)
	}

	return buf
}

func PrefixMatchedLen(node1 []Nibble, node2 []Nibble) int {
	matched := 0
	for i := 0; i < len(node1) && i < len(node2); i++ {
		n1, n2 := node1[i], node2[i]
		if n1 == n2 {
			matched++
		} else {
			break
		}
	}

	return matched
}