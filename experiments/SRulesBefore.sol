contract SRules {

    struct Client {
        bool isExist;
        uint id;
        address addr;
        uint referrerID;
        string status;
        uint256 createdOn;
        string inviteCode;
    }

    mapping (address => Client) public clients;
    mapping (uint => address) private clientList;
    uint private currClientID = 10000;
    uint private ownerID = 0;

    mapping(string => address) private codeMapping;

    struct TreeSponsor {
        uint clientID;
        uint uplineID;
        uint level;
    }
    mapping (uint => TreeSponsor) public treeSponsors;
    mapping (uint => uint[] ) public sponsorDownlines;

    struct Portfolio {
        uint id;
        uint clientID;
        uint256 amount;
        uint256 bonusValue;
        uint256 withdrawAmt;
        // uint referenceNo;
        // uint trnxHash;
        string status;
        uint256 createdOn;
        uint256 updatedOn;
    }
    mapping (uint => Portfolio) public portfolios;
    mapping (uint => uint[]) private clientPortfolios;
    mapping (uint => uint256) public clientBV;
    mapping (uint => uint256) public cacheClientBV;
    mapping (uint => uint256) public rebate2Client;

    uint private clientBonusCount = 0;
    uint private portfolioID = 0;
    uint256 private minReentryValue = 1;
    uint256 private maxReentryValue = 500;


    struct WalletDetail {
        uint percentage;
        address payable toWallet;
    }
    mapping (uint => WalletDetail) public walletDetails;
    uint private walletDetailsCount = 0;
    mapping (uint => uint256) public poolBalance;
    address payable defaultGasAddr = 0x0B6593C16CecC4407FE9f4727ceE367327EF4779;

    struct WithdrawalDetail {
        uint minDay;
        uint charges;
    }
    mapping (uint => WithdrawalDetail) public withdrawalDetails;

    struct RebateSetting{
        uint max;
        uint min;
        uint percent;
    }
    mapping (uint => RebateSetting) public rebateSettings;
    uint private rebateSettingsCount = 0;
    uint public rebateDisplay = 0.33 * 100;

    uint private prevRebatePercent = 0;
    uint public defaultRebatePercent = 0.33 * 100;
    uint public defaultRebateDays = 21;
    uint public rebateDays = 1;
    uint public lowestRebateFlag = 0;

    mapping (uint => uint) public clientGoldmine;
    mapping (uint => uint) public goldmineSettingsPer;
    mapping (uint => uint) public goldmineDownlineSet;

    uint private maxGoldmineLevel = 50;

    uint256 public totalSales = 0;
    uint256 public totalPayout = 0;

    uint256 public cacheTotalSales = 0;
    uint256 public cacheTotalPayout = 0;
    uint256 transferAmount = 1;
    uint start; 
    uint end;
    uint downlineCounts = 0;

    function initpoolBalance() public {

        for(uint i = 1; i <= walletDetailsCount;i++){
            poolBalance[i] = 0;
        }
    }

    function distSales () private {
        for(uint i = 1; i <= walletDetailsCount;i++){
            
            transferAmount = transferAmount * walletDetails[i].percentage;
        }
    }
}