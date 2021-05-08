// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Ownable} from "@openzeppelin/contracts/ownership/Ownable.sol";
import {Crowdsale} from "@openzeppelin/contracts/crowdsale/Crowdsale.sol";

import {LeafLib} from "../lib/LeafLib.sol";

contract MerkleProofCappedCrowdsale is Ownable, LeafLib, Crowdsale {
  using SafeMath for uint256;

  mapping(address => bool) public isRootAdder;

  modifier onlyRootAdder() {
    require(msg.sender == owner() || isRootAdder[msg.sender], "no-root-adder");
    _;
  }

  function addRootAdder(address account) external onlyOwner {
    isRootAdder[account] = true;
  }

  function addRoot(bytes32 root) public onlyRootAdder {
    super.addRoot(root);
  }

  mapping(address => uint256) private _contributions;

  /**
   * @dev Returns the amount contributed so far by a specific beneficiary.
   * @param beneficiary Address of contributor
   * @return Beneficiary contribution so far
   */
  function getContribution(address beneficiary) public view returns (uint256) {
    return _contributions[beneficiary];
  }

  /**
   * @param amount cap
   * @param root merkle root
   * @param proof merkle proof
   */
  function buyTokensWithProof(
    uint256 amount,
    bytes32 root,
    bytes calldata proof
  ) external payable {
    addLeaf(root, msg.sender, amount, proof);
    buyTokens(msg.sender);
  }

  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(_contributions[beneficiary].add(weiAmount) <= amounts[beneficiary], "MerkleProofCappedCrowdsale: exceeds cap");
  }

  /**
   * @dev Extend parent behavior to update beneficiary contributions.
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
    super._updatePurchasingState(beneficiary, weiAmount);
    _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
  }
}
