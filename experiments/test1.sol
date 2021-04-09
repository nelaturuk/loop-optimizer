// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

contract Test1 {
    
    uint256[] public _tokens0;
    uint256 public total0;

    /** 
     * @notice modifies total0
     * @notice postcondition total0 >= __verifier_sum_uint(_tokens0)
     * @notice postcondition (total0 == __verifier_old_uint(total0) + __verifier_sum_uint(_tokens0))
  */
   function testfn2() public {
      uint i = 0;
      require(_tokens0.length > 0);
      /// @notice invariant (i < _tokens0.length) || (total0 == __verifier_old_uint(total0) + __verifier_sum_uint(_tokens0))
     for(i = 0; i < _tokens0.length; i++){
        total0 = total0 + _tokens0[i];
      }
   }
}