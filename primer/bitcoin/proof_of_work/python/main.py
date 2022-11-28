"""
sha256 - Used for creating hash.
time - Used for getting current timestamp.
json - For encoding the block content.
"""
import json
import time
from hashlib import sha256


class Block:
    """
    Block
    -----
    Block class contains the information of a single Block
    along with a function to calculate the hash.

    Attributes
    ----------
    self.index = The Block Number.
    self.transactions = The Block Transaction(s).
    self.timestamp = The Block Timestamp.
    self.previous_hash = The hash of previous block.
    self.nonce = The block nonce.
    self.hash = The block hash.

    Methods
    -------
    create_hash(self)

    """

    def __init__(self, index, transactions, timestamp, previous_hash="", nonce=0):
        """
        __init__
        --------
        Initialized the block parameters.

        Parameters
        ----------
        index - The block index number.
        transactions - The transactions to be added to this particular block.
        timestamp - The block timestamp.
        previous_hash - The hash of the previous block.
        nonce - The block nonce.

        """
        self.index = index
        self.transactions = transactions
        self.timestamp = timestamp
        self.previous_hash = previous_hash
        self.nonce = nonce

    def create_hash(self):
        """
        create_hash
        -----------
        To create the hash of a block.

        Return
        ------
        Returns the SHA256 hash of the block.

        """
        encoded_block = json.dumps(self.__dict__, sort_keys=True).encode()
        return sha256(encoded_block).hexdigest()


class Blockchain:
    """
    Blockchain
    ----------
    Blockchain class contains the blockchain parameters and corresponding methods for proper
    functioning of that Blockchain.


    Attributes
    ----------
    self.difficulty = The difficulty of that blockchain mining process.
    self.chain = Contains the chain of blocks.
    self.unconfirmed_transactions = Contains the transactions which are not yet confirmed.

    Methods
    -------
    create_genesis_block(self)
    last_block(self)
    print_block(self)
    proof_of_work(self, block)
    add_block(self, block, proof)
    is_valid_proof(self, block, block_hash)
    add_new_transaction(self, transactions)
    mine(self)

    """

    def __init__(self):
        """
        __init__
        --------
        Initialized the Blockchain Parameters and calls the Genesis Block creation.

        """
        self.difficulty = 5
        self.chain = []
        self.unconfirmed_transactions = []
        self.create_genesis_block()

    def create_genesis_block(self):
        """
        create_genesis_block
        --------------------
        Creates the Genesis Block of the Blockchain.

        """
        genesis_block = Block(0, ["Genesis Block"], time.time(), "")
        genesis_block.hash = genesis_block.create_hash()
        print('Mining the block containing "Genesis Block"')
        while not genesis_block.hash.startswith("0" * self.difficulty):
            genesis_block.nonce += 1
            genesis_block.hash = genesis_block.create_hash()
            print(genesis_block.hash, end="\r")
        print(genesis_block.hash + "\n")
        self.chain.append(genesis_block)

    @property
    def last_block(self):
        """
        last_block
        ----------
        Returns the last block of the Blockchain.

        Return
        ------
        Last block of the Blockchain.

        """
        return self.chain[-1]

    def print_block(self):
        """
        print_block
        -----------
        Prints the entire blockchain one block at a time.

        """
        length = len(self.chain)
        for i in range(length):
            print("Block: " + str(self.chain[i].index))
            print("Previous Hash: " + self.chain[i].previous_hash)
            print("Transaction: " + " ".join(self.chain[i].transactions))
            print("Nonce: " + str(self.chain[i].nonce))
            print("Hash: " + self.chain[i].hash + "\n")

    def proof_of_work(self, block):
        """
        proof_of_work
        -------------
        Calculates the Proof Of Work of a particular block.

        Parameters
        ----------
        block - The Block which contains all the block details.

        Return
        ------
        The hash of the block passed as parameter.

        """
        block.nonce = 0
        created_hash = block.create_hash()
        while not created_hash.startswith("0" * self.difficulty):
            block.nonce += 1
            created_hash = block.create_hash()
            print(created_hash, end="\r")
        print(created_hash + "\n")
        return created_hash

    def add_block(self, block, proof):
        """
        add_block
        ---------
        Function to add block to the blockchain. Verification of proofs are done.

        Parameters
        ----------
        block - The Block which contains all the block details.
        proof - The hash details of the block for verification.

        Return
        ------
        True if verification passes, False otherwise.

        """
        previous_hash = self.last_block.hash
        if previous_hash != block.previous_hash:
            return False
        if not self.is_valid_proof(block, proof):
            return False
        block.hash = proof
        self.chain.append(block)
        return True

    def is_valid_proof(self, block, block_hash):
        """
        is_valid_proof
        --------------
        Checks if a proof is valid or not based on difficulty and hash of the block.

        Parameters
        ----------
        block - The Block which contains all the block details.
        block_hash - The hash details of the block for validation.

        Return
        ------
        True if validation passes, False otherwise.

        """
        return (
            block_hash.startswith("0" * self.difficulty)
            and block_hash == block.create_hash()
        )

    def add_new_transaction(self, transactions):
        """
        add_new_transaction
        -------------------
        Function to add new transactions to the unconfirmed list.

        Parameters
        ----------
        transactions - The transactions to be added.

        """
        print('Mining the block containing "' + transactions + '"')
        self.unconfirmed_transactions.append(transactions)

    def mine(self):
        """
        mine
        ----
        Function to mine a new block.

        Return
        ------
        The index of the block created.

        """
        if not self.unconfirmed_transactions:
            return False

        last_block = self.last_block

        new_block = Block(
            index=last_block.index + 1,
            transactions=self.unconfirmed_transactions,
            timestamp=time.time(),
            previous_hash=last_block.hash,
        )

        proof = self.proof_of_work(new_block)
        self.add_block(new_block, proof)
        self.unconfirmed_transactions = []
        return new_block.index


def main():
    """
    main
    ----
    The main entry point of the program.

    """
    bitcoin = Blockchain()

    bitcoin.add_new_transaction("Send 1 BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.add_new_transaction("Send 2 more BTC to Nick Cage")
    bitcoin.mine()
    bitcoin.add_new_transaction("Send 5 more BTC to Nick Cage")
    bitcoin.mine()

    bitcoin.print_block()


if __name__ == "__main__":
    main()
