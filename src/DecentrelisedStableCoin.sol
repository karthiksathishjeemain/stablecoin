// SPDX-License-Identifier:MIT
/*Layout of Contract:
version
imports
errors
interfaces, libraries, contracts
Type declarations
State variables
Events
Modifiers
Functions

Layout of Functions:
constructor
receive function (if exists)
fallback function (if exists)
external
public
internal
private
view & pure functions*/

pragma solidity ^0.8.9;

import {ERC20Burnable, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error DecentralizedStableCoin_amountshouldbegreaterthanzero();
error DecentralizedStableCoin_CannotBurnMoreThanBalance();
error DecentralizedStableCoin_ZeroAddress();

contract DecentralizedStableCoin is ERC20Burnable {
    constructor() ERC20("DecentralizedStableCoin", "DSC") {}
    // modifier onlyOwner() {}

    function burn(uint256 amount) public override /*onlyOwner */ {
        if (amount <= 0) {
            revert DecentralizedStableCoin_amountshouldbegreaterthanzero();
        }
        if (balanceOf(msg.sender) < amount) {
            revert DecentralizedStableCoin_CannotBurnMoreThanBalance();
        }
        super.burn(amount);
    }

    function mint(address _to, uint256 amount) public /*onlyOwner*/ returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin_ZeroAddress();
        }
        if (amount <= 0) {
            revert DecentralizedStableCoin_amountshouldbegreaterthanzero();
        }
        _mint(_to, amount);
        return true;
    }
}
