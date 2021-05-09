pragma solidity ^0.5.17;

import {Ownable} from "@openzeppelin/contracts/ownership/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";

import {Crowdsale} from "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import {AllowanceCrowdsale} from "@openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import {TimedCrowdsale} from "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import {FinalizableCrowdsale} from "@openzeppelin/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import {RefundableCrowdsale} from "@openzeppelin/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

import {DSMath} from "../lib/ds-hub.sol";

import {PricePicker} from "./PricePicker.sol";
import {RoundCrowdsale} from "./RoundCrowdsale.sol";
import {MerkleProofCappedCrowdsale} from "./MerkleProofCappedCrowdsale.sol";

/**
 * @dev RefundableCrowdsale is only used to prevent `wallet` from receiving Ether
 *      during crowdsale.
 */
contract PublicSale is
  DSMath,
  Ownable,
  Crowdsale,
  AllowanceCrowdsale,
  TimedCrowdsale,
  MerkleProofCappedCrowdsale,
  FinalizableCrowdsale,
  RefundableCrowdsale,
  RoundCrowdsale,
  PricePicker
{
  constructor(
    IERC20 token, // The token being sold
    address payable wallet, // Address where funds are collected
    address tokenWallet, // Address where the token is stored
    uint256 openingTime, // Time when the sale is opened
    uint256 closingTime
  ) public Crowdsale(1, wallet, token) AllowanceCrowdsale(tokenWallet) TimedCrowdsale(openingTime, closingTime) RefundableCrowdsale(1) {}

  ////////////////////////
  // Prices
  ////////////////////////
  function DAI_CFX() public view returns (uint256) {
    return getCurrentRate();
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

  function calcTokenAmountWithEthPrice(uint256 ethAmount) public view returns (uint256) {
    return wmul(ethAmount, ETH_CFX());
  }

  function isOpen() public view returns (bool) {
    return RoundCrowdsale.isOpen() && TimedCrowdsale.isOpen();
  }

  /**
   * @dev Override FinalizableCrowdsale#finalize
   */
  function finalize() public onlyOwner {
    super.finalize();
  }

  /**
   * @dev Override RefundableCrowdsale#claimRefund
   */
  function claimRefund(address payable) public {
    revert("PublicSale: not supported");
  }

  /**
   * @dev Override RefundableCrowdsale#goalReached
   * @return Whether funding goal was reached
   */
  function goalReached() public view returns (bool) {
    return hasClosed();
  }

  function goal() public view returns (uint256) {
    revert("PublicSale: not supported");
  }

  /**
   * @dev Overrides Crowdsale._preValidatePurchase
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(msg.sender == tx.origin, "PublicSale: invalid tx origin");
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
  }
}
