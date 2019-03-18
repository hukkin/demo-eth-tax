const Common = require("./common.js");

if (typeof process.argv[2] === 'undefined') {
	console.log('ERROR: Specify the amount to transfer')
    process.exit(1);
}
let amount = parseInt(process.argv[2], 10);

Common.web3.eth.sendTransaction({from: Common.accounts.ethTaxOwner, to: Common.taxableAccountAddress, value: amount});
console.log('Funded account with ' + amount + ' wei');
