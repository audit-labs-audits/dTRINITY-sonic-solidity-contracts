import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { getConfig } from "../config/config";
import { isLocalNetwork } from "../typescript/hardhat/deploy";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const config = await getConfig(hre);

  if (!isLocalNetwork(hre.network.name)) {
    console.log(
      `🪙 ${__filename.split("/").slice(-2).join("/")}: Skipped - not a local network`
    );
    return false;
  }

  if (!config.MOCK_ONLY?.tokens) {
    throw new Error("No tokens configured for deployment");
  }

  // Deploy each configured token
  for (const [symbol, tokenConfig] of Object.entries(config.MOCK_ONLY.tokens)) {
    const deployed = await hre.deployments.deploy(`${symbol}`, {
      contract: "TestERC20",
      from: deployer,
      args: [tokenConfig.name, symbol, tokenConfig.decimals],
      autoMine: true,
      log: false,
    });
    // An initial supply is minted to the deployer during contract deployment

    console.log(
      `Deployed ${symbol} (${tokenConfig.name}) at ${deployed.address}`
    );
  }

  console.log(`🪙  ${__filename.split("/").slice(-2).join("/")}: ✅`);
  return true;
};

func.tags = ["local-setup", "tokens"];
func.id = "local_token_setup";

export default func;
