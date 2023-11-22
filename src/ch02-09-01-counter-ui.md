# Counter Smart Contract UI Integration

This guide walks readers through integrating a simple counter smart contract with a frontend. By the end of this guide, readers will understand how to:

- Connect the frontend to a smart contract.
- Initiate transactions, such as incrementing or decrementing the counter.
- Read and display data, such as showing the counter value on the frontend.

For a visual walkthrough, do check out the [Basecamp frontend session](https://drive.google.com/file/d/1Dtb3Ol_BVoNV4w-_MKV8aeyyRra8nRtz/view). This comprehensive session delves deeper into the nuances of the concepts we've touched upon, presenting a mix of theoretical explanations and hands-on demonstrations.

## Tools Used

- [Reactjs](https://react.dev/learn/start-a-new-react-project): A frontend building framework.
- [@argent/get-starknet](https://www.npmjs.com/package/@argent/get-starknet): A wrapper for **[starknet.js](https://github.com/0xs34n/starknet.js)**, aiding interaction with wallet extensions.
- [starknet](https://www.npmjs.com/package/starknet): A JavaScript library for Starknet.

## Setting Up the Environment

To begin, clone the project repository:

```bash
git clone https://github.com/Darlington02/basecamp-frontend-boilerplate
```

Then, navigate to the project directory and install necessary packages:

```bash
cd basecamp-frontend-boilerplate
npm install
```

To launch the project, run:

```bash
yarn start
```

In `index.js`, several key functions are provided:

```javascript
// Connect to the blockchain via a wallet provider (argentX or Bravoos)
const connectWallet = async () => {};

// Terminate the connection
const disconnectWallet = async () => {};

// Trigger increment
const increaseCounter = async () => {};

// Trigger decrement
const decreaseCounter = async () => {};

// Retrieve current count
const getCounter = async () => {};
```

## Managing Connection

### `connectWallet`

The `connectWallet` function serves as the mechanism to establish a connection to the blockchain through specific wallet providers such as ArgentX or Braavos. It is asynchronous, allowing the use of `await` for handling asynchronous tasks.

```JavaScript
const connectWallet = async() => {
    const connection = await connect({webWalletUrl: "https://web.argent.xyz"});
    if (connection && connection.isConnected) {
      setConnection(connection);
      setAccount(connection.account);
      setAddress(connection.selectedAddress);
    }
}
```

- Initiates the connection using the **`connect`** method from the **`@argent/get-starknet`** library, targeting Starknet.
- Upon a successful connection, updates the React component's state with details of the **`connection`**, **`account`**, and **`selectedAddress`**.

### `disconnectWallet`

The `disconnectWallet` function is designed to sever the connection with the web wallet asynchronously. After disconnection, it updates the component's state, resetting connection details.

```bash
const disconnectWallet = async() => {
    await disconnect();
    setConnection(undefined);
    setAccount(undefined);
    setAddress('');
}
```

- It utilizes the **`disconnect`** function, possibly from an external library, and handles the operation asynchronously with **`await`**.
- Post-disconnection, the state of the React component is updated:
  - **`setConnection`** is set to **`undefined`**.
  - **`setAccount`** is set to **`undefined`**.
  - **`setAddress`** is cleared with an empty string.

### `EagerlyConnect`

The `EagerlyConnect` mechanism leverages React's `useEffect` hook to initiate a connection to Starknet upon the component's mounting or initial rendering.

```javascript
useEffect(() => {
  const connectToStarknet = async () => {
    const connection = await connect({
      modalMode: "neverAsk",
      webWalletUrl: "https://web.argent.xyz",
    });

    if (connection && connection.isConnected) {
      setConnection(connection);
      setAccount(connection.account);
      setAddress(connection.selectedAddress);
    }
  };
  connectToStarknet();
}, []);
```

- Inside the **`useEffect`**, the **`connectToStarknet`** function is defined, aiming to establish an asynchronous connection using the **`connect`** function. Parameters like **`modalMode`** and **`webWalletUrl`** are passed to guide the connection process.
- If successful in connecting (**`connection && connection.isConnected`**), the state updates with details of the connection, the account, and the selected address using **`setConnection`**, **`setAccount`**, and **`setAddress`**.
- The **`connectToStarknet`** function is executed immediately after its definition.

## Important Refresher on Smart Contract Interactions

For effective interaction with a smart contract on the network, it's crucial to understand key components after establishing a connection. Among these are the `contract address`, `ABI`, `Signer`, and `Provider`.

### ABI (Application Binary Interface)

ABI is a standardized bridge between two binary program modules. It is essential for:

- Interacting with smart contracts on the blockchain.
- Specifying the structure of functions, events, and variables for software applications.
- Enabling smooth communication with the smart contract, detailing function signatures, input/output types, event formats, and variable types.
- Facilitating invocation of functions and data retrieval from the contract.

### Signer

The Signer plays a pivotal role in:

- Signing transactions.
- Authorizing actions on the blockchain.
- Bearing the fees associated with blockchain operations.

Signers are especially linked to write operations that change the state of the blockchain. These operations need cryptographic signing for security and validity.

### Provider

The Provider acts as the medium for:

- Communication with the blockchain.
- Creating transactions.
- Fetching data from the blockchain.

To initiate a write transaction, the connected account (signer) must be provided. This signer then signs the transaction, bearing the necessary fee for execution.

## Invoking the `increment` Function

```javascript
const increaseCounter = async () => {
  try {
    const contract = new Contract(contractAbi, contractAddress, account);
    await contract.increment();
    alert("You successfully incremented the counter!");
  } catch (err) {
    alert(err.message);
  }
};
```

The **`increaseCounter`** function is crafted to interact with a smart contract and increment a specific counter. Here's a step-by-step breakdown:

1. Establishes a new contract instance using the provided contract's ABI, its address, and the connected account. The account is essential since this write transaction alters the contract's state.
2. Executes the contract's **`increment`** method. The **`await`** keyword ensures the program pauses until this action completes.
3. On successful execution, the user receives a confirmation alert indicating the counter's increment.
4. In case of any errors during the process, an alert displays the corresponding error message to the user.

## Invoking the `decrement` Function

```javascript
const decreaseCounter = async () => {
  try {
    const contract = new Contract(contractAbi, contractAddress, account);
    await contract.decrement();
    alert("You successfully decremented the counter!");
  } catch (err) {
    alert(err.message);
  }
};
```

The **`decreaseCounter`** function is designed to interact with a smart contract and decrement a specific counter. Here's a succinct breakdown of its operation:

1. Creates a new contract instance by utilizing the provided contract's ABI, its address, and the connected account. The account is vital as this write transaction modifies the contract's state.
2. Initiates the contract's **`decrement`** method. With the use of the **`await`** keyword, the program ensures it waits for the decrement action to finalize.
3. Upon successful execution, the user is notified with an alert indicating the counter's decrement.
4. Should any errors arise during the interaction, the user is promptly alerted with the pertinent error message.

## Fetching the Current Count with `get_current_count` Function

```javascript
const getCounter = async () => {
  const provider = new Provider({
    sequencer: { network: constants.NetworkName.SN_MAIN },
  });
  try {
    const mycontract = new Contract(contractAbi, contractAddress, provider);
    const num = await mycontract.get_current_count();
    setRetrievedValue(num.toString());
  } catch (err) {
    alert(err.message);
  }
};
```

The **`getCounter`** function is designed to retrieve the current count from a smart contract. Here's a breakdown of its operation:

1. Establishes a provider instance, specifying the sequencer network – in this instance, it's set to the **`mainnet`** through **`constants.NetworkName.SN_MAIN`**.
2. With this provider, it then initiates a contract instance using the provided contract's ABI, its address, and the aforementioned provider.
3. The function then invokes the **`get_current_count`** method of the contract to fetch the current count. This is an asynchronous action, and the program waits for its completion with the **`await`** keyword.
4. Once successfully retrieved, the count, which is presumably a number, is converted to a string and stored using the **`setRetrievedValue`** function.
5. In the event of any errors during the process, an alert provides the user with the relevant error message.

It's essential to emphasize that while performing read operations, like fetching data from a blockchain network, the function uses the provider. Unlike write operations, which typically require a signer (or an account) for transaction signing, read operations don't mandate such authentication. Thus, in this function, only the provider is specified, and not the signer.

## Wrapping It Up: Integrating a Frontend with a Counter Smart Contract

In this tutorial, we review the process of integrating a basic counter smart contract with a frontend application.

Here's a quick recap:

1. **Establishing Connection**: With the **`connectWallet`** function, we made seamless connections to the blockchain, paving the way for interactions with our smart contract.
2. **Terminating Connection**: The **`disconnectWallet`** function ensures that users can safely terminate their active connections to the blockchain, maintaining security and control.
3. **Interacting with the Smart Contract**: Using the **`increaseCounter`**, **`decreaseCounter`**, and **`getCounter`** functions, we explored how to:
   - Initiate transactions
   - Adjust the counter value (increment or decrement)
   - Fetch data from the blockchain

For a visual walkthrough, do check out the [Basecamp frontend session](https://drive.google.com/file/d/1Dtb3Ol_BVoNV4w-_MKV8aeyyRra8nRtz/view). This comprehensive session delves deeper into the nuances of the concepts we've touched upon, presenting a mix of theoretical explanations and hands-on demonstrations.
