## installation
```shell
npm install --save-dev hardhat
npx hardhat
```

## how to use hardhat
```shell
export ALCHEMY_API_KEY=
export GOERLI_PRIVATE_KEY=
export BAOBAB_PRIVATE_KEY=
export METADATA_URL=
npx hardhat test test/~
npx hardhat run scripts/deploy.ts --network goerli ||  npx hardhat run scripts/deploy.ts --network baobab  
```

- `env` 명령어를 통해 위에 `export` 명령어로 등록한 환경변수를 shell에서 확인할 수 있다

## 명함 NFT
- _safeMint로 수정했는데 맞는지 아직 모르겠음
- for loop에서 왜 i++ 증감문을 뒤에 쓰는게 가스비가 적게 나오는지 모르겠음
```typescript
const constructorArgs = process.env.METADATA_URL;
const contract = await Nft.deploy(constructorArgs);
// 이렇게 contructor 값을 넣어줬는데, 제대로 잘 들어가는 코드인 지 모르겠다
```