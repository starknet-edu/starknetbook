package main

import (
	"fmt"
	"net/http"
	"encoding/json"
)

const ETH_EXPLORER_URL = "https://api.blockcypher.com/v1/eth/main"

type Trie interface {
	Get(key []byte) ([]byte, bool)
	Put(key []byte, value []byte)
	Del(key []byte, value []byte) bool
}

func pullBlock(blockHeight string) Block {
	client := &http.Client {}
	req, err := http.NewRequest(http.MethodGet, ETH_EXPLORER_URL + "/blocks/" + blockHash, nil)
	if err != nil {
	  panic(err.Error())
	}
	res, err := client.Do(req)
	if err != nil {
		panic(err.Error())
	}
	defer res.Body.Close()

	var block Block
	json.NewDecoder(res.Body).Decode(&block)
	return block
}