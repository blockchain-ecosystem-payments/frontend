pragma solidity ^0.5.0;
import "https://github.com/provable-things/ethereum-api/oraclizeAPI_0.5.sol";

// Contract PaymentForEcosystemService is a child of contract usingOraclize to include Oraclize API
contract PaymentForEcosystemServices is usingOraclize {
    
    // Define general state variables
    uint constant public PES_amount = 0.5 ether;
    address payable constant PES_buyer = 0xEEF8Acd8C3530f28b61549fA5012E0A462E8A67F;
    address payable constant PES_seller = 0x885E7dcC139eAcab9B981eCB6A0bA8418A10aCc7;
    
    mapping (uint => bool) monthonce;
    mapping (bytes32 => uint) monthquery;
    
    uint[5] months_lcc  = [14, 13, 11, 0, 0] ;
    uint[5] months_ts = [1561935600, 1564520400, 1567198800, 1569877200, 1572472800] ;


    
    // Initialize PES payment
    function initPES (uint _month) public payable {
        if(msg.sender != PES_buyer) revert();
        if(_month != 6 &&  _month != 7 &&  _month != 8 &&  _month != 9 &&  _month != 10) revert();
        if(monthonce[_month] == true) revert();
        
        bytes32 queryID = oraclize_query(months_ts[_month - 6], "computation", ["QmdcTduyJVa3k5RBv8sEMHzbpbSQGkdrmKysa6TwrGaGWy"]);
            
        monthquery[queryID] = _month;
        monthonce[_month] = true;
    }
    
    
    
    // Oraclize callback function
    function __callback(bytes32 _myid, string memory _result) public {
        if(msg.sender != oraclize_cbAddress()) revert();
        months_lcc[monthquery[_myid] - 6] = parseInt(_result);
        transferPES(parseInt(_result));
    }
    
    
    
    //Executing the payment
    function transferPES (uint _lcc) internal {
        if (_lcc <= 15) {
            PES_seller.transfer(PES_amount);
        }
    }
    
    
    
    // Get balance for display on frontend
    function getBalance () view public returns(uint) {
        return address(this).balance;
    }
    
    
    
    // Get LCC for display on frontend
    function getLCC (uint _month) view public returns(uint) {
        if(_month != 6 &&  _month != 7 &&  _month != 8 &&  _month != 9 &&  _month != 10) revert();
        return months_lcc[_month - 6];
    }
    
    
    
    // Get TS for display on frontend
    function getTSS (uint _month) view public returns(uint) {
        if(_month != 6 &&  _month != 7 &&  _month != 8 &&  _month != 9 &&  _month != 10) revert();
        return months_ts[_month - 6];
    }

    

    // Deposit donation
    function deposit() payable public {
    }
    
}
