# Multi-Signature Accounts

Multisignature (multisig) technology is an integral part of the modern
blockchain landscape. It enhances security by requiring multiple
signatures to confirm a transaction, hence reducing the risk of
fraudulent transactions and increasing control over asset management.

In Starknet, the concept of multisig accounts is abstracted at the
protocol level, allowing developers to implement custom account
contracts that embody this concept. In this chapter, we’ll delve into
the workings of a multisig account and see how it’s c reated in Starknet
using an account contract.

## What is a Multisig Account?

A multisig account is an account that requires more than one signature
to authorize transactions. This significantly enhances security,
requiring multiple entities' consent to transact funds or perform
critical actions.

Key specifications of a multisig account include:

- Public keys that form the account

- Threshold number of signatures required

A transaction signed by a multisig account must be individually signed
by the different keys specified for the account. If fewer than the
threshold number of signatures needed are present, the resultant
multisignature is considered invalid.

In Starknet, accounts are abstractions provided at the protocol level.
Therefore, to create a multisig account, one needs to code the logic
into an account contract and deploy it.

The contract below serves as an example of a multisig account contract.
When deployed, it can create a native multisig account using the concept
of account abstraction. Please note that this is a simplified example
and lacks comprehensive checks and validations found in a
production-grade multisig contract.

## Multisig Account Contract

This is the Cairo code for a multisig account contract:

