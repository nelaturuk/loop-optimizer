

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./SuperFairAfter.sol";
import "./SuperFairBefore.sol";


/** 
 * @notice invariant SuperFairBefore.startNum == SuperFairAfter.startNum0
 * @notice invariant SuperFairBefore.end == SuperFairAfter.end0
 * @notice invariant forall (uint i) !(SuperFairBefore.startNum <= i && i < SuperFairBefore.startNum + SuperFairBefore.end) || (SuperFairBefore.waitOrder[rid][i].execute == SuperFairAfter.waitOrder0[rid][i].execute)
 */
contract SimulationCheck is SuperFairAfter, SuperFairBefore {


    constructor() public
        SuperFairAfter()
        SuperFairBefore()
    { }

    /** @notice modifies SuperFairAfter.waitOrder0
      * @notice modifies SuperFairBefore.waitOrder
     */
    function checkexecuteLine0() public {

        SuperFairAfter.executeLine0();
        SuperFairBefore.executeLine();

    }
}