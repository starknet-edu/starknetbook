import os
import asyncio
from requests import get

from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.starknet.services.api.feeder_gateway.block_hash import calculate_block_hash, calculate_event_hash
from starkware.starknet.definitions.general_config import StarknetGeneralConfig

async def main():
    data = get("https://alpha-mainnet.starknet.io/feeder_gateway/get_block?blockNumber=2360").json()

    txHashes = []
    txSignatures = []
    eventHashes = []

    for tx in data["transactions"]:
        txHashes.append(int(tx["transaction_hash"], 16))
        if "signature" in tx and len(tx["signature"]):
            txSignatures.append([int(tx["signature"][0], 16), int(tx["signature"][1], 16)])
        else:
            txSignatures.append([])

    for tx_receipt in data["transaction_receipts"]:
        for e in tx_receipt["events"]:
            keys = [int(k, 16) for k in e["keys"]]
            tx_data = [int(d, 16) for d in e["data"]]

            evHash = calculate_event_hash(
                int(e["from_address"], 16),
                keys,
                tx_data,
                pedersen_hash
            )
            eventHashes.append(evHash)

    hash = await calculate_block_hash(
        StarknetGeneralConfig,
        int(data["parent_block_hash"], 16),
        data["block_number"],
        bytes.fromhex(data["state_root"]),
        int(data["sequencer_address"], 16),
        data["timestamp"],
        txHashes,
        txSignatures,
        eventHashes,
        pedersen_hash
    )
    print("Fetched Hash: ", data["block_hash"])
    print("Calculated Hash: 0x%x" % (hash))
    print("Match: " , int(data["block_hash"], 16) == hash)

asyncio.run(main())