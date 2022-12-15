# Autonomous proposal
## Why?
Delegating proposition power to a smart contract instead of wallet address gives ultimate transparency to how the proposition power would be used and what the created proposal body will be.

## The flow
An Autonomous proposal must implement 2 methods
- _create()_: This method can be called by anyone when enough people delegate proposition power to the contract.
- _vote()_: This method can be called by anyone once the proposal has been created. This method will use any voting power delegated to this contract to vote.

## Simple Autonomous Proposal
[SimpleAutonomousProposal](/src/contracts/SimpleAutonomousProposal.sol): Using this contract, it can be able to generate a simple autonomous proposal, by just supplying
a few params on constructor.

![Autonomous proposal scheme][image-1]

## How to use?
[AutonomousProposal](/src/contracts/AutonomousProposal.sol) - is an abstract smart contract. Which should be extended, providing the implementation for the methods:
- `create()`
- `vote()`

Keep in mind that the `create()` should have the constraint that once proposals are created, it should not be callable again (to not duplicate proposals).

## Use case
**Creating proposals for LONG executor**
On AAVE Governance, there are 2 types of executors, SHORT and LONG.
Creating proposal for LONG executor (the one which can modify governance itself) require significant proposition power, which no single AAVE holder poses, and it makes sense to delegate proposition power to on-chain smart contract, with clear intend.

**Deploying proposal without proposition power**
With AutonomousProposal it’s easy to create a proposal even with 0 proposition power and ask the community to back it up. It’s way easier and more transparent to ask for proposition power to an already deployed and immutable smart contract, rather than a user wallet with intention to create a certain proposal.


**Important note**. After proposal creation, users need to maintain the proposition power on the contract until the proposals have been executed, or they can be canceled.

## Example
[FEIExampleAutonomousProposal.sol](/tests/utils/FEIExampleAutonomousProposal.sol) is an example on how to change FEI reserveFactor through AutonomousProposal.
FEI parameters are for demo purposes only. But it should provide sufficient example on how easy it is to create your own proposals.
It also has another payload with a simple event emission, to illustrate that it can have custom logic.
[SimpleAutonomousProposalTest](/tests/SimpleAutonomousProposal.t.sol) shows how to use the SimpleAutonomousProposal contract for the most common use case of only one payload per proposal.

## Usage
You need to set up you local `.env` file:
```
cp .env.example .env
```

and install npm dependencies:
```
npm i
```

This repository is made with foundry.
```
forge install    // install deps
forge build      // build contracts
```

## Tests
- [AutonomousProposal.t.sol](/tests/AutonomousProposal.t.sol): Test using the FEI example proposal.

To run the tests:
```
forge tests
```

[image-1]:	./images/Autonomous.png
