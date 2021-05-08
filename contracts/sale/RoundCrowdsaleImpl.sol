pragma solidity ^0.5.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Crowdsale} from "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import {AllowanceCrowdsale} from "@openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol";

import {RoundCrowdsale} from "./RoundCrowdsale.sol";

contract RoundCrowdsaleImpl is Crowdsale, RoundCrowdsale, AllowanceCrowdsale {
  constructor(
    IERC20 token,
    address payable wallet,
    address tokenWallet
  ) public Crowdsale(1, wallet, token) AllowanceCrowdsale(tokenWallet) {}
}
