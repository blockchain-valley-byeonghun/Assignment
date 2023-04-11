# Reentrancy Attack


```shell
npm install
npx hardhat node
npx hardhat run scripts/deploy-etherbank.ts --network localhost
npx hardhar run scripts/deploy-etherbankAttack.ts --network localhost
npx hardhat run scripts/deploy-etherbanksg.ts --network localhost
npx hardhat run scripts/deploy-etherbanksgAttack.ts --network localhost
```

1. `deploy-etherbank.ts`
- 3 ETH 세팅
2. `deploy-etherbankAttack.ts`
- 3 ETH 뺴오는 공격
3. `deploy-etherbanksg.ts`
- openzeppelin의 ReentrancyGuard를 import 해서 사용한다
    - `import "@openzeppelin/contracts/security/ReentrancyGuard.sol";`
    - `_ENTERED` 값과 `_NOT_ENTERED` 값이 사용된다
    - withdraw함수 실행 시 바로 `_status = _ENTERED;`가 된다
    - 다 끝나야 `_status = _NOT_ENTERED;`로 처리
4. `deploy-etherbanksgAttack.ts`
    - 공격이 되지않는다.
    - `Error: cannot estimate gas;` 에러가 나는데, ether.js는 처음에 estimate_gas를 하고 transcation을 발생시키는데, fee estimate이 되지 않으면 어짜피 트랜잭션에서 에러가 날거라 저 에러가 뜨면 문제가 있는 트랜잭션이다 라고 이해하면 될 것 같다 