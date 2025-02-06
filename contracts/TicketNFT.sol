// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ITicketNFT} from "./interfaces/ITicketNFT.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";


contract TicketNFT is ERC1155, ITicketNFT {
    // your code goes here (you can do it!)

    address public owner;

    //this def needs to be changed ... i think... 
    constructor() ERC1155("https://fake_marketplace_idk.json") {
        owner = msg.sender;
    }

    function mintFromMarketPlace(address to, uint256 nftId) external {
        //require(balanceOf(to, nftId) == 0, "NFT already exists");
        _mint(to, nftId, 1, "");
    }

}   