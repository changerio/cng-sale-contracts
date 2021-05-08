pragma solidity ^0.5.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {PublicSale} from "./PublicSale.sol";
import {PricePickerMock} from "./PricePickerMock.sol";

/**
 * @dev RefundableCrowdsale is only used to prevent `wallet` from receiving Ether
 *      during crowdsale.
 */
contract PublicSaleMock is PublicSale, PricePickerMock {
  constructor(
    IERC20 token, // The token being sold
    address payable wallet, // Address where funds are collected
    address tokenWallet, // Address where the token is stored
    uint256 openingTime, // Time when the sale is opened
    uint256 closingTime
  ) public PublicSale(token, wallet, tokenWallet, openingTime, closingTime) {}
}
