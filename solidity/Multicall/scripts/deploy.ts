import { getContractAddress } from "ethers/lib/utils"
import { ethers } from "hardhat"

async function main() {
  const Animals = await ethers.getContractFactory("Animals")
  const animals = await Animals.deploy()

  const Multicall = await ethers.getContractFactory("Multicall")
  const multicall = await Multicall.deploy()

  const DelegateMulticall = await ethers.getContractFactory("DelegateMulticall")
  const delegateMulticall = await DelegateMulticall.deploy()

  const CalculatorAndMinting = await ethers.getContractFactory("CalculatorAndMinting")
  const calculatorAndMinting = await CalculatorAndMinting.deploy()

  const Helper = await ethers.getContractFactory("Helper")
  const helper = await Helper.deploy()
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
