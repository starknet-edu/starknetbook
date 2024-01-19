# Multisignature (multisig) Account.

Multisig, refers to a system where multiple signatures are required to authorize a transaction. This is commonly used in the context of cryptocurrency wallets, where funds can only be spent if a certain number of private keys agree to the transaction.

Multisignature (multisig) technology is an integral part of the modern
blockchain landscape. It enhances security by requiring multiple
signatures to confirm a transaction, hence reducing the risk of
fraudulent transactions and increasing control over asset management.

In Starknet, the concept of multisig accounts is abstracted at the
protocol level, allowing developers to implement custom account
contracts that embody this concept. In this chapter, we’ll delve into
the workings of a multisig account and see how it’s created in Starknet
using an account contract.

## Why Multisig.

There are several reasons why someone might choose to use a multisig wallet:

### Enhanced security:

Multisig contract account are much more secure than traditional single-signature contract accounts. With a single-signature contract account, if your private key is lost or stolen, your funds are gone. With a multisig contract account, even if one private key is compromised, the funds are still safe. This is because at least two (or more) private keys are required to authorize a transaction.

### Disaster recovery:

Multisig contract account can be used to protect against the loss of a private key. If one private key is lost, the other keys can still be used to recover the funds. This can be helpful in the event of a natural disaster, hardware failure, or other unforeseen event.

### Transparency and accountability:

Multisig contract account can be used to increase transparency and accountability in organizations. For example, a company might use a multisig wallet to store its funds, and require the signatures of two or more executives to authorize any spending. This can help to prevent fraud and ensure that everyone is aware of how the company's money is being spent.

The benefits of Multisig contract account can be realized more in the context of account abstraction.

### Multisig Account Abstraction Creation.

Account abstraction enables built-in multisig functionality within accounts.
Each account can be programmed to demand multiple signatures before transaction execution.
This eliminates the need for separate multisig smart contracts, simplifying their use.

A multisig account must have different traits that a smart contract must implement to be considered an account contract. In this book we will create an account contract from scratch following the SNIP-6 and SRC-5 standards.

## Project Setup

