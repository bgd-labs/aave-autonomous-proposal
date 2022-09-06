# Autonomous proposal
Autonomous proposal is an example of a contract with 2 methods
_create()_ and  _execute()_
Create method can be called by anyone when enough people delegate proposition power to the contract. In that particular case, it’s 80k. Once enough proposition power is accumulated, anyone can call `create()` method, which will create the proposal referencing the same contract with `execute()` signature.

After proposal is created, normal voting will happen and if succeeded, `execute()` method will be called via delegate call.

![Autonomous proposal scheme](./images/scheme.png)

**Important note**. After proposal execution, users need to revoke their proposition power from a smart contract manually, as the functionality to revoke proposition power from recieving end is not available in current AAVE governance version. 

## Use case
On AAVE Governance there are 2 types of executors, SHORT and LONG. 
Creating proposal for LONG executor (the one which can modify governance itself) require significant proposition power, which no single AAVE holder poses, and it makes sense to delegate proposition power to on-chain smart contract, with clear intend