

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./DividendManagerAfter.sol";
import "./DividendManagerBefore.sol";


/** 
 * @notice invariant __verifier_eq(DividendManagerBefore.notClaimedList, DividendManagerAfter.notClaimedList0)
 * @notice invariant __verifier_eq(DividendManagerBefore.dividends, DividendManagerAfter.dividends0)
 * @notice invariant forall (uint i) !(0 <= i && i < DividendManagerBefore.dividends) || (DividendManagerBefore.dividendsClaimed[msg.sender] == DividendManagerAfter.dividendsClaimed0[msg.sender])
 * @notice invariant DividendManagerBefore.currentSupply == DividendManagerAfter.currentSupply0
 */
contract SimulationCheck is DividendManagerAfter, DividendManagerBefore {


    constructor() public
        DividendManagerAfter()
        DividendManagerBefore()
    { }

    /** @notice modifies DividendManagerAfter.currentSupply0
      * @notice modifies DividendManagerBefore.currentSupply
     */
    function checkdepositDividend() public {

        DividendManagerAfter.depositDividend0();
        DividendManagerBefore.depositDividend();

    }

    /** @notice modifies DividendManagerAfter.dividendsClaimed0
      * @notice modifies DividendManagerBefore.dividendsClaimed
     */
    function checkclaimDividendAll() public {

        DividendManagerAfter.claimDividendAll0();
        DividendManagerBefore.claimDividendAll();

    }
}