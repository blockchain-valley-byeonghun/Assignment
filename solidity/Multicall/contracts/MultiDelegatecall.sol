// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DelegateMulticall {
    function delegateMulticall(bytes[] calldata data) external payable returns (bytes[] memory) {
        bytes[] memory results = new bytes[](data.length);
        for (uint i; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "DELEGATE: !success");
            results[i] = result;
        }
        return results;
    }
}

contract CalculatorAndMinting is DelegateMulticall {
    event Log(address caller, uint answer);

    function adder(uint _a, uint _b) external returns (uint _answer) {
        _answer = _a + _b;
        emit Log(msg.sender, _answer);
    }

    function subtractor(uint _a, uint _b) external returns (uint _answer) {
        _answer = _a - _b;
        emit Log(msg.sender, _answer);
    }

    mapping(address => uint) public balanceOf;

    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function encodeAdder() external pure returns (bytes memory) {
        return abi.encodeWithSelector(CalculatorAndMinting.adder.selector, 1, 2);
    }

    function encodeSubtractor() external pure returns (bytes memory) {
        return abi.encodeWithSelector(CalculatorAndMinting.subtractor.selector, 3, 2);
    }

    function encodeMint() external pure returns (bytes memory) {
        return abi.encodeWithSelector(CalculatorAndMinting.mint.selector);
    }
}
