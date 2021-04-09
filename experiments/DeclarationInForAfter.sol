pragma solidity >=0.5.0;

contract DeclarationInForAfter {
    uint8 CategoriesLength = 10;
    mapping(uint8 => uint256) Categories; 

    /**
    * @notice modifies DeclarationInForAfter.Categories
    * @notice postcondition CategoriesLength == __verifier_old_uint(CategoriesLength)
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < CategoriesLength && a == Categories[j]) || (a == __verifier_old_uint(a))
     * @notice postcondition forall (uint8 j) !(0 <= j && j < CategoriesLength) || (Categories[j] == 1000) 
     */
    function fooAfter() public {
        uint256 testeth = 1000;
        uint256 rvariable = testeth;
        uint8 initial = 0;
        uint8 loopcondition = CategoriesLength;
        foo_for(rvariable, initial, loopcondition);
    }

    /**
    * @notice modifies DeclarationInForAfter.Categories
    * @notice postcondition CategoriesLength == __verifier_old_uint(CategoriesLength)
    * @notice postcondition forall (uint8 j) !(0 <= j && j < loopcondition) || (Categories[j] == rvariable) 
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < loopcondition && a == Categories[j]) || (a == __verifier_old_uint(a))
     */
    function foo_for(
        uint256 rvariable,
        uint8 initial,
        uint8 loopcondition
    ) internal {
        require(loopcondition > 0);
        /**
          * @notice invariant forall (uint8 j) (j >= i || j < 0) || (Categories[j] == rvariable) 
          * @notice invariant !(i == loopcondition) || (Categories[i-1] == rvariable)
          * @notice invariant forall (uint256 a) exists (uint8 j) (j < loopcondition && a == Categories[j]) || (a == __verifier_old_uint(a))
       */
        for (uint8 i = initial; i < loopcondition; i++) {
            Categories[i] = rvariable;
        }
    }
}
