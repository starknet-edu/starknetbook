# MultiCaller Account

**NOTE:**
**THIS CHAPTER NEEDS TO BE UPDATED TO REFLECT THE NEW SYNTAX FOR ACCOUNT CONTRACTS. PLEASE DO NOT USE THIS CHAPTER AS A REFERENCE UNTIL THIS NOTE IS REMOVED.**

**CONTRIBUTE: This subchapter is missing an example of declaration, deployment and interaction with the contract. We would love to see your contribution! Please submit a PR.**

[Multicall](https://github.com/joshstevens19/ethereum-multicall#readme)
is a powerful technique that allows multiple constant smart contract
function calls to be aggregated into a single call, resulting in a
consolidated output. With Starknet’s account abstraction feature,
multicalls can be seamlessly integrated into account contracts.

## Why Multicalls?

Multicalls come handy in several scenarios. Here are some examples:

1.  **Token Swapping on Decentralized Exchanges**: In a typical token
    swap operation on a decentralized exchange (DEX), you first need to
    approve the spending of the tokens and then initiate the swap.
    Executing these operations separately could be cumbersome from a
    user experience perspective. With multicall, these calls can be
    combined into a single transaction, simplifying the user’s task.

2.  **Fetching Blockchain Data**: When you want to query the prices of
    two different tokens from the blockchain, it’s beneficial to have
    them both come from the same block for consistency. Multicall
    returns the latest block number along with the aggregated results,
    providing this consistency.

The benefits of multicall transactions can be realized more in the
context of account abstraction.

## Multicall Functionality in Account Contracts

To facilitate multicalls, we can introduce specific functions in the
account contract. Here are two core functions:

### `_execute_calls` Function

The `_execute_calls` function is responsible for executing the
multicalls. It iterates over an array of calls, executes them, and
aggregates the results.

```rust
    fn _execute_calls(mut calls: Array<AccountCall>, mut res:Array::<Array::<felt>>) -> Array::<Array::<felt>> {
        match calls.pop_front() {
            Option::Some(call) => {
                let _res = _call_contract(call);
                res.append(_res);
                return _execute_calls(calls, res);
            },
            Option::None(_) => {
                return res;
            },
        }
    }
```

Apart from the traditional **`execute`** function, adding the
**`_execute_calls`** function to your account contract can ensure that
you can make a multicall using your smart contract account.

The above code is a simple example snippet where the **"return
*execute\_calls(calls, res);"* statement makes recursive calls to the
**`_execute_calls`** function thereby bundling the calls together.
The final result will be aggregated and returned in the ***res***
variable.

### `_call_contract` Function

The `_call_contract` function is a helper function used to make
individual contract calls.

```rust
    fn _call_contract(call: AccountCall) -> Array::<felt> {
        starknet::call_contract_syscall(
            call.to, call.selector, call.calldata
        ).unwrap_syscall()
    }
```

## Considerations

While multicall provides significant benefits in terms of UX and data
consistency, it’s important to note that it may not significantly reduce
gas fees compared to individual calls. However, the primary advantage of
using multicall is that it ensures results are derived from the same
block, providing a much-improved user experience.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
