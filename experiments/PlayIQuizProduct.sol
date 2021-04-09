

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./PlayIQuizAfter.sol";
import "./PlayIQuizBefore.sol";


/** 
 * @notice invariant __verifier_eq(PlayIQuizBefore.admins, PlayIQuizAfter.admins0)
 * @notice invariant forall (uint i) !(0 <= i && i < PlayIQuizBefore.admins.length) || (PlayIQuizBefore.admin[admins[i]] == PlayIQuizAfter.admin0[admins[i]])
 */
contract SimulationCheck is PlayIQuizAfter, PlayIQuizBefore {


    constructor() public
        PlayIQuizAfter()
        PlayIQuizBefore()
    { }

    /** @notice modifies PlayIQuizAfter.admin0
      * @notice modifies PlayIQuizBefore.admin
     */
    function checkreset() public {

        PlayIQuizAfter.initAdmins0();
        PlayIQuizBefore.initAdmins();

    }
}