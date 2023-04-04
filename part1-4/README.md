## installation
```shell
npm install --save-dev hardhat
npx hardhat
```

## how to use hardhat
```shell
export ALCHEMY_API_KEY=
export GOERLI_PRIVATE_KEY=
npx hardhat test test/~
npx hardhat run scripts/deploy.ts --network goerli
```

- `env` 명령어를 통해 위에 `export` 명령어로 등록한 환경변수를 shell에서 확인할 수 있다

## 명함 NFT
- 발급 비용
  - owner가 변경할 수 있게 설정 
- 유저는 최초 1회에 한하여 자신의 명함 10장을 mint할 수 있는 권한 설정
  - 10개 민팅 후 민팅 불가능하게 설정