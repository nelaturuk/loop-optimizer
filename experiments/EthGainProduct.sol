

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./EthGainAfter.sol";
import "./EthGainBefore.sol";


/** 
 * @notice invariant ETHGainBefore._userID == ETHGainAfter._userID0
 * @notice invariant forall (uint i) !(1 <= i && i <= 16) || (ETHGainBefore.users[_userID].starActive[i] == ETHGainAfter.user0[_userID0].starActive0[i])
 * @notice invariant ETHGainBefore.noFreeReferrer == ETHGainAfter.noFreeReferrer0
 * @notice invariant __verifier_eq (ETHGainBefore.referrals, ETHGainAfter.referrals0)
 * @notice invariant ETHGainBefore.freeReferrer == ETHGainAfter.freeReferrer0
 */
contract SimulationCheck is ETHGainAfter, ETHGainBefore {


    constructor() public
        ETHGainAfter()
        ETHGainBefore()
    { }

    /** @notice modifies ETHGainAfter.user0
      * @notice modifies ETHGainBefore.users
     */
    function checksetUserData() public {

        ETHGainAfter.setUserData0();
        ETHGainBefore.setUserData();

    }

    /** @notice modifies ETHGainAfter.noFreeReferrer0
      * @notice modifies ETHGainBefore.noFreeReferrer
     */
    function checkfindFreeReferrer() public {

        ETHGainAfter.findFreeReferrer0();
        ETHGainBefore.findFreeReferrer();

    }

    /** @notice modifies ETHGainAfter.freeReferrer0
      * @notice modifies ETHGainBefore.freeReferrer
     */
    function checkfindFreeReferrer2() public {

        ETHGainAfter.findFreeReferrer20();
        ETHGainBefore.findFreeReferrer2();

    }
}