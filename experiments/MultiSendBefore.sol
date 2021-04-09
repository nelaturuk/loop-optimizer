contract multiSend{
    address public baseAddr = 0x500Df47E1dF0ef06039218dCF0960253D89D6658;
	uint public distributedAmount = 2001200;
    address[] addrs;

    function sendOutToken() public {
        for(uint i=0;i<addrs.length;i++){
            distributedAmount += 100;
        }
    }
}