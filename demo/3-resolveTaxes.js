const Common = require("./common.js");

value = Common.taxableAccount.getReceivablesFromTaxOffice();
Common.taxableAccount.resolveTaxes({from: Common.accounts.ethTaxOwner, gas: 15500000, value: value});
console.log('Refunded ' + value + ' wei');
