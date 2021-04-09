

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./ISDTAfter.sol";
import "./ISDTBefore.sol";


/** 
 * @notice invariant ISDTBefore.MAX_JUDGE == ISDTAfter.MAX_JUDGE0
 * @notice invariant forall (uint i) !(0 <= i && i < ISDTBefore.MAX_JUDGE) || (ISDTBefore.voteBox[i].result == ISDTAfter.voteBox0[i].result)
 */
contract SimulationCheck is ISDTAfter, ISDTBefore {


    constructor() public
        ISDTAfter()
        ISDTBefore()
    { }

    /** @notice modifies ISDTAfter.voteBox0
      * @notice modifies ISDTBefore.voteBox
     */
    function checkreset() public {

        ISDTAfter._voteResult0();
        ISDTBefore._voteResult();

    }
}