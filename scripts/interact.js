const { ethers } = require("hardhat");

async function main() {
  // Set up the deployed contract addresses
  const contractAddress = "0xeAd3526770f975E0a5d8a1D326320DD3E5BF9099";  // MultiAgentContract address
  const oracleAddress = "0x69075e1E27A8164d3Be0F41eb575A8afeb3732c8";  // Oracle contract address

  // Attach to deployed contract
  const MultiAgentContract = await ethers.getContractFactory("MultiAgentContract");
  const multiAgent = await MultiAgentContract.attach(contractAddress);

  const Oracle = await ethers.getContractFactory("OracleContract");
  const oracle = await Oracle.attach(oracleAddress);

  const [deployer] = await ethers.getSigners();

  console.log("Updating global state...");
  await oracle.updateGlobalState(75); // Example state 
  console.log("Global state updated.");

  console.log(`Setting reward for ${deployer.address}...`);
  await multiAgent.updateReward(deployer.address, ethers.utils.parseEther("10"));
  console.log(`Reward for ${deployer.address} updated.`);

  console.log("Setting agent behavior to true...");
  await multiAgent.setAgentBehavior(deployer.address, true);
  console.log("Agent behavior set to true.");

  console.log("Paying reward to the agent...");
  try {
    const tx = await multiAgent.payReward(deployer.address, {
      gasLimit: 1000000, 
    });
    console.log("Reward paid to the agent.");
    await tx.wait();  
    console.log("Transaction confirmed.");
  } catch (error) {
    console.error("Error while paying reward:", error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
