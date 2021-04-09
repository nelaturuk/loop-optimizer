contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 50;

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    address owner;
    address newOwner;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    uint transactionId;
    uint count;

    function removeOwner()
    {
        for (uint i=0; i< owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
            }
    }

    function replaceOwner()
    {

        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
            }
    }

    function isConfirmed()
    {
        for (uint i=0; i<owners.length; i++) {
            count += 1;
        }
    }
}