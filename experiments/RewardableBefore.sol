contract Rewardable is Ownable {
    struct Payment {
        uint amount; 
        uint members;
    }

    uint public all_members;
    uint public to_repayment;
    uint public last_repayment = block.timestamp;

    Payment[] private repayments;

    mapping(address => bool) public members;
    mapping(address => uint) private rewards;

    function availableRewards(address _addr) public view returns(uint sum) {
        for(uint i = rewards[_addr]; i < repayments.length; i++) {
            sum += repayments[i].amount;
        }
    }
}