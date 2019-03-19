pragma solidity >=0.5.0 <0.6.0;

import './openzeppelin-solidity-2.2.0/contracts/math/SafeMath.sol';

contract TaxableAccount {
    using SafeMath for uint256;

    EthTax controller;
    address public owner;
    uint256 public locked;
    uint256 public totalReceived;  // total amount received in the current period
    uint256 public totalWithheld;  // total amount withheld in the current period
    uint256 public withholdingPercent;

    constructor(EthTax _controller, address _owner, uint256 _initialWithholdingPercent) public {
        require(_initialWithholdingPercent >= 0 && _initialWithholdingPercent < 100);

        controller = _controller;
        owner = _owner;
        locked = 0;
        totalReceived = 0;
        totalWithheld = 0;
        withholdingPercent = _initialWithholdingPercent;
    }

    function () external payable {
        totalReceived = totalReceived.add(msg.value);
        uint256 amountToWithhold = msg.value.mul(withholdingPercent).div(100);
        locked = locked.add(amountToWithhold);
        totalWithheld = totalWithheld.add(amountToWithhold);
        controller.logTaxableTransaction(msg.sender, address(this), msg.value);
    }

    function send(address payable _receiver, uint256 _amount) external {
        require(msg.sender == owner);
        uint256 availableFunds = address(this).balance.sub(locked);  // throws if negative available
        require(availableFunds >= _amount);

        // Send funds using .call.value(amount)("") instead of the reentrancy safe
        // .transfer(amount) so that we have enough gas to send to another taxable account.
        (bool success, bytes memory __data) = _receiver.call.value(_amount)("");
        (__data);  // Silence the compiler warning about unused local variable
        require(success);
    }

    function resolveTaxes() external payable {
        require(msg.sender == controller.owner());

        // Handle the case where too much tax was withheld, and tax office returns it
        if (isEnoughTaxLocked()) {
            // TODO: Bug. This can go negative. It is possible we pay too little taxes during period,
            // but we still have enough locked funds to pay everything.
            // Example steps:
            //   - node 1-fundAccount.js 1000
            //   - node 3-resolveTaxes.js
            //   - node 2-setWithholdingPercentage.js 1
            //   - node 1-fundAccount.js 1000
            //   - node 3-resolveTaxes.js
            // ---> ERROR
            uint256 extraTaxLocked = totalWithheld.sub(controller.getTaxToPay(totalReceived));
            locked = locked.sub(extraTaxLocked);
            totalReceived = 0;
            totalWithheld = 0;
            return;
        }

        uint256 newLocked = locked.add(getExtraTaxToPay());
        uint256 payables;

        if (address(this).balance >= newLocked) {
            payables = newLocked;
            newLocked = 0;
        }
        else {
            payables = address(this).balance;
            newLocked = newLocked.sub(address(this).balance);
        }

        locked = newLocked;
        totalReceived = 0;
        totalWithheld = 0;
        controller.taxDestination().transfer(payables);
    }

    function setWithholdingPercent(uint256 _withholdingPercent) external {
        require(msg.sender == controller.owner());
        require(_withholdingPercent >= 0 && _withholdingPercent < 100);

        withholdingPercent = _withholdingPercent;
    }

    // Return the amount of taxes that still needs to be paid this period.
    function getExtraTaxToPay() private view returns (uint256) {
        uint256 taxToPay = controller.getTaxToPay(totalReceived);
        return taxToPay.sub(totalWithheld);
    }

    function isEnoughTaxLocked() private view returns (bool) {
        uint256 taxToPay = controller.getTaxToPay(totalReceived);
        if (taxToPay > locked) {
            return false;
        }
        return true;
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
                taxToPay = taxToPay.add(unprocessedAmount.mul(taxBrackets[i].taxPercent).div(100));
                return taxToPay;
            }
            else {
                taxToPay = taxToPay.add(taxBrackets[i].maxAmount.mul(taxBrackets[i].taxPercent).div(100));
                unprocessedAmount = unprocessedAmount.sub(taxBrackets[i].maxAmount);
            }
        }

        taxToPay = taxToPay.add(unprocessedAmount.mul(taxPercentAfterBrackets).div(100));
        return taxToPay;
    }
}
