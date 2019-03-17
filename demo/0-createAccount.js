const Common = require("./common.js");

Common.ethTax.makeAccount(Common.accounts.accountOwners[0], 15, {from: Common.accounts.ethTaxOwner, gas: 3000000});
