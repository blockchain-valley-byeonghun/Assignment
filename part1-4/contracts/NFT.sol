// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    string public metadataURI; // contructor로 설정될 메타데이터 주소
    uint256 MINT_AMOUNT = 10; // 한번에 10번 민팅하는 요구사항 충족을 위함
    uint256 COST = 1 ether; // 가격 1 ether (klay) 로 설정

    mapping(address => bool) isMintedAddress; // 민팅을 한번 한 주소는 하지 못하게 하는 매핑

    constructor(string memory _metadataURI) ERC721("cardNFT", "NFT") {
        metadataURI = _metadataURI;
    }

    function mintNFT() external payable {
        require(msg.value >= COST, "YOU HAVE TO PAY EXACT COST");
        require(isMintedAddress[msg.sender] == false, "YOU ALREADY FINISH TO MINT");
        for(uint i = 0; i <= MINT_AMOUNT; i++) {
            uint tokenId = totalSupply() + 1;
            _mint(msg.sender, tokenId);
        }
        isMintedAddress[msg.sender] = true;
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        if(isRevealed == false) return notRevealedURI;
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    // onlyOwner

    // owner권한으로 가격 설정 가능
    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
    }
}