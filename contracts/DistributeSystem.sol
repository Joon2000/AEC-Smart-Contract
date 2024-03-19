// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface VotingSystemInterface {
    function getVotingStatus(uint256 agendaTokenId) external view returns (address[] memory, uint256[] memory, bool, bool);
}

interface APTInterface {
    function getTotalTokenNumber() external view returns(uint256);
    function getOwnerOfToken(uint256 tokenId) external view returns(address);
}

contract DistributeSystem {

    address VotingSystemAddress= 0xbA3eFEA0c245a8E1637ca48Fc334Be95b4e1A249;
    address APTAddress = 0xAdB8d027111ae2cB88e3C00730AF8EEeCBc21Ca8;

    VotingSystemInterface VotingSystemContract = VotingSystemInterface(VotingSystemAddress);
    APTInterface APTContract = APTInterface(APTAddress);

    struct AgendaData {
        string url;
        string title;
        string[3] summary;
        string detail;
        string positiveOpinion;
        string negativeOpinion;
    }

    function distribute (uint256 agendaTokenId) external {
        address[] memory voters;
        uint256[] memory votes;
        bool isListed;
        bool isDistributed;
        (voters, votes, isListed, isDistributed) = VotingSystemContract.getVotingStatus(agendaTokenId);
        require(isListed, "Not sufficient amout voting");
        require(!isDistributed, "Already distributed");
        
    }
}