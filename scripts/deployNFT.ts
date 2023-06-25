import { ethers } from "hardhat";


async function main() {
  const IPFS = "https://ipfs.io/ipfs/bafkreig2xnzfhpgdqgz4tnsgzdx2y6svimng3a7h76mr2dnxs7ieihuwqy";
  const nome = "IDentity Funder";
  const symbol = "IDF";

  const NFT = await ethers.getContractFactory("IDfunder");
  const nft = await NFT.deploy(IPFS, 0, nome, symbol);

  await nft.deployed();

  //deploy do builder
  const NFTbuilder = await ethers.getContractFactory("IDbuilder");
  const nftbuilder = await NFTbuilder.deploy("https://ipfs.io/ipfs/", nome, symbol);

  await nftbuilder.deployed();


  //deploy do builder
  const NFTsubmit = await ethers.getContractFactory("IDsubmit");
  const nftsubmit = await NFTsubmit.deploy("https://ipfs.io/ipfs/", 0, nome, symbol);

  await nftsubmit.deployed();

  console.log("deployed IDBuilder to:", nftbuilder.address,"deployed IDFunder to:",nft.address, "deployed IDsubmit to:", nftsubmit.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
