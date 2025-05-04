// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title SimulatedTransactions
 * @dev A smart contract to simulate cryptocurrency transactions without using real ETH with basic security features added
 */
contract SimulatedTransactions {
    address public owner;
    
    // Track simulated balances
    mapping(address => uint256) public simulatedBalances;
    
    event SimulatedTransaction(address indexed from, address indexed to, uint256 amount, string transactionType);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event TransactionLimitChanged(uint256 oldLimit, uint256 newLimit);
    
    bool private locked;
    uint256 public transactionLimit = 1000;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "Reentrancy protection: contract is locked");
        locked = true;
        _;
        locked = false;
    }
    
    modifier belowTransactionLimit(uint256 _amount) {
        require(_amount <= transactionLimit, "Amount exceeds transaction limit");
        _;
    }
    
    modifier hasEnoughBalance(uint256 _amount) {
        require(simulatedBalances[msg.sender] >= _amount, "Insufficient simulated balance");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        // Give the owner some initial balance for testing
        simulatedBalances[msg.sender] = 10000;
    }
    
    // Both functions would reject real ETH transfers
    receive() external payable {
        revert("No real ETH please! - this is all fake :(");
    }
    
    fallback() external payable {
        revert("No real ETH please! - this is all fake :(");
    }
    
    // Owner management function
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Cannot transfer to zero address");
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnerChanged(oldOwner, _newOwner);
    }
    
    function setTransactionLimit(uint256 _newLimit) public onlyOwner {
        uint256 oldLimit = transactionLimit;
        transactionLimit = _newLimit;
        emit TransactionLimitChanged(oldLimit, _newLimit);
    }
    
    // Simulate ETH minting (like getting ETH from a faucet)
    function mintSimulatedEther(uint256 _amount) public nonReentrant belowTransactionLimit(_amount) {
        require(_amount > 0, "Amount must be greater than 0");
        simulatedBalances[msg.sender] += _amount;
        emit SimulatedTransaction(address(0), msg.sender, _amount, "Mint");
    }
    
    // For owner to grant simulated ETH to users
    function grantSimulatedEther(address _to, uint256 _amount) public onlyOwner nonReentrant belowTransactionLimit(_amount) {
        require(_to != address(0), "Cannot grant to zero address");
        require(_amount > 0, "Amount must be greater than 0");
        
        simulatedBalances[_to] += _amount;
        emit SimulatedTransaction(address(this), _to, _amount, "Grant");
    }
    
    // Simulate ETH transfer between accounts
    function transferSimulatedEther(address _to, uint256 _amount) public nonReentrant hasEnoughBalance(_amount) belowTransactionLimit(_amount) {
        require(_to != address(0), "Cannot send to zero address");
        require(_to != msg.sender, "Cannot send to yourself");
        require(_amount > 0, "Amount must be greater than 0");
        
        simulatedBalances[msg.sender] -= _amount;
        simulatedBalances[_to] += _amount;
        
        emit SimulatedTransaction(msg.sender, _to, _amount, "Transfer");
    }
    
    // Simulate burning ETH
    function burnSimulatedEther(uint256 _amount) public nonReentrant hasEnoughBalance(_amount) belowTransactionLimit(_amount) {
        require(_amount > 0, "Amount must be greater than 0");
        
        simulatedBalances[msg.sender] -= _amount;
        emit SimulatedTransaction(msg.sender, address(0), _amount, "Burn");
    }
    
    function checkSimulatedBalance(address _user) public view returns (uint256) {
        return simulatedBalances[_user];
    }
    
    function resetSimulatedBalance(address _user) public onlyOwner {
        simulatedBalances[_user] = 0;
        emit SimulatedTransaction(_user, address(0), simulatedBalances[_user], "Reset");
    }
}