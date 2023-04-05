// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    // 수영: uint == uint256이지만 하나로 통일할 필요는 있을 것 같습니다. (저는 uint 쓰는 편입니다.)
    string public metadataURI; // contructor로 설정될 메타데이터 주소
    string public groupName = "blockchainValley";

    // 수영: 아래 변수들 + mapping도 public 명시해 주는 것이 좋습니다.
    // MINT_AMOUNT는 바꿀 수 없는 것인가요? 그렇다면 constant 처리해 주는 것이 좋습니다.
    uint256 MINT_AMOUNT = 10; // 한번에 10번 민팅하는 요구사항 충족을 위함 ( 상수 )
    uint256 cost = 1 ether; // 가격 1 ether (klay) 로 설정
    uint256 specialCost = 2 ether; // 조직이 발급해주는 명함 비용
    uint256 registerFee = 2 ether; // 조직 등록 비용


    mapping(address => bool) isMintedAddress; // 유저는 최초 1회에 한하여 자신의 명함 10장을 mint할 수 있는 권한을 가지게 됩니다
    mapping(address => bool) isGroupAddress; // 조직에 속한 멤버인지 체크 하는 매핑
    mapping(uint => UserData) userData; // 명함 제작에 필요한 유저 정보를 기록합니다.

    constructor(string memory _metadataURI) ERC721("cardNFT", "NFT") {
        metadataURI = _metadataURI;
    }

    // 수영: event명은 대문자로 시작하는 것이 컨벤션입니다.
    event mint(address indexed owner, string name, string group, string job, bool isGroupMember);
    event registerMember(address indexed member);

    // 수영: 구조체는 문제 없는 듯합니다~
    struct UserData { // 유저 이름, 소속, 하는 일, 그룹 멤버 여부확인
        address wallet;
        string name;
        string group;
        string job;
        bool isGroupMember;
    }

    // 2 ETH를 컨트랙트에 예치하면 조직의 권한을 얻을 수 있습니다.
    function registerGroup() external payable {
        require(msg.value == registerFee, "YOU HAVE TO PAY EXACT COST");
        require(!isGroupAddress[msg.sender], "YOU ARE ALREADY MEMBER OF GROUP");
        isGroupAddress[msg.sender] = true;
        emit registerMember(msg.sender);
    }

    // 조직에서는 조직에 속한 멤버에게 멤버의 명함을 만들어 줄 수 있습니다.
    // 수영: 원래 의도는 "조직"이 직접 "구성원"의 명함을 발급해 주는 것입니다.
    // 그런 의미에서 onlyOwner은 빠져야 하고, isGroupAddress[msg.sender] 여부를 확인하는 것이 추가되어야 합니다.
    // + 
    // external 함수에서는 memory보다 calldata를 쓰는 게 효율적입니다. 
    // e.g. `string memory _name` -> string calldata _name
    function mintGroupNft(address _member, string memory _name, string memory _job) external payable onlyOwner {
        require(msg.value == specialCost, "YOU HAVE TO PAY EXACT COST");
        require(isGroupAddress[_member], "NOT ALLOWED ADDRESS");
        uint tokenId = totalSupply() + 1;
        _safeMint(_member, tokenId);
        userData[tokenId] = UserData(_member, _name, groupName, _job, true); // 이때 유저의 명함에 찍히는 조직은 반드시 명함을 발급해 준 조직이어야 합니다.
        emit mint(_member, _name, groupName, _job, true);
    }

    function mintNft(string memory _name, string memory _group, string memory _job) external payable {
        require(msg.value == cost, "YOU HAVE TO PAY EXACT COST");
        require(!isMintedAddress[msg.sender], "ALREADY MINTED ADDRESS");

        // 수영: for문 내 첫 2줄만 다르게 써보겠습니다.
        // uint tokenId = totalSupply();
        // for(uint i = 0; i <= MINT_AMOUNT; i++) {
        // tokenId ++; 
        // ...(후략)
        //
        // totalSupply() 함수를 사용하는 것은 스토리지의 데이터를 가져오는 것인데, 이게 비용이 비쌉니다. 
        // 메모리에서 데이터를 가져오는 게 훨씬 쌉니다. 
        // 이렇게 하면 스토리지에서 최초 1번만 데이터를 가져오고 이후에는 메모리 참조로 해결할 수 있습니다.
        // 
        // 아이디어)
        // mint 한 번 할때 가스가 꽤 듭니다. 
        // 실제로 NFT를 mint해주는 것이 아니라, "mint할 수 있는 권한"을 10개 주는 것은 어떨까요?
        // 민트는 유저가 스스로 하게 시키는 겁니다. (가스비=유저 부담)
        // 이때 장점: 
        // 처음 1ETH 낼 때는 민트해줄 필요 없이 `mintable`같은 변수 만들어서 숫자만 올려주면 됨 
        // mint를 다른 사람에게 다이렉트로 해줄 수 있음 (mint 함수의 to 참고)
        for(uint i = 0; i <= MINT_AMOUNT; i++) {
            uint tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId);
            userData[tokenId] = UserData(msg.sender, _name, _group, _job, false);
            emit mint(msg.sender, _name, _group, _job, false);
        }
        isMintedAddress[msg.sender] = true; // 10개 모두 민팅되면 해당 주소 minting 불가능
    }

    // 명함은 NFT이므로 유저는 타인에게 NFT를 transfer할 수 있습니다.
    // 수영: 이건 오픈제플린 ERC721에 transfer 함수와 동일하지 않나요? 그거 쓰면 될 것 같네요
    function transferNFT(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(from, tokenId), "YOU ARE NOT THE OWNER OF NFT");
        require(to != address(0), "CAN NOT TRANSFER TO ZERO ADDRESS");
        _transfer(from, to, tokenId);
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    // 명함 발급비용은 Owner 가 변경할 수 있습니다.
    function setCost(uint256 _newCost) external onlyOwner {
        cost = _newCost;
    }

    // 조직이 발급해 주는 개인 명함의 가격 또한 별도로 설정할 수 있습니다.
    function setSpecialCost(uint256 _newSpecialCost) external onlyOwner {
        specialCost = _newSpecialCost;
    }

    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "THERE IS NO BALANCE TO WITHDRAW");
        payable(msg.sender).transfer(balance);
    }
}