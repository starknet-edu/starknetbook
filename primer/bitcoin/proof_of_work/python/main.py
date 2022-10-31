from hashlib import sha256
import time
import json

class Block:
    def __init__(self, index, transactions, timestamp, previousHash = '', nonce = 0):        
        self.index = index
        self.transactions = transactions
        self.timestamp = timestamp
        self.previousHash = previousHash
        self.nonce = nonce

    def createHash(self):
        encodedBlock = json.dumps(self.__dict__, sort_keys=True).encode()
        return sha256(encodedBlock).hexdigest()

class Blockchain:
    def __init__(self):
        self.difficulty = 5
        self.chain = []
        self.unconfirmedTransactions = []
        self.createGenesisBlock()
    
    def createGenesisBlock(self):
        genesisBlock = Block(0, ['Genesis Block'], time.time(), '')
        genesisBlock.hash = genesisBlock.createHash()
        print('Mining the block containing "Genesis Block"')
        while not genesisBlock.hash.startswith('0' * self.difficulty):
            genesisBlock.nonce += 1
            genesisBlock.hash = genesisBlock.createHash()
            print(genesisBlock.hash, end='\r')
        print(genesisBlock.hash + '\n')
        self.chain.append(genesisBlock)
    
    @property
    def lastBlock(self):
        return self.chain[-1]

    def printBlock(self):
        length = len(self.chain)
        for i in range(length):
            print("Block: "+str(self.chain[i].index))
            print("Previous Hash: "+self.chain[i].previousHash)
            print("Transaction: "+' '.join(self.chain[i].transactions))
            print("Nonce: "+str(self.chain[i].nonce))
            print("Hash: "+self.chain[i].hash + '\n')

    def proofOfWork(self, block):
        block.nonce = 0
        createdHash = block.createHash()
        while not createdHash.startswith('0' * self.difficulty):
            block.nonce += 1
            createdHash = block.createHash()
            print(createdHash, end='\r')
        print(createdHash + '\n')
        return createdHash
    
    def addBlock(self, block, proof):
        previousHash = self.lastBlock.hash
        if previousHash != block.previousHash:
            return False
        if not self.isValidProof(block, proof):
            return False
        block.hash = proof
        self.chain.append(block)
        return True
    
    def isValidProof(self, block, blockHash):
        return blockHash.startswith('0' * self.difficulty) and blockHash == block.createHash()
    
    def addNewTransaction(self, transactions):
        print('Mining the block containing "' + transactions + '"')
        self.unconfirmedTransactions.append(transactions)

    def mine(self):
        if not self.unconfirmedTransactions:
            return False
        
        lastBlock = self.lastBlock

        newBlock = Block(index = lastBlock.index + 1,
                        transactions = self.unconfirmedTransactions,
                        timestamp = time.time(),
                        previousHash = lastBlock.hash)
        
        proof = self.proofOfWork(newBlock)
        self.addBlock(newBlock, proof)
        self.unconfirmedTransactions = []
        return newBlock.index

def main():
    bitcoin = Blockchain()

    bitcoin.addNewTransaction("Send 1 BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.addNewTransaction("Send 2 more BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.addNewTransaction("Send 5 more BTC to Nick Cage")
    bitcoin.mine()

    bitcoin.printBlock()

if __name__=="__main__":
    main()