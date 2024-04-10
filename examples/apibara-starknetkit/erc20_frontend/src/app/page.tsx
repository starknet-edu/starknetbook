"use client";
import Head from "next/head";
import { useExplorer, useAccount } from "@starknet-react/core";
import { Button } from "@/components/ui/Button";
import ConnectModal from "@/components/connect-modal";

function Home() {
  const explorer = useExplorer();

  return (
    <>
      <Head>
        <title>Homepage</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="text-center">
        <p className="text-4xl mb-4 mt-5">
          A basic web3 example with StarknetJS
        </p>
        <p> Deployed Contract URL: </p>
        <a
          href={explorer.contract(
            "0x04e965f74cf456a71ccc0b1b7aed651c1b738d233dfb447ca7e6b2cf5bb5c54c",
          )}
          target="_blank"
          rel="noreferrer"
        >
          <Button className="mb-10">
            {" "}
            View your Contract on {explorer.name}{" "}
          </Button>
        </a>
        <div>
          <ConnectModal />
        </div>
      </div>
    </>
  );
}

export default Home;
