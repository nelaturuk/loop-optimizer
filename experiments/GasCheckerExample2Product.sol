

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./GasCheckerExample2After.sol";
import "./GasCheckerExample2Before.sol";


/** 
 * @notice invariant __verifier_eq(GasCheckerExample2Before.strikes, GasCheckerExample2After.strikes0)
 * @notice invariant __verifier_eq(GasCheckerExample2Before.options, GasCheckerExample2After.options0)
 * @notice invariant GasCheckerExample2Before.numOptions == GasCheckerExample2After.numoptions00
 * @notice invariant forall (uint i) !(0 <= i && i < GasCheckerExample2Before.strikes.length && numOptions > 20 && numoptions00 > 20) || (GasCheckerExample2Before.options[i] == GasCheckerExample2After.options0[i])
 */
contract SimulationCheck is GasCheckerExample2After, GasCheckerExample2Before {


    constructor() public
        GasCheckerExample2After()
        GasCheckerExample2Before()
    { }

    /** @notice modifies GasCheckerExample2After.options0
      * @notice modifies GasCheckerExample2Before.options
      * @notice modifies GasCheckerExample2Before.numOptions
      * @notice modifies GasCheckerExample2After.numoptions00
     */
    function checkreset() public {

        GasCheckerExample2After.setVar0();
        GasCheckerExample2Before.setVar();

    }
}