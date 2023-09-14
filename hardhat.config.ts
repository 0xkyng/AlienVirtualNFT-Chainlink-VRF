import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";


const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: process.env.GOERLI_RPC,
      // @ts-ignore
      accounts: [process.env.PRIVATE_kEY],
    },
  },
};

export default config;
