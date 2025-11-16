// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import '@openzeppelin/contracts/utils/Strings.sol';
using Strings for uint256;
using Strings for address;

// Vote for a candidate
// Register a candidate
// Get a candidate
// Get a candidate with the highest vote
// Register a voter
// Voter cannot vote more than once
// Set voting duration
// Availability of record

contract VotingContract {
    // Candidate object
    struct Candidate {
        uint256 id;
        string name;
        uint256 score;
        bool winner;
    }

    struct Vote {
        // address voter;
        uint256 candidateID;
        uint256 timeOfVote;
    }

    event CandidateRegistered(string name, uint256 id);
    event CandidateWon(string name, uint256 id);
    event userVoted(address voter, uint256 candidateID, string name);

    address public owner;
    uint256 private candidateCount = 1;
    uint256 public votingStart;
    uint256 public votingEnd;
    // uint256 public timeOfVote;

    // Store candidates
    // We can use a mapping or we can use an array id: candidate
    mapping(uint256 => Candidate) public candidates;
    Candidate[] public candidateArray;

    mapping(address => Vote) public votesByCandidate;
    // A mapping for registered voters. 0x0efo3: true -- voter is regitered
    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;

    constructor(uint256 _votingDuration) {
        owner = msg.sender;
        votingStart = block.timestamp;
        votingEnd = votingStart + _votingDuration;
    }

    // modifier verifying if voting is active
    modifier votingActive() {
        require(block.timestamp >= votingStart, 'Voting has not started');
        require(block.timestamp <= votingEnd, 'Voting has ended');
        _;
    }

    modifier checkIfVoterCanVote() {
        require(
            registeredVoters[msg.sender] = true,
            'You are not a registered voter'
        );
        require(hasVoted[msg.sender] == false, 'You have already cast your vote');
        _;
    }

    // Helper function to convert uint to string
    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return '0';
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * Register a candidate
     * @param _name Name of the candidate
     * return _name, id of the candidate
     */
    function registerCandidate(
        string memory _name
    ) public returns (string memory) {
        Candidate memory newCandidate = Candidate(
            candidateCount,
            _name,
            0,
            false
        );
        candidateArray.push(newCandidate);
        candidates[candidateCount] = newCandidate;
        // Broadcast a candidate has been registered
        emit CandidateRegistered(_name, candidateCount);
        candidateCount++; // increase the candidate count
        return
            string(
                abi.encodePacked(
                    'New candidate registered is ',
                    _name,
                    ' with id ',
                    uint2str(candidateCount - 1)
                )
            );
    }

    function getCandidate(uint256 _id) private view returns (Candidate memory) {
        return candidates[_id];
    }

    function getCandidateWithHighestVote()
        public
        view
        returns (Candidate memory)
    {
        uint256 initialMaxVote = candidateArray[0].score;
        uint256 winnerId = 0;
        for (uint256 i = 0; i < candidateArray.length; i++) {
            if (candidateArray[i].score > initialMaxVote) {
                winnerId = candidateArray[i].id;
            }
        }
        return candidates[winnerId];
    }

    function registerAVoter() public {
        registeredVoters[msg.sender] = true;
    }

    function voteForACandidate(
        uint256 id
    )
        public
        votingActive
        checkIfVoterCanVote()
        returns (string memory)
    {
        if (registeredVoters[msg.sender] != true)
            revert('Voter is not registered');
        // require(registeredVoters[msg.sender], "Voter is not registered");
        Candidate memory candidateToVote = candidates[id]; // Get the candidate
        candidateToVote.score += 1;
        candidates[id] = candidateToVote;

        //   uint256  timeOfVote = block.timestamp;
        votesByCandidate[msg.sender] = Vote({
            candidateID: id,
            timeOfVote: block.timestamp
        });
        hasVoted[msg.sender] = true;

        emit userVoted(msg.sender, id, candidateToVote.name);

        return
            string(
                abi.encodePacked(
                    msg.sender.toHexString(),
                    'cast their vote at',
                    block.timestamp.toString()
                )
            );
    }
}