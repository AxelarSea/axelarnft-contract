//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "../AxelarSeaNftBridgeController.sol";

abstract contract IAxelarSeaNftBridge {
  AxelarSeaNftBridgeController public immutable controller;

  constructor(address _controller) {
    controller = AxelarSeaNftBridgeController(_controller);
  }

  modifier onlyController {
    require(msg.sender == address(controller), "Not Controller");
    _;
  }

  function _bridge(uint128 chainId, address from, bytes calldata payload) virtual internal;
  function bridge(uint128 chainId, address from, bytes calldata payload) public payable onlyController {
    _bridge(chainId, from, payload);
  }
}