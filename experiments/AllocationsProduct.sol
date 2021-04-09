

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./AllocationsAfter.sol";
import "./AllocationsBefore.sol";


/** 
 * @notice invariant __verifier_eq(AllocationsAfter.payout0, AllocationsBefore.payout)
 * @notice invariant __verifier_eq(AllocationsAfter.totalSupport0, AllocationsBefore.totalSupport)
 */
contract SimulationCheck is AllocationsAfter, AllocationsBefore {


    constructor() public
        AllocationsAfter()
        AllocationsBefore()
    { }

    /** @notice modifies AllocationsAfter.totalSupport0
      * @notice modifies AllocationsBefore.totalSupport
     */
    function checkreset() public {

        AllocationsAfter._getTotalSupport0();
        AllocationsBefore._getTotalSupport();

    }
}