pragma solidity ^0.4.17;

// Prototype of non delivery call option
contract Call_opt_naked{
    address public seller;
    address public buyer;
   
    uint public strike;
    string public underlying_ticker;
    //string private currency;
    uint public exp_date;
    uint public value;
    enum State { Created, Locked, Inactive }
    State public state;
    
    
    // Events that will be fired on changes.
    event exercise(address seller, address buyer, uint amount);
    event expired(address seller, address buyer,  uint amount);
    event Aborted();
    event TradeConfirmed();
   
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }
    
    modifier notExpired() {
        require(now <= exp_date);
        _;
    }
    
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    /// Offer the parice as a seller
    function Trade()
        public 
        // Revert the call if the expired
        onlySeller
        notExpired
        payable {
        seller = msg.sender;
        value = msg.value;
        }    
        
    /// Confirm the trade as a buer
        function confirmTrade()
        public
        inState(State.Created)
        condition(msg.value == value)
        onlyBuyer
        payable {
            //emit TradeConfirmed();
            buyer = msg.sender;
            buyer.transfer(value);
            seller.transfer(this.balance);
        }

}
