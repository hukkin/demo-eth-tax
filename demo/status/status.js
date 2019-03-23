if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
} else {
    // set the provider you want from Web3.providers
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
}

let taxableAccounts = [];
let otherBalances = [];
otherBalances.push({identity: 'Tax office', address: web3.eth.accounts[0], balance: 'unknown'})
otherBalances.push({identity: 'Taxable account owner', address: web3.eth.accounts[1], balance: 'unknown'})

var taxablesDynatable = $('#taxableAccounts').dynatable().data('dynatable');
var othersDynatable = $('#otherBalances').dynatable().data('dynatable');

ethTax = web3.eth.contract(ethTaxAbi).at(ethTaxAddress);

function getAllAccountData(address) {
    return Promise.all([
        getTotalReceived(address),
        getTotalWithheld(address),
        getLocked(address),
        getWithholdingPercent(address),
        getBalance(address)
        ]);
}

let getTotalReceived = (address) => {
    let web3Account = web3.eth.contract(taxableAccountAbi).at(address);
    return new Promise(
        (resolve, reject) => {
            web3Account.totalReceived.call(function(error, result) {
                if (error) reject(error);
                resolve(result);
            })
        }
    );
};
let getTotalWithheld = (address) => {
    let web3Account = web3.eth.contract(taxableAccountAbi).at(address);
    return new Promise(
        (resolve, reject) => {
            web3Account.totalWithheld.call(function(error, result) {
                if (error) reject(error);
                resolve(result);
            })
        }
    );
};
let getLocked = (address) => {
    let web3Account = web3.eth.contract(taxableAccountAbi).at(address);
    return new Promise(
        (resolve, reject) => {
            web3Account.locked.call(function(error, result) {
                if (error) reject(error);
                resolve(result);
            })
        }
    );
};
let getWithholdingPercent = (address) => {
    let web3Account = web3.eth.contract(taxableAccountAbi).at(address);
    return new Promise(
        (resolve, reject) => {
            web3Account.withholdingPercent.call(function(error, result) {
                if (error) reject(error);
                resolve(result);
            })
        }
    );
};
let getBalance = (address) => {
    return new Promise(
        (resolve, reject) => {
            web3.eth.getBalance(address, function(error, result) {
                if (error) reject(error);
                console.log("Got balance " + result + " for address " + address);
                resolve(result);
            })
        }
    );
};

ethTax.LogTaxableTransaction().watch(function(error, result) {
    if (!error) {
        console.log('Taxable transaction occured');
    } else {console.log("error");}
});

ethTax.LogNewAccount().watch(function(error, result) {
    if (!error) {
        console.log('New taxable account created');
        let newAccount = result.args;
        newAccount.address = newAccount.receiver;

        getAllAccountData(newAccount.address).then(([totalReceived, totalWithheld, locked, withholdingPercent, balance]) => {
            newAccount.fundsReceivedThisPeriod = totalReceived;
            newAccount.fundsWithheldThisPeriod = totalWithheld;
            newAccount.lockedBalance = locked;
            newAccount.withholdingPercent = withholdingPercent;
            newAccount.balance = balance;
            newAccount.spendableBalance = balance - locked;
            taxableAccounts.push(newAccount);
            updateDynatable(taxablesDynatable, taxableAccounts);
        });
    } else {console.log("error");}
});

function updateTaxablesTable() {
    taxableAccounts.forEach(function(account, index, theArray) {
        getAllAccountData(account.address).then(([totalReceived, totalWithheld, locked, withholdingPercent, balance]) => {
            account.fundsReceivedThisPeriod = totalReceived;
            account.fundsWithheldThisPeriod = totalWithheld;
            account.lockedBalance = locked;
            account.withholdingPercent = withholdingPercent;
            account.balance = balance;
            account.spendableBalance = balance - locked;
            theArray[index] = account;
        });
    });
    console.log("Updating dynatable");
    updateDynatable(taxablesDynatable, taxableAccounts);
}

function updateOtherBalancesTable() {
    otherBalances.forEach(function(account, index, theArray) {
        getBalance(account.address).then((balance) => {
            account.balance = balance;
            theArray[index] = account;
        });
    });
    console.log("Updating other balances dynatable");
    updateDynatable(othersDynatable, otherBalances);
}

const taxablesTableUpdater = setInterval(updateTaxablesTable, 3000);
const othersTableUpdater = setInterval(updateOtherBalancesTable, 3000);


function updateDynatable(table, content) {
    table.settings.dataset.originalRecords = content;
    table.process();
}
