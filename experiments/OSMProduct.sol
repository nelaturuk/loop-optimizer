

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./OSMAfter.sol";
import "./OSMBefore.sol";


/** 
 * @notice invariant __verifier_eq(OSMBefore.a, OSMAfter.a0)
 * @notice invariant forall (uint i) !(0 <= i && i < OSMBefore.a.length) || (OSMBefore.bud[a[i]] == OSMAfter.bud0[a[i]])
 */
contract SimulationCheck is OSMAfter, OSMBefore {


    constructor() public
        OSMAfter()
        OSMBefore()
    { }

    /** @notice modifies OSMAfter.bud0
      * @notice modifies OSMBefore.bud
     */
    function checkdiss0() public {

        OSMAfter.diss0();
        OSMBefore.diss();

    }

    /** @notice modifies OSMAfter.bud0
      * @notice modifies OSMBefore.bud
     */
    function checkkiss0() public {

        OSMAfter.kiss0();
        OSMBefore.kiss();

    }
}