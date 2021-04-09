contract multiSend{
    address public baseAddr = 0x500Df47E1dF0ef06039218dCF0960253D89D6658;
	uint public distributedAmount = 2001200;
    address[] addrs;

    function sendOutToken() public {
    uint initial = 0;
    uint initialSum = distributedAmount; 
    uint loopcondition = addrs.length;
    distributedAmount = sendOutToken_for(initial, initialSum, loopcondition);
  }
  function sendOutToken_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + 100;
    }
    return temp_total;
  } 
}