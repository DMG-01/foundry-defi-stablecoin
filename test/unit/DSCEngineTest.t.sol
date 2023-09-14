//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DSCEngine} from "src/DSCengine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployDSC} from "script/DeployDsc.s.sol";

contract DscEngineTest is Test{
DeployDSC deployer;
DecentralizedStableCoin dsc;
DSCEngine dscEngine;
HelperConfig config;
address wethUsdPriceFeed;
address weth;

    function setUp() public {
         deployer = new DeployDSC();
        (dsc,dscEngine,config) = deployer.run();
        (wethUsdPriceFeed,,weth,,) = config.activeNetworkConfig();
    }

    function testGetUsdValue() external {
uint256 ethAmount = 15e18;
uint256 expectedUsd = 3000e18;
uint256 actualUsd = dscEngine.getUsdValue(weth,ethAmount);
assertEq(expectedUsd,actualUsd);
    }
}
