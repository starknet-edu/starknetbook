❯ starknet new_account --account vote_admin
Account address: 0x04d77bb090f6d4a11662cc007995d9026015b13c0264094aa1f246d9200a604a
Public key: 0x067d6df0bbfa943b1a3a4231652919ead749586e697d4ab6c4184f1226c6892e
Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.

NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.

❯ starknet deploy_account --account vote_admin

Sending the transaction with max_fee: 0.000055 ETH (54618464052066 WEI).
Sent deploy account contract transaction.

Contract address: 0x04d77bb090f6d4a11662cc007995d9026015b13c0264094aa1f246d9200a604a
Transaction hash: 0x3214351502cf04620db8d137e636b1b1ce41a9e7e96a721b6d0c465442a8275

❯ starknet declare --contract target/release/starknetbook_chapter_2_Vote.json --account vote_admin
Sending the transaction with max_fee: 0.000009 ETH (9003962062427 WEI).
Declare transaction was sent.
Contract class hash: 0x67c09a7c2856c4e2074385176af70f8a649fd4a19a654d55dc5d5fa1640497a
Transaction hash: 0x1e21fbd05593f49a7614eda4a995ce4fe6762b71dd019129c2c52bd492d22e

❯ starknet deploy --class_hash 0x2ea78c8db1aba7d319d2fc1b6e967816b587697315c66c82b1158d0444eac2 --inputs 0x22a026743b1eb8a79eacce3f82c16d85f57466048ee938f2b32e04c662c9388 0x06dcb489c1a93069f469746ef35312d6a3b9e56ccad7f21f0b69eb799d6d2821 0x4d77bb090f6d4a11662cc007995d9026015b13c0264094aa1f246d9200a604a --account vote_admin --max_fee 100000000000000000
Invoke transaction for contract deployment was sent.
Contract address: 0x04a03ec28549ea6ea24ef18af17551deabf9357bad53be81f89fa71f75943ee1
Transaction hash: 0x765337df68088a4ea1ab0a33d9c02834fe88ab0c9092df62b3905eb6221373b


