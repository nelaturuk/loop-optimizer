// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./IfCheckBefore.sol";
import "./IfCheckAfter.sol";


/** 
 * @notice invariant IfCheckBefore.CategoriesLength0 == IfCheckAfter.CategoriesLength
 * @notice invariant IfCheckBefore.Creator0 == IfCheckAfter.Creator
 */
contract SimulationCheck is IfCheckAfter, IfCheckBefore {


    constructor() public
        IfCheckAfter()
        IfCheckBefore()
    { }

    /** @notice modifies IfCheckBefore.Categories0
      * @notice modifies IfCheckAfter.Categories
      * @notice postcondition forall (uint8 i) !(0 <= i && i < IfCheckBefore.CategoriesLength0 && msg.sender == IfCheckBefore.Creator0) || (IfCheckBefore.Categories0[i] == IfCheckAfter.Categories[i])
      * @notice postcondition forall (uint8 i) !(0 <= i && i < IfCheckBefore.CategoriesLength0 && msg.sender == IfCheckAfter.Creator) || (IfCheckBefore.Categories0[i] == IfCheckAfter.Categories[i])
     */
    function checktestfn1() public {

        IfCheckBefore.foo();
        IfCheckAfter.fooAfter();

    }
}