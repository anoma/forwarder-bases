// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin-contracts-5.7.0/access/Ownable.sol";
import {Pausable} from "@openzeppelin-contracts-5.7.0/utils/Pausable.sol";

contract ProtocolAdapterMock is Ownable, Pausable {
    constructor(address emergencyStopCaller) Ownable(emergencyStopCaller) {}

    function emergencyStop() external onlyOwner whenNotPaused {
        _pause();
    }

    function resume() external onlyOwner whenPaused {
        _unpause();
    }

    function isEmergencyStopped() public view returns (bool isStopped) {
        isStopped = paused();
    }
}
