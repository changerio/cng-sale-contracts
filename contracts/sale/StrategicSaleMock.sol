pragma solidity ^0.5.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {StrategicSale} from "./StrategicSale.sol";
import {PricePickerMock} from "./PricePickerMock.sol";

contract StrategicSaleMock is StrategicSale, PricePickerMock {
  constructor(
    IERC20 token, // The token being sold
    address payable wallet, // Address where funds are collected
    address tokenWallet, // Address where the token is stored
    uint256 openingTime, // Time when the sale is opened
    uint256 closingTime // Time when the sale is closed
  ) public StrategicSale(token, wallet, tokenWallet, openingTime, closingTime) {}
}
