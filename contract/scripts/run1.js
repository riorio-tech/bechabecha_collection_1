// run.js


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
