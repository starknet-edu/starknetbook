# BaseCamp Frontend Session

This guide provides a walkthrough of the BaseCamp frontend session. It showcases how to integrate a simple counter smart contract with the front end, at the end of the walk-through, the reader should have understood how to establish a connection between the front end and smart contract, initiate transactions i.e incrementing, decrementing counter, read, and display data i.e display counter value to the front end.

The toolings utilized in this guide are:

- [Reactjs](https://react.dev/learn/start-a-new-react-project) : a  framework for building frontend application
- [@argent/get-starknet](https://www.npmjs.com/package/@argent/get-starknet) : a light wrapper around **[starknet.js](https://github.com/0xs34n/starknet.js)** to interact with the wallet extension.
- [starknet](https://www.npmjs.com/package/starknet) : javascript library for Starkent

To follow along, setup the development environment by installing the following:

Clone the project repository: 
```bash
https://github.com/Darlington02/basecamp-frontend-boilerplate
```

After cloning the project run the command below:

```bash
cd basecamp-frontend-boilerplate

npm install
```

To start project , run the command:

```bash
yarn start
```

The index.js contains some important functions such as:

```bash
//establish a connection with blockchain through a wallet provider (argentX or Bravoos)
  const connectWallet = async() => {

  }

//Discontinue connection
  const disconnectWallet = async() => {

  }

//invoke  increment()

  const increaseCounter = async() => {

  }

//invoke decrement()

  const decreaseCounter = async() => {

  }

//call get_current_count()

  const getCounter = async() => {

  }

```

## Creating Connection

### ConnectWallet

```bash
//establish a connection with blockchain through a wallet provider (argentX or Bravoos)
const connectWallet = async() => {
    const connection = await connect( {webWalletUrl: "https://web.argent.xyz" } );
    if (connection && connection.isConnected) {
      setConnection(connection)
      setAccount(connection.account)
      setAddress(connection.selectedAddress)
    }
  }
  ```

  The `connectWallet` function is asynchronous, allowing for the use of await to handle asynchronous operations.

- The `connect` function from the `@argent/get-starknet`` library is called to attempt the connection to Starknet.
- If the connection is successful (connection && connection.isConnected), it updates the React component's state to store the connection details, `account`, and `selected address`.

### DisconnectWallet

```bash
const disconnectWallet = async() => {
    await disconnect()
    setConnection(undefined)
    setAccount(undefined)
    setAddress('')
  }
  ```
The **`disconnectWallet`** function is an asynchronous function that disconnects from the web wallet, presumably using a **`disconnect`** function from an unspecified library. 

- It calls the **`disconnect`** function using **`await`** to handle the asynchronous disconnection process.
- After successfully disconnecting, it proceeds to update the React component's state by resetting the connection (**`setConnection`**), account (**`setAccount`**), and address (**`setAddress`**) to appropriate values. In this case, it sets the connection and account to **`undefined`** and the address to an empty string.

### EagerlyConnect

```bash
useEffect(() => {
    const connectToStarknet = async() => {
      const connection = await connect( { modalMode: "neverAsk", webWalletUrl: "https://web.argent.xyz" } );
      
      if(connection && connection.isConnected) {
        setConnection(connection)
        setAccount(connection.account)
        setAddress(connection.selectedAddress)
      }
    }
    connectToStarknet()
  }, [])
```

The **`useEffect`** hook in React is being used to trigger a connection to Starknet as soon as the component mounts or when it is initially rendered.

- The **`connectToStarknet`**, an asynchronous connection to Starknet is attempted using the **`connect`** function, passing specific options such as **`modalMode`** and **`webWalletUrl`**.
- If the connection is successful (**`connection && connection.isConnected`**), the state is updated to reflect the connection details, account, and selected address using the **`setConnection`**, **`setAccount`**, and **`setAddress`** functions.
- Finally, the **`connectToStarknet`** function is invoked immediately after being defined.

# Important refresher

After establishing a connection to the network, it is noteworthy to recall that in order to create an instance of the smart contract to interact with, you need the `contract address`,  `abi` `Signer` or `Provider`.

**ABI:**

 Application Binary Interface is a standardized format that defines how to interact with a smart contract on the blockchain. It specifies the structure of functions, events, and variables in a way that software applications can understand, enabling seamless communication and interaction with the smart contract. It includes function signatures, input/output types, event formats, and variable types, facilitating the invocation of functions and retrieval of data from the contract.

**Signer:**

A signer is an entity responsible for signing transactions, providing authorization, and paying fees for actions on a blockchain. It's often associated with write operations that modify the blockchain's state, requiring cryptographic signing to ensure security and validity.

**Provider:**

A provider facilitates communication, transaction creation, and data retrieval from the blockchain.


To initiate a write transaction, the signer i.e connected account, has to be provided, in this case, the signer signs the transaction and pays the fee needed to execute a call.

## Invoking `increment` function

```bash
const increaseCounter = async() => {
    try {
      const contract = new Contract(contractAbi, contractAddress, account)
      await contract.increment()
      alert("you successfully incremented the counter!")
    }
    catch(err) {
      alert(err.message)
    }
  }
```
The increaseCounter function is an asynchronous JavaScript function responsible for interacting with a smart contract to increment a counter. It first creates a contract instance using the contract's ABI, contract address, and the connected account (as this is a write transaction that modifies the contract's state). The function then calls the increment function of the contract using await to ensure it waits for the increment to complete. If successful, it alerts the user that the counter was incremented. If an error occurs during this process, it alerts the user with an appropriate error message.

## Invoking `decrement` function

```bash
const decreaseCounter = async() => {
    try {
      const contract = new Contract(contractAbi, contractAddress, account)
      await contract.decrement()
      alert("you successfully decremented the counter!")
    }
    catch(err) {
      alert(err.message)
    }
  }
```

The decreaseCounter function is an asynchronous JavaScript function responsible for interacting with a smart contract to decrement a counter. It first creates a contract instance using the contract's ABI, contract address, and the connected account (as this is a write transaction that modifies the contract's state). The function then calls the decrement function of the contract using await to ensure it waits for the decrement to complete. If successful, it alerts the user that the counter was decremented. If an error occurs during this process, it alerts the user with an appropriate error message.

## Call `get_current_count` function

```bash
const getCounter = async() => {
    const provider = new Provider({ sequencer: { network:constants.NetworkName.SN_MAIN } })
    try {
      const mycontract = new Contract(contractAbi, contractAddress, provider)
      const num = await mycontract.get_current_count()
      setRetrievedValue(num.toString())
    }
    catch(err) {
      alert(err.message)
    }
  }
```

The **`getCounter`** function first creates a provider instance. It then initializes a contract instance by passing the provider as the third parameter, designating the network where the contract is deployed, typically the `mainnet`. It's important to note that when reading data from the network, you specify the provider, not the signer (account).

In conclusion, this guide demonstrated how to integrate a simple counter smart contract with the front end. 

The guide covered critical functions such as connecting and disconnecting from the blockchain using **`connectWallet`** and **`disconnectWallet`** functions, respectively. It also showcased how to interact with the smart contract through **`increaseCounter`**, **`decreaseCounter`**, and **`getCounter`** functions, demonstrating transaction initiation, counter manipulation, and data retrieval.

For a more comprehensive understanding of the concepts explored in this guide, we encourage you to refer to the recorded [Basecamp frontend session](https://drive.google.com/file/d/1Dtb3Ol_BVoNV4w-_MKV8aeyyRra8nRtz/view). This session offers a deeper dive into the discussed topics, providing valuable insights and practical applications.
