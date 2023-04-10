import { ethers } from "hardhat";
import { SecureEtherVault__factory } from "../typechain-types";
import addressBook from "./addressBook.json";
import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
async function main() {
  //* Read File
  const addressBookData = readFileSync(join(__dirname, "addressBook.json"));
  const addressBook = JSON.parse(addressBookData.toString());

  const attackFactory = await ethers.getContractFactory("Attack");

  const attack = await attackFactory.deploy(addressBook["InsecureEtherVault"]);

  addressBook.attackPeer = attack.address;
  writeFileSync(
    join(__dirname, "addressBook.json"),
    JSON.stringify(addressBook, null, 2)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
