

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./ALinuxGoldAfter.sol";
import "./ALinuxGoldBefore.sol";


/** 
 * @notice invariant __verifier_eq(ALinuxGoldBefore._addr, ALinuxGoldAfter._addr0)
 * @notice invariant forall (uint i) !(0 <= i && i < ALinuxGoldBefore._addr.length) || (ALinuxGoldBefore.balanceLocked[_addr[i]] == ALinuxGoldAfter.balanceLocked0[_addr[i]])
 */
contract SimulationCheck is ALinuxGoldAfter, ALinuxGoldBefore {


    constructor() public
        ALinuxGoldAfter()
        ALinuxGoldBefore()
    { }

    /** @notice modifies ALinuxGoldAfter.balanceLocked0
      * @notice modifies ALinuxGoldBefore.balanceLocked
     */
    function checkunlock() public {

        ALinuxGoldAfter.unlock0();
        ALinuxGoldBefore.unlock();

    }

    /** @notice modifies ALinuxGoldAfter.balanceLocked0
      * @notice modifies ALinuxGoldBefore.balanceLocked
     */
    function checklock() public {

        ALinuxGoldAfter.lock0();
        ALinuxGoldBefore.lock();

    }
}