In order to be able to compile an account contract to Sierra, a prerequisite to deploy it to testnet or mainnet, you’ll need to make sure to have a version of [Scarb](https://docs.swmansion.com/scarb/download.html) that includes a Cairo compiler that targets Sierra 1.3 as it’s the latest version supported by Starknet’s testnet. At this point in time is Scarb 2.4.4 is used.

```cairo
mac@Macs-MacBook-Pro-2 Desktop % scarb --version
scarb 2.4.4 (0c8def3aa 2023-10-31)
cairo: 2.4.4 (https://crates.io/crates/cairo-lang-compiler/2.4.4)
sierra: 1.3.0

```

With Scarb we can create a new project using the new command.

```cairo
~ $ scarb new multisign
```

The command creates a folder with the same name that includes a configuration file for Scarb.

```cairo
~ $ cd multisign
aa $ tree .
>>>
.
├── Scarb.toml
└── src
    └── lib.cairo
```

By default, Scarb configures our project for vanilla Cairo instead of Starknet smart contracts.

```cairo
# Scarb.toml

[package]
name = "multisign"
version = "0.1.0"

[dependencies]
# foo = { path = "vendor/foo" }

```

We need to make some changes to the configuration file to activate the Starknet plugin in the compiler so we can work with smart contracts.

```cairo
# Scarb.toml

[package]
name = " multisign "
version = "0.1.0"

# See more keys and their definitions at https://docs.swmansion.com/scarb/docs/reference/manifest.html

[dependencies]

starknet = ">=2.4.4"

[[target.starknet-contract]]
sierra = true
casm = true


```

We can now replace the content of the sample Cairo code that comes with a new project with the scaffold of our account contract.

```cairo

#[starknet::contract]
mod Multisign {}

```

Given that one of the most important features of our account contract is to validate signatures, we need to store the public key associated with the private key of the signer.

```cairo
#[starknet::contract]
mod Multisign {

  #[storage]
  struct Storage {
    public_key: felt252
  }
}

```

To make sure everything is wired up correctly, let’s compile our project.

```cairo
mac@Macs-MacBook-Pro-2 multisign % scarb build
>>>
   Compiling multisign v0.1.0 (/Users/mac/multisig/Scarb.toml)
    Finished release target(s) in 2 seconds


```

It works, time to move to the interesting part of our tutorial.

## SNIP-6

Recall that for a smart contract to be considered an account contract, it must implement the trait defined by SNIP-6.

```cairo
trait ISRC6 {
  fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(calls: Array<Call>) -> felt252;
  fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

```

Because we will eventually annotate the implementation of this trait with the external attribute, the contract state will be the first argument provided to each method. We can define the type of the contract state with the generic T.

```cairo

trait ISRC6<T> {
  fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(self: @T, calls: Array<Call>) -> felt252;
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}

```

The **execute** function is the only one that receives a reference to the contract state because it’s the only one likely to either modify its internal state or to modify the state of another smart contract and thus to require the payment of gas fees for its execution. The other two functions, **validate** and is_valid_signature, are read-only and shouldn’t require the payment of gas fees. For this reason they are both receiving a snapshot of the contract state instead.

Let's now define the trait for our multisig account explicitly.

```cairo


#[starknet::interface]
trait TestMultisign<T> {
	fn __execute__(ref self: T, calls: Array<account::Call>) -> Array<Span<felt252>>;
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;
	fn is_valid_signature( self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

```

Each function inside an implementation annotated with the external attribute will have its own selector that other people and smart contracts can use to interact with my account contract.

The functions **execute** and **validate** are meant to be used only by the Starknet protocol even if the functions are publicly accessible via its selectors. The only function that I want to make public for web3 apps to use for signature validation is is_valid_signature.

In addition, we will create a separate trait annotated with the interface attribute that will group all the functions in the account contract that is expected to interact with. On the other hand, we will auto generate the trait for all those functions that users will not see to use directly even though they are public.

```cairo
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
	// @dev Asserts threshold in relation with signers-len
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


```

## Exploring Multisig Functions

Let’s take a closer look at the various functions associated with
multisig functionality in the provided contract.

### `add_signers` Function

This is an internal function designed to add the public keys of the
account owners to a permanent storage. Ideally, a multisig account
structure should permit adding and deleting owners as per the agreement
of the account owners. However, each change should be a transaction
requiring the threshold number of signatures.

```cairo


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
```

### `is_signer_using_last` Function

This function allows the owners of the account to submit
transactions. Upon submission, the function checks the validity of the
signer, ensures the caller is one of the account owners, and adds
the transaction to the transactions map. It also increments the current
transaction index.

```cairo

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


```

### `is_valid_signer_signature` Function

Similarly, the **_`is_valid_signer_signature`_** function provides a way to record
confirmations for each signer. An account owner, who did not submit
the transaction, can confirm it, increasing its confirmation count.

```cairo

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

### _`execute_multi_call`_ Function

The _execute_multi_call_ function serves as the final step in the transaction
process. It checks the validity of the transaction, whether it has been
previously executed, and if the threshold number of signatures has been
reached. The transaction is executed if all the checks pass.

```cairo
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

## Protecting Protocol-Only Functions

There maybe other use cases for other smart contracts to directly interact with the functions **execute** and **validate** of my account contract, I would rather restrict them to be callable only by the Starknet protocol in case there’s an attack vector that I’m failing to foresee.

When the Starknet protocol calls a function it uses the zero address as the caller. We can use this fact to create a private function named only_protocol. To create private functions we simply create a new implementation that is not annotated with the external attribute so no public selectors are created.

```cairo
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
```

Notice that the function is_valid_signature is not protected by the **only_protocol** function because we do want to allow anyone to use it.

## Signature Validation

To validate the signature of a transaction we will need to use the public key associated with the signer of the account contract. We have already defined public_key to be part of the storage of our account but we need to capture its value during deployment using the constructor.

```cairo

#[storage]
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
	// @dev Asserts threshold in relation with signers-len
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
```

The logic of the function is_valid_signature can be implemented , if the signature is valid, it should return the short string ‘VALID’ and if not it should return the value 0. Returning zero is just a convention, we can return any felt as long as it is not the felt that represents the short string ‘VALID’.

The logic of returning a felt252 value instead of a boolean maybe confusing. That’s why there is a need to create an internal function called is_valid_signature_bool that will perform the same logic but will return a boolean instead of a felt252 depending on the result of validating a signature.

```cairo
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


```

Private function can be used to validate a transaction signature as required by the **validate** function. In contrast to the function is_valid_signature we will use an assert to stop the transaction execution in case the signature is found to be invalid.
Here’s a little casting problem. The function is_valid_signature_bool expects the signature to be passed as an Array but the signature variable inside the **validate** function is a Span. Because it is easier (and cheaper) to derive a Span from an Array than the opposite, I’ll change the function signature of is_valid_signature_bool to expect a Span instead of an Array.

This little change will require deriving a Span from the signature variable inside the function is_valid_signature before calling is_valid_signature_bool which we can easily do with the span() method available on the ArrayTrait.

## Conclusion

In conclusion, account abstraction and multisig converge to create a more secure, flexible, and user-centric approach to account management in blockchain ecosystems.
Additional benefits of this relationship include:

Social recovery: Account abstraction enables social recovery mechanisms for multisig accounts, allowing for account recovery in case of key loss.

Fee payment delegation: Account contracts can be configured to pay transaction fees, reducing friction for multisig transactions.

As account abstraction gains traction, multisig is poised to become a more accessible and versatile tool for safeguarding assets and enhancing control in Starknet protocol.
This chapter is an introduction to the concept of multisig accounts in
Starknet and illustrated how they can be implemented using an account contract. However, it’s important to note that this is a simplified example, and a production-grade multisig contract should contain
additional checks and validations for robustness and security.
