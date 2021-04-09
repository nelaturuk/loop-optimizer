pragma solidity >=0.5.0;
contract MappingWithIfBefore {
    
    uint24 public SmallContractsLength0=10; 
    address public Creator0;//addres of god
    mapping(uint24=> uint) public smallContractsIncoming0;//stores ether count per small contract
    
    /**
     * @notice modifies MappingWithIfBefore.smallContractsIncoming0
     * @notice postcondition SmallContractsLength0 == __verifier_old_uint(SmallContractsLength0)
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < SmallContractsLength0 && a == smallContractsIncoming0[j]) || (a == __verifier_old_uint(a))
     * @notice postcondition forall (uint8 j) !(0 <= j && j < SmallContractsLength0 && SmallContractsLength0 > 0 && msg.sender == Creator0) || (smallContractsIncoming0[j] == 0) || (smallContractsIncoming0[j] < 0)
     */
    function foo() public {
        if(msg.sender==Creator0) { 
            uint24 i = 0;
            require(SmallContractsLength0 > 0);
            /**
             * @notice invariant forall (uint8 j) (j >= i || j < 0) || (smallContractsIncoming0[j] == 0) || smallContractsIncoming0[j] < 0 
             * @notice invariant !(i == SmallContractsLength0) || (smallContractsIncoming0[i-1] == 0) || (smallContractsIncoming0[i-1] < 0)
             * @notice invariant forall (uint256 a) exists (uint8 j) (j < SmallContractsLength0 && a == smallContractsIncoming0[j]) || (a == __verifier_old_uint(a))
             */
            for (i = 0;i < SmallContractsLength0;i++){
                if(smallContractsIncoming0[i] > 0 ){//if more than 0.005 ether
                    smallContractsIncoming0[i]=0;
                }
            }
        }
    }
}