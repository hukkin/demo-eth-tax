const Common = require("./common.js");

if (typeof process.argv[2] === 'undefined') {
	console.log('ERROR: Specify the amount to transfer')
    process.exit(1);
}
let amount = parseInt(process.argv[2], 10);

let funder = Common.accounts.ethTaxOwner;
let accountToFund = Common.accounts['taxableAccounts'][0];

Common.web3.eth.sendTransaction({from: funder, to: accountToFund, value: amount});
console.log('Funded account with ' + amount + ' wei');
