pragma solidity >=0.5.0;
contract MappingWithIfAfter {
    uint24 public SmallContractsLength = 10;
    address public Creator; //addres of god
    mapping(uint24 => uint256) public smallContractsIncoming; //stores ether count per small contract

    /**
    * @notice modifies MappingWithIfAfter.smallContractsIncoming
    * @notice postcondition SmallContractsLength == __verifier_old_uint(SmallContractsLength)
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < SmallContractsLength && a == smallContractsIncoming[j]) || (a == __verifier_old_uint(a))
     * @notice postcondition forall (uint8 j) !(0 <= j && j < SmallContractsLength && msg.sender == Creator) || (smallContractsIncoming[j] == 0) || (smallContractsIncoming[j] < 0) 
     */
    function fooAfter() public {
        if (msg.sender == Creator) {
            uint256 rvariable = 0;
            uint24 initial = 0;
            uint24 loopcondition = SmallContractsLength;
            foo_for(rvariable, initial, loopcondition);
        }
    }

    /**
    * @notice modifies MappingWithIfAfter.smallContractsIncoming
    * @notice postcondition SmallContractsLength == __verifier_old_uint(SmallContractsLength)
    * @notice postcondition forall (uint8 j) !(0 <= j && j < loopcondition) || (smallContractsIncoming[j] == rvariable) || smallContractsIncoming[j] < 0 
     * @notice postcondition forall (uint256 a) exists (uint8 j) (j < loopcondition && a == smallContractsIncoming[j]) || (a == __verifier_old_uint(a))
     */
    function foo_for(
        uint256 rvariable,
        uint24 initial,
        uint24 loopcondition
    ) internal {
        require(loopcondition > 0);
        /**
          * @notice invariant forall (uint8 j) (j >= i || j < 0) || (smallContractsIncoming[j] == rvariable) || smallContractsIncoming[j] < 0 
          * @notice invariant !(i == loopcondition) || (smallContractsIncoming[i-1] == rvariable) || (smallContractsIncoming[i-1] < 0)
          * @notice invariant forall (uint256 a) exists (uint8 j) (j < loopcondition && a == smallContractsIncoming[j]) || (a == __verifier_old_uint(a))
       */
        for (uint24 i = initial; i < loopcondition; i++) {
            if (smallContractsIncoming[i] > 0) {
                smallContractsIncoming[i] = rvariable;
            }
        }
    }
}
