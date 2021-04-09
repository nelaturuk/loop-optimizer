

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./Optimized.sol";
import "./UnOptimized.sol";


/** 
 * @notice invariant __verifier_eq(UnOptimized._beneficiaries0, Optimized._beneficiaries)
 * @notice invariant __verifier_eq(UnOptimized._tokens0, Optimized._tokens)
 * @notice invariant forall (uint i) !(0 <= i && i < UnOptimized._beneficiaries0.length) || (UnOptimized.whitelist0[_beneficiaries0[i]] == Optimized.whitelist[Optimized._beneficiaries[i]])
 * @notice invariant __verifier_eq(UnOptimized.total0, Optimized.total)
 */
contract SimulationCheck is UnOptimized, Optimized {


    constructor() public
        Optimized()
        UnOptimized()
    { }

    /** @notice modifies UnOptimized.whitelist0
      * @notice modifies Optimized.whitelist
     */
    function checktestfn1() public {

        Optimized.testfn1_0();
        UnOptimized.testfn1();

    }

    /**
      * @notice modifies UnOptimized.total0
      * @notice modifies Optimized.total
     */ 
    function checktestfn2() public {
        Optimized.testfn2_1();
        UnOptimized.testfn2();
    }
}