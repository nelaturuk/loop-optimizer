

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./BeneficiaryOptionsAfter.sol";
import "./BeneficiaryOptionsBefore.sol";


/** 
 * @notice invariant __verifier_eq(BeneficiaryOptionsBefore.beneficiaries, BeneficiaryOptionsAfter.beneficiaries0)
 * @notice invariant forall (uint i) !(0 <= i && i < BeneficiaryOptionsBefore.beneficiaries.length) || (BeneficiaryOptionsBefore.operationsCountByBeneficiaryIndex[i] == BeneficiaryOptionsAfter.operationsCountByBeneficiaryIndex0[i])
 * @notice invariant __verifier_eq(BeneficiaryOptionsBefore.newBeneficiaries, BeneficiaryOptionsAfter.newBeneficiaries0)
 * @notice invariant forall (uint i) !(0 <= i && i < BeneficiaryOptionsBefore.newBeneficiaries.length) || (BeneficiaryOptionsBefore.beneficiariesIndices[newBeneficiaries0[i]] == BeneficiaryOptionsAfter.beneficiariesIndices0[newBeneficiaries0[i]])
*/
contract SimulationCheck is BeneficiaryOptionsAfter, BeneficiaryOptionsBefore {


    constructor() public
        BeneficiaryOptionsAfter()
        BeneficiaryOptionsBefore()
    { }

    /** @notice modifies BeneficiaryOptionsAfter.operationsCountByBeneficiaryIndex0
      * @notice modifies BeneficiaryOptionsBefore.operationsCountByBeneficiaryIndex
     */
    function check_cancelAllPending0() public {

        BeneficiaryOptionsAfter._cancelAllPending0();
        BeneficiaryOptionsBefore._cancelAllPending();

    }

     /** @notice modifies BeneficiaryOptionsAfter.beneficiariesIndices0
      * @notice modifies BeneficiaryOptionsBefore.beneficiariesIndices
     */
    function check_transferBeneficiaryShipWithHowMany0() public {

        BeneficiaryOptionsAfter.transferBeneficiaryShipWithHowMany0();
        BeneficiaryOptionsBefore.transferBeneficiaryShipWithHowMany();

    }
}