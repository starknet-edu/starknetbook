package main

import (
	"fmt"
	"math"
	"time"
	"bytes"
	// "strconv"
	"math/big"
	"crypto/sha256"
)

// block header storing the difficulty that the block was mined
const targetBits = 20

var maxNonce int64 = math.MaxInt64

// Blockchain keeps a sequence of Blocks
type Blockchain struct {
	blocks []*Block
}

type ProofOfWork struct {
	block *Block
	target *big.Int
}

type Block struct {
	Timestamp     int64
	Data          []byte
	PrevBlockHash []byte
	Hash          []byte
	Nonce         int64
}

func main() {
	bitcoin := NewBlockchain()

	bitcoin.AddBlock("Send 1 BTC to Nick Cage")
	bitcoin.AddBlock("Send 2 more BTC to Nick Cage")
	bitcoin.AddBlock("Send 5 more BTC to Nick Cage")

	for i, block := range bitcoin.blocks {
		fmt.Println("BLOCK: ", i)
		fmt.Printf("Prev hash: %x\n", block.PrevBlockHash)
		fmt.Printf("Data: %x\n", block.Data)
		fmt.Printf("Hash: %x\n", block.Hash)
	}
}

func (pow *ProofOfWork) Run() (nonce int64, hash [32]byte) {
	fmt.Printf("Mining the block containing \"%s\"\n", pow.block.Data)
	for nonce < maxNonce {
		data, err := pow.prepareData(nonce)
		if err != nil {
			fmt.Println("ERR: ", err)
		}
		hash = sha256.Sum256(data)
		fmt.Printf("\r%x", hash)
		hashInt := new(big.Int).SetBytes(hash[:])

		if hashInt.Cmp(pow.target) == -1 {
			break
		} else {
			nonce++
		}
	}
	fmt.Print("\n\n")

	return nonce, hash
}

func NewProofOfWork(b *Block) *ProofOfWork {
	target := big.NewInt(1)
	
	// Target is the upper bound of the PoW answer(ex: 0x10000000000000000000000000000000000000000000000000000000000)
	// - lowering the target will increase PoW difficulty as there are less valid answers
	target.Lsh(target, uint(256-targetBits))

	pow := &ProofOfWork{b, target}

	return pow
}

func NewBlock(data string, prevBlockHash []byte) *Block {
	block := &Block{
		Timestamp: time.Now().Unix(),
		Data: []byte(data),
		PrevBlockHash: prevBlockHash,
	}

	pow := NewProofOfWork(block)
	nonce, hash := pow.Run()

	block.Hash = hash[:]
	block.Nonce = nonce

	return block
}

// NewBlockchain creates a new Blockchain with genesis Block
func NewBlockchain() *Blockchain {
	return &Blockchain{[]*Block{NewBlock("Genesis Block", []byte{})}}
}

func (pow *ProofOfWork) prepareData(nonce int64) (data []byte, err error) {
	var buf bytes.Buffer
	_, err = buf.Write(pow.block.PrevBlockHash)
	_, err = buf.Write(pow.block.Data)
	_, err = buf.Write(Int64ToBytes(pow.block.Timestamp))
	_, err = buf.Write(Int64ToBytes(int64(targetBits)))
	_, err = buf.Write(Int64ToBytes(nonce))
	if err != nil {
		return data, err
	}
	return buf.Bytes(), nil
}

// AddBlock saves provided data as a block in the blockchain
func (bc *Blockchain) AddBlock(data string) {
	prevBlock := bc.blocks[len(bc.blocks)-1]
	newBlock := NewBlock(data, prevBlock.Hash)
	bc.blocks = append(bc.blocks, newBlock)
}

// IntToHex converts an int64 to a byte array
func Int64ToBytes(number int64) []byte {
    big := new(big.Int)
    big.SetInt64(number)
    return big.Bytes()
}