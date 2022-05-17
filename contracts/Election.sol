// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Election {
    string public candidate;

    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    constructor() public{
        candidate = "Candidate 1";
        addCandidate("Candidate 2")
    }

    function addCandidate(string _name) private {
        candidatesCount ++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }
}