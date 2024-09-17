// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Polling {
    address public admin;

    struct Participant {
        bool hasVoted;
    }

    struct Poll {
        string description;
        uint id;
        uint voteCount;
        address creator;
        mapping(address => Participant) participants;
    }

    mapping(uint => Poll) public polls;

    uint public pollCount = 0;

    event PollCreated(address indexed creator);
    event VoteRecorded(address indexed voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can create a poll");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createPoll(string memory _description) public onlyAdmin {
        Poll storage newPoll = polls[pollCount];

        newPoll.description = _description;
        newPoll.voteCount = 0;
        newPoll.creator = msg.sender;
        newPoll.id = pollCount;

        pollCount++;

        emit PollCreated(msg.sender);
    }

    function getTotalPolls() public view returns (uint) {
        return pollCount;
    }

    function getPollDetails(uint _id) public view returns (string memory description, uint id, uint voteCount, address creator) {
        Poll storage p = polls[_id];
        return (p.description, p.id, p.voteCount, p.creator);
    }

    function castVote(uint _id) public {
        require(!polls[_id].participants[msg.sender].hasVoted, "You have already voted");
        require(polls[_id].creator != address(0), "Poll not found");

        polls[_id].voteCount += 1;
        polls[_id].participants[msg.sender].hasVoted = true;

        emit VoteRecorded(msg.sender);
    }

    function checkIfVoted(uint _pollId, address _participant) public view returns (bool) {
        Poll storage p = polls[_pollId];
        return p.participants[_participant].hasVoted;
    }
}
