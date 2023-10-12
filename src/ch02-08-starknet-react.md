# Starknet-React: React Integration

Several tools exist in the starknet ecosystem to build the front-end for
your application. The most popular ones are:

- [starknet-react](https://github.com/apibara/starknet-react)
  ([documentation](https://apibara.github.io/starknet-react)):
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
exploring the comprehensive example dApp project at
[starknet-demo-dapp](https://github.com/finiam/starknet-demo-dapp/).

## Integrating Starknet React

Embarking on your Starknet React journey necessitates the incorporation
of vital dependencies. Let’s start by adding them to your project.

    yarn add @starknet-react/core starknet get-starknet

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

    const connectors = [
      new InjectedConnector({ options: { id: "braavos" } }),
      new InjectedConnector({ options: { id: "argentX" } }),
    ];

    return (
        <StarknetConfig
          connectors={connectors}
          autoConnect
        >
          <App />
        </StarknetConfig>
    )

## Establishing Connection and Managing Account

Once the connectors are defined in the config, the stage is set to use a
hook to access these connectors, enabling users to connect their
wallets:

    export default function Connect() {
      const { connect, connectors, disconnect } = useConnectors();

      return (
        <div>
          {connectors.map((connector) => (
            <button
              key={connector.id}
              onClick={() => connect(connector)}
              disabled={!connector.available()}
            >
              Connect with {connector.id}
            </button>
          ))}
        </div>
      );
    }

Observe the `disconnect` function that terminates the connection when
invoked. Post connection, access to the connected account is provided
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

    const { data, signTypedData } = useSignTypedData(typedMessage)

    return (
      <>
        <p>
          <button onClick={signTypedData}>Sign</button>
        </p>
        {data && <p>Signed: {JSON.stringify(data)}</p>}
      </>
    )

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

    const { data, isError, isLoading, status } = useStarkName({ address });
    // You can track the status of the request with the status variable ('idle' | 'error' | 'loading' | 'success')

    if (isLoading) return <p>Loading...</p>
    return <p>Account: {isError ? address : data}</p>

You also have additional information you can get from this hook →
**error**, **isIdle**, **isFetching**, **isSuccess**, **isFetched**,
**isFetchedAfterMount**, **isRefetching**, **refetch** which can give
you more precise information on what is happening.

## Fetching address from StarkName

You could also want to retrieve an address corresponding to a StarkName.
For this purpose, you can use the `useAddressFromStarkName` hook.

    const { data, isLoading, isError } = useAddressFromStarkName({ name: 'vitalik.stark' })

    if (isLoading) return <p>Loading...</p>
    if (isError) return <p>Something went wrong</p>
    return <p>Address: {data}</p>

If the provided name does not have an associated address, it will return
**"0x0"**

## Navigating the Network

In addition to wallet and account management, Starknet React equips
developers with hooks for network interactions. For instance, useBlock
enables the retrieval of the latest block:

    const { data, isError, isFetching } = useBlock({
        refetchInterval: 10_000,
        blockIdentifier: "latest",
    });

    if (isError) {
      return (
        <p>Something went wrong</p>
      )
    }

    return (
        <p>Current block: {isFetching ? "Loading..." : data?.block_number}<p>
    )

In the aforementioned code, refetchInterval controls the frequency of
data refetching. Behind the scenes, Starknet React harnesses
[react-query](https://github.com/TanStack/query/) for managing state and
queries. In addition to useBlock, Starknet React offers other hooks like
useContractRead and useWaitForTransaction, which can be configured to
update at regular intervals.

The useStarknet hook provides direct access to the ProviderInterface:

    const { library } = useStarknet();

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

    const { data: balance, isLoading, isError, isSuccess } = useContractRead({
        abi: abi_erc20,
        address: CONTRACT_ADDRESS,
        functionName: "allowance",
        args: [owner, spender],
        // watch: true <- refresh at every block
    });

For ERC20 operations, Starknet React offers a convenient useBalance
hook. This hook exempts you from passing an ABI and returns a suitably
formatted balance value.

      const { data, isLoading } = useBalance({
        address,
        token: CONTRACT_ADDRESS, // <- defaults to the ETH token
        // watch: true <- refresh at every block
      });

      return (
        <p>Balance: {data?.formatted} {data?.symbol}</p>
      )

### Write Functions

The useContractWrite hook, designed for write operations, deviates
slightly from wagmi. The unique architecture of Starknet facilitates
multicall transactions natively at the account level. This feature
enhances the user experience when executing multiple transactions,
eliminating the need to approve each transaction individually. Starknet
React capitalizes on this functionality through the useContractWrite
hook. Below is a demonstration of its usage:

    const calls = useMemo(() => {
        // compile the calldata to send
        const calldata = stark.compileCalldata({
          argName: argValue,
        });

        // return a single object for single transaction,
        // or an array of objects for multicall**
        return {
          contractAddress: CONTRACT_ADDRESS,
          entrypoint: functionName,
          calldata,
        };
    }, [argValue]);


    // Returns a function to trigger the transaction
    // and state of tx after being sent
    const { write, isLoading, data } = useContractWrite({
        calls,
    });

    function execute() {
      // trigger the transaction
      write();
    }

    return (
      <button type="button" onClick={execute}>
        Make a transaction
      </button>
    )

The code snippet begins by compiling the calldata using the
compileCalldata utility provided by Starknet.js. This calldata, along
with the contract address and entry point, are passed to the
useContractWrite hook. The hook returns a write function that is
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

The useTransaction hook allows for the tracking of transaction states
given a transaction hash. This hook maintains a cache of all
transactions, thereby minimizing redundant network requests.

    const { data, isLoading, error } = useTransaction({ hash: txHash });

    return (
      <pre>
        {JSON.stringify(data?.calldata)}
      </pre>
    )

The full array of available hooks can be discovered in the Starknet
React documentation, accessible here:
<https://apibara.github.io/starknet-react/>.

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

## Further Reading

- [Starknet.js](https://starknet.js.org)

- [Starknet React Docs](https://www.apibara.com/starknet-react-docs)

- [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook)

- [Mastering Bitcoin](https://github.com/bitcoinbook/bitcoinbook)

The Book is a community-driven effort created for the community.

- If you’ve learned something, or not, please take a moment to provide
  feedback through [this 3-question
  survey](https://a.sprig.com/WTRtdlh2VUlja09lfnNpZDo4MTQyYTlmMy03NzdkLTQ0NDEtOTBiZC01ZjAyNDU0ZDgxMzU=).

- If you discover any errors or have additional suggestions, don’t
  hesitate to open an [issue on our GitHub
  repository](https://github.com/starknet-edu/starknetbook/issues).
