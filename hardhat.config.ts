import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";

// eslint-disable-next-line @typescript-eslint/no-var-requires
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.REACT_APP_RINKEBY_RPC_URL}`,
      accounts: [process.env.REACT_APP_PRIVATE_KEY || ""],
    },
  },
};

export default config;
