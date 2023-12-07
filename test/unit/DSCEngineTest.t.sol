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
address weth;

address public USER = makeAddr("user");
uint256 public constant COLLATERAL_AMOUNT = 10 ether;
uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
         deployer = new DeployDSC();
        (dsc,dscEngine,config) = deployer.run();
        (wethUsdPriceFeed,,weth,,) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(address(USER),STARTING_ERC20_BALANCE);
    }

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
}
