const Common = require("./common.js");

let withholdingPercent;
if (typeof process.argv[2] === 'undefined') {
	withholdingPercent = 15;
	console.log('Initial withholding percent not specified. Defaulting to ' + withholdingPercent);
}
else {
	withholdingPercent = parseInt(process.argv[2], 10);
}

Common.ethTax.makeAccount(Common.accounts.accountOwners[0], withholdingPercent, {from: Common.accounts.ethTaxOwner, gas: 3000000});
console.log('New taxable account created');
