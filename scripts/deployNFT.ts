import { ethers } from "hardhat";


async function main() {
  const IPFS = "https://bafkreihmlilck3ha4htkz6rebasnghehwsq2yawkq6r4nb6uo5gsrzgrky.ipfs.dweb.link/?filename=Financiador.json";
  const nome = "IDentity Funder";
  const symbol = "IDF";

  const NFT = await ethers.getContractFactory("IDfunder");
  const nft = await NFT.deploy(IPFS, 0, nome, symbol);

  await nft.deployed();

  //deploy do builder
  const NFTbuilder = await ethers.getContractFactory("IDbuilder");
  const nftbuilder = await NFTbuilder.deploy("https://bafybeieifvwsa7qcphtagbqg4wwaqcdhhdcw2umi5qnbuvajqbsduj6ggi.ipfs.nftstorage.link/Aluno.json", "IDentity builder", "IDBUILDER");

  await nftbuilder.deployed();


  //deploy do builder
  const NFTsubmit = await ethers.getContractFactory("IDsubmit");
  const nftsubmit = await NFTsubmit.deploy("https://bafybeieifvwsa7qcphtagbqg4wwaqcdhhdcw2umi5qnbuvajqbsduj6ggi.ipfs.nftstorage.link/Idealizador.json", 0, "IDentity Submit", "IDSUBMIT");

  await nftsubmit.deployed();

   //deploy do ProRec
   const NFTprRec = await ethers.getContractFactory("ProRec");
   const nftprrec = await NFTprRec.deploy("https://bafybeieifvwsa7qcphtagbqg4wwaqcdhhdcw2umi5qnbuvajqbsduj6ggi.ipfs.nftstorage.link/OceanDAO.json", 0,0, "Hype-tech", "HYPETECH","0xAaa7cCF1627aFDeddcDc2093f078C3F173C46cA4",nftsubmit.address,nft.address,
   nftbuilder.address);
 
   await nftprrec.deployed();

  console.log("deployed IDBuilder to:", nftbuilder.address,"deployed IDFunder to:",nft.address, "deployed IDsubmit to:", nftsubmit.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
