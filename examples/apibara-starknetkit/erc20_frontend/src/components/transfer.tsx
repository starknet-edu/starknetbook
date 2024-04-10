import { useState, useMemo } from "react";
import contractABI from "@/components/lib/abi";
import {
  useAccount,
  useContract,
  useContractWrite,
} from "@starknet-react/core";
import { Uint256, cairo } from "starknet";
import { Button } from "./ui/Button";

const ContractAddress =
  "0x04e965f74cf456a71ccc0b1b7aed651c1b738d233dfb447ca7e6b2cf5bb5c54c";
const DECIMALS = 18;

export default function Transfer() {
  const { address } = useAccount();
  const [recipient, setRecipient] = useState("");
  const [amount, setAmount] = useState("");

  const { contract } = useContract({
    abi: contractABI,
    address: ContractAddress,
  });

  const newAmount: Uint256 = cairo.uint256((amount as any) * 10 ** DECIMALS);

  const calls = useMemo(() => {
    if (!contract || !recipient || !address) return [];
    return contract.populateTransaction["transfer"]!(recipient, newAmount);
  }, [contract, address, recipient, newAmount]);

  const { writeAsync, data, isPending } = useContractWrite({
    calls,
  });

  return (
    <>
      <div className="flex flex-col gap-4 items-center">
        <div className="flex items-center space-x-3 mr-3">
          <label className="text-lg font-medium text-gray-700">Recipient</label>
          <input
            type="text"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
            className="mt-1 px-4 py-2 w-64 bg-white border border-green-500 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        </div>
        <div className="flex items-center space-x-3">
          <label className="text-lg font-medium text-gray-700">Amount</label>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="mt-1 px-3 py-2 w-64 bg-white border border-green-500 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
        </div>
        <Button
          className="mt-6 px-6 py-3 text-lg w-full sm:w-auto"
          onClick={() => writeAsync()}
        >
          Transfer
        </Button>
        <p>status: {isPending && <div>Submitting...</div>}</p>
        <p>hash: {data?.transaction_hash}</p>
      </div>
    </>
  );
}
