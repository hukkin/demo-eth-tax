const Common = require("./common.js");

if (typeof process.argv[2] === 'undefined') {
	console.log('ERROR: Specify the amount to be sent');
    process.exit(1);
}
let amount = parseInt(process.argv[2], 10);

let accountOwner = Common.accounts.accountOwners[0];
let receiver = Common.accounts.accountOwners[0];

Common.taxableAccount.send(receiver, amount, {from: accountOwner, gas: 100000});
console.log('Sent ' + amount + ' wei to ' + receiver);
