package main

import (
	"fmt"
)

type Trie interface {
	Get(key []byte) ([]byte, bool)
	Put(key []byte, value []byte)
	Del(key []byte, value []byte) bool
}

