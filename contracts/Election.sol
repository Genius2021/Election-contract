// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Election {

    struct Candidate{
        uint id;
        string firstname;
        string lastname;
        string party;
    }

    mapping(uint => Candidate) public candidates;
    mapping(uint => uint) public candidateToVotes;
    mapping(address => bool) public haveVoted;
    enum Election_State { ONGOING, FINISHED, CALCULATING_WINNER }
    Election_State public election_state;
    uint public candidateCount;
    event AddedCandidate(uint indexed _candidateCount, string indexed _firstname, string indexed _lastname, string _party);
    event DisqualifiedCandidate(uint indexed _id, string indexed _party);
    event ElectionStarted(uint256 indexed _timestamp);
    event ElectionEnded(uint256 indexed _timestamp);
    event Reset(uint256 indexed _timestamp);
    event votedEvent(address indexed _voter);
    uint[] public candidatesArray;
    address public electoralChairman;
    address[] public votersArray;

    constructor() public{
        candidateCount = 0;
        electoralChairman = msg.sender;
        election_state = Election_State.FINISHED;
    }

    modifier restricted() {
        require(
        msg.sender == electoralChairman,
        "This function call is restricted to the electoral chairman"
        );
        _;
    }


    function startElection() public restricted {
        require(election_state == Election_State.FINISHED, "The election is already ongoing");
        election_state = Election_State.ONGOING;
        emit ElectionStarted(block.timestamp);
    }

    function stopElection() public restricted {
        require(election_state == Election_State.ONGOING, "You have not started the election");
        election_state = Election_State.FINISHED;
        emit ElectionEnded(block.timestamp);
    }

    function addCandidate(string memory _firstname, string memory _lastname, string memory _party) private restricted {
        require(election_state == Election_State.FINISHED, "You cannot add a candidate in the middle of an election");
        candidates[candidateCount] = Candidate(candidateCount, _firstname, _lastname, _party);
        candidatesArray.push(candidateCount);
        emit AddedCandidate(candidateCount, _firstname, _lastname, _party);
        candidateCount += 1;
    }

    function disqualifyCandidate(uint _id, string memory _party) public restricted {
        // Disqualification happens only after the end or before the beginning of an election
        require(election_state == Election_State.FINISHED);
        delete candidates[_id];
        candidateCount -= 1;
        emit DisqualifiedCandidate(_id, _party);
    }

    function vote(uint _id) public {
        require(election_state == Election_State.ONGOING, "The election has not started");
        require(haveVoted[msg.sender] == false, "You cannot vote multiple times");
        candidateToVotes[_id] += 1;
        haveVoted[msg.sender] = true;
        votersArray.push(msg.sender);
        emit votedEvent(msg.sender);
    }

    function calculateWinner() public restricted returns(uint){
        require(election_state == Election_State.FINISHED, "The election is still ongoing");
        election_state = Election_State.CALCULATING_WINNER;
        uint winner = 0;
        for(uint candidatesArrayIndex = 0; candidatesArrayIndex < candidatesArray.length; candidatesArrayIndex++){
            uint id = candidatesArray[candidatesArrayIndex];
            uint votes = candidateToVotes[id];
            if(votes > winner){
                winner = votes;
            }
        }

        election_state == Election_State.FINISHED;
        return winner;

    }

    function reset() public restricted {
        require(election_state == Election_State.FINISHED, "You cannot reset an ongoing election");
        candidateCount = 0;
        for(uint votersArrayIndex = 0; votersArrayIndex < votersArray.length; votersArrayIndex++){
            address voter = votersArray[votersArrayIndex];
            haveVoted[voter] = false;
        }
        votersArray = new address[](0);

        for(uint candidatesArrayIndex = 0; candidatesArrayIndex < candidatesArray.length; candidatesArrayIndex++){
            uint candidate_id = candidatesArray[candidatesArrayIndex];
            candidateToVotes[candidate_id] = 0;
            candidates[candidate_id].id = 0;
            candidates[candidate_id].firstname = '';
            candidates[candidate_id].lastname = '';
            candidates[candidate_id].party = '';
        }
        candidatesArray = new uint[](0);
        emit Reset(block.timestamp);

    }
}