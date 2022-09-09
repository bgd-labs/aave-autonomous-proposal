# Autonomous proposal
## Why?
Delegating proposition power to a smart contract instead of wallet address gives ultimate transparency to how the proposition power would be used and what the created proposal body will be. 
## The flow
Autonomous proposal is an example of a contract with 2 methods
_create()_ and  _execute()_
Create method can be called by anyone when enough people delegate proposition power to the contract. In that particular case, it’s 80k. Once enough proposition power is accumulated, anyone can call `create()` method, which will create the proposal referencing the same contract with `execute()` signature.

After proposal is created, normal voting will happen and if succeeded, `execute()` method will be called via delegate call.

![Autonomous proposal scheme][image-1]
## How to use?
`contracts/AutonomousProposal.sol` - is an abstract smart contract. Which anyone can extend from providing only `execute()` method. 
`create()` is a solid implementation which will create a proposal, expecting `execute()` method is provided by contract implementation.
But to keep in mind `create()` method has 3 important conditions, each proposal can be created only **once per contract**, proposal can **only be created with 80k** of proposition power and proposal is using `address(this)` as execution target to achieve maximum transparency.
## Example
In reality using smart contract is simple, create your own contract extending from AutonomousProposal and override `execute()` method
File `contracts/FEIExampleAutonomousProposal.sol` is an example on how to change FEI reserveFactor through AutonomousProposal with tests to verify the changes directly on AAVE. 
FEI and reserveFactor parameters is for demo purposes only. But it should provide sufficient example on how easy it is to create your own proposals. 

## Tests
If you want to use `tests/AutonomousProposal.t.sol` as a base to test your proposals. Change 
`proposalPayload = new FEIExampleAutonomousProposal(); ` and the body of the function `_testProposalExecution ` to reflect desired changes after your proposal execution, all the remaining tests should work out of the box.

**Important note**. After proposal creation, users need to revoke their proposition power from a smart contract manually, as the functionality to revoke proposition power from the recieving end is not available in current AAVE governance version. 

## Use case
**Creating proposals for LONG executor**
On AAVE Governance, there are 2 types of executors, SHORT and LONG. 
Creating proposal for LONG executor (the one which can modify governance itself) require significant proposition power, which no single AAVE holder poses, and it makes sense to delegate proposition power to on-chain smart contract, with clear intend.

**Deploying proposal without proposition power**
With AutonomousProposal it’s easy to create a proposal even with 0 proposition power and ask the community to back it up. It’s way easier and more transparent to ask for proposition power to an already deployed and immutable smart contract, rather than a user wallet with intention to create a certain proposal.

[image-1]:	./images/scheme.png