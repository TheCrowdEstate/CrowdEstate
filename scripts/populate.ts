import { ethers } from 'hardhat'
import artifact from '../artifacts/contracts/CrowdEstate.sol/CrowdEstate.json'
import * as dotenv from 'dotenv'

const JsonRpcProvider = 'https://sepolia.infura.io/v3/a3afa70929da403a883b221f3f31725a'
const contractAddress = '0xB56a8a938F7296996711B01aCCdAD87abB1193Fa'
dotenv.config()

const properties = [
  { name: '19 Eden Grove', location: "19 Eden Grove, Rathfarnham, Dublin 16", images: [], shares: ethers.utils.parseEther('2') },
]

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(JsonRpcProvider)

  // Create a wallet using your private key
  const privateKey = process.env.PRIVATE_KEY || ''
  const wallet = new ethers.Wallet(privateKey, provider)

  // Contract instance setup
  const contract = new ethers.Contract(
    contractAddress,
    artifact.abi,
    wallet
  )

  for (const property of properties) {
    const tx = await contract.addProperty(property.name, property.location, property.images, property.shares)
    await tx.wait()

    console.log(
      `Added property ${property.name} with ${property.shares} shares`
    )
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
