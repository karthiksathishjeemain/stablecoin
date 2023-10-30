// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../src/DecentrelisedStableCoin.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DepolyDSC is Script {
    constructor() {}

    address[] Token_addresses;
    address[] PriceFeed_addresses;

    function run() public returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (address wETH_USD, address wBTC_USD, address wETH, address wBTC,) = helperConfig.active_NetworkConfig();
        Token_addresses = [wETH, wBTC];
        PriceFeed_addresses = [wETH_USD, wBTC_USD];
        vm.startBroadcast();
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine dsc_engine = new DSCEngine(Token_addresses, PriceFeed_addresses, address(dsc));
        
        vm.stopBroadcast();
        return (dsc, dsc_engine, helperConfig);
    }
}
