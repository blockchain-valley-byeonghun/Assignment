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

## 요구사항 정의서
### 1. Problem

NFT의 가치가 안정적이지 않습니다.

### 2. Solution

개인의 Identity를 NFT로 발행하여, NFT의 가치가 owner의 가치(명성, 영향력 등)을 따라가게 합니다.

### 3. Contract

**3.1 개인**

- 명함 제작에 필요한 유저 정보를 기록합니다.
   - 유저 이름, 소속 등등
- 유저는 최초 1회에 한하여 자신의 명함 10장을 mint할 수 있는 권한을 가지게 됩니다.
- 이후 유저는 `1 ETH (=1 KLAY)` 를 지불하여 자신의 명함 10장을 얻을 수 있습니다.
   - 명함 발급비용은 `Owner` 가 변경할 수 있습니다.
   - (Optional) 명함 발급 비용을 ETH(native token) 대신 우리가 자체 발행하는 ERC20으로 받을 수 있습니다.
- 명함은 NFT이므로 유저는 타인에게 NFT를 transfer할 수 있습니다.

**3.1 조직 [ Organization ]**

- `2 ETH`를 컨트랙트에 예치하면 조직의 권한을 얻을 수 있습니다.
- 조직에서는 조직에 속한 멤버에게 멤버의 명함을 만들어 줄 수 있습니다.
   - 이때 유저의 명함에 찍히는 조직은 반드시 명함을 발급해 준 조직이어야 합니다.
   - 조직이 발급해 주는 개인 명함의 가격 또한 별도로 설정할 수 있습니다.

**3.2 거래소 (Optional)**

- 타인의 명함을 거래할 수 있습니다.
- 조직은 구성원의 명함을 거래소에 게시할 수 있는 권한이 주어집니다.
- (Optional) 명함을 경매의 방식으로 거래할 수 있습니다.

### 4. Tip

- 원하는 기능은 마음껏 추가해도 좋습니다.
- 테스트는 hardhat에서 지원하는 local node를 사용해 보세요.
   - `npx hardhat node` 를 사용하면 로컬에 노드를 띄울 수 있습니다.
- (Optional) `Unpgradeable`한 컨트랙트
- (Optional) 테스트 코드 → 구글링 or ChatGPT의 도움!
- Typescript 사용 권장
