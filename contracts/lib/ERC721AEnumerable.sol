//SPDX-License-Identifier: None
pragma solidity ^0.8.7;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableExtension {
  /**
    * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
    * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
    */
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

  /**
    * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
    * Use along with {totalSupply} to enumerate all tokens.
    */
  function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract ERC721AEnumerable is ERC721AQueryable, IERC721EnumerableExtension {
  /**
    * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
    * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
    */
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
    return ERC721AQueryable(address(this)).tokensOfOwnerIn(owner, index, index+1)[0];
  }

  /**
    * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
    * Use along with {totalSupply} to enumerate all tokens.
    */
  function tokenByIndex(uint256 index) external pure returns (uint256) {
    return index;
  }
}