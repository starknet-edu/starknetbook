import "@shardlabs/starknet-hardhat-plugin";

const config = {
  starknet: {
    network: "integrated-devnet",
  },
  networks: {
    integratedDevnet: {
      url: "http://127.0.0.1:5050",
      dockerizedVersion: "latest",
      args: ["--lite-mode", "--gas-price", "2000000000", "--seed", "1"],
      stdout: "STDOUT",
      stderr: "/dev/null",
    },
  },
};

export default config;
