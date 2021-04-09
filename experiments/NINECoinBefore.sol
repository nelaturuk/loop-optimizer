contract NINECOIN  {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;
     uint256[] _amount;
     uint256 sum;

    function batchTransfer() {
        for(uint256 i = 0; i < _amount.length; i++) { 
            sum = sum + _amount[i]; 
        }
    }
}