// SPDX-License-Identifier : MIT
pragma solidity ^0.8.0;

contract Numbers {
    function One() public view returns(uint num, uint timestamp) {
        return (1, block.timestamp);
    }
    function Two() public view returns(uint num, uint timestamp) {
        return (2, block.timestamp);
    }
    function Three() public view returns(uint num, uint timestamp) {
        return (3, block.timestamp);
    }

    function encodeOne() external view returns(bytes memory data)  {
        return abi.encodeWithSelector(this.One.selector);
    }
    function encodeTwo() external view returns(bytes memory data)  {
        return abi.encodeWithSelector(this.Two.selector);
    }
    function encodeThree() external view returns(bytes memory data)  {
        return abi.encodeWithSelector(this.Three.selector);
    }
}

contract Multicall {
    // 파라미터에 주소 array, function array를 넣어야한다
    function multicall(address[] calldata targets, bytes[] calldata data) external view returns(bytes[] memory){
        require(targets.length == data.length, '!Array length');

        bytes[] memory results = new bytes[](targets.length);

        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, '!success');
            results[i] = result;
        }
        return results;
    }
}