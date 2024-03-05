interface TokenImages {
  [key: string]: string;
}

interface TokenTicker {
  [key: string]: string;
}

export const tokenImages: TokenImages = {
  "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7":
    "./tokens/eth.svg",
  "0x068f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8":
    "./tokens/usdt.png",
  "0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8":
    "./tokens/usdc.png",
  "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d":
    "./tokens/strk.png",
};

export const tokenTicker: TokenTicker = {
  "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7": "ETH",
  "0x068f5c6a61780768455de69077e07e89787839bf8166decfbf92b645209c0fb8": "USDT",
  "0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8": "USDC",
  "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d": "STRK",
};
