pragma solidity >=0.5.0;

contract IfCheckBefore {
    uint8 CategoriesLength0 = 10;
    mapping(uint8 => uint256) Categories0; //array representation

    address public Creator0; //addres of god

    /**
     * @notice modifies IfCheckBefore.Categories0
     * @notice postcondition CategoriesLength0 == __verifier_old_uint(CategoriesLength0)
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < CategoriesLength0 && a == Categories0[j]) || (a == __verifier_old_uint(a))
     * @notice postcondition forall (uint8 j) !(0 <= j && j < CategoriesLength0 && CategoriesLength0 > 0 && msg.sender == Creator0) || (Categories0[j] == 0)
     */
    function foo() public {
        if (msg.sender == Creator0) {
            uint8 i = 0;
            require(CategoriesLength0 > 0);
            /**
             * @notice invariant forall (uint8 j) (j >= i || j < 0) || (Categories0[j] == 0)
             * @notice invariant !(i == CategoriesLength0) || (Categories0[i-1] == 0)
             * @notice invariant forall (uint256 a) exists (uint8 j) (j < CategoriesLength0 && a == Categories0[j]) || (a == __verifier_old_uint(a))
             */
            for (i = 0; i < CategoriesLength0; i++) {
                //in each contract
                Categories0[i] = 0; //reset votes
            }
        }
    }
}
