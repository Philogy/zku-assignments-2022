// SPDX-License-Identifier: GPL-3.0-only
pragma solidity =0.8.12;

/// @author Philippe Dumonet
contract MerkleManager {
    struct MerkleBranch {
        bytes32 hash;
        uint256 children;
    }

    bytes32[] public leaves;
    bytes32[] public rootSnapshots;
    MerkleBranch public lastFullRoot;

    address public immutable controller;

    constructor() {
        controller = msg.sender;
    }

    function rootSnapshotCount() external view returns (uint256) {
        return rootSnapshots.length;
    }

    function leafCount() external view returns (uint256) {
        return leaves.length;
    }

    function getRoot()
        public
        view
        returns (
            bytes32 rootHash,
            MerkleBranch memory newLastFull,
            bool changed
        )
    {
        uint256 totalLeaves = leaves.length;
        require(totalLeaves > 0, "MerkleManager: No tree");

        MerkleBranch memory lastFullRootMem = lastFullRoot;
        MerkleBranch memory currentBranch;
        unchecked {
            MerkleBranch[] memory branches = new MerkleBranch[](_log2(totalLeaves) + 1);
            branches[0] = lastFullRootMem;
            uint256 lastBranchIndex = 0;

            uint256 j;
            for (uint256 i = branches[0].children; i < totalLeaves; i++) {
                currentBranch = MerkleBranch({hash: leaves[i], children: 1});

                // underflow if i reaches `0` desired
                for (j = lastBranchIndex; j != type(uint256).max; j--) {
                    if (currentBranch.children != branches[j].children) break;
                    _mergeMerkleBranches(currentBranch, branches[j]);
                }
                lastBranchIndex = j + 1; // overflow if j underflowed desired
                branches[lastBranchIndex] = currentBranch;
            }

            newLastFull = branches[0];
            changed = newLastFull.hash != lastFullRootMem.hash;

            for (uint256 i = lastBranchIndex - 1; i != type(uint256).max; i--) {
                _mergeMerkleBranches(currentBranch, branches[i]);
            }
        }
        rootHash = currentBranch.hash;
    }

    function submitLeafBatch(bytes32[] calldata _newLeaves) external {
        require(msg.sender == controller, "MerkleManager: Access denied");
        require(_newLeaves.length > 0, "MerkleManager: No leaves");
        if (leaves.length == 0) {
            lastFullRoot = MerkleBranch({hash: _newLeaves[0], children: 1});
        }
        uint256 newLeafCount = _newLeaves.length;
        for (uint256 i = 0; i < newLeafCount; ) {
            leaves.push(_newLeaves[i]);
            unchecked {
                i++;
            }
        }
    }

    function _mergeMerkleBranches(MerkleBranch memory _a, MerkleBranch memory _b) internal pure {
        _a.children += _b.children;
        _a.hash = hashTwo(_a.hash, _b.hash);
    }

    function hashTwo(bytes32 _a, bytes32 _b) public pure returns (bytes32) {
        return _a <= _b ? _efficientHash(_a, _b) : _efficientHash(_b, _a);
    }

    /**
     * @dev computes `floor(log_2(x))`
     */
    function _log2(uint256 _x) internal pure returns (uint256 y) {
        uint256 f = 128;
        for (uint256 i = 0; i < 8; ) {
            if (_x >= (1 << f)) {
                unchecked {
                    y += f;
                    i++;
                }
                _x >>= f;
            }
            f >>= 1;
        }
    }

    /**
     * @dev taken from OpenZeppelin's MerkleProof implementation
     */
    function _efficientHash(bytes32 _a, bytes32 _b) internal pure returns (bytes32 value) {
        assembly {
            mstore(0x00, _a)
            mstore(0x20, _b)
            value := keccak256(0x00, 0x40)
        }
    }
}
