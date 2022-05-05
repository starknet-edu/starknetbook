package main

import (
	"os"
	"fmt"
	"testing"
	"encoding/json"
)

func BenchmarkBlockHash(b *testing.B) {
	rawBlockFile, err := os.ReadFile("../rawBTCBlock.json")
	if err != nil {
		panic(err.Error())
	}
	var block Block
	err = json.Unmarshal(rawBlockFile, &block)
	if err != nil {
		panic(err.Error())
	}

	for i := 0; i < b.N; i++ {
		block.MrklRoot = fmt.Sprintf("%x", block.GetMerkleRootQuiet())
		_, err = block.HashBlock()
		if err != nil {
			panic(err.Error())
		}
	}
}

func BenchmarkReadFile(b *testing.B) {
    f, err := os.Create("bank.txt")
    if err != nil {
		panic(err.Error())
	}
	_, err = f.WriteString("account XYZ: 5.00\n")
    if err != nil {
		panic(err.Error())
	}
	f.Close()

	for i := 0; i < b.N; i++ {
		_, _ = os.ReadFile("bank.txt")
	}
}