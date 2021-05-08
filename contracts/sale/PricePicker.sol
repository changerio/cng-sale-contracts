pragma solidity ^0.5.17;

import {Ownable} from "@openzeppelin/contracts/ownership/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {DSValue, DSMath} from "../lib/ds-hub.sol";
import {IUniswapV2Pair} from "../lib/IUniswapV2Pair.sol";

// calc eth price in usd
contract PricePicker is DSMath, Ownable {
  function src() public pure returns (address) {
    return 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;
  }

  function getPrice() public view returns (uint256) {
    (uint112 reserve0, uint112 reserve1) = IUniswapV2Pair(src()).getReserves();
    return wdiv(uint256(reserve0), uint256(reserve1));
  }
}
