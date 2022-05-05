package main

import (
	"fmt"
	"os"
	"math"
	"bytes"
	"strings"
	"encoding/json"
	"crypto/sha256"
)

func main() {
    rawBlockFile, err := os.ReadFile("../rawBTCBlock.json")
	if err != nil {
		panic(err.Error())
	}
	var block Block
	err = json.Unmarshal(rawBlockFile, &block)
	if err != nil {
		panic(err.Error())
	}

	// first we will trust the merkle root
	hash, err := block.HashBlock()
	if err != nil {
		panic(err.Error())
	}

	fmt.Printf("Given Hash: \t\t%s\n", block.Hash)
	fmt.Printf("Calculated Hash: \t%x\n", hash)
	fmt.Println("Match: ", fmt.Sprintf("%x", hash) == block.Hash)
	fmt.Print("\n\n")

	root := block.GetMerkleRoot()
	fmt.Println("Given Merkle Root: ", block.MrklRoot)
	fmt.Printf("Calculated Merkle Root: %x\n", root)
	fmt.Println("Match: ", fmt.Sprintf("%x", root) == block.MrklRoot)
	fmt.Print("\n\n")
}

func (block Block) HashBlock() ([]byte, error) {
	header := block.FmtHeader()

	hashBytes := sha256.Sum256(header[:])
	hashBytes = sha256.Sum256(hashBytes[:])

	return  Reverse(hashBytes[:]), nil
}

func (block Block) GetMerkleRoot() (root []byte) {
	var merkleHold [][]byte
	var merklePass [][]byte

	// format transaction hashes in little endian
	for _, tx := range block.Tx {
		merkleHold = append(merkleHold, HexToBytes(tx.Hash))
	}

	// ensure even leaves
	if len(merkleHold) % 2 == 1 {
		merkleHold = append(merkleHold, merkleHold[len(merkleHold)-1])
	}

	// get the merkle tree height
	height := int(math.Ceil(math.Log2(float64(len(merkleHold)))))
	fmt.Println("Num leaves: ", len(merkleHold))
	fmt.Println("Rounds: ", height)

	for i := 0; i < height; i++ {
		if i % 2 == 0 {
			// ensure even nodes
			if len(merkleHold) % 2 == 1 {
				merkleHold = append(merkleHold, merkleHold[len(merkleHold)-1])
			}

			// hash adjacent nodes in the row
			for j := 0; j < len(merkleHold); j += 2 {
				merklePass = append(merklePass, hashFunc(append(merkleHold[j], merkleHold[j+1]...)))
			}

			fmt.Printf("Round %d: %s 0x%x %s 0x%x \n", i, strings.Repeat("  ", i), merklePass[0][:4], strings.Repeat("....", height - i), merklePass[len(merklePass)-1][:4])
			merkleHold = make([][]byte, 0)
		} else {
			// ensure even nodes
			if len(merklePass) % 2 == 1 {
				merklePass = append(merklePass, merklePass[len(merklePass)-1])
			}

			// hash adjacent nodes in the row
			for j := 0; j < len(merklePass); j += 2 {
				merkleHold = append(merkleHold, hashFunc(append(merklePass[j], merklePass[j+1]...)))
			}

			fmt.Printf("Round %d: %s 0x%x %s 0x%x \n", i, strings.Repeat("  ", i), merkleHold[0][:4], strings.Repeat("....", height - i), merkleHold[len(merkleHold)-1][:4])
			merklePass = make([][]byte, 0)
		}
	}
	fmt.Print()

	// flip merkle root to big endian
	if height % 2 == 0 {
		return Reverse(merkleHold[0])
	} else {
		return Reverse(merklePass[0])
	}
}

func hashFunc(data []byte) []byte {
	hash := sha256.Sum256(data)
	hash = sha256.Sum256(hash[:])
	return hash[:]
}

func (block Block) FmtHeader() []byte {
	var buf bytes.Buffer
	_, err := buf.Write(Int64ToBytes(block.Ver))
	_, err = buf.Write(HexToBytes(block.PrevBlock))
	_, err = buf.Write(HexToBytes(block.MrklRoot))
	_, err = buf.Write(Int64ToBytes(block.Time))
	_, err = buf.Write(Int64ToBytes(block.Bits))
	_, err = buf.Write(Int64ToBytes(block.Nonce))
	if err != nil {
		return buf.Bytes()
	}
	return buf.Bytes()
}
