const Common = require("./common.js");

Common.taxableAccount.resolveTaxes({from: Common.accounts.ethTaxOwner, gas: 15500000});
console.log('Taxes resolved');
