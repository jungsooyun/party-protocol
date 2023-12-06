// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

import "../tokens/IERC4907.sol";
import "./LibProposal.sol";
import "./IProposalExecutionEngine.sol";
import "../globals/IGlobals.sol";


contract RentProposal {

    // ABI-encoded RentProposalData passed into execute
    struct RentProposalData {
        IERC4907 nftContract;  // token contract address
        uint256 tokenId;       // token id
        address user;          // user address 'that rent the token'
        uint64 expires;        // expiration date
    }

    event RentExecuted(uint256 proposalId, uint256 tokenId);
    event RentCanceled(uint256 proposalId, uint256 tokenId);
    event RentExpired(uint256 proposalId, uint256 tokenId);

    // The `Globals` contract storing global configuration values. This contract
    // is immutable and it's address will never change.

    IGlobals private immutable _GLOBALS;
    // NOTE: 전역 설정값을 가져오기 위해 사용하는 인터페이스, 다만 Rent에는 필요없을 것 같지만 일단 넣어둠

    // Set immutables.
    constructor(IGlobals globals) {
        _GLOBALS = globals;
    }

    function _executeRent(
        IProposalExecutionEngine.ExecuteProposalParams memory params)
        internal returns (bytes memory nextProgressData) {
            RentProposalData memory rentalData = abi.decode(params.progressData, (RentProposalData));
            // 필요한 조건 검증
            require(rentalData.expires < block.timestamp, "Proposal is not executable");
            // uint256 ethAvailable = allowRentToSpendPartyEth ? address(this).balance : msg.value;

            rentalData.nftContract.setUser(rentalData.tokenId, rentalData.user, rentalData.expires);

            emit RentExecuted(params.proposalId, rentalData.tokenId);

            // Nothing left to do, so return empty progress data
            return "";
        }
}
