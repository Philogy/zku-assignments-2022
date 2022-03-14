import hre from 'hardhat'
const { ethers } = hre
import { expect } from 'chai'
import type { MyNFT } from '../typechain'

describe('MyNFT', () => {
  let deployer, user1, user2, attacker
  let token: MyNFT

  const TOKEN_URI_HEAD = /data:application\/json;base64,/

  before(async () => {
    ;[deployer, user1, user2, attacker] = await ethers.getSigners()
    const MyNFT = await ethers.getContractFactory('MyNFT')
    token = await MyNFT.deploy()
  })
  it('creates correctly formatted metadata URI', async () => {
    const tokenURI = await token.tokenURI(21)
    expect(tokenURI.match(TOKEN_URI_HEAD)).to.not.equal(null)
    const [, dataJsonBase64] = tokenURI.split(TOKEN_URI_HEAD)
    const tokenMetadata = JSON.parse(atob(dataJsonBase64))
    expect(Object.keys(tokenMetadata).length).to.equal(2)
  })
  it('allows deployer to mint NFTs', async () => {
    await token.mintTo(user1.address, 20)
  })
})
