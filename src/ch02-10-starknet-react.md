# Starknet-React: React Integration

In the starknet ecosystem, several tools are available for front-end development. The most notable are:

- [starknet-react](https://github.com/apibara/starknet-react) ([documentation](https://starknet-react.com/docs/getting-started)): A collection of React hooks tailored for Starknet, inspired by [wagmi](https://github.com/tmm/wagmi) and powered by [starknet.js](https://github.com/0xs34n/starknet.js).

- [starknet.js](https://github.com/0xs34n/starknet.js): This JavaScript library facilitates interactions with Starknet contracts, akin to [web3.js](https://web3js.org/) for Ethereum.

Developed by the [Apibara](https://github.com/apibara/) team, [Starknet React](https://github.com/apibara/starknet-react/) is an open-source suite of React providers and hooks specifically for Starknet.

## Integrating Starknet React

The fastest way to get started using Starknet React is by using the `create-starknet` Command Line Interface (CLI). The tool will guide you through setting up your Starknet application:

```bash
npm init starknet
```

Or, if you want to do it manually you will need to add the following dependencies to your project:

```bash
npm install @starknet-react/chains @starknet-react/core starknet get-starknet-core
```

[Starknet.js](https://www.starknetjs.com/) is an SDK designed to simplify interactions with Starknet. Conversely, [get-starknet](https://github.com/starknet-io/get-starknet/) specializes in wallet connection management.

Wrap your app in the `StarknetConfig` component to configure and provide a React Context. This component lets you specify wallet connection options for users through its connectors prop.

```javascript
export default function App({ children }) {
  const chains = [goerli, mainnet];
  const provider = publicProvider();
  const { connectors } = useInjectedConnectors({
    // Show these connectors if the user has no connector installed.
    recommended: [argent(), braavos()],
    // Hide recommended connectors if the user has any connector installed.
    includeRecommended: "onlyIfNoConnectors",
    // Randomize the order of the connectors.
    order: "random",
  });

  return (
    <StarknetConfig chains={chains} provider={provider} connectors={connectors}>
      {children}
    </StarknetConfig>
  );
}
```

## Establishing Connection and Managing Account

After defining the connectors in the `config`, you can use a hook to access them. This enables users to connect their wallets.

```javascript
export default function Component() {
  const { connect, connectors } = useConnect();
  return (
    <ul>
      {connectors.map((connector) => (
        <li key={connector.id}>
          <button onClick={() => connect({ connector })}>
            {connector.name}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

Now, observe the `disconnect` function that terminates the connection when
invoked:

```javascript
const { disconnect } = useDisconnect();
return <button onClick={() => disconnect()}>Disconnect</button>;
```

Once connected, the `useAccount` hook provides access to the connected account, giving insights into the connection's current state.

```javascript
const { address, isConnected, isReconnecting, account } = useAccount();

return <div>{isConnected ? <p>Hello, {address}</p> : <Connect />}</div>;
```

State values like `isConnected` and `isReconnecting` update automatically, easing UI updates. This is particularly useful for asynchronous processes, removing the need for manual state management in your components.

Once connected, signing messages is easy with the account value from the `useAccount` hook. For a smoother experience, you can also use the `useSignTypedData` hook.

```Javascript
    const { data, isPending, signTypedData } = useSignTypedData(exampleData);

    return (
      <button
        onClick={() => signTypedData(exampleData)}
        disabled={!account}
      >
        {isPending ? <p>Waiting for wallet...</p> : <p>Sign Message</p>}
      </button>
    );
```

Starknet React supports signing an array of `BigNumberish` values or an object. When signing an object, ensure the data adheres to the EIP712 type. For detailed guidance on signing, see the Starknet.js documentation: [here](https://www.starknetjs.com/docs/guides/signature/).

## Displaying StarkName

Once an account is connected, the `useStarkName` hook retrieves the `StarkName` of the account. Linked to [Starknet.id](https://www.starknet.id/), it allows for displaying the user address in a user-friendly manner.

```Javascript
    const { data, isLoading, isError } = useStarkName({ address });

    if (isLoading)
        return <span>Loading...</span>;
    if (isError)
        return <span>Error fetching name...</span>;

    return <span>StarkName: {data}</span>;
```

This hook provides additional information: **error**, **status**, **fetchStatus**, **isSuccess**, **isError**, **isPending**, **isFetching**, **isLoading**. These details offer precise insights into the current process.

## Fetching Address from `StarkName`

To retrieve an `address` from a `StarkName`, use the `useAddressFromStarkName` hook.

```Javascript
    const { data, isLoading, isError } = useAddressFromStarkName({
      name: "vitalik.stark",
    });

    if (isLoading)
        return <span>Loading...</span>;
    if (isError)
        return <span>Error fetching address...</span>;

    return <span>address: {data}</span>;
```

If the provided name does not have an associated address, it will return
`0x0`

## Navigating the Network

Starknet React provides developers with tools for network interactions, including hooks like useBlock for retrieving the latest block:

```Javascript
        const { data, isLoading, isError } = useBlock({
        refetchInterval: 10_000,
        blockIdentifier: "latest" as BlockNumber,
        });

        if (isLoading)
            return <span>Loading...</span>;
        if (isError || !data)
            return <span>Error...</span>;

        return <span>Hash: {data.block_hash}</span>;
```

Here, `refetchInterval` sets the data refresh rate. Starknet React uses [react-query](https://github.com/TanStack/query/) for state and query management. Other hooks like `useContractRead` and `useWaitForTransaction` are also available for interval-based updates.

The useStarknet hook gives direct access to the ProviderInterface:

```Javascript
    const { provider } = useProvider()

    // library.getClassByHash(...)
    // library.getTransaction(...)
```

## Tracking Wallet changes

For a better dApp user experience, tracking wallet changes is crucial. This includes account changes, connections, disconnections, and network switches. Reload balances on account changes, or reset your dApp's state on network changes. Use `useAccount` and `useNetwork` for this.

`useNetwork` provides the current network chain:

```Javascript
    const { chain: { id, name } } = useNetwork();

    return (
        <>
            <p>Connected chain: {name}</p>
            <p>Connected chain id: {id}</p>
        </>
    )
```

This hook also offers **blockExplorer**, **testnet** for detailed network information.

Monitor user interactions with account and network using the `useEffect` hook:

```Javascript
    const { chain } = useNetwork();
    const { address } = useAccount();

    useEffect(() => {
        if(address) {
            // Do some work when the user changes the account on the wallet
            // Like reloading the balances
        }else{
            // Do some work when the user disconnects the wallet
            // Like reseting the state of your dApp
        }
    }, [address]);

    useEffect(() => {
        // Do some work when the user changes the network on the wallet
        // Like reseting the state of your dApp
    }, [chain]);
```

## Contract Interactions

### Read Functions

Starknet React introduces `useContractRead`, similar to wagmi, for read operations on contracts. These operations are independent of the user's connection status and don't require a signer.

```javascript
    const { data, isError, isLoading, error } = useContractRead({
        functionName: "balanceOf",
        args: [address as string],
        abi,
        address: testAddress,
        watch: true,
    });

    if (isLoading)
        return <div>Loading ...</div>;
    if (isError || !data)
        return <div>{error?.message}</div>;

    return <div>{parseFloat(data.balance.low)}n</div>;
```

For ERC20 operations, the `useBalance` hook simplifies retrieving balances without needing an ABI.

```javascript
const { isLoading, isError, error, data } = useBalance({
  address,
  watch: true,
});

if (isLoading) return <div>Loading ...</div>;
if (isError || !data) return <div>{error?.message}</div>;

return (
  <div>
    {data.value.toString()}
    {data.symbol}
  </div>
);
```

### Write Functions

The `useContractWrite` hook, unlike wagmi, benefits from Starknet's native support for multicall transactions. This improves user experience by facilitating multiple transactions without individual approvals.

```javascript
    const calls = useMemo(() => {
      if (!address || !contract) return [];
      // return a single object for single transaction,
      // or an array of objects for multicall**
      return contract.populateTransaction["transfer"]!(address, { low: 1, high: 0 });
    }, [contract, address]);

    const {
      writeAsync,
      data,
      isPending,
    } = useContractWrite({
      calls,
    });

    return (
      <>
        <button onClick={() => writeAsync()}>Transfer</button>
        <p>status: {isPending && <div>Submitting...</div>}</p>
        <p>hash: {data?.transaction_hash}</p>
      </>
    );
```

This setup starts with the `populateTransaction` utility, followed by executing the transaction through `writeAsync`. The hook also provides transaction status and hash.

### A Single Contract Instance

For cases where a single contract instance is more than apecifying the contract address and ABI in each hook., use the `useContract` hook:

```javascript
const { contract } = useContract({
  address: CONTRACT_ADDRESS,
  abi: abi_erc20,
});

// Call functions directly on contract
// contract.transfer(...);
// contract.balanceOf(...);
```

## Tracking Transactions

`UseWaitForTransaction` tracks transaction states with a transaction hash, reducing network requests through caching.

```javascript
const { isLoading, isError, error, data } = useWaitForTransaction({
  hash: transaction,
  watch: true,
});

if (isLoading) return <div>Loading ...</div>;
if (isError || !data) return <div>{error?.message}</div>;

return <div>{data.status?.length}</div>;
```

Explore all available hooks in Starknet React's documentation: <https://starknet-react.com/hooks/>.

## Conclusion

The Starknet React library provides a range of React hooks and providers specifically designed for Starknet and the Starknet.js SDK. These tools enable developers to create applications on the Starknet network.
