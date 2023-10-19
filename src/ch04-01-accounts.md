# Account Contracts

Now that we know better the concept of AA, let’s actually code it in
Starknet.

## Account Contract Interface (SNIP-6)

Account contracts, while essentially being smart contracts,
differentiate themselves through unique methods. A smart contract gains
the status of an account contract when it implements the public interface as
described by SNIP-6 ([StarkNet Improvement Proposal-6: Standard Account
Interface](https://github.com/ericnordelo/SNIPs/blob/feat/standard-account/SNIPS/snip-6.md)).
This standard borrows from SRC-6 and SRC-5, which are akin to Ethereum’s
ERCs, setting application-level conventions and contract standards.


```rust
/// @title Represents a call to a target contract
/// @param to The target contract address
/// @param selector The target function selector
/// @param calldata The serialized function parameters
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

/// @title SRC-6 Standard Account
trait ISRC6 {
    /// @notice Execute a transaction through the account
    /// @param calls The list of calls to execute
    /// @return The list of each call's serialized return value
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;

    /// @notice Assert whether the transaction is valid to be executed
    /// @param calls The list of calls to execute
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate__(calls: Array<Call>) -> felt252;

    /// @notice Assert whether a given signature for a given hash is valid
    /// @param hash The hash of the data
    /// @param signature The signature to validate
    /// @return The string 'VALID' represented as felt when the signature is valid
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

/// @title SRC-5 Standard Interface Detection
trait ISRC5 {
    /// @notice Query if a contract implements an interface
    /// @param interface_id The interface identifier, as specified in SRC-5
    /// @return `true` if the contract implements `interface_id`, `false` otherwise
    fn supports_interface(interface_id: felt252) -> bool;
}

```

As seen in the proposal above, an account contract must implement 
at least the methods `__execute__`, `__validate__` and `is_valid_signature`, 
formulated in the `ISRC6` trait.


The functions represented above serve the following purposes:

- `__validate__`: This function takes in the list of calls scheduled
  for execution and validates them in line with the rules specified in
  the contract. It returns a short string (e.g., VALID), as opposed to a
  boolean, encapsulated within a `felt252` that signifies the validation outcome.
  This is because in Cairo, a short string is simply the ASCII representation
  of a single felt and not a real string. Which is why the return type is `felt252`.
  If the signature verification fails, you can return literally any other felt that
  is not the aforementioned short string. The number `0` is a common choice.

- `is_valid_signature`: This function is tasked with validating the
  signature of a transaction. It receives a hash of the transaction
  data and a signature, which may be validated against a public key or
  through any other method as specified by the contract creator. It
  returns a short string (e.g., VALID) encapsulated within a `felt252`
  that signifies the validation outcome.

- `__execute__`: Post-validation, the `__execute__` function is
  responsible for executing an array of contract calls (as `Call`
  structs). It returns an array of `Span<felt252>` structs
  representing the return values of the executed calls.

Moreover, the `SNIP-5` (Standard Interface Detection) trait needs to be
defined with a function called `supports_interface`. This function
verifies whether a contract supports a specific interface, receiving an
interface ID and returning a boolean.

```rust
    trait ISRC5 {
        fn supports_interface(interface_id: felt252) -> bool;
    }
```

In summary, when a user sends an `invoke` transaction, the first thing the
protocol does is to call the `__validate__` method to authenticate the signer
associated with the account. Note that there are restrictions on what you
can do inside the `__validate__` method to protect the Sequencer against
Denial of Service (DoS) attacks [1]. If the signature verification is
successful, it returns VALID felt252 element. If it fails, return 0.


Once the protocol authenticates the signer, it then calls the function `__execute__`.
It passes as an argument an array of all the "calls", or operations, the user wants to 
perform as a multicall. Each contract call defines a target smart contract address (`to`), a
method to call (the `selector`) and the arguments expected by the method (the `calldata`).


```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {

    ....
   
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;

    ....

}

```

The execution of each `Call` might result in a value being returned
from the target smart contract. This value could be a felt252, boolean, or a
complex data structure such as a struct or an array. The Starknet protocol
will then serialize this response using `Span<felt252>`. And since a `Span`
represents a snapshot of an Array [2], the `__execute__` method returns an array
of `Span<felt252>` elements, which represents a serialized response from each
call in the multicall.

  
The method `is_valid_signature` is not defined or used by the Starknet protocol.
It's instead an agreement between builders in the Starknet community as a way
to allow web3 apps to perform user authentication. Example, think of a user
trying to authenticate to an NFT marketplace using their wallet. The web app
will ask the user to sign a message, then call the `is_valid_signature` method
to verify that the connected wallet address belongs to the user.


To allow other smart contracts to know that your account contract adheres to
the SNIP-6 public interface, you should implement `supports_interface` 
method from the `ISRC5` introspection standard trait, with SNIP-6's Interface 
ID passed as a parameter.


```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {

    // __execute__, __validate__, is_valid_signature methods implemented here.
}


trait ISRC5 {

    fn supports_interface(interface_id: felt252) -> bool;

}

```

The `interface_id` parameter is the combined hash of the trait's selectors as
defined by Ethereum's ERC165 [3]. You can calculate for yourself the id
by using the `src5-rs` utility [4], or trust that the id is
**1270010605630597976495846281167968799381097569185364931397797212080166453709.** 


So far, we have created the basic structure for the account contract, as defined
by the SNIP-G Interface standard;


```rust
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(calls: Array<Call>) -> felt252;
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}

```


##Additional Interface

The elements described above are foundational to defining an account
contract and sufficient to implement the SNIP-6 standard. Nevertheless,
there are additional components that can be incorporated to bolster the
account contract’s functionality. 


For instance, the `__validate_declare__` function is added if the contract
is used to declare other contracts and pay the associated gas fees, 
providing a mechanism to validate the contract declaration. 
Additionally, to counterfactually deploy a smart contract one can include the
`__validate_deploy__` function. 


Counterfactual deployment is a mechanism to deploy an account contract without
relying on another account contract to pay for the related gas fees.
It's important if we don't want to associate a new account contract with the
address that deployed it, but instead have a new beginning.


The deployment process starts by calculating locally the would-be-address of 
our account contract without actually deploying it yet. This is possible
to achieve using the Starkli [5] tool. Once we know the account contract's
address, we then send enough ETH to that address to cover the costs of
deploying our account contract.


Once the precalculated account address is funded, we can finally send a `deploy_account`
transaction to Starknet with the compiled code of our account contract. 
The sequencer will deploy the account contract to the precalculated address
and pay itself gas fees with the ETH we sent there. There's no need to `declare`
an account contract before deploying it.


To allow tools like Starkli to easily integrate with our smart contract in the
future, its recommended to expose the `public_key` of the signer as a view
function as part of the public interface. With that in mind, the extended
account contract's interface is as follows;


```rust
/// @title IAccount Additional account contract interface
trait IAccountAddon {
    /// @notice Assert whether a declare transaction is valid to be executed
    /// @param class_hash The class hash of the smart contract to be declared
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_declare__(class_hash: felt252) -> felt252;

    /// @notice Assert whether counterfactual deployment is valid to be executed
    /// @param class_hash The class hash of the account contract to be deployed
    /// @param salt Account address randomizer
    /// @param public_key The public key of the account signer
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;

    /// @notice Exposes the signer's public key
    /// @return The public key
    fn public_key() -> felt252;
}

```  


In summary, a fully fledged account contract should implement the **SNIP-5**, **SNIP-6** 
and the **Addon** interface.



```rust
// Cheat sheet

struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

trait ISRC6 {
    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(calls: Array<Call>) -> felt252;
    fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

trait ISRC5 {
    fn supports_interface(interface_id: felt252) -> bool;
}

trait IAccountAddon {
    fn __validate_declare__(class_hash: felt252) -> felt252;
    fn __validate_deploy__(class_hash: felt252, salt: felt252, public_key: felt252) -> felt252;
    fn public_key() -> felt252;
}

```



## Summary

We elucidated the unique aspects of account contracts and their
derivation from basic smart contracts by adhering to specific methods
outlined in SNIP-6.

We defined the `ISRC6` trait, detailing the critical functions, namely,
`__validate__`, `is_valid_signature`, and `__execute__`. These functions
carry out tasks such as transaction validation, signature verification,
and contract call execution, respectively. We further introduced the
`ISRC5` trait, emphasizing the `supports_interface` function for
verifying interface support in contracts.

Furthermore, we defined a single contract call using the `Call` struct,
explaining its fields— `to`, `selector`, and `calldata`. We also
discussed potential enhancements to account contracts using
`__validate_declare__` and `__validate_deploy__` functions..

In the next subchapter, we will implement a simple account contract and
learn how to deploy it on Starknet. This will provide a practical
understanding of how account contracts work and how to interact with
them.



## References:

-  \[1\] Starknet Docs: Limitations on the validate function
   <https://docs.starknet.io/documentation/architecture_and_concepts/Account_Abstraction/validate_and_execute/#validate_limitations>

-  \[2\] Cairo Book: The span data type
   <https://book.cairo-lang.org/ch02-06-common-collections.html#span>

-  \[3\] ERC-165: Standard Interface Detection
   <https://eips.ethereum.org/EIPS/eip-165>

-  \[4\] Github: src5-rs
   <https://github.com/ericnordelo/src5-rs>

-  \[5\] Github: starkli
   <https://github.com/xJonathanLEI/starkli>

 
The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
