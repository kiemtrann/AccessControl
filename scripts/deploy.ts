import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const EVAToken = await ethers.getContractFactory("EVAToken");

  const gasPrice = await EVAToken.signer.getGasPrice();
  console.log(`Current gas price: ${gasPrice}`);

  const estimatedGas = await EVAToken.signer.estimateGas(EVAToken.getDeployTransaction());
  console.log(`Estimated gas: ${estimatedGas}`);

  const deploymentPrice = gasPrice.mul(estimatedGas);
  const deployerBalance = await EVAToken.signer.getBalance();
  console.log(`Deployer balance:  ${ethers.utils.formatEther(deployerBalance)}`);
  console.log(`Deployment price:  ${ethers.utils.formatEther(deploymentPrice)}`);

  if (deployerBalance.lt(deploymentPrice)) {
    throw new Error(
      `Insufficient funds. Top up your account balance by ${ethers.utils.formatEther(
        deploymentPrice.sub(deployerBalance),
      )}`,
    );
  }

  const token = await EVAToken.deploy();
  await token.deployed();

  console.log("Token address:", token.address);

  const isBurner = await token.connect(deployer).isBurner(deployer.address);

  if (isBurner) {
    console.log("The deployer is burner");
  } else console.log("The deployer is not burner");

  await token.connect(deployer).setupBurner(deployer.address, false);

  const isBurnerAgain = await token.connect(deployer).isBurner(deployer.address);

  if (isBurnerAgain) {
    console.log("The deployer is burner");
  } else console.log("The deployer is not burner");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
