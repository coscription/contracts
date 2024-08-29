// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ITokenMultiSend {

    function transferETH(address payable[] calldata _addresses, uint256[] calldata _values) external payable;

    function transferERC20(address _token,address[] calldata _addresses,uint256[] calldata _values) external;
}
