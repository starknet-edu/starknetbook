# Web Wallet: Web2 Simplicity with self-custody

Web Wallet, developed by Argent ([documentation](https://docs.argent.xyz/starknet/web-wallet-sdk)), is a tool that uses the full power and capacity of Account Abstraction. It's a self-custodial, browser-based wallet that simplifies blockchain interactions. Unlike traditional wallets that often involve seed phrases and wallet downloads, Web Wallet utilizes a simple email and password setup. This approach blends the ease of web2 interfaces with the advanced capabilities of web3, making Starknet more accessible and user-friendly.

Key Features:

- **Simplified Seed Phrases**: Web Wallet eliminates the need for seed phrases. Access your wallet easily using your email and password. Accounts are easily recoverable if lost.
- **No Downloads Needed**: Access Starknet directly from your browser using your email. No need to download an application or extension to create a wallet.
- **Multi-Device Support**: Web Wallet can be used across various devices seamlessly, like any standard web2 application.

## dApps Integration Guide

To integrate Web Wallet in a dApp, start by installing `starknetkit`:

```bash
yarn add starknetkit
```

Import necessary methods such as **`connect`** and **`disconnect`**:

```js
import { connect, disconnect } from "starknetkit";
```

Create a wallet connection using the `connect` method:

```js
const connection = await connect({ webWalletUrl: "https://web.argent.xyz" });
```

Below is an example function that establishes a connection, then sets the connection, provider, and address states:

```js
const connectWallet = async () => {
  const connection = await connect({ webWalletUrl: "https://web.argent.xyz" });

  if (connection && connection.isConnected) {
    setConnection(connection);
    setProvider(connection.account);
    setAddress(connection.selectedAddress);
  }
};
```

> **NOTE:** Web Wallet is currently available only on the mainnet. For testnet access, contact the Argent team.

## Transaction Signing Process

Signing transactions with Web Wallet follows a process akin to the Argent X browser extension:

```js
const tx = await connection.account.execute({
  //let's assume this is an erc20 contract
  contractAddress: "0x...",
  selector: "transfer",
  calldata: [
    "0x...",
    // ...
  ],
});
```

Users will see a transaction confirmation request. Upon approval, the dApp receives a transaction hash:

<img src="./img/ch04-05-05-web-wallet-tx-page.jpg" width="100%" alt="webwalllet signing page">

If the user's wallet is already funded it will ask the user to confirm the transaction. The dapp will get feedback if the user has confirmed or rejected the transaction request. If confirmed, the dapp will get a transaction hash.

### Addressing Unfunded Wallets

When users lack funds, they are guided through simple "Add Funds" steps. This includes access to on-ramps for easy funding. The process is streamlined with minimal KYC requirements, ensuring a user-friendly experience. Once complete, the wallet is funded and prepared for deployment.

### Preparing for First Transaction

Once the wallet is funded, it's set for the initial transaction. Wallet deployment occurs simultaneously with this first transaction, typically unnoticed by the user. It's important to note that a wallet may be connected but not yet deployed.
