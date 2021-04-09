

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./AddressListAfter.sol";
import "./AddressListBefore.sol";


/** 
 * @notice invariant __verifier_eq(AddressListBefore.addresses, AddressListAfter.addresses0)
 * @notice invariant forall (uint i) !(0 <= i && i < AddressListBefore.addresses.length) || (AddressListBefore.address_status[addresses0[i]] == AddressListAfter.address_status0[addresses0[i]])
 */
contract SimulationCheck is AddressListAfter, AddressListBefore {


    constructor() public
        AddressListAfter()
        AddressListBefore()
    { }

    /** @notice modifies AddressListAfter.address_status0
      * @notice modifies AddressListBefore.address_status
     */
    function checkreset() public {

        AddressListAfter._reset0();
        AddressListBefore._reset();

    }
}