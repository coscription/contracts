// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract CoscriptionRecord is Ownable {
    address public signer;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public TYPE_HASH;

    mapping(address => uint256) private userNonces;
    mapping(address => uint256) private userPayed;

    event Payed(
        address indexed user,
        uint256 level,
        uint256 amount,
        uint256 nonces,
        uint256 timestamp
    );

    constructor(address _signer) {
        signer = _signer;
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("CoscriptionRecord")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        TYPE_HASH = keccak256(
            "Payed(address user,uint256 level,uint256 amount,uint256 nonce,uint256 _timestamp)"
        );
    }

    function pay(
        uint256 level,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        require(deadline >= block.timestamp, "PAY_EXPIRED");
        require(msg.value > 0, "INVALID VALUE");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        TYPE_HASH,
                        msg.sender,
                        level,
                        msg.value,
                        userNonces[msg.sender],
                        deadline
                    )
                )
            )
        );
        address user = ecrecover(digest, v, r, s);
        require(user == signer, "MSG.VALUE INVALID");
        emit Payed(
            msg.sender,
            level,
            msg.value,
            userNonces[msg.sender],
            block.timestamp
        );
        userPayed[msg.sender] += msg.value;
        ++userNonces[msg.sender];
    }

    function getUserNonce(address _user) external view returns (uint256) {
        return userNonces[_user];
    }

    function getUserTotalPayed(address _user) external view returns (uint256) {
        return userPayed[_user];
    }

    function changeSigner(address _newSigner) external onlyOwner {
        signer = _newSigner;
    }

    function withdrawETH(
        address payable _to,
        uint256 _amount
    ) external onlyOwner {
        require(address(this).balance >= _amount, "INVALID AMOUNT");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}
