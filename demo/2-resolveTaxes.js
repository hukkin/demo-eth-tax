const Common = require("./common.js");

let newWithholdingPercent;
if (typeof process.argv[2] === 'undefined') {
	newWithholdingPercent = 15;
	console.log('Withholding percent not specified. Defaulting to ' + newWithholdingPercent)
}
else {
	newWithholdingPercent = parseInt(process.argv[2], 10);
}

value = Common.taxableAccount.getReceivablesFromTaxOffice();
console.log('Refunding ' + value);
Common.taxableAccount.resolveTaxes(newWithholdingPercent, {from: Common.accounts.ethTaxOwner, gas: 15500000, value: value});
