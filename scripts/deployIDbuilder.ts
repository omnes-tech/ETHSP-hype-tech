import { ethers } from "hardhat";

async function main() {
  const IPFS = "https://ipfs.io/ipfs/bafkreig2xnzfhpgdqgz4tnsgzdx2y6svimng3a7h76mr2dnxs7ieihuwqy/";
  const nome = "IDentity Funder";
  const symbol = "IDF";

  const NFT = await ethers.getContractFactory("IDbuilder");
  const nft = await NFT.deploy(IPFS, nome, symbol);

  await nft.deployed();


  console.log("deployed IDBuilder to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});