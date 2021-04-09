

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./WrappedCFAfter.sol";
import "./WrappedCFBefore.sol";


/** 
 * @notice invariant __verifier_eq(WrappedCFBefore._chainFaceIds, WrappedCFAfter._chainFaceIds0)
 * @notice invariant forall (uint i) !(0 <= i && i < WrappedCFBefore._chainFaceIds.length) || (WrappedCFBefore.depositedChainFacesArray[i] == WrappedCFAfter.depositedChainFacesArray0[i])
 * @notice invariant forall (uint i) !(0 <= i && i <  WrappedCFBefore._chainFaceIds.length && WrappedCFBefore._chainFaceIds[i] == 0) || ( WrappedCFBefore.chainFaceIsDepositedInContract[_chainFaceIds[i]] == WrappedCFAfter.chainFaceIsDepositedInContract0[_chainFaceIds0[i]])
 */
contract SimulationCheck is WrappedCFAfter, WrappedCFBefore {


    constructor() public
        WrappedCFAfter()
        WrappedCFBefore()
    { }

    /** @notice modifies WrappedCFAfter.depositedChainFacesArray0
      * @notice modifies WrappedCFBefore.depositedChainFacesArray
     */
    function checkdepositChainFacesAndMintTokens() public {

        WrappedCFAfter.depositChainFacesAndMintTokens0();
        WrappedCFBefore.depositChainFacesAndMintTokens();

    }

    /** @notice modifies WrappedCFAfter.chainFaceIsDepositedInContract0
      * @notice modifies WrappedCFBefore.chainFaceIsDepositedInContract
     */
    function checkChainFacesMintTokens() public {

        WrappedCFAfter.ChainFacesMintTokens0();
        WrappedCFBefore.ChainFacesMintTokens();

    }
}