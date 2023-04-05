// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    string public metadataURI; // contructor로 설정될 메타데이터 주소
    string public groupName = "blockchainValley";
    uint256 MINT_AMOUNT = 10; // 한번에 10번 민팅하는 요구사항 충족을 위함
    uint256 cost = 1 ether; // 가격 1 ether (klay) 로 설정
    uint256 specialCost = 2 ether; // 조직이 발급해주는 명함 비용
    uint256 registerFee = 2 ether; // 조직 등록 비용

    mapping(address => bool) isMintedAddress; // 민팅을 한번 한 주소는 하지 못하게 하는 매핑
    mapping(address => bool) isGroupAddress; // 조직에 속한 멤버인지 체크 하는 매핑
    mapping(uint => UserData) userData; // 유저 정보를 저장할 매핑

    constructor(string memory _metadataURI) ERC721("cardNFT", "NFT") {
        metadataURI = _metadataURI;
    }

    event mint(address indexed owner, string name, string group, string job, bool isGroupMember);
    event registerMember(address indexed member);

    struct UserData { // 임시로 3가지만 함
        string name;
        string group;
        string job;
        bool isGroupMember;
    }

    function registerGroup() external payable {
        require(msg.value == registerFee, "YOU HAVE TO PAY EXACT COST");
        require(!isGroupAddress[msg.sender], "YOU ARE ALREADY MEMBER OF GROUP");
        isGroupAddress[msg.sender] = true;
        emit registerMember(msg.sender);
    }

    function mintGroupNft(address member, string _name, string job) external payable onlyOwner {
        require(msg.value == specialCost, "YOU HAVE TO PAY EXACT COST");
        require(isGroupAddress[member], "NOT ALLOWED ADDRESS");
        uint tokenId = totalSupply() + 1;
        _safeMint(member, tokenId);
        userData[tokenId] = UserData(member, _name, groupName, _job, true);
        emit mint(member, _name, groupName, _job, true);
    }

    function mintNft(string _name, string _group, string _job) external payable {
        require(msg.value == cost, "YOU HAVE TO PAY EXACT COST");
        require(!isMintedAddress[msg.sender], "ALREADY MINTED ADDRESS");
        for(uint i = 0; i <= MINT_AMOUNT;) {
            uint tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId);
            i++; // 가스비 더 적게 발생됨 이유는?
        }
        isMintedAddress[msg.sender] = true; // 10개 모두 민팅되면 해당 주소 minting 불가능
        userData[tokenId] = UserData(msg.sender, _name, _group, _job, false); // tokenId 안에 입력된 정보(파라미터)들을 저장한다
        emit mint(msg.sender, _name, _group, _job, false); // 이벤트 발생
    }

    function transfer(address _from, address _to, uint256 _tokenId) override external {
        _transfer(_from, _to, _tokenId);
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
    }

    function setSpecialCost(uint256 _newSpecialCost) external onlyOwner {
        specialCost = _newSpecialCost;
    }

    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "THERE IS NO BALANCE TO WITHDRAW");
        payable(msg.sender).transfer(balance);
    }
}