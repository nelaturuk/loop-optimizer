

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./KYCVerificationAfter.sol";
import "./KYCVerificationBefore.sol";


/** 
 * @notice invariant __verifier_eq(KYCVerificationBefore._kycAddress, KYCVerificationAfter._kycAddress0)
 * @notice invariant KYCVerificationBefore._status == KYCVerificationAfter._status0
 * @notice invariant forall (uint i) !(0 <= i && i < KYCVerificationBefore._kycAddress.length) || (KYCVerificationBefore.kycAddress[_kycAddress0[i]] == KYCVerificationAfter.kycAddress0[_kycAddress0[i]])
 */
contract SimulationCheck is KYCVerificationAfter, KYCVerificationBefore {


    constructor() public
        KYCVerificationAfter()
        KYCVerificationBefore()
    { }

    /** @notice modifies KYCVerificationAfter.kycAddress0
      * @notice modifies KYCVerificationBefore.kycAddress
     */
    function checkupdateVerifcationBatch0() public {

        KYCVerificationAfter.updateVerifcationBatch0();
        KYCVerificationBefore.updateVerifcationBatch();

    }
}