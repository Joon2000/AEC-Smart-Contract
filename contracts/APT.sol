// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AgendaProposalToken is ERC721, Ownable {
    uint256  private _nextTokenId;
    
    struct AgendaData {
        string url;
        string title;
        string[3] summary;
        string detail;
        string positiveOpinion;
        string negativeOpinion;
    }

    mapping(uint256=>AgendaData) private tokenIdToAgendaData;

    constructor()
        ERC721(" Agenda Proposal Token", "APT")
        Ownable(msg.sender)
    {}

    function safeMint(address to, AgendaData memory agendaData) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        tokenIdToAgendaData[tokenId] = agendaData;
        _safeMint(to, tokenId);
    }

    function getTotalTokenNumber() public view returns(uint256) {
        return  _nextTokenId;
    }

    function getAgendaData(uint256 tokenId) public view returns(AgendaData memory) {
        return tokenIdToAgendaData[tokenId];
    }

    function getOwnerOfToken(uint256 tokenId) public view returns(address) {
        return _ownerOf(tokenId);
    }
}
//0xAdB8d027111ae2cB88e3C00730AF8EEeCBc21Ca8