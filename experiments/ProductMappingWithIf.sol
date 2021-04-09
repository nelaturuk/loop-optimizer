// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./MappingWithIfBefore.sol";
import "./MappingWithIfAfter.sol";


/** 
 * @notice invariant MappingWithIfBefore.SmallContractsLength0 == MappingWithIfAfter.SmallContractsLength
 * @notice invariant MappingWithIfBefore.Creator0 == MappingWithIfAfter.Creator
 */
contract SimulationCheck is MappingWithIfAfter, MappingWithIfBefore {


    constructor() public
        MappingWithIfAfter()
        MappingWithIfBefore()
    { }

    /** @notice modifies MappingWithIfBefore.smallContractsIncoming0
      * @notice modifies MappingWithIfAfter.smallContractsIncoming
      * @notice postcondition forall (uint8 i) !(0 <= i && i < MappingWithIfBefore.SmallContractsLength0 && msg.sender == MappingWithIfBefore.Creator0) || (MappingWithIfBefore.smallContractsIncoming0[i] == MappingWithIfAfter.smallContractsIncoming[i]) || (MappingWithIfBefore.smallContractsIncoming0[i] < 0) || (MappingWithIfAfter.smallContractsIncoming[i] < 0)
     */
    function checktestfn1() public {

        MappingWithIfBefore.foo();
        MappingWithIfAfter.fooAfter();

    }
}