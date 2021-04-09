contract InfinestEthPublisher
{
    address public _owner;
    mapping(address => bool) public _approved;
  uint256[] _amountList;
    uint256 balance = 0;
     uint256 sumOfBalances = 0;

    function drop() 
    {
        for(uint256 i=0; i<_amountList.length; i++)
        {
            sumOfBalances = sumOfBalances + _amountList[i];
        }
    }
}