//SPDX-License-Identifier:MIT

pragma solidity^0.8.18;

import {ERC20}  from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract DecentralizedStableCoin is ERC20Burnable,Ownable{

error DecentralizedStableCoin_amountMustBeMoreThanZero();
error DecentralizedStableCoin_BurnAmountExceedsBalance();
error DecentralizedStableCoin_NotZeroAddress();

    constructor() ERC20("DECENTRALIZED STABLECOIN", "DSC"){

    }

    function burn(uint256 _amount) override public  onlyOwner {
       uint256 balance = balanceOf(msg.sender);

       if( _amount <= 0) {
        revert DecentralizedStableCoin_amountMustBeMoreThanZero();
       }
       if(_amount > balance) {
        revert DecentralizedStableCoin_BurnAmountExceedsBalance();
       }
       super.burn(_amount); // the super here is used to call a function from the parent contract 
    }

   function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if(_to == address(0)){
            revert DecentralizedStableCoin_NotZeroAddress();
        }
        if(_amount <= 0) {
            revert DecentralizedStableCoin_amountMustBeMoreThanZero();
        }
        _mint(_to,_amount);
        return(true);
   }
}