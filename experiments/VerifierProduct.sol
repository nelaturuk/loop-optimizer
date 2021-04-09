

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./VerifierAfter.sol";
import "./VerifierBefore.sol";


/** 
 * @notice invariant __verifier_eq(VerifierBefore.input, VerifierAfter.input0)
 * @notice invariant forall (uint i) !(0 <= i && i < input.length) || (VerifierBefore.inputValues[i] == VerifierAfter.inputValues0[i])
 */
contract SimulationCheck is VerifierAfter, VerifierBefore {


    constructor() public
        VerifierAfter()
        VerifierBefore()
    { }

    /** @notice modifies VerifierAfter.inputValues0
      * @notice modifies VerifierBefore.inputValues
     */
    function checkreset() public {

        VerifierAfter.verifyProof0();
        VerifierBefore.verifyProof();

    }
}