import { ethers } from "hardhat";
import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { SecureEtherVault__factory } from "../typechain-types";

async function main() {
  const sevFactory: SecureEtherVault__factory = await ethers.getContractFactory(
    "SecureEtherVault"
  );
  const sev = await sevFactory.deploy();
  console.log(sev.address);
  //* Make etherBank addressBook.json
  const addressBookData = readFileSync(join(__dirname, "addressBook.json"));
  const addressBook = JSON.parse(addressBookData.toString());
  addressBook.secureEtherVault = sev.address;
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
