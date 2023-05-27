import { ethers } from 'hardhat'

const CONTRACT_FACTORY = 'CrowdEstate'

async function main() {
  const Contract = await ethers.getContractFactory(CONTRACT_FACTORY)
  const contract = await Contract.deploy()

  await contract.deployed()

  console.log(`Contract deployed to ${contract.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
