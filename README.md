# Autonomous proposal
## Why?
Delegating proposition power to a smart contract instead of wallet address gives ultimate transparency to how the proposition power would be used and what the created proposal body will be.
## The flow
Each deployment of autonomous proposal need to provide only 2 parameters in constructor: type of executor, ipfs hash and `create()` method which will be called after voting is closed.
This way, an autonomous proposal will always have external `create()` method implemented in abstract contract referencing itself.
After enough proposition power is acquired, `created()` method can be called by anyone.
Once a proposal is created, proposal ID is saved and create() method can not be called again.
AutonomousProposal contract has 2 more methods, view `getProposalCreatedId()` which will return proposal id or 0 if proposal is not created and `vote()` method which will vote on created proposal with all delegated voting power, in case it was delegated by accident.

![Autonomous proposal scheme][image-1]
## How to use?
`contracts/AutonomousProposal.sol` - is an abstract smart contract. Which anyone can extend from providing only `execute()` method.
`create()` is a solid implementation which will create a proposal, expecting `execute()` method is provided by contract implementation.
But to keep in mind `create()` method has 3 important conditions, each proposal can be created only **once per contract**, proposal can **only be created with 80k** of proposition power and proposal is using `address(this)` as execution target to achieve maximum transparency.
## Example
`FEIExampleAutonomousProposal.sol` is a simulation example of executed governance proposal 96 https://app.aave.com/governance/proposal/96/
Changing FEI risk parameters. All the parameters are talking as is from the transaction
https://etherscan.io/tx/0x1bd77b5a8982dd1b1cfdf337f68c3f802cf36755e21f4874b319d9a1d084b6e1#eventlog


## Tests
To verify that tests are working properly, FEI risk parameters are changed to 20_000 and after proposal execution changed back to 10_000 to completely test the whole flow of calling execute() with permissions 


**Important note**. After proposal creation, users need to revoke their proposition power from a smart contract manually, as the functionality to revoke proposition power from the recieving end is not available in current AAVE governance version.

## Use case
**Creating proposals for LONG executor**
On AAVE Governance, there are 2 types of executors, SHORT and LONG.
Creating proposal for LONG executor (the one which can modify governance itself) require significant proposition power, which no single AAVE holder poses, and it makes sense to delegate proposition power to on-chain smart contract, with clear intend.

**Deploying proposal without proposition power**
With AutonomousProposal it’s easy to create a proposal even with 0 proposition power and ask the community to back it up. It’s way easier and more transparent to ask for proposition power to an already deployed and immutable smart contract, rather than a user wallet with intention to create a certain proposal.

[image-1]:	./images/scheme.png
