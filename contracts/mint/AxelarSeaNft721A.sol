//SPDX-License-Identifier: None
pragma solidity ^0.8.7;

import "../lib/ERC721AEnumerable.sol";
import "./lib/AxelarSeaNftBase.sol";

contract AxelarSeaNft721A is ERC721AEnumerable, AxelarSeaNftBase {
  constructor() ERC721A("_", "_") {}

  function _mintInternal(address to, uint256 amount) internal override {
    walletMinted[to] += amount;

    uint256 supply = totalSupply();
    if(supply + amount > maxSupply) {
      revert SupplyLimited();
    }

    _safeMint(to, amount);
  }

  function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721A, IERC721A) {
    AxelarSeaNftBase._beforeTokenTransferCheck(from);
    super.transferFrom(from, to, tokenId);
  }

  function exists(uint256 tokenId) public override view returns(bool) {
    return _exists(tokenId);
  }

  /**
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 tokenId) public view override(AxelarSeaNftBase, ERC721A, IERC721A) virtual returns (string memory) {
    return AxelarSeaNftBase.tokenURI(tokenId);
  }

  /**
    * @dev See {IERC721Metadata-name}.
    */
  function name() public view override(AxelarSeaNftBase, ERC721A, IERC721A) virtual returns (string memory) {
    return AxelarSeaNftBase.name();
  }

  /**
    * @dev See {IERC721Metadata-symbol}.
    */
  function symbol() public view override(AxelarSeaNftBase, ERC721A, IERC721A) virtual returns (string memory) {
    return AxelarSeaNftBase.symbol();
  }

  /**
    * @dev See {IERC165-supportsInterface}.
    */
  function supportsInterface(bytes4 interfaceId) public view virtual override(AxelarSeaNftBase, ERC721A, IERC721A) returns (bool) {
    return AxelarSeaNftBase.supportsInterface(interfaceId) || ERC721A.supportsInterface(interfaceId);
  }
}