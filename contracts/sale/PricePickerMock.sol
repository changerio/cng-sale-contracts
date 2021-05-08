pragma solidity ^0.5.17;

import {PricePicker} from "./PricePicker.sol";

contract PricePickerMock is PricePicker {
  function getPrice() public view returns (uint256) {
    // 2150.24 ETH/USD
    uint256 reserve0 = (215024 * WAD) / 100;
    uint256 reserve1 = 1 * WAD;

    return wdiv(uint256(reserve0), uint256(reserve1));
  }
}
