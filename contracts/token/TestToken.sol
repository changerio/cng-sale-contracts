pragma solidity ^0.5.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
  constructor(uint256 initialSupply) public {
    _mint(_msgSender(), initialSupply);
  }
}
