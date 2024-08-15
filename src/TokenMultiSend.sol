// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract TokenMultiSend {

    function transferETH(address payable[] calldata _addresses, uint256[] calldata _values) external payable {
        for (uint256 i = 0; i < _addresses.length; i += 1) {
            _addresses[i].transfer(_values[i]);
        }
    }

   
    function transferERC20(
        address _token,
        address[] calldata _addresses,
        uint256[] calldata _values
    ) external {
        require(_addresses.length == _values.length, "Address array and values array must be same length");
        for (uint256 i = 0; i < _addresses.length; i += 1) {
            IERC20(_token).transferFrom(msg.sender, _addresses[i], _values[i]);
        }
    }
}
