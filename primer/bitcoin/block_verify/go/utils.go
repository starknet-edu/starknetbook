package main

import (
	"fmt"
	"math"
	"strings"
	"math/big"
	"encoding/hex"
	// "crypto/sha256"
)

type Block struct {
	Hash         string   `json:"hash"`
	Ver          int64      `json:"ver"`
	PrevBlock    string   `json:"prev_block"`
	MrklRoot     string   `json:"mrkl_root"`
	Time         int64      `json:"time"`
	Bits         int64      `json:"bits"`
	Nonce        int64    `json:"nonce"`
	NTx          int64      `json:"n_tx"`
	Size         int64      `json:"size"`
	BlockIndex   int64      `json:"block_index"`
	MainChain    bool     `json:"main_chain"`
	Height       int64      `json:"height"`
	ReceivedTime int64      `json:"received_time"`
	RelayedBy    string   `json:"relayed_by"`
	Tx           []Transaction `json:"tx"`
}

type Transaction struct {
	Hash        string `json:"hash"`
	Ver         int64    `json:"ver"`
	VinSz       int64    `json:"vin_sz"`
	VoutSz      int64    `json:"vout_sz"`
	Size        int64    `json:"size"`
	Weight      int64    `json:"weight"`
	Fee         int64    `json:"fee"`
	RelayedBy   string `json:"relayed_by"`
	LockTime    int64    `json:"lock_time"`
	TxIndex     int64  `json:"tx_index"`
	DoubleSpend bool   `json:"double_spend"`
	Time        int64    `json:"time"`
	BlockIndex  int64    `json:"block_index"`
	BlockHeight int64    `json:"block_height"`
	Inputs      []struct {
		Sequence int64  `json:"sequence"`
		Witness  string `json:"witness"`
		Script   string `json:"script"`
		Index    int64    `json:"index"`
		PrevOut  struct {
			TxIndex           int64    `json:"tx_index"`
			Value             int64    `json:"value"`
			N                 int64  `json:"n"`
			Type              int64    `json:"type"`
			Spent             bool   `json:"spent"`
			Script            string `json:"script"`
			SpendingOutpoints []struct {
				TxIndex int64 `json:"tx_index"`
				N       int64   `json:"n"`
			} `json:"spending_outpoints"`
		} `json:"prev_out"`
	} `json:"inputs"`
	Out []struct {
		Type              int64           `json:"type"`
		Spent             bool          `json:"spent"`
		Value             int64           `json:"value"`
		SpendingOutpoints []interface{} `json:"spending_outpoints"`
		N                 int64           `json:"n"`
		TxIndex           int64         `json:"tx_index"`
		Script            string        `json:"script"`
		Addr              string        `json:"addr,omitempty"`
	} `json:"out"`
}


/*
	utils
*/
func Int64ToBytes(number int64) []byte {
    big := new(big.Int)
    big.SetInt64(number)
    return Reverse(big.Bytes())
}

func HexToBytes(hexString string) []byte {
	numStr := strings.Replace(hexString, "0x", "", -1)
	if (len(numStr) % 2) != 0 {
		numStr = fmt.Sprintf("%s%s", "0", numStr)
	}

	by, _ := hex.DecodeString(numStr)
	return Reverse(by)
}

// little endian conversions
func Reverse(numbers []byte) []byte {
	for i, j := 0, len(numbers)-1; i < j; i, j = i+1, j-1 {
		numbers[i], numbers[j] = numbers[j], numbers[i]
	}
	return numbers
}

func (block Block) GetMerkleRootQuiet() (root []byte) {
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
			merklePass = make([][]byte, 0)
		}
	}
	// flip merkle root to big endian
	if height % 2 == 0 {
		return Reverse(merkleHold[0])
	} else {
		return Reverse(merklePass[0])
	}
}