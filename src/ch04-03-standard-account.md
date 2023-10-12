# Standard Account Contract

**NOTE:**
**THIS CHAPTER NEEDS TO BE UPDATED TO REFLECT THE NEW SYNTAX FOR ACCOUNT CONTRACTS. PLEASE DO NOT USE THIS CHAPTER AS A REFERENCE UNTIL THIS NOTE IS REMOVED.**

**CONTRIBUTE: This subchapter is missing an example of declaration, deployment and interaction with the contract. We would love to see your contribution! Please submit a PR.**

In this chapter, we build upon our exploration of account contracts in
Starknet by introducing a more complex account contract. This Standard
Account Contract includes additional features such as signature
validation, providing a more robust example of an account contract in
Cairo language. You can find the full code for this contract in the Book
repository (todo: add link). You can interact and compile the contract
using Scarb (review the Scarb subchapter in Chapter 2 of the Book for
more information).

```rust
    // Import necessary modules and traits
    use serde::Serde;
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use array::SpanTrait;
    use option::OptionTrait;

    // Define the Account contract
    #[account_contract]
    mod Account {
        use array::ArrayTrait;
        use array::SpanTrait;
        use box::BoxTrait;
        use ecdsa::check_ecdsa_signature;
        use option::OptionTrait;
        use super::Call;
        use starknet::ContractAddress;
        use zeroable::Zeroable;
        use serde::ArraySerde;

        // Define the contract's storage variables
        struct Storage {
            public_key: felt252
        }

        // Constructor function for initializing the contract
        #[constructor]
        fn constructor(public_key_: felt252) {
            public_key::write(public_key_);
        }

        // Internal function to validate the transaction signature
        fn validate_transaction() -> felt252 {
            let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
            let signature = tx_info.signature; // Extract signature
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH'); // Check signature length

            // Verify ECDSA signature
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key::read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED // Return validation status
        }

        // Validate contract deployment
        #[external]
        fn __validate_deploy__(
            class_hash: felt252, contract_address_salt: felt252, public_key_: felt252
        ) -> felt252 {
            validate_transaction()
        }

        // Validate contract declaration
        #[external]
        fn __validate_declare__(class_hash: felt252) -> felt252 {
            validate_transaction()
        }

        // Validate contract execution
        #[external]
        fn __validate__(
            contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>
        ) -> felt252 {
            validate_transaction()
        }

        // Execute a contract call
        #[external]
        #[raw_output]
        fn __execute__(mut calls: Array<Call>) -> Span<felt252> {
            // Validate caller
            assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

            let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            assert(calls.len() == 1_u32, 'MULTI_CALL_NOT_SUPPORTED'); // Only single calls are supported
            let Call{to, selector, calldata } = calls.pop_front().unwrap();

            // Call the target contract
            starknet::call_contract_syscall(
                address: to, entry_point_selector: selector, calldata: calldata.span()
            ).unwrap_syscall()
        }
    }

    // Define the Call struct
    #[derive(Drop, Serde)]
    struct Call {
        to: ContractAddress,
        selector: felt252,
        calldata: Array<felt252>
    }
```

## Grasping ECDSA Signature

Elliptic Curve Digital Signature Algorithm (ECDSA) is a cryptographic
protocol extensively utilized across various blockchains to ensure data
integrity and verify the sender’s authenticity. As a variant of the
Digital Signature Algorithm (DSA), ECDSA leverages elliptic curve
cryptography, offering superior security with shorter keys than the
traditional DSA.

An ECDSA signature comprises two components, commonly referred to as _r_
and _s_. These two values, generated using the signer’s private key and
the hash of the message (or transaction) being signed, collectively form
the signature for a given input.

### Deciphering signature_r and signature_s

Within the context of the Standard Account Contract, _signature_r_ and
_signature_s_ represent the two constituents of the ECDSA signature.
These are utilized in the _check_ecdsa_signature_ function to
authenticate the transaction’s legitimacy.

- `signature_r (r)`: A random number generated during the signing
  process, unique for each signature. Reusing _r_ across different
  messages may lead to private key exposure.

- `signature_s (s)`: This is computed using _r_, the private key, and
  the hash of the message. Like _r_, _s_ is also unique for each
  signature.

The function _check_ecdsa_signature_ takes these two values, the
public key of the signer, and the hash of the message to authenticate
the signature. A valid signature indicates that the message was indeed
signed by the private key owner and remains unaltered.

```rust
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key::read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );
```

The above code snippet employs _check_ecdsa_signature_ function to
assert the legitimacy of the transaction signature. If the signature is
not valid, the assertion fails, returning _INVALID_SIGNATURE_.

## Contract Anatomy

### Storage

In the standard account contract, we declare a single storage variable:
_public_key_. This assists in transaction signature validation. The
public key, stored as a _felt252_ (a 252-bit unsigned integer), is
written to the storage in the constructor function and is accessed from
the storage in the _validate_transaction_ function.

```rust
    struct Storage {
        public_key: felt252
    }
```

### Constructor

The constructor function serves to initialize the contract, storing the
supplied public key in the contract’s storage.

```rust
    #[constructor]
    fn constructor(public_key_: felt252) {
        public_key::write(public_key_);
    }
```

### `validate_transaction`

