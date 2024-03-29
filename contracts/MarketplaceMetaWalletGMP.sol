//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

// Minimal contract for allowing token transfer seperated from user wallet

import "./Marketplace.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IWETH is IERC20 {
  function deposit() external payable;
  function transfer(address to, uint value) external returns (bool);
  function withdraw(uint) external;
}

// Temporary use for testnet campaign
contract MarketplaceMetaWalletGMP is ReentrancyGuard, AxelarExecutable, Ownable {
  using SafeERC20 for IERC20;

  event Buy(address indexed token, uint256 indexed tokenId, uint256 amount, address priceToken, uint256 price, address indexed seller);

  AxelarSeaMarketplace public immutable master;
  IAxelarGasService public immutable gasReceiver;
  string public addressthis;
  IWETH public immutable weth;

  mapping(bytes32 => string) public whitelisted;

  constructor(address _master, address _gateway, address _gasReceiver, address _WETH) AxelarExecutable(_gateway) {
    master = AxelarSeaMarketplace(_master);
    gasReceiver = IAxelarGasService(_gasReceiver);
    addressthis = Strings.toHexString(uint160(address(this)), 20);
    weth = IWETH(_WETH);
  }

  function addWhitelist(string memory sourceChain, string memory addr) public onlyOwner {
    whitelisted[keccak256(bytes(sourceChain))] = addr;
  }

  function buyERC721(address walletAddress, IERC721 token, address seller, uint256 tokenId) internal {
    AxelarSeaMarketplace.SaleInfo memory saleInfo = master.getSale(seller, address(token), tokenId);

    saleInfo.priceToken.safeApprove(address(master), saleInfo.price + 10000); // + 10000 To prevent floating point error
    master.buyERC721(walletAddress, token, seller, tokenId);

    // Prevent any exploit
    saleInfo.priceToken.safeApprove(address(master), 0);

    emit Buy(address(token), tokenId, 1, address(saleInfo.priceToken), saleInfo.price, seller);
  }

  function buyERC1155(address walletAddress, IERC1155 token, address seller, uint256 tokenId, uint256 amount) internal {
    AxelarSeaMarketplace.SaleInfo memory saleInfo = master.getSale(seller, address(token), tokenId);
    
    saleInfo.priceToken.safeApprove(address(master), saleInfo.price * amount + 10000); // + 10000 To prevent floating point error
    master.buyERC1155(walletAddress, token, seller, tokenId, amount);

    // Prevent any exploit
    saleInfo.priceToken.safeApprove(address(master), 0);

    emit Buy(address(token), tokenId, amount, address(saleInfo.priceToken), saleInfo.price, seller);
  }

  function bridge(
    string calldata destinationChain,
    bytes calldata payload,
    string calldata symbol,
    uint256 gasAmount
  ) public payable {
    uint256 amount = msg.value - gasAmount;

    gasReceiver.payNativeGasForContractCallWithToken{value: gasAmount}(
      address(this),
      destinationChain,
      whitelisted[keccak256(bytes(destinationChain))],
      payload,
      symbol,
      amount,
      msg.sender
    );

    weth.deposit{value: amount}();
    weth.approve(address(gateway), amount);

    gateway.callContractWithToken(destinationChain, whitelisted[keccak256(bytes(destinationChain))], payload, symbol, amount);
  }

  function _executeWithToken(
    string memory sourceChain,
    string memory sourceAddress,
    bytes calldata payload,
    string memory tokenSymbol,
    uint256 amount
  ) internal virtual override {
    require(keccak256(bytes(whitelisted[keccak256(bytes(sourceChain))])) == keccak256(bytes(sourceAddress)), "Fake");
    (address walletAddress, IERC721 token, address seller, uint256 tokenId) = abi.decode(payload, (address, IERC721, address, uint256));
    buyERC721(walletAddress, token, seller, tokenId);
  }
}