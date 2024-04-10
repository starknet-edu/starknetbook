"use client";
import { Button } from "./ui/Button";
import ReadBalance from "@/components/readBalance";
import Transfer from "@/components/transfer";
import { useStarknetkitConnectModal, connect, disconnect } from "starknetkit";
import {
  useConnect,
  useDisconnect,
  useAccount,
  useNetwork,
} from "@starknet-react/core";
import { Card } from "@radix-ui/themes";
import { InjectedConnector } from "starknetkit/injected";

function Connect() {
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { account, address } = useAccount();
  const { chain } = useNetwork();
  const addressShort = address
    ? `${address.slice(0, 6)}...${address.slice(-4)}`
    : null;

  const connectWallet = async () => {
    const connectors = [
      new InjectedConnector({ options: { id: "argentX", name: "Argent X" } }),
      new InjectedConnector({ options: { id: "braavos", name: "Braavos" } }),
    ];

    const { starknetkitConnectModal } = useStarknetkitConnectModal({
      connectors: connectors,
      dappName: "ERC20 UI",
      modalTheme: "system",
    });

    const { connector } = await starknetkitConnectModal();
    await connect({ connector });
  };

  return (
    <div>
      <Card className="max-w-[380px] mx-auto">
        <div className="max-w-[400px] mx-auto p-4 bg-white shadow-md rounded-lg">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gray-200 rounded-full flex justify-center items-center">
              <span>👛</span>
            </div>
            <div>
              <p className="text-lg font-semibold">Your Wallet</p>
              <p className="text-gray-600">
                {address
                  ? `Connected as ${addressShort} on ${chain.name}`
                  : "Connect wallet to get started"}
              </p>
            </div>
          </div>
        </div>
      </Card>
      <div className="relative h-screen">
        {!account ? (
          <div>
            <Button onClick={connectWallet}>Connect</Button>
          </div>
        ) : (
          <div>
            <Button onClick={() => disconnect()}>Disconnect</Button>
            <div className="mt-8">
              Token Balance: <ReadBalance />{" "}
            </div>
            <div className="mt-8">
              <Transfer />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Connect;
