

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./AshTokenBefore.sol";
import "./AshTokenAfter.sol";


/** 
 * @notice invariant __verifier_eq(AshTokenBefore._addrs, AshTokenAfter._addrs0)
 * @notice invariant __verifier_eq(AshTokenBefore._amounts, AshTokenAfter._amounts0)
 * @notice invariant AshTokenBefore.totalSupply == AshTokenAfter.totalSupply0
 */
contract SimulationCheck is AshTokenBefore, AshTokenAfter {


    constructor() public
        AshTokenBefore()
        AshTokenAfter()
    { }

    /**
      * @notice modifies AshTokenBefore.totalSupply
      * @notice modifies AshTokenAfter.totalSupply0
     */ 
    function checktestfn2() public {
        AshTokenBefore.init();
        AshTokenAfter.init0();
    }
}