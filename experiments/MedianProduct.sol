

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./MedianAfter.sol";
import "./MedianBefore.sol";


/** 
 * @notice invariant __verifier_eq(MedianBefore.a, MedianAfter.a0)
 * @notice invariant forall (uint i) !(0 <= i && i < MedianBefore.a.length) || (MedianBefore.bud[a[i]] == MedianAfter.bud0[a[i]])
 */
contract SimulationCheck is MedianAfter, MedianBefore {


    constructor() public
        MedianAfter()
        MedianBefore()
    { }

    /** @notice modifies MedianAfter.bud0
      * @notice modifies MedianBefore.bud
     */
    function checkdiss0() public {

        MedianAfter.diss0();
        MedianBefore.diss();

    }

    /** @notice modifies MedianAfter.bud0
      * @notice modifies MedianBefore.bud
     */
    function checkkiss0() public {

        MedianAfter.kiss0();
        MedianBefore.kiss();

    }
}