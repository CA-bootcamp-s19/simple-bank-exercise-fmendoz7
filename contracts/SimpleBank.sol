/*
    This exercise has been updated to use Solidity version 0.6.12
    Breaking changes from 0.5 to 0.6 can be found here: 
    https://solidity.readthedocs.io/en/v0.6.12/060-breaking-changes.html
*/

/*
    PROGRAMMER: Francis Mendoza
    EMAIL: fmendoz7@asu.edu
    ASSIGNMENT: Simple Bank Exercise
*/

pragma solidity ^0.6.12;

contract SimpleBank {

    // STATE VARIABLES
    /* [X] Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) private balances;
    
    /* [X] Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* [X] Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner;
/*----------------------------------------------------------------------------------------------------------------------------------------*/    
    // EVENTS - publicize actions to external listeners
    // NOTE: Events are important, as they are the only way to document state changes + debug state bugs 
    
    /* [X] Add an argument for this event, an accountAddress */
    //Index your addresses so you can keep track later! (Following input would be logged)
    event LogEnrolled(address indexed accountAddress);

    /* [X] Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(address indexed accountAddress, uint amount);

    /* [X] Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    // FUNCTIONS

    /* [X] Use the appropriate global variable to get the sender of the transaction */
    constructor() public {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is REVERTED if the contract fails (add balance to msg.sender)
    // otherwise, the sender's money is transferred to contract
    fallback() external payable {
        revert();
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    // [X]
    /// [X] @notice Get balance
    /// [X] @return The balance of the user
    // [X] A SPECIAL KEYWORD prevents function from editing state variables (NOT MODIFY STATE, view);
    // [X] allows function to run locally/off blockchain
    function getBalance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */
        return balances[msg.sender];
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    // [X]
    /// [X] @notice Enroll a customer with the bank
    /// [X] @return The users enrolled status
    // [X] Emit the appropriate event
    function enroll() public returns (bool){
        //NOTICE: Only triggers if the user was NOT enrolled before (false by default)
        require(enrolled[msg.sender] == false, "ERROR: User must haven not enrolled");
        enrolled[msg.sender] = true;

        //Do NOT need assert condition here. Wasteful, as burns up gas and simple emit will suffice
        // Use assert for more complex state changes
        //EMIT: Changed state, so emit LogEnrolled event
        emit LogEnrolled(msg.sender);

        //RETURN: Return enrolled status  
        return enrolled[msg.sender];
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // [X] Add the appropriate keyword so that this function can receive ether (payable)
    // [X] Use the appropriate global variables to get the transaction sender and value
    // [X] Emit the appropriate event    
    // [X] Users should be enrolled before they can make deposits
    function deposit() public payable returns (uint) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */
        require(enrolled[msg.sender], "ERROR: User is not enrolled into banking system");
        require(msg.value > 0, "ERROR: Deposit value must be a positive integer and greater than 0");
        balances[msg.sender] += msg.value;
        
        //EMIT event to log deposit (msg.value)
        emit LogDepositMade(msg.sender, msg.value);

        //Return balance of SENDER
        return balances[msg.sender];
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/

    /// @notice Withdraw ether from bank
    /// [X] @dev This does NOT RETURN any excess ether sent to it (handled by assert)
    /// [X] @param withdrawAmount amount you want to withdraw
    /// [X] @return The balance remaining for the user
    // Emit the appropriate event    
    function withdraw(uint withdrawAmount) public returns (uint) {
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw. 
           return the user's balance.*/

        //Require that user is enrolled, use assert to prevent withdrawal of nonexistent ether
        require(enrolled[msg.sender], "ERROR: User is not enrolled into banking system");
        require(balances[msg.sender] >= withdrawAmount, "ERROR: Insufficient funds for requested withdrawal");
        require(withdrawAmount > 0, "ERROR: Amount of Ether to withdraw MUST be a positive integer greater than 0");

        //Potential Attack: If withdrawals can be zero, can exhaust contract gas!

        //Pre-record pretransaction balance for extra-security check
        uint pretransactionBalance = balances[msg.sender];

        //Change state of user account (msg.sender), transfer Ether to sender account
        balances[msg.sender] -= withdrawAmount;
        msg.sender.transfer(withdrawAmount); 
        //Where to withdraw amount TO? Unless withdrawal is burning Ether..

        require(balances[msg.sender] < pretransactionBalance, "ERROR: Bug Detected. New amount MORE than previous amount");
        
        //EMIT: Withdrawal
        emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);

        //Return Balances
        return balances[msg.sender];
    }

}
