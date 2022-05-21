var Election = artifacts.require("./Election.sol");


contract("Election", (accounts)=>{
    let instance;

    it("initializes total candidates to zero", ()=>{

        return Election.deployed().then((instance)=>{
            return instance.candidateCount();
        }).then((totalCandidates)=>{
            assert.equal(totalCandidates, 0);
        })
    })

    it("initializes electoralChairman to msg.sender", ()=>{

        return Election.deployed().then((inst)=>{
            instance = inst;
            return instance.electoralChairman();
        }).then((electoralChairman)=>{
            assert.equal(electoralChairman, accounts[0]);
        })
    })
    it("initializes electoral state as finished", ()=>{

        return Election.deployed().then((inst)=>{
            instance = inst;
            return instance.election_state();
        }).then((electionState)=>{
            assert.equal(electionState, 1);
        })
    })
})


