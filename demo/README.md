## A guide to demoing the contract

### Install dependencies

Before the first run, dependencies need to be installed for the test scripts and the status viewer.

```shell
npm install -g ganache-cli
npm install -g bower
```

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
truffle migrate
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

### End the tax period and resolve taxes

```shell
cd demo/
node 2-resolveTaxes.js
```
