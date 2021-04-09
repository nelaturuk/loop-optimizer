contract DividendManagerAfter {
    struct Dividend {
        uint256 blockNumber;
        uint256 timestamp;
        uint256 amount;
        uint256 claimedAmount;
        uint256 totalSupply;
        bool recycled;
        mapping(address => bool) claimed;
    }

    Dividend[] public dividends0;

    mapping(address => uint256) dividendsClaimed;

    struct NotClaimed {
        uint256 listIndex;
        bool exists;
    }

    mapping(address => NotClaimed) public notClaimed0;
    NotClaimed[] public notClaimedList0;
    uint256 currentSupply0;

    /**
     * @notice modifies DividendManagerAfter.currentSupply0
     * @notice postcondition currentSupply0 >= __verifier_old_uint(currentSupply0)
     * @notice postcondition currentSupply0 == __verifier_old_uint(currentSupply0) + __verifier_sum_uint(notClaimedList0.listIndex)
     */
    function depositDividend0() public {
        uint256 initial = 0;
        uint256 initialSum = currentSupply0;
        uint256 loopcondition = notClaimedList0.length;
        currentSupply0 = depositDividend_for(initial, initialSum, loopcondition);
    }

    /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != notClaimedList0.length || initial != 0 || val == initialSum + __verifier_sum_uint(notClaimedList0.listIndex)
     */
    function depositDividend_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 temp_total = initialSum;
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(notClaimedList0[0].listIndex ... notClaimedList0[i].listIndex)
         */
        for (uint256 i = initial; i < loopcondition; i++) {
            temp_total = temp_total + notClaimedList0[i].listIndex;
        }
        return temp_total;
    }

    /**
     * @notice modifies DividendManagerBefore.dividendsClaimed
     * @notice postcondition dividends0.length == __verifier_old_uint(dividends0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < dividends0.length) || (dividendsClaimed[msg.sender] == __verifier_old_uint(dividendsClaimed[msg.sender]))
     */
    function claimDividendAll0() public {
        uint256 initial = dividendsClaimed[msg.sender];
        uint256 initialSum = 0;
        uint256 loopcondition = dividends0.length;
        dividendsClaimed[msg.sender] = claimDividendAll_for(
            initial,
            initialSum,
            loopcondition
        );
    }

    function claimDividendAll_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 temp_total = initialSum;
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant !(i == loopcondition) || (temp_total == i + 1)
         * @notice invariant forall (address a) exists (uint j) (j < loopcondition) || (temp_total == __verifier_old_uint(temp_total))
         */
        for (i = initial; i < loopcondition; i++) {
            temp_total = i + 1;
        }
        return temp_total;
    }
}
