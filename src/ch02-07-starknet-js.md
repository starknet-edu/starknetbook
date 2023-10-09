# Starknet-js: Javascript SDK

Starknet.js is a JavaScript/TypeScript library designed to connect your
website or decentralized application (D-App) to Starknet. It aims to
mimic the architecture of [ethers.js](https://docs.ethers.org/v5/), so
if you are familiar with ethers, you should find Starknet.js easy to
work with.

<img alt="Starknet-js in your dapp" src="img/ch02-starknet-js.png" class="center" style="width: 50%;" />

<span class="caption">Starknet-js in your dapp</span>

# Installation

To install Starknet.js, follow these steps:

-   For the latest official release (main branch):

<!-- -->

    npm install starknet

-   To use the latest features (merges in develop branch):

<!-- -->

    npm install starknet@next

## Getting Started

To build an app that users are able to connect to and interact with
Starknet, we recommend adding the
[get-starknet](https://github.com/starknet-io/get-starknet) library,
which allows you to manage wallet connections.

With these tools ready, there are basically 3 main concepts to know on
the frontend: Account, Provider, and Contracts.

### Account 

We can generally think of the account as the "end user" of a
dapp, and some user interaction will be involved to gain access to it.

Think of a dapp where the user connects their browser extension wallet
(such as ArgentX or Braavos) - if the user accepts the connection, that
gives us access to the account and signer, which can sign transactions
and messages.

Unlike Ethereum, where user accounts are Externally Owned Accounts,
Starknet **accounts are contracts**. This might not necessarily impact
your dapp’s frontend, but you should definitely be aware of this
difference.

```ts
async function connectWallet() {
    const starknet = await connect();
    console.log(starknet.account);
    
    const nonce = await starknet.account.getNonce();
    const message = await starknet.account.signMessage(...)
}
```
The snippet above uses the `connect` function provided by `get-starknet` to establish a connection to the user wallet. Once connected, we are able to access account methods, such as `signMessage` or `execute`.

### Provider 

The provider allows you to interact with the Starknet
network. You can think of it as a "read" connection to the blockchain,
as it doesn’t allow signing transactions or messages. Just like in
Ethereum, you can use a default provider, or use services such as Infura
or Alchemy, both of which support Starknet, to create an RPC provider.

By default, the Provider is a sequencer provider.

```ts
export const provider = new Provider({
  sequencer: {
    network: "goerli-alpha",
  },
  // rpc: {
  //   nodeUrl: INFURA_ENDPOINT
  // }
});

const block = await provider.getBlock("latest"); // <- Get latest block    
console.log(block.block_number);
```

## Contracts 

Your frontend will likely be interacting with deployed
contracts. For each contract, there should be a counterpart on the
frontend. To create these instances, you will need the contract’s
address and ABI, and either a provider or signer.

```ts
const contract = new Contract(
  abi_erc20,
  contractAddress,
  starknet.account
);

const balance = await contract.balanceOf(starknet.account.address);
const transfer = await contract.transfer(recipientAddress, amountFormatted);
//or: const transfer = await contract.invoke("transfer", [to, amountFormatted]); 

console.log(`Tx hash: ${transfer.transaction_hash}`);
```

If you create a contract instance with a provider, you’ll be limited to
calling read functions on the contract - only with a signer can you
change the state of the blockchain. However, you are able to connect a
previously created `Contract` instance with a new account:

```ts
const contract = new Contract(
  abi_erc20,
  contractAddress,
  provider
);

contract.connect(starknet.account);
```

In the snippet above, after
calling the `connect` method, it would be possible to call read
functions on the contract, but not before.

### Units 

If you have previous experience with web3, you know dealing
with units requires care, and Starknet is no exception. Once again, the
docs are very useful here, in particular [this section on data
transformation](https://www.starknetjs.com/docs/guides/define_call_message/).

Very often you will need to convert Cairo structs (such as Uint256) that
are returned from contracts into numbers:

```ts
// Uint256 shape:
// { 
//    type: 'struct', 
//    low: Uint256.low, 
//    high: Uint256.high 
// 
// }
const balance = await contract.balanceOf(address); // <- uint256
const asBN = uint256.uint256ToBN(uint256); // <- uint256 into BN
const asString = asBN.toString() //<- BN into string
```

And vice versa:

```ts
const amount = 1;

const amountFormatted = {
    type: "struct",
    ...uint256.bnToUint256(amount),
};
```

There are other helpful utils, besides `bnToUint256` and `uint256ToBN`,
provided by Starknet.js.

We now have a solid foundation to build a Starknet dapp. However, there
are framework specific tools that help us build Starknet dapps, which
are covered in chaper 5.

## Additional Resources

-   Starknet.js GitHub Repository:
    <https://github.com/0xs34n/starknet.js>

-   Official Starknet.js Website and documentation:
    <https://www.starknetjs.com/>

Stay tuned for more updates on Starknet.js, including detailed guides,
examples, and comprehensive documentation.

The Book is a community-driven effort created for the community.

-   If you’ve learned something, or not, please take a moment to provide
    feedback through [this 3-question
    survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

-   If you discover any errors or have additional suggestions, don’t
    hesitate to open an [issue on our GitHub
    repository](https://github.com/starknet-edu/starknetbook/issues).
