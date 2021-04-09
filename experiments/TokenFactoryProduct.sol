

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./TokenFactoryAfter.sol";
import "./TokenFactoryBefore.sol";


/** 
 * @notice invariant __verifier_eq(TokenFactoryBefore._auditSelectors, TokenFactoryAfter._auditSelectors0)
 * @notice invariant forall (uint i) !(0 <= i && i < TokenFactoryBefore._auditSelectors.length) || (TokenFactoryBefore.values[i] == TokenFactoryAfter.values0[i])
 */
contract SimulationCheck is TokenFactoryAfter, TokenFactoryBefore {


    constructor() public
        TokenFactoryAfter()
        TokenFactoryBefore()
    { }

    /** @notice modifies TokenFactoryAfter.values0
      * @notice modifies TokenFactoryBefore.values
     */
    function checkreset() public {

        TokenFactoryAfter.reviewToken0();
        TokenFactoryBefore.reviewToken();

    }
}