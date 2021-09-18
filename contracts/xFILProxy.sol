// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract XFILProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address _admin,
        address _owner
    ) TransparentUpgradeableProxy(_logic, _admin, abi.encodeWithSignature("initialize(address)", _owner)) {}
}
