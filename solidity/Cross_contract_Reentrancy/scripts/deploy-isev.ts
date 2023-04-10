import { readFileSync, writeFileSync } from "fs";
import { ethers } from "hardhat";
import { join } from "path";

import {
  InsecureEtherVault,
  InsecureEtherVault__factory,
} from "../typechain-types";

async function main() {
  const isevFactory: InsecureEtherVault__factory =
    await ethers.getContractFactory("InsecureEtherVault");
  const isev = await isevFactory.deploy();
  console.log(isev.address);
  //* Make etherBank addressBook.json
  const addressBookData = readFileSync(join(__dirname, "addressBook.json"));
  const addressBook = JSON.parse(addressBookData.toString());
  addressBook.InsecureEtherVault = isev.address;
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
