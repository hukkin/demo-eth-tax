# Ethereum Taxable Accounts Demo

## Overview

The tax office creates a master smart contract. This contract sets the tax brackets for progressive taxation and defines the destination of tax payments. It is also used to generate taxable accounts.

Taxable accounts:
* hold taxable entity's funds
* store the tax withholding percentage of the taxable entity
* withhold tax when receiving funds
* does not allow taxable entity to withdraw more than `balance - withheld balance` amount of funds

At the end of a tax period, tax office creates a transaction to each taxable account that resolves the final tax percentage for that account and refunds or withholds tax accordingly.
