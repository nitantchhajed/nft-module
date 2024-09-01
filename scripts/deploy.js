const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const AddressManager = await hre.ethers.getContractFactory("AddressManager");
  const addressManager = await AddressManager.deploy(deployer.address);

  await addressManager.waitForDeployment();
  const addressManagerAddress = await addressManager.getAddress();
  console.log("AddressManager deployed to:", await addressManager.getAddress());

// Deploy CollectionFactory
const CollectionFactory = await hre.ethers.getContractFactory("CollectionFactory");
const collectionFactory = await CollectionFactory.deploy(addressManagerAddress);
console.log("Collection Factory deployed to:", await collectionFactory.getAddress());
const collectionFactoryAddress = await collectionFactory.getAddress()

// Deploy CollectionToken

const CollectionToken = await hre.ethers.getContractFactory("CollectionToken");
const collectionToken = await CollectionToken.deploy(addressManagerAddress);

const collectionTokenAddress = await collectionToken.getAddress();
console.log("CollectionToken deployed to:", collectionTokenAddress);

// Deploy NFTModule
const NFTModule = await hre.ethers.getContractFactory("NFTModule");
const nftModule = await hre.upgrades.deployProxy(NFTModule, [addressManagerAddress], { initializer: 'initialize' });

await nftModule.waitForDeployment();

const nftModuleAddress = await nftModule.getAddress();
console.log("NFTModule deployed to:", nftModuleAddress);

// Wait for block confirmations
console.log("Waiting for block confirmations...");
await addressManager.deploymentTransaction().wait(6);
await nftModule.deploymentTransaction().wait(6);

// Verify AddressManager
console.log("Verifying AddressManager...");
await hre.run("verify:verify", {
  address: addressManagerAddress,
  constructorArguments: [deployer.address],
});

// Verifying Contract Factory 
console.log("Verifying Contract Factory ...");
await hre.run("verify:verify", {
  address: collectionFactoryAddress,
  constructorArguments: [addressManagerAddress],
});

// Verifying Contract Factory 
console.log("Verifying Contract Factory ...");
await hre.run("verify:verify", {
  address: collectionTokenAddress,
  constructorArguments: [addressManagerAddress],
});

// Verify NFTModule
console.log("Verifying NFTModule...");
await hre.run("verify:verify", {
  address: nftModuleAddress,
  constructorArguments: [],
});
  console.log("Contract verified");



}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });