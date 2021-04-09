

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./WADZTokenAfter.sol";
import "./WADZTokenBefore.sol";


/** 
 * @notice invariant __verifier_eq(WADZTokenBefore._addresses, WADZTokenAfter._addresses0)
 * @notice invariant forall (uint i) !(0 <= i && i < WADZTokenBefore._addresses.length) || (WADZTokenBefore.admins[_addresses0[i]] == WADZTokenAfter.admins0[_addresses0[i]])
 * @notice invariant forall (uint i) !(0 <= i && i < WADZTokenBefore._addresses.length) || (WADZTokenBefore.whitelist[_addresses0[i]] == WADZTokenAfter.whitelist0[_addresses0[i]])
 */
contract SimulationCheck is WADZTokenAfter, WADZTokenBefore {


    constructor() public
        WADZTokenAfter()
        WADZTokenBefore()
    { }

    /** @notice modifies WADZTokenAfter.admins0
      * @notice modifies WADZTokenBefore.admins
      * @notice modifies WADZTokenAfter.whitelist0
      * @notice modifies WADZTokenBefore.whitelist
     */
    function checkreset() public {

        WADZTokenAfter.setAdministrators0();
        WADZTokenBefore.setAdministrators();

    }
}