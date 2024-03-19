// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface APCInterface {
    function getTotalTokenNumber() external view returns(uint256);
    function getOwnerOfToken(uint256 tokenId) external view returns(address);
}

interface AECInterface {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract VotingSystem {
    address APTAddress = 0xAdB8d027111ae2cB88e3C00730AF8EEeCBc21Ca8;
    // address  AECAddress = 0xb07959116C226f4e5A089B9453Ac3370cD882b08;

    APCInterface APTcontract = APCInterface(APTAddress);
    // AECInterface AECcontract = AECInterface(AECAddress);

    address contractOwner;

    uint256 totalAgendaNumber = APTcontract.getTotalTokenNumber();
    uint256 maxVoteToken = 100;

    uint256[] private listedAgendaId;

    struct AgendaStatus {
        address[] voters;
        uint256 totalVotes;
        mapping(address=>uint256) voterTokenValue;
        bool isListed;
        bool isDistributed;
    }

    mapping (uint256 => AgendaStatus) idToAgendaData;

    event Vote(address voterAddress, uint256 amount);
    event Listed(uint256 agendaTokenId);

    constructor() {
        contractOwner = msg.sender;

    }

    function vote(uint256 agendaTokenId, uint256 amount) public {
        require (agendaTokenId<=totalAgendaNumber, "No existing agenda id");
        require (amount>0, "0 token transferred");
        require (idToAgendaData[agendaTokenId].totalVotes+amount<=maxVoteToken, "Maximum available token input exceeded");

        // require(AECcontract.transferFrom(msg.sender, address(this), amount*10**18), "Transfer failed");

        AgendaStatus storage agenda = idToAgendaData[agendaTokenId];
        agenda.totalVotes+= amount;

        bool isVoterExists = false;
        for (uint i = 0; i < agenda.voters.length; i++) {
            if (agenda.voters[i] == msg.sender) {
                isVoterExists = true;
                break;
            }
        }
        if (!isVoterExists) {
            agenda.voters.push(msg.sender);
        }

        agenda.voterTokenValue[msg.sender] += amount;
        emit Vote(msg.sender, amount);
        if(agenda.totalVotes==maxVoteToken){
            listedAgendaId.push(agendaTokenId);
            agenda.isListed = true;
            emit Listed(agendaTokenId);
        }
    }

    function getVoteNumber(uint256 agendaTokenId) public view returns (uint256){
        return idToAgendaData[agendaTokenId].totalVotes;
    }
 
    function getListedAgendas() public view returns(uint256[] memory){
        return listedAgendaId;
    }

    function getVotingStatus(uint256 agendaTokenId) public view returns (address[] memory, uint256[] memory, bool, bool) {
        AgendaStatus storage agenda = idToAgendaData[agendaTokenId];
        return (agenda.voters, getVoterTokenValues(agenda), agenda.isListed, agenda.isDistributed);
    }

    function getVoterTokenValues(AgendaStatus storage agenda) private view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](agenda.voters.length);
        for (uint i = 0; i < agenda.voters.length; i++) {
            address voter = agenda.voters[i];
            values[i] = agenda.voterTokenValue[voter];
        }
        return values;
    }
}

//0xbA3eFEA0c245a8E1637ca48Fc334Be95b4e1A249