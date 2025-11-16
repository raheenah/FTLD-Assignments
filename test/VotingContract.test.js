const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotingContract", function () {
  let Voting;
  let voting;
  let owner, voter1, voter2;

  beforeEach(async function () {
    [owner, voter1, voter2] = await ethers.getSigners();
    Voting = await ethers.getContractFactory("VotingContract");
    voting = await Voting.deploy(3600); // 1 hour voting duration
    await voting.deployed();
  });

  it("should register a candidate", async function () {
    const tx = await voting.registerCandidate("Alice");
    await tx.wait();
    const candidate = await voting.getCandidate(1);
    expect(candidate.name).to.equal("Alice");
    expect(candidate.score).to.equal(0);
  });

  it("should register a voter", async function () {
    await voting.connect(voter1).registerAVoter();
    const isRegistered = await voting.registeredVoters(voter1.address);
    expect(isRegistered).to.be.true;
  });

  it("should allow a registered voter to vote", async function () {
    await voting.registerCandidate("Alice");
    await voting.connect(voter1).registerAVoter();

    const voteTx = await voting.connect(voter1).voteForACandidate(1);
    await voteTx.wait();

    const candidate = await voting.getCandidate(1);
    expect(candidate.score).to.equal(1);

    const voterVote = await voting.votesByCandidate(voter1.address);
    expect(voterVote.candidateID).to.equal(1);
  });

  it("should prevent double voting", async function () {
    await voting.registerCandidate("Alice");
    await voting.connect(voter1).registerAVoter();
    await voting.connect(voter1).voteForACandidate(1);

    await expect(
      voting.connect(voter1).voteForACandidate(1)
    ).to.be.revertedWith("You have already cast your vote");
  });
});
