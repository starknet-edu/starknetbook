# Starknet Aliases(add to local profile e.g. .zshrc, .bashrc, .profile)
# alias cairodev="python3.9 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-goerli; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"
# alias cairoprod="python3.9 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-mainnet; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"
# alias starktx="starknet get_transaction --hash "
import os

CAIRO_PATH = os.getenv("CAIRO_PATH")

GOERLI_NODE = os.getenv("GOERLI_URL")
GOERLI_CORE_CONTRACTS = 0xDE29D060D45901FB19ED6C6E959EB22D8626708E
GOERLI_VERIFIER = 0xAB43BA48C9EDF4C2C4BB01237348D1D7B28EF168
GOERLI_MEMORY_REGISTRY = 0x743789FF2FF82BFB907009C9911A7DA636D34FA7

FEEDER_URL = "https://alpha4.starknet.io/feeder_gateway"

ESTIMATE_FEE_ENDPOINT = FEEDER_URL + "/estimate_fee"
TRANSACTION_TRACE_ENDPOINT = FEEDER_URL + "/get_transaction_trace?transactionHash="
STATE_UPDATE_ENDPOINT = FEEDER_URL + "/get_state_update?blockNumber="
CALL_CONTRACT_ENDPOINT = FEEDER_URL + "/call_contract"
