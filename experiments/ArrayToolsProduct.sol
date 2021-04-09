

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./ArrayToolsBefore.sol";
import "./ArrayToolsAfter.sol";


/** 
 * @notice invariant __verifier_eq(ArrayToolsBefore._array, ArrayToolsAfter._array0)
 * @notice invariant ArrayToolsBefore.fullAmount == ArrayToolsAfter.fullAmount0
 */
contract SimulationCheck is ArrayToolsBefore, ArrayToolsAfter {


    constructor() public
        ArrayToolsBefore()
        ArrayToolsAfter()
    { }

    /**
      * @notice modifies ArrayToolsBefore.fullAmount
      * @notice modifies ArrayToolsAfter.fullAmount0
     */ 
    function checktestfn2() public {
        ArrayToolsBefore._combineArray();
        ArrayToolsAfter._combineArray0();
    }
}