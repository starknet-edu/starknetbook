# Account Contracts

Now that we know better the concept of AA, let’s actually code it in
Starknet.

## Account Contract Interface

Account contracts, while essentially being smart contracts,
differentiate themselves through unique methods. A smart contract gains
the status of an account contract when it implements the interface as
described by SNIP-6 ([StarkNet IMprovement Proposa-6: Standar Account
Interface](https://github.com/ericnordelo/SNIPs/blob/feat/standard-account/SNIPS/snip-6.md)).
This standard borrows from SRC-6 and SRC-5, which are akin to Ethereum’s
ERCs, setting application-level conventions and contract standards.

To initiate, let’s formulate the `ISRC6` (SNIP-6: Standard Account
Interface) trait, which outlines the requisite functions for an account
contract:

```rust
    trait ISRC6 {
        fn __validate__(calls: Array<Call>) -> felt252;
        fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
        fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
    }
```

The functions represented above serve the following purposes:

-   `__validate__`: This function takes in the list of calls scheduled
    for execution and validates them in line with the rules specified in
    the contract. It returns a short string (e.g., VALID) encapsulated
    within a `felt252` that signifies the validation outcome.

-   `is_valid_signature`: This function is tasked with validating the
    signature of a transaction. It receives a hash of the transaction
    data and a signature, which may be validated against a public key or
    through any other method as specified by the contract creator. It
    returns a short string (e.g., VALID) encapsulated within a `felt252`
    that signifies the validation outcome.

-   `__execute__`: Post-validation, the `__execute__` function is
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

Until now, we’ve mentioned contract calls without explicitly defining
them. Let’s remedy that.

The `Call` struct represents a single contract call:

```rust
    struct Call {
        to: ContractAddress,
        selector: felt252,
        calldata: Array<felt252>
    }
```

Here’s what each field signifies:

-   `to`: The address of the target contract.

-   `selector`: The function’s selector to be invoked on the target
    contract.

-   `calldata`: An array that encapsulates the function parameters.

The elements described above are foundational to defining an account
contract and sufficient to implement the SNIP-6 standard. Nevertheless,
there are additional components that can be incorporated to bolster the
account contract’s functionality. For instance, the
`__validate_declare__` function might be added if the contract is used
to declare other contracts, providing a mechanism to validate the
contract declaration. Additionally, to counterfactually deploy a smart
contract (i.e., have it pay for its own deployment), one can include the
`__validate_deploy__` function. Detailed implementations of these
functions will be covered in the subsequent chapters.

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
`__validate_declare__` and `__validate_deploy__` functions. These
additional features, along with detailed function implementations, will
be explored in the chapters ahead.

In the next subchapter, we will implement a simple account contract and
learn how to deploy it on Starknet. This will provide a practical
understanding of how account contracts work and how to interact with
them.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
