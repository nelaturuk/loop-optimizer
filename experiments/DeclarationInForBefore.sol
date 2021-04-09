pragma solidity >=0.5.0;
contract DeclarationInForBefore {
    uint8 CategoriesLength0 = 10;
    mapping(uint8 => uint256) Categories0; //array representation

    /**
    * @notice modifies DeclarationInForBefore.Categories0
    * @notice postcondition CategoriesLength0 == __verifier_old_uint(CategoriesLength0)
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < CategoriesLength0 && a == Categories0[j]) || (a == __verifier_old_uint(a))
     * @notice postcondition forall (uint8 j) !(0 <= j && j < CategoriesLength0 && CategoriesLength0 > 0) || (Categories0[j] == 1000) 
     */
    function foo() public {
        uint8 i = 0;
        require(CategoriesLength0 > 0);
        /**
          * @notice invariant forall (uint8 j) (j >= i || j < 0) || (Categories0[j] == 1000) 
          * @notice invariant !(i == CategoriesLength0) || (Categories0[i-1] == 1000)
          * @notice invariant forall (uint256 a) exists (uint8 j) (j < CategoriesLength0 && a == Categories0[j]) || (a == __verifier_old_uint(a))
       */
        for (i = 0; i < CategoriesLength0; i++) {
            //in each contract
            uint256 testeth = 1000;
            Categories0[i] = testeth; //reset votes
        }
    }
}