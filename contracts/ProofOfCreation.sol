// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Proof of Creation
/// @author Shana Campbell
/// @notice Stamps the fingerprint (SHA-256 hash) of a creative work on the blockchain,
///         so a creator can later prove the work existed, unchanged, at that moment.
///         The file itself never goes on-chain: only its fingerprint.
contract ProofOfCreation {
    struct Proof {
        address creator;   // the wallet that stamped it
        uint64 timestamp;  // when it was stamped (seconds since 1 Jan 1970)
        string title;      // optional public title, max 100 characters
    }

    // fingerprint => proof
    mapping(bytes32 => Proof) private proofs;

    // how many works each wallet has stamped
    mapping(address => uint256) public stampsBy;

    // how many works have been stamped in total
    uint256 public totalStamps;

    event Stamped(bytes32 indexed fingerprint, address indexed creator, uint64 timestamp, string title);

    /// @notice Stamp a work's fingerprint. Each fingerprint can only be stamped once,
    ///         so the first stamp is the proof.
    function stamp(bytes32 fingerprint, string calldata title) external {
        require(fingerprint != bytes32(0), "Empty fingerprint");
        require(proofs[fingerprint].creator == address(0), "Already stamped");
        require(bytes(title).length <= 100, "Title too long");

        uint64 nowTs = uint64(block.timestamp);
        proofs[fingerprint] = Proof(msg.sender, nowTs, title);
        stampsBy[msg.sender] += 1;
        totalStamps += 1;

        emit Stamped(fingerprint, msg.sender, nowTs, title);
    }

    /// @notice Check a fingerprint. Free to call: reading the blockchain costs nothing.
    function verify(bytes32 fingerprint)
        external
        view
        returns (bool exists, address creator, uint64 timestamp, string memory title)
    {
        Proof memory p = proofs[fingerprint];
        return (p.creator != address(0), p.creator, p.timestamp, p.title);
    }
}
