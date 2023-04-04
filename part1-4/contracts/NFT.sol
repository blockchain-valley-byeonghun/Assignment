// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    string public metadataURI; // contructor로 설정될 메타데이터 주소
    uint256 MINT_AMOUNT = 10; // 한번에 10번 민팅하는 요구사항 충족을 위함
    uint256 cost = 1 ether; // 가격 1 ether (klay) 로 설정

    mapping(address => bool) isMintedAddress; // 민팅을 한번 한 주소는 하지 못하게 하는 매핑
    mapping(uint => UserData) userData; // 유저 정보를 저장할 매핑

    constructor(string memory _metadataURI) ERC721("cardNFT", "NFT") {
        metadataURI = _metadataURI;
    }

    event mint(address indexed owner, string name, string company, string job);

    struct UserData { // 임시로 3가지만 함
        string name;
        string company;
        string job;
    }

    function mintNFT(string _name, string _company, string _job) external payable {
        require(msg.value == cost, "YOU HAVE TO PAY EXACT COST");
        require(!isMintedAddress[msg.sender], "ALREADY MINTED ADDRESS");
        for(uint i = 0; i <= MINT_AMOUNT;) {
            uint tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId); // _mint vs _safeMint ?
            i++; // 가스비 더 적게 발생됨 이유는?
        }
        isMintedAddress[msg.sender] = true; // 10개 모두 민팅되면 해당 주소 minting 불가능
        userData[tokenId] = UserData(msg.sender, _name, _company, _job); // tokenId 안에 입력된 정보(파라미터)들을 저장한다
        emit mint(msg.sender, _name, _company, _job); // 이벤트 발생
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    // onlyOwner

    // owner권한으로 가격 설정 가능
    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
    }

    // 컨트랙트에 쌓인 자산 인출
    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "THERE IS NO BALANCE TO WITHDRAW");
        payable(msg.sender).transfer(balance);
    }
}