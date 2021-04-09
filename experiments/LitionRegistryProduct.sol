

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./LitionRegistryAfter.sol";
import "./LitionRegistryBefore.sol";


/** 
 * @notice invariant __verifier_eq(LitionRegistryBefore.validators, LitionRegistryAfter.validators0)
 * @notice invariant forall (uint i) !(0 <= i && i < LitionRegistryBefore.validators.length) || (LitionRegistryBefore.miningValidators[validators0[i]] == LitionRegistryAfter.miningValidators0[validators0[i]])
 */
contract SimulationCheck is LitionRegistryAfter, LitionRegistryBefore {


    constructor() public
        LitionRegistryAfter()
        LitionRegistryBefore()
    { }

    /** @notice modifies LitionRegistryAfter.miningValidators0
      * @notice modifies LitionRegistryBefore.miningValidators
     */
    function checkprocessValidatorsRewards20() public {

        LitionRegistryAfter.processValidatorsRewards20();
        LitionRegistryBefore.processValidatorsRewards2();

    }
}