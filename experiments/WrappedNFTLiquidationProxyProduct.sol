

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./WrappedNFTLiquidationProxyAfter.sol";
import "./WrappedNFTLiquidationProxyBefore.sol";


/** 
 * @notice invariant WrappedNFTLiquidationProxyBefore._numTokensToPurchase == WrappedNFTLiquidationProxyAfter._numTokensToPurchase0
 * @notice invariant forall (uint i) !(0 <= i && i < WrappedNFTLiquidationProxyBefore._numTokensToPurchase) || (WrappedNFTLiquidationProxyBefore.destinationAddresses[i] == WrappedNFTLiquidationProxyAfter.destinationAddresses0[i])
 * @notice invariant forall (uint i) !(0 <= i && i < WrappedNFTLiquidationProxyBefore._numTokensToPurchase) || (WrappedNFTLiquidationProxyBefore.tokenIds[i] == WrappedNFTLiquidationProxyAfter.tokenIds0[i])
 * @notice invariant __verifier_eq(WrappedNFTLiquidationProxyBefore.tokenIds1, WrappedNFTLiquidationProxyAfter.tokenIds10)
 * @notice invariant WrappedNFTLiquidationProxyBefore._isMixedBatchOfNFTs == WrappedNFTLiquidationProxyAfter._isMixedBatchOfNFTs0
 * @notice invariant forall (uint i) !(0 <= i && i < WrappedNFTLiquidationProxyBefore.tokenIds1.length && _isMixedBatchOfNFTs0 == true) || (WrappedNFTLiquidationProxyBefore._nftIds[i] == WrappedNFTLiquidationProxyAfter._nftIds0[i])
 */
contract SimulationCheck is WrappedNFTLiquidationProxyAfter, WrappedNFTLiquidationProxyBefore {


    constructor() public
        WrappedNFTLiquidationProxyAfter()
        WrappedNFTLiquidationProxyBefore()
    { }

    /** @notice modifies WrappedNFTLiquidationProxyAfter.destinationAddresses0
      * @notice modifies WrappedNFTLiquidationProxyBefore.destinationAddresses
     */
    function checkpurchaseNFTsAssignSender0() public {

        WrappedNFTLiquidationProxyAfter.purchaseNFTsAssignSender0();
        WrappedNFTLiquidationProxyBefore.purchaseNFTsAssignSender();

    }

    /** @notice modifies WrappedNFTLiquidationProxyAfter.tokenIds0
      * @notice modifies WrappedNFTLiquidationProxyBefore.tokenIds
     */
    function checkpurchaseNFTsAssignConstant0() public {

        WrappedNFTLiquidationProxyAfter.purchaseNFTsAssignConstant0();
        WrappedNFTLiquidationProxyBefore.purchaseNFTsAssignConstant();

    }

    /** @notice modifies WrappedNFTLiquidationProxyAfter._nftIds0
      * @notice modifies WrappedNFTLiquidationProxyBefore._nftIds
     */
    function checkwrapNFTs0() public {

        WrappedNFTLiquidationProxyAfter.wrapNFTs0();
        WrappedNFTLiquidationProxyBefore.wrapNFTs();

    }
}