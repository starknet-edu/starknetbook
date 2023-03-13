package main

import (
	"os"
	"fmt"
	"testing"
)

func BenchmarkBlockHash(b *testing.B) {
	block := pullBlock("0000000000000000000836929e872bb5a678546b0a19900b974c206c338f0947")

	for i := 0; i < b.N; i++ {
		block.MrklRoot = fmt.Sprintf("%x", block.GetMerkleRootQuiet())
		_, err := block.HashBlock()
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

	err = os.Remove("bank.txt")
	if err != nil {
		panic(err.Error())
	}
}
