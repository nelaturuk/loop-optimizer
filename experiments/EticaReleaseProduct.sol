

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./EticaReleaseAfter.sol";
import "./EticaReleaseBefore.sol";


/** 
 * @notice invariant __verifier_eq(EticaReleaseBefore.periodsCounter, EticaReleaseAfter.periodsCounter)
 * @notice invariant EticaReleaseBefore._totalfor == EticaReleaseAfter._totalfor
 * @notice invariant EticaReleaseBefore._totalagainst == EticaReleaseAfter._totalagainst
 */
contract SimulationCheck is EticaReleaseAfter, EticaReleaseBefore {


    constructor() public
        EticaReleaseAfter()
        EticaReleaseBefore()
    { }

    /**
      * @notice modifies EticaReleaseBefore._totalfor
      * @notice modifies EticaReleaseAfter._totalfor
     */ 
    function checkreset() public {

        EticaReleaseAfter.readjustThreshold10();
        EticaReleaseBefore.readjustThreshold1();

    }

     /** @notice modifies EticaReleaseAfter._totalagainst
      * @notice modifies EticaReleaseBefore._totalagainst
     */
    function checkreset1() public {

        EticaReleaseAfter.readjustThreshold20();
        EticaReleaseBefore.readjustThreshold2();

    }
}