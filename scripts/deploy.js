const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Oracle = await ethers.getContractFactory("OracleContract");
  const oracle = await Oracle.deploy();
  await oracle.deployed();

  console.log("Oracle deployed to:", oracle.address);

  const MultiAgentContract = await ethers.getContractFactory("MultiAgentContract");
  const multiAgent = await MultiAgentContract.deploy(oracle.address);

  await multiAgent.deployed();

  console.log("MultiAgentContract deployed to:", multiAgent.address);

  const tx = await deployer.sendTransaction({
    to: multiAgent.address,
    value: ethers.utils.parseEther("1.0")
  });

  await tx.wait();
  console.log("1 ETH sent to MultiAgentContract.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});

