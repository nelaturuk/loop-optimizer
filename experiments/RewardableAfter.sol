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
    uint sum;
    address _addr;
    function availableRewards() public {
    uint initial = rewards[_addr];
    uint initialSum = sum; 
    uint loopcondition = repayments.length;
    sum = availableRewards_for(initial, initialSum, loopcondition);
  }
  function availableRewards_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + repayments[i].amount;
    }
    return temp_total;
  }  
}