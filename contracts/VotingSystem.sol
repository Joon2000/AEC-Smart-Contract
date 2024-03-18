// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AgendaProposalToken {
    function getTotalTokenNumber() external view returns(uint256);
    function getOwnerOfToken(uint256 tokenId) external view returns(address);
}

interface AECToken {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function burn(address account, uint256 amount) external returns (bool);
}

contract VotingSystem {
    address APTAddress = 0xAdB8d027111ae2cB88e3C00730AF8EEeCBc21Ca8;
    address AECAddress = 0x20552E92665A832cA5c3EA22199f4B1E800652c4;

    AgendaProposalToken APTcontract = AgendaProposalToken(APTAddress);
    AECToken AECcontract = AECToken(AECAddress);

    address contractOwner;

    uint256 totalAgendaNumber = APTcontract.getTotalTokenNumber();
    uint256 maxVoteToken = 100;

    uint256[] private listedAgendaId;

    struct AgendaStatus {
        address[] voters;
        uint256 totalVotes;
        mapping(address=>uint256) voterTokenValue;
        bool isListed;
    }

    mapping (uint256 => AgendaStatus) idToAgendaData;

    event Vote(address voterAddress, uint256 amount);
    event Listed(uint256 agendaTokenId);

    constructor() {
        contractOwner = msg.sender;
    }

    function vote(uint256 agendaTokenId, address voterAddress, uint256 amount) public {
        require (contractOwner == msg.sender, "Only contract owner can confirm vote");
        require (agendaTokenId<=totalAgendaNumber, "No existing agenda id");
        require (amount>0, "0 token transferred");
        require (idToAgendaData[agendaTokenId].totalVotes+amount<=maxVoteToken, "Maximum available token input exceeded");
        AECcontract.burn(voterAddress, amount);
        // approveAndTransfer(voterAddress, amount);
        AgendaStatus storage agenda = idToAgendaData[agendaTokenId];
        agenda.totalVotes+= amount;

        bool isVoterExists = false;
        for (uint i = 0; i < agenda.voters.length; i++) {
            if (agenda.voters[i] == voterAddress) {
                isVoterExists = true;
                break;
            }
        }
        if (!isVoterExists) {
            agenda.voters.push(voterAddress);
        }

        agenda.voterTokenValue[voterAddress] += amount;
        emit Vote(voterAddress, amount);
        if(agenda.totalVotes==maxVoteToken){
            listedAgendaId.push(agendaTokenId);
            agenda.isListed = true;
            emit Listed(agendaTokenId);
        }
    }

    // function approveAndTransfer(address spender, uint256 amount) private{
    //     AECToken(AECAddress).approve(spender, amount);
    //     AECToken(AECAddress).transferFrom(spender, contractOwner, amount);
    // }

    function getVoteNumber(uint256 agendaTokenId) public view returns (uint256){
        return idToAgendaData[agendaTokenId].totalVotes;
    }
 
    function getListedAgendas() public view returns(uint256[] memory){
        return listedAgendaId;
    }

    function getVotingStatus(uint256 agendaTokenId) public view returns (address[] memory, uint256[] memory) {
        AgendaStatus storage agenda = idToAgendaData[agendaTokenId];
        return (agenda.voters, getVoterTokenValues(agenda));
    }

    function getVoterTokenValues(AgendaStatus storage agenda) private view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](agenda.voters.length);
        for (uint i = 0; i < agenda.voters.length; i++) {
            address voter = agenda.voters[i];
            values[i] = agenda.voterTokenValue[voter];
        }
        return values;
    }

    function getOwner(uint256 AgendaTokenId) public view returns (address) {
        return APTcontract.getOwnerOfToken(AgendaTokenId);
    }
}

