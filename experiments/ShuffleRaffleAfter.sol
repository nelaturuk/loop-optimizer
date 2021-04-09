contract ShuffleRaffle {
    using SafeMath for uint256;
    
    struct Order {
        uint48 position;
        uint48 size;
        address owner;
    }
    
    mapping(uint256 => Order[]) TicketBook;
    uint256 public RaffleNo = 1;
    uint256 public TicketPrice = 5*10**18;
    uint256 public PickerReward = 5*10**18;
    uint256 public minTickets = 9;
    uint256 public nextTicketPrice = 5*10**18;
    uint256 public nextPickerReward = 5*10**18;
    uint256 public nextminTickets = 9;
    uint256 public NextRaffle = 1574197200;
    uint256 public random_seed = 0;
    bool    public raffle_closed = false;
    uint256 _tt=0;
    address addr;
    uint RaffleNo;
    function TicketsOfAddress() public {
    uint initial = 0;
    uint initialSum = _tt; 
    uint loopcondition = TicketBook[RaffleNo].length;
    _tt = TicketsOfAddress_for(initial, initialSum, loopcondition);
  }
  function TicketsOfAddress_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
        if (TicketBook[RaffleNo][i].owner == addr)
            temp_total = temp_total + TicketBook[RaffleNo][i].size;
    }
    return temp_total;
  }  
}