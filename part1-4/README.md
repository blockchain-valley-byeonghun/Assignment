## installation guide
```shell
npm install --save-dev hardhat
npx hardhat
npm install @openzeppelin/contracts
```

## how to use hardhat
```shell
export ALCHEMY_API_KEY=
export GOERLI_PRIVATE_KEY=
export BAOBAB_PRIVATE_KEY=
export METADATA_URL=
npx hardhat test test/~
npx hardhat complie && npx hardhat run scripts/deploy.ts --network goerli
npx hardhat complie && npx hardhat run scripts/deploy.ts --network baobab
```

- `env` 명령어를 통해 위에 `export` 명령어로 등록한 환경변수를 shell에서 확인할 수 있다
- 현재는 goerli와 baobab testnet에 컨트랙트를 배포할 수 있다

## 질문
1. 현재까지 작성된 부분의 코드에서 피드백 주실 게 있는 지 궁금합니다
   2. e.g. struct를 잘 사용한 건지 .. 등
2. _safeMint로 수정했는데 정확히 _mint() <-> _safeMint() 차이점을 모르겠습니다
3. 10개 명함 NFT mint 하는 for loop 를 아래처럼 수정하면 가스비가 적게 나오는지 알고싶습니다
   ```solidity
       function mintNft(string memory _name, string memory _group, string memory _job) external payable {
        require(msg.value == cost, "YOU HAVE TO PAY EXACT COST");
        require(!isMintedAddress[msg.sender], "ALREADY MINTED ADDRESS");
        for(uint i = 0; i <= MINT_AMOUNT;) {
            uint tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId);
            userData[tokenId] = UserData(msg.sender, _name, _group, _job, false);
            emit mint(msg.sender, _name, _group, _job, false);
            i++;
        }
        isMintedAddress[msg.sender] = true; // 10개 모두 민팅되면 해당 주소 minting 불가능
    }
   ```
4. hardhat으로 deploy 할 때 contructor에 값을 넣어주지 못하면 에러가 나서 아래 임시 코드로 해결해서 배포 테스트를 해보긴 했는데, 나중에 문제 없는 코드인지 궁금합니다.
    ```typescript
    const constructorArgs = process.env.METADATA_URL;
    const contract = await Nft.deploy(constructorArgs);
    ```
5. [optional] 부분에서 거래소쪽의 기능을 개발하려면 어떻게 해야하는 지 감이 안왔습니다. 