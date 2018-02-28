pragma solidity ^0.4.17;

// Prototype of non delivery call option
contract Call_opt_naked{
    address public seller;
    address public buyer;
    //mapping (uint => uint) opt_parameter;
    uint current_underl_price = 120;
    uint private strike = 100;
    string private underlying_ticker = 'AAPL';
    //string private currency;
    uint public exp_days = 30;
    uint public start_date = block.timestamp;
    uint public premium_value;
    uint public margin;
    uint exp_price = 80;
    uint public profit_loss;
    
    enum State { Created, Locked, Inactive }
    State public state;

    modifier inState(State _state) {
            require(state == _state);
            _;
        }
    modifier condition(bool _condition) {
            require(_condition);
            _;
        }
        
    function Offer(uint x)
        public
        condition(msg.value >= current_underl_price*1 ether)
        payable
        {
        margin = msg.value;
        seller = msg.sender;
        state = State.Created;    
        premium_value = x * 1 ether;
        
        }
        
    function abort()
        public
        condition(msg.sender == seller)
        inState(State.Created)
        {
        state = State.Inactive;
        seller.transfer(this.balance);
        }    
        
    /// Offer the parice as a seller
    function Trade()
        public
        condition(msg.sender != seller)
        inState(State.Created)
        condition(msg.value == premium_value)
        payable
        {
        buyer = msg.sender;
        seller.transfer(premium_value);
        state = State.Locked;
        }
    
    function Expiration()
        public
        inState(State.Locked)
        condition(now >= start_date + exp_days*1 days)
        payable
        {
        profit_loss = strike*1 ether - exp_price*1 ether;
        buyer.transfer(profit_loss);
        seller.transfer(this.balance);
        state = State.Inactive;
        }
    


    function get_strike() public view returns (uint) {
    return strike;
      	}
    function get_underl() public view returns (string) {
    return underlying_ticker;
      	}
    function get_exp() public view returns (uint) {
    return exp_days;
        }
    function get_value() public view returns (uint) {
    return premium_value;
        }
    function get_seller() public view returns (address) {
    return seller;
        }

}

