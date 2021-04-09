// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./WPXBefore.sol";
import "./WPXAfter.sol";


/** 
 * @notice invariant __verifier_eq(WPXBefore.timelockList, WPXAfter.timelockList0)
 * @notice invariant WPXBefore.totalBalance == WPXAfter.totalBalance0
 */
contract SimulationCheck is WPXBefore, WPXAfter {


    constructor() public
        WPXBefore()
        WPXAfter()
    { }

    /**
      * @notice modifies WPXBefore.totalBalance
      * @notice modifies WPXAfter.totalBalance0
     */ 
    function checktestfn2() public {
        WPXBefore.balanceOf();
        WPXAfter.balanceOf0();
    }
}