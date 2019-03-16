pragma solidity >=0.5.0 <0.6.0;

import './SafeMath.sol';

contract TaxableAccount {
    using SafeMath for uint256;

    EthTax controller;
    address public owner;
    uint256 public locked;
    uint256 public totalReceived;  // total amount received in the current period
    uint256 public totalWithheld;  // total amount withheld in the current period
    uint256 public withholdingPercent;

    constructor(EthTax _controller, address _owner, uint256 _initialWithholdingPercent) public {
        controller = _controller;
        owner = _owner;
        withholdingPercent = _initialWithholdingPercent;
        locked = 0;
        totalReceived = 0;
        totalWithheld = 0;
    }

    function () external payable {
        totalReceived += msg.value;
        uint256 amountToWithhold = msg.value * withholdingPercent / 100;
        locked += amountToWithhold;
        totalWithheld += amountToWithhold;
        controller.logTaxableTransaction(msg.sender, address(this), msg.value);
    }

    function send(address payable _receiver, uint256 _amount) external {
        require(msg.sender == owner);
        uint256 availableFunds = address(this).balance - locked;  // throws if negative available
        require(availableFunds >= _amount);

        _receiver.transfer(_amount);
    }

    function resolveTaxes(uint256 _newWithholdingPercent) external payable {
        require(msg.sender == controller.owner());
        require(msg.value == getReceivablesFromTaxOffice());
        require(_newWithholdingPercent < 100 && _newWithholdingPercent >= 0);

        // Handle the case where too much tax was withheld, and tax office returns it
        if (msg.value > 0) {
            locked = 0;
            totalReceived = 0;
            totalWithheld = 0;
            withholdingPercent = _newWithholdingPercent;
            return;
        }

        uint256 newLocked = locked + getExtraTaxToPay();
        uint256 payables;

        if (address(this).balance >= newLocked) {
            payables = newLocked;
            newLocked = 0;
        }
        else {
            payables = address(this).balance;
            newLocked -= address(this).balance;
        }

        locked = newLocked;
        totalReceived = 0;
        totalWithheld = 0;
        withholdingPercent = _newWithholdingPercent;
        controller.taxDestination().transfer(msg.value);
    }

    // Return the amount of taxes that still needs to be paid this period.
    function getExtraTaxToPay() private view returns (uint256) {
        uint256 taxToPay = controller.getTaxToPay(totalReceived);
        return taxToPay - totalWithheld;
    }

    // Get the amount that tax office owes this account
    function getReceivablesFromTaxOffice() public view returns (uint256) {
        uint256 taxToPay = controller.getTaxToPay(totalReceived);
        if (taxToPay > locked) {
            return 0;
        }
        return locked - taxToPay;
    }
}

contract EthTax {
    using SafeMath for uint256;

    address public owner;
    address payable public taxDestination;

    struct TaxBracket {
        uint256 maxAmount;
        uint256 taxPercent;
    }

    TaxBracket[] taxBrackets;
    uint256 public taxPercentAfterBrackets;

    event LogNewAccount(address receiver);
    event LogTaxableTransaction(address indexed from, address indexed to, uint256 amount);

    constructor() public {
        owner = msg.sender;
        taxDestination = msg.sender;

        taxBrackets.push(TaxBracket(15000, 10));
        taxBrackets.push(TaxBracket(10000, 25));
        taxBrackets.push(TaxBracket(45000, 50));
        taxPercentAfterBrackets = 55;
    }

    function makeAccount(address _owner, uint256 _initialWithholdingPercent)
        external returns (address account)
    {
        require(_initialWithholdingPercent < 100 && _initialWithholdingPercent >= 0);
        require(msg.sender == owner);
        account = address(new TaxableAccount(this, _owner, _initialWithholdingPercent));
        emit LogNewAccount(account);
    }

    function logTaxableTransaction(address _from, address _to, uint256 _amount) external {
        emit LogTaxableTransaction(_from, _to, _amount);
    }

    function getTaxToPay(uint256 _amount) external view returns (uint256) {
        uint256 taxToPay = 0;
        uint256 unprocessedAmount = _amount;

        for (uint256 i=0; i<taxBrackets.length; i++) {
            if (unprocessedAmount <= taxBrackets[i].maxAmount) {
                taxToPay += unprocessedAmount * taxBrackets[i].taxPercent / 100;
                return taxToPay;
            }
            else {
                taxToPay += taxBrackets[i].maxAmount * taxBrackets[i].taxPercent / 100;
                unprocessedAmount -= taxBrackets[i].maxAmount;
            }
        }

        taxToPay += unprocessedAmount * taxPercentAfterBrackets / 100;
        return taxToPay;
    }
}
