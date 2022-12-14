pragma solidity ^0.8.0;

interface IAutonomousProposal {
  struct ProposalParams {
    address target;
    bool withDelegateCall;
    uint256 value;
    bytes callData;
    string signature;
  }

  /// @dev returns the creation timestamp in seconds from when a proposal can be created
  function PROPOSALS_CREATION_TIMESTAMP() external returns (uint256);

  /// @dev returns a time frame in seconds in which a proposal can be created
  function GRACE_PERIOD() external returns (uint256);

  /**
   * @dev creates proposals. To be implemented on children contract
   */
  function create() external virtual;

  /**
   * @dev votes on proposals. To be implemented on children contract
   */
  function vote() external virtual;

  /**
   * @dev method to be called to resque ERC20 tokens incorrectly sent to this contract. Can only be called by
          Short Executor.
   * @param erc20Token address of the token to rescue
   * @param to address where the rescued tokens will be sent
   * @param amount amount to be rescued
   */
  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external;
}
