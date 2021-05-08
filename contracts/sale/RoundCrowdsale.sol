pragma solidity ^0.5.17;

import "@openzeppelin/contracts/math/SafeMath.sol";
import {Crowdsale} from "@openzeppelin/contracts/crowdsale/Crowdsale.sol";

import {DSMath} from "../lib/ds-hub.sol";

contract RoundCrowdsale is DSMath, Crowdsale {
  using SafeMath for uint256;

  bool private _initialized;

  uint256 private _startTime;

  uint256 private _nRound;

  // array of block time stamps
  uint256[] private _roundEndTime;

  // array of rates of tokens per wei in WAD unit.
  uint256[] private _rates;

  uint256 private _roundTokenCap;

  mapping(uint256 => uint256) private _roundSoldToken;

  function initialize(
    uint256 roundTokenCap,
    uint256 startTime,
    uint256[] memory roundEndTime,
    uint256[] memory rates
  ) public {
    require(_initialized == false);
    require(roundEndTime.length == rates.length, "RoundCrowdsale: invalid input length");
    require(startTime < roundEndTime[0], "RoundCrowdsale: invalid start time");

    uint256 n = roundEndTime.length;

    for (uint256 i = 1; i < n; i++) {
      require(roundEndTime[i - 1] < roundEndTime[i], "RoundCrowdsale: time not sorted");
    }
    _startTime = startTime;
    _nRound = n;

    _roundEndTime = roundEndTime;
    _rates = rates;

    _roundTokenCap = roundTokenCap;

    _initialized = true;
  }

  function nRound() public view returns (uint256) {
    return _nRound;
  }

  function startTime() public view returns (uint256) {
    return _startTime;
  }

  function roundEndTimes(uint256 i) public view returns (uint256) {
    return _roundEndTime[i];
  }

  function roundSoldToken(uint256 i) public view returns (uint256) {
    return _roundSoldToken[i];
  }

  function roundTokenCap() public view returns (uint256) {
    return _roundTokenCap;
  }

  function rates(uint256 i) external view returns (uint256) {
    return _rates[i];
  }

  function isOpen() public view returns (bool) {
    // solhint-disable-next-line not-rely-on-time
    return block.timestamp >= _startTime && block.timestamp <= _roundEndTime[_roundEndTime.length - 1];
  }

  /**
   * The base rate function is overridden to revert, since this crowdsale doesn't use it, and
   * all calls to it are a mistake.
   */
  function rate() public view returns (uint256) {
    revert("RoundCrowdsale: rate() called");
  }

  function getCurrentRound() public view returns (uint256) {
    require(isOpen());

    uint256 index;
    for (; index < _rates.length; index++) {
      if (block.timestamp <= _roundEndTime[index]) break;
    }

    return index;
  }

  /**
   * @dev Returns the rate of tokens per wei at the present time.
   * Note that, as price _increases_ with time, the rate _decreases_.
   * @return The number of tokens a buyer gets per wei at a given time
   */
  function getCurrentRate() public view returns (uint256) {
    if (!isOpen()) {
      return 0;
    }

    return _rates[getCurrentRound()];
  }

  /**
   * @dev Override Crowdsale#_processPurchase
   * @param beneficiary Address receiving the tokens
   * @param tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
    uint256 index = getCurrentRound();

    require(_roundSoldToken[index].add(tokenAmount) < _roundTokenCap, "RoundCrowdsale: over payment");

    _roundSoldToken[index] = _roundSoldToken[index].add(tokenAmount);
    super._processPurchase(beneficiary, tokenAmount);
  }

  /**
   * @dev Overrides parent method taking into account variable rate.
   * @param weiAmount The value in wei to be converted into tokens
   * @return The number of tokens _weiAmount wei will buy at present time
   */
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
    uint256 currentRate = getCurrentRate();
    return wmul(currentRate, weiAmount);
  }

  /**
   * @dev Overrides Crowdsale._preValidatePurchase
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(isOpen(), "RoundCrowdsale: not open yet");
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
  }
}
