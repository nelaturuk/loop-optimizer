contract DividendManagerBefore {
    struct Dividend {
        uint256 blockNumber;
        uint256 timestamp;
        uint256 amount;
        uint256 claimedAmount;
        uint256 totalSupply;
        bool recycled;
        mapping (address => bool) claimed;
    }

    Dividend[] public dividends;

    mapping (address => uint256) dividendsClaimed;

    struct NotClaimed {
        uint listIndex;
        bool exists;
    }

    mapping (address => NotClaimed) public notClaimed;
    NotClaimed[] public notClaimedList;
    uint256 currentSupply;

    /**
     * @notice modifies DividendManagerBefore.currentSupply
     * @notice postcondition currentSupply >= __verifier_old_uint(currentSupply)
     * @notice postcondition currentSupply == __verifier_old_uint(currentSupply) + __verifier_sum_uint(notClaimedList.listIndex)
     */
    function depositDividend() payable public {
        uint256 i = 0;
        require(notClaimedList.length > 0);
        /**
         * @notice invariant fullAmount >= __verifier_old_uint(fullAmount)
         * @notice invariant fullAmount == __verifier_old_uint(fullAmount) + sum(notClaimedList[0].listIndex ... notClaimedList[i].listIndex)
         */
        for(i = 0; i < notClaimedList.length; i++) {
            currentSupply = currentSupply + notClaimedList[i].listIndex;
        }
    }

     /**
     * @notice modifies DividendManagerBefore.dividendsClaimed
     * @notice postcondition dividends.length == __verifier_old_uint(dividends.length)
     * @notice postcondition forall (address a) exists (uint j) (j < dividends.length) || (dividendsClaimed[msg.sender] == __verifier_old_uint(dividendsClaimed[msg.sender]))
     */
    function claimDividendAll() public {
        uint256 i = 0;
        require(dividends.length > 0);
        /**
         * @notice invariant !(i == dividends.length) || (dividendsClaimed[msg.sender] == i + 1)
         * @notice invariant forall (address a) exists (uint j) (j < dividends.length) || (dividendsClaimed[msg.sender] == __verifier_old_uint(dividendsClaimed[msg.sender]))
         */
        for (i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
            dividendsClaimed[msg.sender] = i + 1;
        }
    }
}