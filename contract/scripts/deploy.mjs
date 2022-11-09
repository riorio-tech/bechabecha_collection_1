// deploy.js
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-ethers";
import hre from 'hardhat'
// import { getEnvVariable } from './helpers'


// const main = async () => {

//   const nftContractFactory = await hre.ethers.getContractFactory("Becha");

//   const nftContract = await nftContractFactory.deploy();

//   await nftContract.deployed();
//   console.log("Contract deployed to:", nftContract.address);

//   let txn = await nftContract.makeAnEpicNFT();

//   await txn.wait();
//   console.log("Minted NFT #1");

//   txn = await nftContract.makeAnEpicNFT();

//   await txn.wait();
//   console.log("Minted NFT #2");
// };

// const runMain = async () => {
//   try {
//     await main();
//     process.exit(0);
//   } catch (error) {
//     console.log(error);
//     process.exit(1);
//   }
//   runMain();
// };


async function main() {
  const deploycontract = await hre.ethers.getContractFactory("Becha");
  console.log('Deploying ERC721A token...');
  const token = await deploycontract.deploy();
  await token.deployed();
  console.log('Contract deployed to:', token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

