// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMAL = 8;
    int256 public constant Eth_USD_value = 2000e8;
    int256 public constant Bth_USD_value = 1000e8;
    uint256 private ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public active_NetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            active_NetworkConfig = getSepoliaNetwork();
        } else {
            active_NetworkConfig = getAnvilNetwork();
        }
    }

    struct NetworkConfig {
        address wETH_USD;
        address wBTC_USD;
        address wETH;
        address wBTC;
        uint256 Private_key;
    }

    function getSepoliaNetwork() public returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaNetwork = NetworkConfig({
            wETH_USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wBTC_USD: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wETH: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wBTC: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            Private_key: vm.envUint("PRIVATE_KEY")
        });

        return SepoliaNetwork;
    }

    function getAnvilNetwork() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator eth_pricefeed = new MockV3Aggregator( DECIMAL,Eth_USD_value);
        ERC20Mock wETHMock = new ERC20Mock();
        MockV3Aggregator bth_pricefeed = new MockV3Aggregator( DECIMAL,Bth_USD_value);
        ERC20Mock wBTHMock = new ERC20Mock();

        vm.stopBroadcast();
        NetworkConfig memory anvilNetwork = NetworkConfig({
            wETH_USD: address(eth_pricefeed),
            wBTC_USD: address(bth_pricefeed),
            wETH: address(wETHMock),
            wBTC: address(wBTHMock),
            Private_key: ANVIL_PRIVATE_KEY
        });
        return anvilNetwork;
    }
}
