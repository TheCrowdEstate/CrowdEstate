import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("CrowdEstate", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const Contract = await ethers.getContractFactory("CrowdEstate");
    const contract = await Contract.deploy();

    return { contract };
  }

  describe("Deployment", function () {
    it("Add property and buy share", async function () {
      const { contract } = await loadFixture(deploy);

      await contract.addProperty("name", "location", [], ethers.utils.parseEther('2'))

      await contract.buyShares(1, { value: ethers.utils.parseEther('0.05') })

      const shares = await contract.soldPropertyShares(1)

      expect(shares).to.equal('2.50%');
    });
  });

});
