

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./AirdropAfter.sol";
import "./AirdropBefore.sol";


/** 
 * @notice invariant __verifier_eq(AirdropBefore._signers, AirdropAfter._signers0)
 * @notice invariant AirdropBefore._active == AirdropAfter._active0
 * @notice invariant forall (uint i) !(0 <= i && i < AirdropBefore._signers.length) || (AirdropBefore.isSigner[_signers[i]] == AirdropAfter.isSigner0[_signers[i]])
 */
contract SimulationCheck is AirdropAfter, AirdropBefore {


    constructor() public
        AirdropAfter()
        AirdropBefore()
    { }

    /** @notice modifies AirdropAfter.isSigner0
      * @notice modifies AirdropBefore.isSigner
     */
    function checkreset() public {

        AirdropAfter.setActiveSigners0();
        AirdropBefore.setActiveSigners();

    }
}