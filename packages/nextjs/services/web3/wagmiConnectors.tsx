import { connectorsForWallets } from "@rainbow-me/rainbowkit";
import {
  coinbaseWallet,
  ledgerWallet,
  metaMaskWallet,
  rainbowWallet,
  safeWallet,
  walletConnectWallet,
} from "@rainbow-me/rainbowkit/wallets";
import { rainbowkitBurnerWallet } from "burner-connector";
import * as chains from "viem/chains";
import scaffoldConfig from "~~/scaffold.config";

const { onlyLocalBurnerWallet, targetNetworks } = scaffoldConfig;

const wallets = [
  walletConnectWallet,
  metaMaskWallet,
  coinbaseWallet,
  rainbowWallet,
  ledgerWallet,
  safeWallet,
  ...(!targetNetworks.some(network => network.id !== (chains.hardhat as chains.Chain).id) || !onlyLocalBurnerWallet
    ? [rainbowkitBurnerWallet]
    : []),
];

/**
 * wagmi connectors for the wagmi context
 */
export const wagmiConnectors = connectorsForWallets(
  [
    {
      groupName: "WalletConnect Wallets",
      wallets: [walletConnectWallet],
    },
    {
      groupName: "Other Wallets",
      wallets: wallets.filter(wallet => wallet !== walletConnectWallet),
    },
  ],

  {
    appName: "Decentralized Staking App",
    projectId: scaffoldConfig.walletConnectProjectId,
    appDescription: "A decentralized staking application built with Scaffold-ETH 2",
    appUrl: "https://staking-app.vercel.app",
    appIcon: "https://staking-app.vercel.app/icon.png",
  },
);
