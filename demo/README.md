## A guide to demoing the contract

### Install dependencies

Before the first run, dependencies need to be installed for the test scripts and the status viewer.

```shell
npm install -g ganache-cli
npm install -g bower
npm install -g truffle
```

The demo has been tested to work with the following software versions:
* nodejs@v11.12.0
* ganache-cli@6.4.1
* bower@1.8.8
* truffle@5.0.9

```shell
cd demo/
npm install
```

```shell
cd demo/status
bower install
```

### Run a deterministic ganache-cli session

```shell
ganache-cli --deterministic --port 7545 --networkId 5777 --gasLimit 16000000
```


### Deploy the contract
In the project root, run:
```shell
rm -rf build/ && truffle migrate
```
### Run the taxable account creator script

```shell
cd demo/
node 0-createAccount.js
```

### Open the status view in browser

Open `demo/status/index.html` in browser.

### Fund the taxable account

```shell
cd demo/
node 1-fundAccount.js 15000
```
The account can be funded multiple times with various values.

### Change tax withholding percentage

```shell
cd demo/
node 2-setWithholdingPercentage.js 25
```

### End the tax period and resolve taxes

```shell
cd demo/
node 3-resolveTaxes.js
```

### Withdraw funds from a taxable account

```shell
cd demo/
node 4-sendFromTaxableAccount.js 123
```
