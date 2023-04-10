// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Animals {
    function Dog() external view returns (uint _num, uint _time) {
        _num = 0;
        _time = block.timestamp;
    }

    function Cat() external view returns (uint _num, uint _time) {
        _num = 1;
        _time = block.timestamp;
    }

    function Hamster() external view returns (uint _num, uint _time) {
        _num = 2;
        _time = block.timestamp;
    }

    function encodeDog() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.Dog.selector);
    }

    function encodeCat() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.Cat.selector);
    }

    function encodeHamster() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.Hamster.selector);
    }
}

contract MultiCall {
    function multicall(
        address[] calldata targets,
        bytes[] calldata data
    ) external view returns (bytes[] memory) {
        bytes[] memory results = new bytes[](data.length);
        for (uint i; i < data.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "MULTICALL: !success");
            results[i] = result;
        }
        return results;
    }
}

contract Mapper {
    struct map {
        uint num;
        string word;
    }
    mapping(address => map) mapMapping;
}
