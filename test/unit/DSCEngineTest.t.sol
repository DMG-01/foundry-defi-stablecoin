//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DSCEngine} from "src/DSCengine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployDSC} from "script/DeployDsc.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/ERC20Mock.sol";

contract DscEngineTest is Test{
DeployDSC deployer;
DecentralizedStableCoin dsc;
DSCEngine dscEngine;
HelperConfig config;
address wethUsdPriceFeed;
address wbtcUsdPriceFeed;
address weth;
address wbtc;
address inCorrectPricefeed;
address ict;

address public USER = makeAddr("user");
uint256 public constant COLLATERAL_AMOUNT = 10 ether;
uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
         deployer = new DeployDSC();
        (dsc,dscEngine,config) = deployer.run();
        (wethUsdPriceFeed,wbtcUsdPriceFeed,weth,wbtc,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(address(USER),STARTING_ERC20_BALANCE);
    }

    address[] public tokenAddresses ;
    address[] public priceFeedAddresses ;
/*********CONSTRUCTOR TEST */
   function testRevertsIfTokenLengthDoesntMatchPriceFeedTest()  external{
     vm.startPrank(USER);
     tokenAddresses.push(weth);
     priceFeedAddresses.push(wethUsdPriceFeed);
     priceFeedAddresses.push(wbtcUsdPriceFeed);
     vm.expectRevert(DSCEngine.tokenAddressesAndPriceFeedAddressesMustBeTheSameLength.selector);
     new DSCEngine(tokenAddresses,priceFeedAddresses,address(dsc));
   }

   function testGetTokenAmountFromUsd() public {
    uint256 usdAmount = 100 ether;
    uint256 expectedAmount = 0.05 ether;
    uint256 actualWeth = dscEngine.getTokenAmountFromUsd(weth,usdAmount);
    assertEq(expectedAmount, actualWeth);
   }
    
    


/****PRICE TEST */
    function testGetUsdValue() external {
    uint256 ethAmount = 15e18;
    uint256 expectedUsd = 30000e18;
    uint256 actualUsd = dscEngine.getUsdValue(weth,ethAmount);
    assertEq(expectedUsd,actualUsd);
    }

    function testRevertsIfCollateralIsZero() external {
        vm.startPrank(USER);
    ERC20Mock(weth).approve(address(dsc),COLLATERAL_AMOUNT);
        vm.expectRevert(DSCEngine.DSCEngine_NeedsMoreThanZero.selector);
        dscEngine.depositCollateral(weth,0);
        vm.stopPrank();
    }

    function testRevertsWithUnApprovedCollateral() external {
    vm.startPrank(USER);
    tokenAddresses.push(ict);
    priceFeedAddresses.push(inCorrectPricefeed);
    vm.expectRevert(DSCEngine.DSC_thisTokenIsNotAllowed.selector);
    dscEngine.depositCollateral(inCorrectPricefeed,COLLATERAL_AMOUNT);
    }
      
      modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine),COLLATERAL_AMOUNT);
        dscEngine.depositCollateral(weth, COLLATERAL_AMOUNT);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
    
    (uint256 totalDscMinted, uint256 totalCollateralInUsd) = dscEngine.getAccountInformation(USER); 
    uint256 expectedDscMinted = 0;
    uint256 expectedDepositAmount = dscEngine.getTokenAmountFromUsd(weth,totalCollateralInUsd);
    assertEq(totalDscMinted, expectedDscMinted);
    assertEq(expectedDepositAmount, COLLATERAL_AMOUNT); 
       
    }
} 