```rust
use starknet::account;

// @title SRC-6 Standard Account
#[starknet::interface]
trait ISRC6<T> {
	// @notice Execute a transaction through the account
	// @param calls The list of calls to execute
	// @return The list of each call's serialized return value
	fn __execute__(
		ref self: T,
		calls: Array<account::Call>
	) -> Array<Span<felt252>>;

	// @notice Assert whether the transaction is valid to be executed
	// @param calls The list of calls to execute
	// @return The string 'VALID' represented as a felt when is valid
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;

	// @notice Assert whether a given signature for a given hash is valid
	// @dev signatures must be deserialized
	// @param hash The hash of the data
	// @param signature The signature to be validated
	// @return The string 'VALID' represented as a felt when is valid
	fn is_valid_signature(
		self: @T,
		hash: felt252,
		signature: Array<felt252>
	) -> felt252;
}

// @title SRC-5 Iterface detection
#[starknet::interface]
trait ISRC5<T> {
	// @notice Query if a contract implements an interface
	// @param interface_id The interface identifier, as specified in SRC-5
	// @return `true` if the contract implements `interface_id`, `false` otherwise
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

// @title Multisign Account
#[starknet::contract]
mod Multisign {
	use super::ISRC6;
	use super::ISRC5;
	use starknet::account;

	const SRC6_INTERFACE_ID: felt252 = 1270010605630597976495846281167968799381097569185364931397797212080166453709; // hash of SNIP-6 trait
	const MAX_SIGNERS_COUNT: usize = 32;

	#[storage]
	struct Storage {
		signers: LegacyMap<felt252, felt252>,
		threshold: usize,
		outside_nonce: LegacyMap<felt252, felt252>
	}

	// @notice Contructor of the account
	// @dev Asserts threshold in relation with signers-length
	// @param threshold Initial threshold
	// @param signers Array of inital signers' public-keys
	#[constructor]
	fn constructor(
		ref self: ContractState,
		threshold: usize,
		signers: Array<felt252>) {
		assert_threshold(threshold, signers.len());

		self.add_signers(signers.span(), 0);
		self.threshold.write(threshold);
	}

	#[external(v0)]
	impl SRC6 of ISRC6<ContractState> {
		fn __execute__(
			ref self: ContractState,
			calls: Array<account::Call>
		) -> Array<Span<felt252>> {
			assert_only_protocol();
			execute_multi_call(calls.span())
		}

		fn __validate__(
			self: @ContractState,
			calls: Array<account::Call>
		) -> felt252 {
			assert_only_protocol();
			assert(calls.len() > 0, 'validate/no-calls');
			self.assert_valid_calls(calls.span());
			starknet::VALIDATED
		}

		fn is_valid_signature(
			self: @ContractState,
			hash: felt252,
			signature: Array<felt252>
		) -> felt252 {
			if self.is_valid_signature_span(hash, signature.span()) {
				starknet::VALIDATED
			} else {
				0
			}
		}
	}

	#[external(v0)]
	impl SRC5 of ISRC5<ContractState> {
		fn supports_interface(
			self: @ContractState,
			interface_id: felt252
		) -> bool {
			interface_id == SRC6_INTERFACE_ID
		}
	}

	#[generate_trait]
	impl Private of PrivateTrait {
		fn add_signers(
			ref self: ContractState,
			mut signers: Span<felt252>,
			last: felt252
		) {
			match signers.pop_front() {
				Option::Some(signer_ref) => {
					let signer = *signer_ref;
					assert(signer != 0, 'signer/zero-signer');
					assert(!self.is_signer_using_last(signer, last),
						'signer/is-already-signer');
					self.signers.write(last, signer);
					self.add_signers(signers, signer);
				},
				Option::None => ()
			}
		}

		fn is_signer_using_last(
			self: @ContractState,
			signer: felt252,
			last: felt252
		) -> bool {
			if signer == 0 {
				return false;
			}

			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			last == signer
		}

		fn is_valid_signature_span(
			self: @ContractState,
			hash: felt252,
			signature: Span<felt252>
		) -> bool {
			let threshold = self.threshold.read();
			assert(threshold != 0, 'Uninitialized');
			let mut signatures = deserialize_signatures(signature)
				.expect('signature/invalid-len');
			assert(threshold == signatures.len(), 'signature/invalid-len');
			let mut last: u256 = 0;
			loop {
				match signatures.pop_front() {
					Option::Some(signature_ref) => {
						let signature = *signature_ref;
						let signer_uint = signature.signer.into();
						assert(signer_uint > last, 'signature/not-sorted');
						if !self.is_valid_signer_signature(
								hash,
								signature.signer,
								signature.signature_r,
								signature.signature_s,
							) {
							break false;
						}
						last = signer_uint;
					},
					Option::None => {
						break true;
					}
				}
			}
		}

		fn is_valid_signer_signature(
			self: @ContractState,
			hash: felt252,
			signer: felt252,
			signature_r: felt252,
			signature_s: felt252
		) -> bool {
			assert(self.is_signer(signer), 'signer/not-a-signer');
			ecdsa::check_ecdsa_signature(hash, signer, signature_r, signature_s)
		}

		fn is_signer(self: @ContractState, signer: felt252) -> bool {
			if signer == 0 {
				return false;
			}
			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			self.get_last() == signer
		}

		fn get_last(self: @ContractState) -> felt252 {
			let mut curr = self.signers.read(0);
			loop {
				let next = self.signers.read(curr);
				if next == 0 {
					break curr;
				}
				curr = next;
			}
		}

		fn assert_valid_calls(
			self: @ContractState,
			calls: Span<account::Call>
		) {
			assert_no_self_call(calls);

			let tx_info = starknet::get_tx_info().unbox();
			assert(
				self.is_valid_signature_span(
					tx_info.transaction_hash,
					tx_info.signature
				),
				'call/invalid-signature'
			)
		}
	}

	fn assert_threshold(threshold: usize, signers_len: usize) {
		assert(threshold != 0, 'threshold/is-zero');
		assert(signers_len != 0, 'signers_len/is-zero');
		assert(signers_len <= MAX_SIGNERS_COUNT,
				'signers_len/too-high');
		assert(threshold <= signers_len, 'threshold/too-high');
	}

	#[derive(Copy, Drop, Serde)]
	struct SignerSignature {
		signer: felt252,
		signature_r: felt252,
		signature_s: felt252
	}

	fn deserialize_signatures(
		mut serialized: Span<felt252>
	) -> Option<Span<SignerSignature>> {
		let mut signatures = ArrayTrait::new();
		loop {
			if serialized.len() == 0 {
				break Option::Some(signatures.span());
			}
			match Serde::deserialize(ref serialized) {
				Option::Some(s) => { signatures.append(s) },
				Option::None => { break Option::None; },
			}
		}
	}

	fn assert_only_protocol() {
		assert(starknet::get_caller_address().is_zero(), 'caller/non-zero');
	}

	fn assert_no_self_call(
		mut calls: Span<account::Call>
	) {
		let self = starknet::get_contract_address();
		loop {
			match calls.pop_front() {
				Option::Some(call) => {
					assert(*call.to != self, 'call/call-to-self');
				},
				Option::None => {
					break ;
				}
			}
		}
	}

	fn execute_multi_call(mut calls: Span<account::Call>) -> Array<Span<felt252>> {
		assert(calls.len() != 0, 'execute/no-calls');
		let mut result: Array<Span<felt252>> = ArrayTrait::new();
		let mut idx = 0;
		loop {
			match calls.pop_front() {
				Option::Some(call) => {
					match starknet::call_contract_syscall(
						*call.to,
						*call.selector,
						call.calldata.span()
					) {
						Result::Ok(retdata) => {
							result.append(retdata);
							idx += 1;
						},
						Result::Err(err) => {
							let mut data = ArrayTrait::new();
							data.append('call/multicall-faild');
							data.append(idx);
							let mut err = err;
							loop {
								match err.pop_front() {
									Option::Some(v) => {
										data.append(v);
									},
									Option::None => {
										break;
									}
								}
							};
							panic(data);
						}
					}
				},
				Option::None => {
					break;
				}
			}
		};
		result
	}
}

#[starknet::interface]
trait TestMultisign<T> {
	fn __execute__(ref self: T, calls: Array<account::Call>) -> Array<Span<felt252>>;
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;
	fn is_valid_signature( self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

```

