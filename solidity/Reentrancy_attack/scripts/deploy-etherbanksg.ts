import { ethers } from "hardhat";
import { join } from "path";
import { writeFileSync, readFileSync } from "fs";
async function main() {
  //* deploy EtherBank contract
  const EtherBankSG = await ethers.getContractFactory("EtherBankSG");
  const etherBankSG = await EtherBankSG.deploy();

  await etherBankSG.deployed();

  console.log("EtherBank deployed to:", etherBankSG.address);

  const [deployer, signer1, signer2] = await ethers.getSigners();

  //* Deployer deposits 1 ether
  await etherBankSG.deposit({ value: ethers.utils.parseEther("1") });
  await etherBankSG
    .connect(signer1)
    .deposit({ value: ethers.utils.parseEther("1") });
  await etherBankSG
    .connect(signer2)
    .deposit({ value: ethers.utils.parseEther("1") });

  console.log(
    "Balance of EtherBank:",
    (await etherBankSG.getBalance()).toString()
  );

  //* Make etherBank addressBook.json

  const addressBookData = readFileSync(join(__dirname, "./addressBook.json"));
  const addressBook = JSON.parse(addressBookData.toString());
  addressBook.EtherBankSG = etherBankSG.address;

  writeFileSync(
    join(__dirname, "./addressBook.json"),
    JSON.stringify(addressBook, null, 2)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
