// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol";
import {DecentralizedStableCoin} from "./DecentrelisedStableCoin.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DSCEngine {
    error didNotPassTheHealthfactor();
    error not_valid_token();
    error SBC_not_minted();
    error DSCEngine_Deposit_failed();
    error DSCEngine_tokenAddressesNotequaltoPriceFeed_Addresses();

    modifier allowed_token(address tokenaddress) {
        if (s_priceFeed[tokenaddress] == address(0)) {
            revert not_valid_token();
            _;
        }
    }

    DecentralizedStableCoin public immutable i_dsc;

    constructor(address[] memory Token_Addresses, address[] memory priceFeed_addresses, address dscaddress) {
        if (Token_Addresses.length != priceFeed_addresses.length) {
            revert DSCEngine_tokenAddressesNotequaltoPriceFeed_Addresses();
        }
        for (uint256 i = 0; i < Token_Addresses.length; i++) {
            s_priceFeed[Token_Addresses[i]] = priceFeed_addresses[i];
            s_token_addresses.push(Token_Addresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscaddress);
    }

    uint256 constant Value_of_SBC_in_USD = 1;
    mapping(address token_address => address pricefeed) public s_priceFeed;
    mapping(address user => uint256 amountofSBC) mintSBC;
    // mapping(address user => address tokenaddress) usertokencollateral;
    mapping(address user => mapping(address token => uint256 amount)) usertokencollateralamount;
    address[] s_token_addresses;

    function Deposit_and_mint(address token_address, uint256 amount_of_token, uint256 amount_of_SBC) public {
        depositcollateral(token_address, amount_of_token);
        _mintSBC(token_address, amount_of_SBC);
    }

    function depositcollateral(address token_address, uint256 amount_of_token) public allowed_token(token_address) {
        /*My idea is put checkhealthfactor in this function -->*/
        // if healthfactor > 1 then only run the above function, as the collatoral needs to be always greater than some ratio of the value of the stable coin
        usertokencollateralamount[msg.sender][token_address] += amount_of_token;
        bool success = IERC20(token_address).transferFrom(msg.sender, address(this), amount_of_token);
        if (success != true) {
            revert DSCEngine_Deposit_failed();
        }
    }

    function _mintSBC(address token_address, uint256 amount_of_SBC) public {
        mintSBC[msg.sender] += amount_of_SBC;
        checkhealthfactor(token_address, amount_of_SBC);
        bool minted = i_dsc.mint(msg.sender, amount_of_SBC);
        if (minted != true) {
            revert SBC_not_minted();
        }
    }

    function checkhealthfactor(address token_address, uint256 amountofSBC) public {
        // uint256 tokenamount = usertokencollateralamount[user];
        bool check = gethealthfactor(token_address, usertokencollateralamount[msg.sender][token_address], amountofSBC);
        if (check != true) {
            revert didNotPassTheHealthfactor();
        }
    }

    function gethealthfactor(address tokenaddress, uint256 amount, uint256 amount_of_SBC) public returns (bool) {
        uint256 health = ((getPriceOfTheCollateral(tokenaddress, amount)) * 50) / (100 * amount_of_SBC); /*=amountofSBC as 1 sbc =1$*/
        return (health > 1);
    }

    function getPriceOfTheCollateral(address tokenaddress, uint256 amount_of_token) public view returns (uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(tokenaddress);
        (, int256 price,,,) = pricefeed.latestRoundData();
        return ((uint256(price) * 1e10) * amount_of_token) / 1e18;
    }
}