## Multisig Transaction Flow

The flow of a multisig transaction includes the following steps:

1.  Submitting a transaction: Any of the owners can submit a transaction
    from the account.

2.  Confirming the transaction: The owner who hasn’t submitted a
    transaction can confirm the transaction.

The transaction will be successfully executed if the number of
confirmations (including the submitter’s signature) is greater than or
equal to the threshold number of signatures, else it fails. This
mechanism of confirmation ensures that no single party can unilaterally
perform critical actions, thereby enhancing the security of the account.

## Exploring Multisig Functions

Let’s take a closer look at the various functions associated with
multisig functionality in the provided contract.

### `add_signers` Function

This is an internal function designed to add the public keys of the
account owners to a permanent storage. Ideally, a multisig account
structure should permit adding and deleting owners as per the agreement
of the account owners. However, each change should be a transaction
requiring the threshold number of signatures.

```rust
    //INTERNAL FUNCTION
    //Function to add the public keys of the multisig in permanent storage
    fn add_signers(
			ref self: ContractState,
			mut signers: Span<felt252>,
			last: felt252
		) {
			match signers.pop_front() {
				Option::Some(signer_ref) => {
					let signer = *signer_ref;
					assert(signer != 0, 'signer/zero-signer');
					assert(!self.is_signer_using_last(signer, last),
						'signer/is-already-signer');
					self.signers.write(last, signer);
					self.add_signers(signers, signer);
				},
				Option::None => ()
			}
		}
fn is_signer_using_last(
			self: @ContractState,
			signer: felt252,
			last: felt252
		) -> bool {
			if signer == 0 {
				return false;
			}

			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			last == signer
		}

```

### `is_valid_signature_span` Function

This external function allows the owners of the account to submit
transactions. Upon submission, the function checks the validity of the
transaction, ensures the caller is one of the account owners, and adds
the transaction to the transactions map. It also increments the current
transaction index.

```rust
    #[external]
    fn is_valid_signature_span(
			self: @ContractState,
			hash: felt252,
			signature: Span<felt252>
		) -> bool {
			let threshold = self.threshold.read();
			assert(threshold != 0, 'Uninitialized');
			let mut signatures = deserialize_signatures(signature)
				.expect('signature/invalid-len');
			assert(threshold == signatures.len(), 'signature/invalid-len');
			let mut last: u256 = 0;
			loop {
				match signatures.pop_front() {
					Option::Some(signature_ref) => {
						let signature = *signature_ref;
						let signer_uint = signature.signer.into();
						assert(signer_uint > last, 'signature/not-sorted');
						if !self.is_valid_signer_signature(
								hash,
								signature.signer,
								signature.signature_r,
								signature.signature_s,
							) {
							break false;
						}
						last = signer_uint;
					},
					Option::None => {
						break true;
					}
				}
			}
		}

```

