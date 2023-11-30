# Starknet-React: React Integration

Several tools exist in the starknet ecosystem to build the front-end for
your application. The most popular ones are:

- [starknet-react](https://github.com/apibara/starknet-react)
  ([documentation](https://starknet-react.com/docs/getting-started)):
  Collection of React hooks for Starknet. It is inspired by
  [wagmi](https://github.com/tmm/wagmi), powered by
  [starknet.js](https://github.com/0xs34n/starknet.js).

- [starknet.js](https://github.com/0xs34n/starknet.js): A JavaScript
  library for interacting with Starknet contracts. It would be the
  equivalent of [web3.js](https://web3js.org/) for Ethereum.

For Vue developers, vue-stark-boil, created by the team at [Don’t Panic
DAO](https://github.com/dontpanicdao), is a great option. For a deeper
understanding of Vue, visit their [website](https://vuejs.org/). The
vue-stark-boil boilerplate enables various functionalities, such as
connecting to a wallet, listening for account changes, and calling a
contract.

Authored by the [Apibara](https://github.com/apibara/) team, [Starknet
React](https://github.com/apibara/starknet-react/) is an open-source
collection of React providers and hooks meticulously designed for
Starknet.

To immerse in the real-world application of Starknet React, we recommend
exploring the comprehensive example dApp project at [Starknet React Demos](https://starknet-react.com/demos/).

## Integrating Starknet React

The fastest way to get started using Starknet React is by using the create-starknet Command Line Interface (CLI). The tool will guide you through setting up your Starknet application:

```bash
$ npm init starknet
Need to install the following packages:
  create-starknet@2.0.1
Ok to proceed? (y) y
✔ What is your project named? … my-starknet-app
✔ What framework would you like to use? › Next.js
Installing dependencies...
Success! Created my-starknet-app at ~/my-starknet-app
```

Or, if you want to manually start your Starknet React journey you will need the incorporation
of vital dependencies. Let’s start by adding them to your project.

    npm install @starknet-react/chains @starknet-react/core starknet get-starknet-core

[Starknet.js](https://www.starknetjs.com/) is an essential SDK
facilitating interactions with Starknet. In contrast,
[get-starknet](https://github.com/starknet-io/get-starknet/) is a
package adept at managing wallet connections.

Proceed by swaddling your app within the `StarknetConfig` component.
This enveloping action offers a degree of configuration, while
simultaneously providing a React Context for the application beneath to
utilize shared data and hooks. The `StarknetConfig` component accepts a
connectors prop, allowing the definition of wallet connection options
available to the user.

        export default function App({ children }) {
            const chains = [goerli, mainnet];
            const provider = publicProvider();
            const { connectors } = useInjectedConnectors({
                // Show these connectors if the user has no connector installed.
                recommended: [
                    argent(),
                    braavos(),
                ],
                // Hide recommended connectors if the user has any connector installed.
                includeRecommended: "onlyIfNoConnectors",
                // Randomize the order of the connectors.
                order: "random"
            });

            return (
                <StarknetConfig
                    chains={chains}
                    provider={provider}
                    connectors={connectors}
                >
                    {children}
                </StarknetConfig>
            );
        }

## Establishing Connection and Managing Account

Once the connectors are defined in the config, the stage is set to use a
hook to access these connectors, enabling users to connect their
wallets:

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

Now, observe the `disconnect` function that terminates the connection when
invoked:

    const { disconnect } = useDisconnect();
    return <button onClick={() => disconnect()}>Disconnect</button>

And, post connection, access to the connected account is provided
through the `useAccount` hook, offering insight into the current state
of connection:

    const { address, isConnected, isReconnecting, account } = useAccount();

    return (
        <div>
          {isConnected ? (
              <p>Hello, {address}</p>
          ) : (
            <Connect />
          )}
        </div>
    );

The state values, such as `isConnected` and `isReconnecting`, receive
automatic updates, simplifying UI conditional updates. This convenient
pattern shines when dealing with asynchronous processes, as it
eliminates the need to manually manage the state within your components.

Having established a connection, signing messages becomes a breeze using
the account value returned from the `useAccount` hook. For a more
streamlined experience, the `useSignTypedData` hook is at your disposal.

    const { data, isPending, signTypedData } = useSignTypedData(exampleData);

    return (
      <button
        onClick={() => signTypedData(exampleData)}
        disabled={!account}
      >
        {isPending ? <p>Waiting for wallet...</p> : <p>Sign Message</p>}
      </button>
    );

Starknet React supports signing an array of `BigNumberish` values or an
object. While signing an object, it is crucial to ensure that the data
conforms to the EIP712 type. For a more comprehensive guide on signing,
refer to the Starknet.js documentation:
[here](https://www.starknetjs.com/docs/guides/signature/).

## Displaying StarkName

After an account has been connected, the `useStarkName` hook can be used
to retrieve the StarkName of this connected account. Related to
[Starknet.id](https://www.starknet.id/) it permits to display the user
address in a more user friendly way.

    const { data, isLoading, isError } = useStarkName({ address });

    if (isLoading)
        return <span>Loading...</span>;
    if (isError)
        return <span>Error fetching name...</span>;

    return <span>StarkName: {data}</span>;

You also have additional information you can get from this hook →
**error**, **status**, **fetchStatus**, **isSuccess**, **isError**,
**isPending**, **isFetching**, **isLoading** which can give
you more precise information on what is happening.

## Fetching address from StarkName

You could also want to retrieve an address corresponding to a StarkName.
For this purpose, you can use the `useAddressFromStarkName` hook.

    const { data, isLoading, isError } = useAddressFromStarkName({
      name: "vitalik.stark",
    });

    if (isLoading)
        return <span>Loading...</span>;
    if (isError)
        return <span>Error fetching address...</span>;

    return <span>address: {data}</span>;

If the provided name does not have an associated address, it will return
**"0x0"**

## Navigating the Network

In addition to wallet and account management, Starknet React equips
developers with hooks for network interactions. For instance, useBlock
enables the retrieval of the latest block:

    const { data, isLoading, isError } = useBlock({
      refetchInterval: 10_000,
      blockIdentifier: 'latest' as BlockNumber
    })

    if (isLoading)
        return <span>Loading...</span>
    if (isError || !data)
        return <span>Error...</span>

    return <span>Hash: {data.block_hash}</span>

In the aforementioned code, refetchInterval controls the frequency of
data refetching. Behind the scenes, Starknet React harnesses
[react-query](https://github.com/TanStack/query/) for managing state and
queries. In addition to useBlock, Starknet React offers other hooks like
useContractRead and useWaitForTransaction, which can be configured to
update at regular intervals.

The useStarknet hook provides direct access to the ProviderInterface:

    const { provider } = useProvider()

    // library.getClassByHash(...)
    // library.getTransaction(...)

## Tracking Wallet changes

To improve your dApp User Experience, you can track the user wallet
changes, especially when the user changes the wallet account (or
connects/disconnects). But also when the user changes the network. You
could want to reload correct balances when the user changes the account,
or to reset the state of your dApp when the user changes the network. To
do so, you can use a previous hook we already looked at: `useAccount`
and a new one `useNetwork`.

The `useNetwork` hook can provide you with the network chain currently
in use.

    const { chain: {id, name} } = useNetwork();

    return (
        <>
            <p>Connected chain: {name}</p>
            <p>Connected chain id: {id}</p>
        </>
    )

You also have additional information you can get from this hook →
**blockExplorer**, **testnet** which can give you more precise
information about the current network being used.

After knowing this you have all you need to track user interaction on
the using account and network. You can use the `useEffect` hook to do
some work on changes.

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

## Contract Interactions

### Read Functions

Starknet React presents useContractRead, a specialized hook for invoking
read functions on contracts, akin to wagmi. This hook functions
independently of the user’s connection status, as read operations do not
necessitate a signer.

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

For ERC20 operations, Starknet React offers a convenient useBalance
hook. This hook exempts you from passing an ABI and returns a suitably
formatted balance value.

    const { isLoading, isError, error, data } = useBalance({
        address,
        watch: true
    })

    if (isLoading)
        return <div>Loading ...</div>;
    if (isError || !data)
        return <div>{error?.message}</div>;

    return <div>{data.value.toString()}{data.symbol}</div>

### Write Functions

The useContractWrite hook, designed for write operations, deviates
slightly from wagmi. The unique architecture of Starknet facilitates
multicall transactions natively at the account level. This feature
enhances the user experience when executing multiple transactions,
eliminating the need to approve each transaction individually. Starknet
React capitalizes on this functionality through the useContractWrite
hook. Below is a demonstration of its usage:

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

The code snippet begins by compiling the calldata using the
populateTransaction utility provided by Starknet.js. This calldata, along
with the contract address and entry point, are passed to the
useContractWrite hook. The hook returns a writeAsync function that is
subsequently used to execute the transaction. The hook also provides the
transaction’s hash and state.

### A Single Contract Instance

In certain use cases, working with a single contract instance may be
preferable to specifying the contract address and ABI in each hook.
Starknet React accommodates this requirement with the useContract hook:

    const { contract } = useContract({
        address: CONTRACT_ADDRESS,
        abi: abi_erc20,
    });

    // Call functions directly on contract
    // contract.transfer(...);
    // contract.balanceOf(...);

## Tracking Transactions

The useWaitForTransaction hook allows for the tracking of transaction states
given a transaction hash. This hook maintains a cache of all
transactions, thereby minimizing redundant network requests.

    const { isLoading, isError, error, data } = useWaitForTransaction({
                                                    hash: transaction,
                                                    watch: true})

    if (isLoading)
        return <div>Loading ...</div>;
    if (isError || !data)
        return <div>{error?.message}</div>;

    return <div>{data.status?.length}</div>

The full array of available hooks can be discovered in the Starknet
React documentation, accessible here:
<https://starknet-react.com/hooks/>.

## Conclusion

The Starknet React library offers a comprehensive suite of React hooks
and providers, purpose-built for Starknet and the Starknet.js SDK. By
taking advantage of these well-crafted tools, developers can build
robust decentralized applications that harness the power of the Starknet
network.

Through the diligent work of dedicated developers and contributors,
Starknet React continues to evolve. New features and optimizations are
regularly added, fostering a dynamic and growing ecosystem of
decentralized applications.

It’s a fascinating journey, filled with innovative technology, endless
opportunities, and a growing community of passionate individuals. As a
developer, you’re not only building applications, but contributing to
the advancement of a global, decentralized network.

Have questions or need help? The Starknet community is always ready to
assist. Join the [Starknet Discord](https://discord.gg/starknet) or
explore the [StarknetBook’s GitHub
repository](https://github.com/starknet-edu/starknetbook) for resources
and support.
