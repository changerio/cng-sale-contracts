pragma solidity ^0.5.17;

import {Ownable} from "@openzeppelin/contracts/ownership/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";

import {Crowdsale} from "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import {AllowanceCrowdsale} from "@openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import {TimedCrowdsale} from "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import {WhitelistCrowdsale} from "@openzeppelin/contracts/crowdsale/validation/WhitelistCrowdsale.sol";
import {IndividuallyCappedCrowdsale} from "@openzeppelin/contracts/crowdsale/validation/IndividuallyCappedCrowdsale.sol";

import {DSMath} from "../lib/ds-hub.sol";

import {PricePicker} from "./PricePicker.sol";

contract StrategicSale is
  DSMath,
  Ownable,
  Crowdsale,
  AllowanceCrowdsale,
  TimedCrowdsale,
  WhitelistCrowdsale,
  IndividuallyCappedCrowdsale,
  PricePicker
{
  uint256 private constant _DAI_CFX = (2 * WAD) / 10; // 1 CFX = $0.2 (5 CFX/1 DAI)

  mapping(address => uint256) individualPrices; // individual prices

  constructor(
    IERC20 token, // The token being sold
    address payable wallet, // Address where funds are collected
    address tokenWallet, // Address where the token is stored
    uint256 openingTime, // Time when the sale is opened
    uint256 closingTime // Time when the sale is closed
  ) public Crowdsale(1, wallet, token) AllowanceCrowdsale(tokenWallet) TimedCrowdsale(openingTime, closingTime) {}

  function setIndividualPrice(address account, uint256 individualPrice) external onlyOwner {
    individualPrices[account] = individualPrice;
  }

  ////////////////////////
  // Prices
  ////////////////////////
  function DAI_CFX() public pure returns (uint256) {
    return _DAI_CFX;
  }

  function ETH_DAI() public view returns (uint256) {
    return getPrice();
  }

  function ETH_CFX() public view returns (uint256) {
    return wdiv(ETH_DAI(), DAI_CFX());
  }

  /**
   * @dev Override Crowdsale#_getTokenAmount
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
    return calcTokenAmountWithEthPrice(weiAmount);
  }

  function calcTokenAmountWithEthPrice(uint256 ethAmount) public view returns (uint256 dfxAmount) {
    uint256 individualPrice = individualPrices[msg.sender];

    uint256 pDAI_CFX = DAI_CFX();
    uint256 pETH_DAI = individualPrice == 0 ? getPrice() : individualPrice;
    uint256 pETH_CFX = wdiv(pETH_DAI, pDAI_CFX);

    dfxAmount = wmul(ethAmount, pETH_CFX);
  }
}
