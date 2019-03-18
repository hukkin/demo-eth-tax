const Common = require("./common.js");

if (typeof process.argv[2] === 'undefined') {
	console.log('ERROR: Specify new withholding percentage as argument');
    process.exit(1);
}
let newWithholdingPercent = parseInt(process.argv[2], 10);

Common.taxableAccount.setWithholdingPercent(newWithholdingPercent, {from: Common.accounts.ethTaxOwner, gas: 100000});
console.log('Set withholding percentage to ' + newWithholdingPercent);
