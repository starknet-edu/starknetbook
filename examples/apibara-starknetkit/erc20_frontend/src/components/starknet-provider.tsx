"use client";
import React from "react";
import { publicProvider, StarknetConfig } from "@starknet-react/core";
import { sepolia, mainnet } from "@starknet-react/chains";
import { voyager } from "@starknet-react/core";

export function StarknetProvider({ children }: { children: React.ReactNode }) {
  const chains = [mainnet, sepolia];
  const provider = publicProvider();

  return (
    <StarknetConfig chains={chains} provider={provider} explorer={voyager}>
      {children}
    </StarknetConfig>
  );
}
