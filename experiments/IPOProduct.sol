

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./IPOAfter.sol";
import "./IPOBefore.sol";


/** 
 * @notice invariant __verifier_eq(IPOBefore.IPOtarget, IPOAfter.IPOtarget0)
 * @notice invariant __verifier_eq(IPOBefore.IdToAdress, IPOAfter.IdToAdress0)
 * @notice invariant IPOBefore.nextIPO == IPOAfter.nextIPO0
 * @notice invariant forall (uint i) !(0 <= i && i < nextIPO) || (IPOBefore._locationData[i] == IPOAfter._locationData0[i])
 * @notice invariant IPOBefore.nextPlayerID == IPOAfter.nextPlayerID0
 * @notice invariant forall (uint i) !(0 <= i && i < nextPlayerID) || (IPOBefore._locationOwner[i] == IPOAfter._locationOwner0[i])
 */
contract SimulationCheck is IPOAfter, IPOBefore {


    constructor() public
        IPOAfter()
        IPOBefore()
    { }

    /** @notice modifies IPOAfter._locationData0
      * @notice modifies IPOBefore._locationData
     */
    function checkreset() public {

        IPOAfter.getIPOInfo0();
        IPOBefore.getIPOInfo();

    }

     /** @notice modifies IPOAfter._locationOwner0
      * @notice modifies IPOBefore._locationOwner
     */
    function checkreset1() public {

        IPOAfter.getPlayerInfo0();
        IPOBefore.getPlayerInfo();

    }
}