This internal function validates the transaction signature. It retrieves
the signature from the transaction info, checks its length, and verifies
the ECDSA signature. If the signature is legitimate, it returns
starknet::VALIDATED, otherwise an error. This function is invoked by
**validate_deploy**, **validate_declare**, and **validate** functions.

The inclusion of this function is optional. If transaction signature
validation is not required, it can be omitted. However, its inclusion in
your account contract is advised to ensure transaction validity and to
facilitate its reuse in all three validation functions.

```rust
    fn validate_transaction() -> felt252 {
            let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
            let signature = tx_info.signature; // Extract signature
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH'); // Check signature length

            // Verify ECDSA signature
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: public_key::read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED // Return validation status
        }
```

### Call Struct

The Call struct outlines the parameters required for a contract call.
These parameters comprise the target contract address (to), the function
to be called (selector), and the function’s arguments (calldata). The
Call struct is utilized in the _execute_ function.

```rust
    #[derive(Drop, Serde)]
    struct Call {
        to: ContractAddress,
        selector: felt252,
        calldata: Array<felt252>
    }
```

### execute

This external function triggers a transaction post successful
validation. It ensures the caller’s validity, checks for a non-zero
transaction version, and supports only single calls. Post validation, it
forwards the call to the target contract. The contract creator can
incorporate multiple calls to different contracts or the same contract
(multicall) within this function. The function returns the output from
the target contract.

```rust
        #[external]
        #[raw_output]
        fn __execute__(mut calls: Array<Call>) -> Span<felt252> {
            // Validate caller
            assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

            let tx_info = starknet::get_tx_info().unbox(); // Unbox transaction info
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            assert(calls.len() == 1_u32, 'MULTI_CALL_NOT_SUPPORTED'); // Only single calls are supported
            let Call{to, selector, calldata } = calls.pop_front().unwrap();

            // Call the target contract
            starknet::call_contract_syscall(
                address: to, entry_point_selector: selector, calldata: calldata.span()
            ).unwrap_syscall()
        }
```

## Improvements to the Standard Account Contract

The implementation of the Standard Account Contract has a few
limitations:

- It currently supports only single calls. We could support multicalls
  to improve the flexibility and utility of the contract.

- The ECDSA signature algorithm, while secure, can be computationally
  intensive. Future versions could explore using more efficient
  signature algorithms, such as Schnorr or BLS. Or quantum-resistant
  signature algorithms, such as the STARKs.

Despite these limitations, the Standard Account Contract provides a
robust and secure foundation for creating and interacting with smart
contracts on Starknet.

## Declaring and Deploying the Hello World Account Contract

This time we have a constructor function that takes the public key as an
argument. We need to generate a private key with the corresponding
public key.

TODO: add section on how to generate a private key and public key.

- Export the required environment variables:

<!-- -->

    export STARKNET_NETWORK=alpha-goerli
    export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount

- Declare the contract (since the contract is already declared, you
  can skip this step. If you want to declare it anyway, run the
  following command but you will receive an error):

<!-- -->

    starknet declare --contract target/release/starknetbook_chapter_7_Account.json --account vote_admin --max_fee 100000000000000000

The class hash is:
0x05501f7806d3d11cab101e19001e409dd4760200c2da2fe03761750f66e4a5e1

- Deploy the contract:

TODO: add section on how to deploy the contract.

Elliptic Curve Digital Signature Algorithm (ECDSA) is a popular choice
for ensuring data integrity and sender authenticity in blockchain
networks, but it’s not the only option. Other alternatives include:

- EdDSA (Edwards-curve Digital Signature Algorithm): EdDSA is another
  form of elliptic curve cryptography that is designed to be faster
  and more secure than ECDSA. EdDSA uses twisted Edwards curves, which
  have strong security properties and allow for more efficient
  computations. An example of EdDSA in use is Monero.

- Schnorr Signatures: Schnorr signatures offer a level of security
  similar to ECDSA but with shorter signatures. They have the
  additional property of being linear, which allows for signature
  aggregation and multi-signatures. This can lead to increased
  efficiency and privacy. Bitcoin developers have proposed adding
  Schnorr signatures to the Bitcoin protocol with the Taproot upgrade.

- RSA (Rivest–Shamir–Adleman): RSA is an older cryptographic algorithm
  that is widely used for secure data transmission. However, RSA
  requires larger key sizes for equivalent security levels, making it
  less efficient than elliptic curve techniques. RSA is not commonly
  used in modern blockchain systems, but it is still used in many
  traditional secure communication protocols.

- BLS (Boneh-Lynn-Shacham) Signatures: BLS signatures, like Schnorr,
  allow for signature aggregation, making them useful in systems that
  require a large number of signatures. This property makes BLS
  signatures particularly useful for consensus algorithms in
  distributed systems and blockchains, such as Ethereum 2.0.

- Post-Quantum Cryptography: With the advent of quantum computing,
  researchers are developing new cryptographic algorithms that are
  resistant to quantum attacks. One example are the STARKs used in
  Starknet.

Each of these alternatives has its strengths and weaknesses in terms of
security, efficiency, complexity, and mathematical properties.

## Summary

In this chapter, we expanded on our understanding of account contracts
in Starknet by examining a more complex "Standard Account Contract". We
dove into the various components of the contract and learned how they
work together to validate and execute transactions.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
