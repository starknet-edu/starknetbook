import { HardhatUserConfig } from "hardhat/types";
import "@shardlabs/starknet-hardhat-plugin";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
  starknet: {
    venv: "active",
    network: "devnet",
  },
  networks: {
    devnet: {
      url: "http://127.0.0.1:5050/",
    },
    testnet: {
      url: "https://alpha4.starknet.io/",
    },
  },
};

export default config;
