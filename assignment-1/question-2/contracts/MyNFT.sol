// SPDX-License-Identifier: GPL-3.0-only
pragma solidity =0.8.12;

// use Azuki ERC721 implementation for better gas use when batch minting
import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {MerkleManager} from "./MerkleManager.sol";

/**
 * @author Philippe Dumonet
 */
contract MyNFT is ERC721A, Ownable {
    using Strings for uint256;
    string public constant DESCRIPTION = "This is NFT that does Merkle root stuff";

    MerkleManager public immutable merkleManager;

    constructor() ERC721A("ZKU Example ERC721 token", "tZKUEX") Ownable() {
        merkleManager = new MerkleManager();
    }

    modifier onlyExistingOwner() {
        address currentOwner = owner();
        require(
            currentOwner == address(0) || currentOwner == _msgSender(),
            "MyNFT: Not authorized to mint"
        );
        _;
    }

    function mintTo(address _recipient, uint256 _quantity) external onlyExistingOwner {
        uint256 nextTokenId = _currentIndex;
        address sender = _msgSender();
        bytes32[] memory leaves = new bytes32[](_quantity);
        for (uint256 i = 0; i < _quantity; ) {
            unchecked {
                leaves[i] = createLeafFor(sender, _recipient, nextTokenId + i);
                i++;
            }
        }
        merkleManager.submitLeafBatch(leaves);
        _safeMint(_recipient, _quantity);
    }

    function createLeafFor(
        address _sender,
        address _recipient,
        uint256 _tokenId
    ) public pure returns (bytes32) {
        // token ID is already part of the metadata URI so no need to add it
        // again
        return keccak256(abi.encodePacked(_sender, _recipient, tokenURI(_tokenId)));
    }

    function tokenURI(uint256 _tokenId) public pure override returns (string memory) {
        // create the metadata JSON
        bytes memory dataURI = abi.encodePacked(
            '{"name":"ZKU Example token #',
            _tokenId.toString(),
            '","description":"',
            DESCRIPTION,
            '"}'
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
