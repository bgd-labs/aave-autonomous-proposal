# Autonomous proposal
## Why?
Delegating proposition power to a smart contract instead of wallet address gives ultimate transparency to how the proposition power would be used and what the created proposal body will be.
## The flow
Each deployment of autonomous proposal need to provide only 2 parameters in constructor: type of executor, ipfs hash and `execute()` method which will be called after voting is closed.
This way, an autonomous proposal will always have external `create()` method implemented in abstract contract referencing itself.
After enough proposition power is received, `created()` method can be called by anyone.
Once a proposal is created, proposal ID is saved and create() method can not be called again.
AutonomousProposal contract has 2 more methods, view `getProposalCreatedId()` which will return proposal id or 0 if proposal is not created and `vote()` method which will vote on created proposal with all delegated voting power, in case it was delegated by accident.

![Autonomous proposal scheme][image-1]
## How to use?
`contracts/AutonomousProposal.sol` - is an abstract smart contract. Which anyone can extend from providing only `execute()` method.
`create()` is a solid implementation which will create a proposal, expecting `execute()` method is provided by contract implementation.
But to keep in mind `create()` method has 3 important conditions, each proposal can be created only **once per contract**, proposal can **only be created with 80k** of proposition power and proposal is using `address(this)` as execution target to achieve maximum transparency.
## Example
`FEIExampleAutonomousProposal.sol` is a simulation example of executed governance proposal 96 https://app.aave.com/governance/proposal/96/ with the same parameters as here
https://etherscan.io/tx/0x1bd77b5a8982dd1b1cfdf337f68c3f802cf36755e21f4874b319d9a1d084b6e1#eventlog




**Important note**. After proposal creation, users need to revoke their proposition power from a smart contract manually, as the functionality to revoke proposition power from the recieving end is not available in current AAVE governance version.

## There are multiple benefits of using contract based on AutonomousProposal instead of custom implementation
- Deploying proposal becomes easier than ever. Providing only necessary parameters, like ipfs hash, executor and `execute()` method itself. It’s the most minimalistic boilerplate required for proposal deployment.
- Deploying proposal implementation ahead of proposition delegation leaves no room for hidden behavior. You can see exactly what will be inside the proposal and how it would be created before delegating any proposition power, since the contract is immutable, there is no other way to use delegated proposition power
- Lowering entry barrier for newcomers to AAVE ecosystem. Good ideas come from different places. Deploying proposal and asking community to back-up with proposition power is the easiest way for non-AAVE holders to engage with on-chain governance

[image-1]:	./images/scheme.png
