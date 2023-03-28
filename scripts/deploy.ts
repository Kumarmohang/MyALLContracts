import { ethers } from "hardhat";

async function main() {
  const PBtoken = await ethers.getContractFactory("PBToken");
  const pbtoken = await PBtoken.deploy();
  await pbtoken.deployed();

  console.log(`PBToken TOken Address is ${pbtoken.address}`);
  const ERC20Address = pbtoken.address;

  const Staking = await ethers.getContractFactory("Staking");
  const staking = await Staking.deploy(ERC20Address);
  await staking.deployed();
  console.log(`Staking addres is ${staking.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
