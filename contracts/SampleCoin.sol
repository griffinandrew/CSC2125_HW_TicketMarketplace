// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";


//i do think that this has to be owned by the marketplace contract
//not sure how to properly construct it tho like that ....
contract SampleCoin is ERC20 {
    // your code goes here (you can do it!)

//just a first shot at trying it out... 
//i need ownability and perhaps some initial supply minted at the begining? 

    //not sure about this constructor

    constructor() ERC20("SampleCoin", "SC") {
        _mint(msg.sender, 100 * 10**18);
    }

    //idk if need this... same with burn but saw example... 
    //not sure if we be called in other code ... 
    function mint(address to, uint256 amount) external{
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external{
        _burn(from, amount);
    }
}

