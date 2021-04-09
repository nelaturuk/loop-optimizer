

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import "./FutureBefore.sol";
import "./FutureAfter.sol";


/** 
 * @notice invariant __verifier_eq(FutureBefore.lockedRound, FutureAfter.lockedRound)
 * @notice invariant __verifier_eq(FutureBefore.luckyAmounts, FutureAfter.luckyAmounts)
 * @notice invariant FutureBefore.randTotal == FutureAfter.randTotal
 * @notice invariant FutureBefore.totalRandom == FutureAfter.totalRandom
 * @notice invariant FutureBefore.amount == FutureAfter.amount
 */
contract SimulationCheck is FutureBefore, FutureAfter {


    constructor() public
        FutureBefore()
        FutureAfter()
    { }

    /**
      * @notice modifies FutureBefore.totalSupply
      * @notice modifies FutureAfter.totalSupply0
     */ 
    function checktestfn2() public {
        FutureBefore.calcLocked();
        FutureAfter.calcLocked();
    }
}