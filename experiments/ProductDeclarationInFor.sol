// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./DeclarationInForBefore.sol";
import "./DeclarationInForAfter.sol";


/** 
 * @notice invariant DeclarationInForBefore.CategoriesLength0 == DeclarationInForAfter.CategoriesLength
 * @notice invariant forall (uint8 i) !(0 <= i && i < DeclarationInForBefore.CategoriesLength0) || (DeclarationInForBefore.Categories0[i] == DeclarationInForAfter.Categories[i])
 */
contract SimulationCheck is DeclarationInForBefore, DeclarationInForAfter {


    constructor() public
        DeclarationInForBefore()
        DeclarationInForAfter()
    { }

    /** @notice modifies DeclarationInForBefore.Categories0
      * @notice modifies DeclarationInForAfter.Categories
     */
    function checktestfn1() public {

        DeclarationInForBefore.foo();
        DeclarationInForAfter.fooAfter();

    }
}