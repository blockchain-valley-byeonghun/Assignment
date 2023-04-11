// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    // 수영: uint == uint256이지만 하나로 통일할 필요는 있을 것 같습니다. (저는 uint 쓰는 편입니다.)
    // 병훈: 수정했습니다.
    string public metadataURI;
    string public groupName = "blockchainValley";

    // 수영: 아래 변수들 + mapping도 public 명시해 주는 것이 좋습니다.
    // MINT_AMOUNT는 바꿀 수 없는 것인가요? 그렇다면 constant 처리해 주는 것이 좋습니다.
    // 병훈: 수정했습니다. constant 키워드와 public을 동시에 가질 수도 있나요?
    uint constant MINT_AMOUNT = 10;
    uint public cost = 1 ether;
    uint public specialCost = 2 ether;
    uint public registerFee = 2 ether;

    mapping(address => bool) public isMintedAddress;
    mapping(address => bool) public isGroupAddress;
    mapping(uint => UserData) public userData;

    constructor(string memory _metadataURI) ERC721("cardNFT", "NFT") {
        metadataURI = _metadataURI;
    }

    // 수영: event명은 대문자로 시작하는 것이 컨벤션입니다.
    // 병훈: 수정했습니다.
    event Mint(address indexed owner, string name, string group, string job, bool isGroupMember);
    event RegisterMember(address indexed member);

    // 수영: 구조체는 문제 없는 듯합니다~
    struct UserData {
        address wallet;
        string name;
        string group;
        string job;
        bool isGroupMember;
    }

    function registerGroup() external payable {
        require(msg.value == registerFee, "YOU HAVE TO PAY EXACT COST");
        require(!isGroupAddress[msg.sender], "YOU ARE ALREADY MEMBER OF GROUP");
        isGroupAddress[msg.sender] = true;
        emit RegisterMember(msg.sender);
    }

    // 조직에서는 조직에 속한 멤버에게 멤버의 명함을 만들어 줄 수 있습니다.
    // 수영: 원래 의도는 "조직"이 직접 "구성원"의 명함을 발급해 주는 것입니다.
    // 그런 의미에서 onlyOwner은 빠져야 하고, isGroupAddress[msg.sender] 여부를 확인하는 것이 추가되어야 합니다.
    // +
    // external 함수에서는 memory보다 calldata를 쓰는 게 효율적입니다.
    // e.g. `string memory _name` -> string calldata _name
    // 병훈: 수정했습니다.
    function mintGroupNft(string calldata _name, string calldata _job) external payable {
        require(msg.value == specialCost, "YOU HAVE TO PAY EXACT COST");
        require(isGroupAddress[msg.sender], "NOT ALLOWED ADDRESS");
        uint tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
        userData[tokenId] = UserData(msg.sender, _name, groupName, _job, true); // 이때 유저의 명함에 찍히는 조직은 반드시 명함을 발급해 준 조직이어야 합니다.
        emit Mint(msg.sender, _name, groupName, _job, true);
    }

    // 수영: for문 내 첫 2줄만 다르게 써보겠습니다.
    // totalSupply() 함수를 사용하는 것은 스토리지의 데이터를 가져오는 것인데, 이게 비용이 비쌉니다.
    // 메모리에서 데이터를 가져오는 게 훨씬 쌉니다.
    // 이렇게 하면 스토리지에서 최초 1번만 데이터를 가져오고 이후에는 메모리 참조로 해결할 수 있습니다.
    // 병훈 : 수정했습니다. + 위에 함수에서는 batch mint가 아니라 그냥  uint tokenId = totalSupply() + 1; 이렇게 선언되어있는데, 괜찮은건가요?

    // 아이디어)
    // mint 한 번 할때 가스가 꽤 듭니다.
    // 실제로 NFT를 mint해주는 것이 아니라, "mint할 수 있는 권한"을 10개 주는 것은 어떨까요?
    // 민트는 유저가 스스로 하게 시키는 겁니다. (가스비=유저 부담)
    // 이때 장점:
    // 처음 1ETH 낼 때는 민트해줄 필요 없이 `mintable`같은 변수 만들어서 숫자만 올려주면 됨
    // mint를 다른 사람에게 다이렉트로 해줄 수 있음 (mint 함수의 to 참고)
    // 병훈 : 아이디어 부분이 이해가 잘 안 갔습니다.
    function mintNft(string calldata _name, string calldata _group, string calldata _job) external payable {
        require(msg.value == cost, "YOU HAVE TO PAY EXACT COST");
        require(!isMintedAddress[msg.sender], "ALREADY MINTED ADDRESS");
        uint tokenId = totalSupply();
        for(uint i = 0; i <= MINT_AMOUNT; i++) {
            tokenId++;
            _safeMint(msg.sender, tokenId);
            userData[tokenId] = UserData(msg.sender, _name, _group, _job, false);
            emit Mint(msg.sender, _name, _group, _job, false);
        }
        isMintedAddress[msg.sender] = true;
    }

    // 수영: 이건 오픈제플린 ERC721에 transfer 함수와 동일하지 않나요? 그거 쓰면 될 것 같네요
    // 병훈: 피드백 주신대로 수정했는데, ERC721에 있는 _transfer함수를 그대로 사용하면 internal이어서 외부에서는 사용을 못하게 되는 것으로 이해했는데, 맞을까요
    function _transfer(address from, address to, uint256 tokenId) internal override {
        super._transfer(from, to, tokenId);
    }


    function tokenURI(uint _tokenId) public override view returns(string memory) {
        return string(abi.encodePacked(metadataURI, '/', Strings.toString(_tokenId), '.json'));
    }

    function setCost(uint _newCost) external onlyOwner {
        cost = _newCost;
    }

    function setSpecialCost(uint _newSpecialCost) external onlyOwner {
        specialCost = _newSpecialCost;
    }

    function withdraw() external payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "THERE IS NO BALANCE TO WITHDRAW");
        payable(msg.sender).transfer(balance);
    }
}