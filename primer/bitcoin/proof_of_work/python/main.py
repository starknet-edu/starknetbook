from hashlib import sha256
import time
import json

class Block:

    def __init__(self, index, transactions, timestamp, previous_hash = '', nonce = 0):
        self.index = index
        self.transactions = transactions
        self.timestamp = timestamp
        self.previous_hash = previous_hash
        self.nonce = nonce

    def create_hash(self):
        encoded_block = json.dumps(self.__dict__, sort_keys=True).encode()
        return sha256(encoded_block).hexdigest()

class Blockchain:

    def __init__(self):
        self.difficulty = 5
        self.chain = []
        self.unconfirmed_transactions = []
        self.create_genesis_block()

    def create_genesis_block(self):
        genesis_block = Block(0, ['Genesis Block'], time.time(), '')
        genesis_block.hash = genesis_block.create_hash()
        print('Mining the block containing "Genesis Block"')
        while not genesis_block.hash.startswith('0' * self.difficulty):
            genesis_block.nonce += 1
            genesis_block.hash = genesis_block.create_hash()
            print(genesis_block.hash, end='\r')
        print(genesis_block.hash + '\n')
        self.chain.append(genesis_block)

    @property
    def last_block(self):
        return self.chain[-1]

    def print_block(self):
        length = len(self.chain)
        for i in range(length):
            print("Block: "+str(self.chain[i].index))
            print("Previous Hash: "+self.chain[i].previous_hash)
            print("Transaction: "+' '.join(self.chain[i].transactions))
            print("Nonce: "+str(self.chain[i].nonce))
            print("Hash: "+self.chain[i].hash + '\n')

    def proof_of_work(self, block):
        block.nonce = 0
        created_hash = block.create_hash()
        while not created_hash.startswith('0' * self.difficulty):
            block.nonce += 1
            created_hash = block.create_hash()
            print(created_hash, end='\r')
        print(created_hash + '\n')
        return created_hash

    def add_block(self, block, proof):
        previous_hash = self.last_block.hash
        if previous_hash != block.previous_hash:
            return False
        if not self.is_valid_proof(block, proof):
            return False
        block.hash = proof
        self.chain.append(block)
        return True

    def is_valid_proof(self, block, block_hash):
        return block_hash.startswith('0' * self.difficulty) and block_hash == block.create_hash()

    def add_new_transaction(self, transactions):
        print('Mining the block containing "' + transactions + '"')
        self.unconfirmed_transactions.append(transactions)

    def mine(self):
        if not self.unconfirmed_transactions:
            return False

        last_block = self.last_block

        new_block = Block(index = last_block.index + 1,
                        transactions = self.unconfirmed_transactions,
                        timestamp = time.time(),
                        previous_hash = last_block.hash)

        proof = self.proof_of_work(new_block)
        self.add_block(new_block, proof)
        self.unconfirmed_transactions = []
        return new_block.index

def main():
    bitcoin = Blockchain()

    bitcoin.add_new_transaction("Send 1 BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.add_new_transaction("Send 2 more BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.add_new_transaction("Send 5 more BTC to Nick Cage")
    bitcoin.mine()

    bitcoin.print_block()

if __name__=="__main__":
    main()