### `is_valid_signer_signature` Function

Similarly, the **_`is_valid_signer_signature`_** function provides a way to record
confirmations for each transaction. An account owner, who did not submit
the transaction, can confirm it, increasing its confirmation count.

```rust
        #[external]
        fn is_valid_signer_signature(
			self: @ContractState,
			hash: felt252,
			signer: felt252,
			signature_r: felt252,
			signature_s: felt252
		) -> bool {
			assert(self.is_signer(signer), 'signer/not-a-signer');
			ecdsa::check_ecdsa_signature(hash, signer, signature_r, signature_s)
		}

		fn is_signer(self: @ContractState, signer: felt252) -> bool {
			if signer == 0 {
				return false;
			}
			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			self.get_last() == signer
		}

```

### Function `get_last`

Function `get_last` retrieves the index of the last signer in a linked list-like structure within a contract state. `fn get_last(self: @ContractState) -> felt252`takes a reference to the contract state (self), returns a felt252 value (likely representing the signer index)
`` let mut curr = self.signers.read(0);` Reads the value at index 0 of self.signers (assumed to be the first signer) and stores it in a mutable variable curr, then Iterates until a specific condition is met

```rust

		fn get_last(self: @ContractState) -> felt252 {
			let mut curr = self.signers.read(0);
			loop {
				let next = self.signers.read(curr);
				if next == 0 {
					break curr;
				}
				curr = next;
			}
		}


```

### assert_valid_calls

Validates incoming calls to ensure they meet security and integrity requirements. The function enforces security measures to protect the contract from unauthorized or invalid actions.
It specifically addresses: - Recursive calls (preventing potential issues)

- Signature validity (ensuring transaction integrity)

The exact implementation of `assert_no_self_call` and `is_valid_signature_span` would provide more specific details about the validation process.

```rust
fn assert_valid_calls(
			self: @ContractState,
			calls: Span<account::Call>
		) {
			assert_no_self_call(calls);

			let tx_info = starknet::get_tx_info().unbox();
			assert(
				self.is_valid_signature_span(
					tx_info.transaction_hash,
					tx_info.signature
				),
				'call/invalid-signature'
			)
		}
	}

```

### _`execute_multi_call`_ Function

The _execute_multi_call_ function serves as the final step in the transaction
process. It checks the validity of the transaction, whether it has been
previously executed, and if the threshold number of signatures has been
reached. The transaction is executed if all the checks pass.

```rust
    #[external]
        fn execute_multi_call(mut calls: Span<account::Call>) -> Array<Span<felt252>> {
		assert(calls.len() != 0, 'execute/no-calls');
		let mut result: Array<Span<felt252>> = ArrayTrait::new();
		let mut idx = 0;
		loop {
			match calls.pop_front() {
				Option::Some(call) => {
					match starknet::call_contract_syscall(
						*call.to,
						*call.selector,
						call.calldata.span()
					) {
						Result::Ok(retdata) => {
							result.append(retdata);
							idx += 1;
						},
						Result::Err(err) => {
							let mut data = ArrayTrait::new();
							data.append('call/multicall-faild');
							data.append(idx);
							let mut err = err;
							loop {
								match err.pop_front() {
									Option::Some(v) => {
										data.append(v);
									},
									Option::None => {
										break;
									}
								}
							};
							panic(data);
						}
					}
				},
				Option::None => {
					break;
				}
			}
		};
		result
	}
}
```

## Closing Thoughts

This chapter has introduced you to the concept of multisig accounts in
Starknet and illustrated how they can be implemented using an account
contract. However, it’s important to note that this is a simplified
example, and a production-grade multisig contract should contain
additional checks and validations for robustness and security.

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
