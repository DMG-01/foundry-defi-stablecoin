//SPDX-License-Identifier:MIT
pragma solidity^0.8.18;

import { DecentralizedStableCoin } from "src/DecentralizedStableCoin.sol";
import { ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DSCEngine is ReentrancyGuard  {
    error DSCEngine_NeedsMoreThanZero();
    error tokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
    error DSC_thisTokenIsNotAllowed();
    error DSC_depositCollateralFailed();
    error DSCEngine_breaksHealthFactor(uint256 healthFactor);
    error DSC__mintFailed();


     /*************EVENTS */
      event collateralDeposited(address indexed user,address indexed token,uint256 indexed amount );

    mapping (address token => address pricefeed) s_priceFeeds;
    mapping (address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping (address user => uint256 DscMinted) private s_DscMinted;
    address[] private s_collateralToken;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant MIN_HEALTH_FACTOR =  1;

    modifier moreThanZero(uint256 amount) {
        if(amount <= 0){
            revert DSCEngine_NeedsMoreThanZero();
        }   
        _;
    }

      modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSC_thisTokenIsNotAllowed();
        }
        _;
    }

    DecentralizedStableCoin immutable private i_dsc;

    constructor() {
        address[] memory tokenAddresses;
        address[] memory pricefeedAddresses;
         address i_dscAddress;

if(tokenAddresses.length != pricefeedAddresses.length){
    revert tokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
}
for(uint256 i = 0; i < tokenAddresses.length; i++ ){
    s_priceFeeds[tokenAddresses[i]] = pricefeedAddresses[i];
    s_collateralToken.push(tokenAddresses[i]);
}
i_dsc = DecentralizedStableCoin(i_dscAddress);

    }

    function depositCollateral(address tokenCollateralAddress,uint256 amountCollateral) external moreThanZero(amountCollateral)  isAllowedToken(tokenCollateralAddress)  nonReentrant() returns(bool){
    s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
    emit collateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
    bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender,address(this), amountCollateral);

    if(!success){
        revert DSC_depositCollateralFailed();
    }
    else {
        return true;
    }
    }
    function depositCollateralAndMintDsc() external{

    }

    function redeemCollateralForDsc() external {

    }
    function redeemCollateral() external {

    }
    function burnDsc() external {

    }
    function mintDsc( uint256 amountDscToMint ) external  moreThanZero(amountDscToMint) nonReentrant{
     s_DscMinted[msg.sender] += amountDscToMint;
     revertIfHealthFactorIsBroken(msg.sender);
     bool minted = i_dsc.mint(msg.sender, amountDscToMint);
     if(!minted) {
        revert DSC__mintFailed();     }
    }
    function liquidate() external {

    }
    function getHealthFactor() external view {

    }


    /****************INTERNAL && PRIVATE FUNCTIONS */
function getAccountInformation(address user) private view returns(uint256 totalDscMinted,uint256 totalCollateralInUsd) {
    totalDscMinted = s_DscMinted[user];
    totalCollateralInUsd = getAccountCollateralValue(user);
    
}

function revertIfHealthFactorIsBroken( address user) internal view  {
uint256 userHealthFactor= _healthFactor(user);
if(userHealthFactor < MIN_HEALTH_FACTOR) {
    revert DSCEngine_breaksHealthFactor(userHealthFactor);
}
}

function _healthFactor(address user) private view returns(uint256) {
(uint256 totalDscMinted,uint256 totalCollateralInUsd) = getAccountInformation(user);
uint256 collateralAdjustedForThreshold = (totalCollateralInUsd * LIQUIDATION_THRESHOLD) / 100;
return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;

}
/**************PUBLIC FUNCTIONS */
function getAccountCollateralValue(address user) public view  returns(uint256 totalCollateralInUsd){
 for(uint256 i; i < s_collateralToken.length; i++) {
      address token = s_collateralToken[i];
      uint256 amount = s_collateralDeposited[user][token];
      totalCollateralInUsd += getUsdValue(token,amount);
 }
 return totalCollateralInUsd;
}

function getUsdValue(address token, uint256 amount) public view returns(uint256){
AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
(,int256 price,,,) = priceFeed.latestRoundData();
return ((uint256 (price) * ADDITIONAL_FEED_PRECISION) * amount)/PRECISION;
}
}