

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./LIXTokenAfter.sol";
import "./LIXTokenBefore.sol";


/** 
 * @notice invariant __verifier_eq(LIXTokenBefore.operVestingTime, LIXTokenAfter.operVestingTime0)
 * @notice invariant LIXTokenBefore.lockTime == LIXTokenAfter.lockTime0
 * @notice invariant forall (uint i) !(1 <= i && i < LIXTokenBefore.operVestingTime) || (LIXTokenBefore.operVestingTimer[i] == LIXTokenAfter.operVestingTimer0[i])
 */
contract SimulationCheck is LIXTokenAfter, LIXTokenBefore {


    constructor() public
        LIXTokenAfter()
        LIXTokenBefore()
    { }

    /** @notice modifies LIXTokenAfter.operVestingTimer0
      * @notice modifies LIXTokenBefore.operVestingTimer
     */
    function checkendSale0() public {

        LIXTokenAfter.endSale0();
        LIXTokenBefore.endSale();

    }
}