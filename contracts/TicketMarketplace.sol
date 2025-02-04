// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ITicketNFT} from "./interfaces/ITicketNFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TicketNFT} from "./TicketNFT.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol"; 
import {ITicketMarketplace} from "./interfaces/ITicketMarketplace.sol";
import "hardhat/console.sol";


//is this the only way to do it? 
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TicketMarketplace is ITicketMarketplace {
    // your code goes here (you can do it!)

    //address owner; // idk need to kow address of owner ... and set it intially so can 
    //verify that only the owner is touching it.... 

    address public nftContract;
    address public ERC20Address;
    uint128 public currentEventId = 0;
    address public owner;

    constructor(address _erc20Address) {
        //nftContract = _nftContract;
        owner = msg.sender;
        ERC20Address = _erc20Address;
    }

    mapping(uint128 => Event) public events; // eventId => Event struct

    struct Event {
        uint128 maxTickets;
        uint256 pricePerTicket;
        uint256 pricePerTicketERC20;
        uint128 ticketsSold;
        uint128 nextTicketToSell;
    }

    //will incurr high gas....
    //uint128 public nextEventId = 0;

    function createEvent(uint128 maxTickets, uint256 pricePerTicket, uint256 pricePerTicketERC20) external {


        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        //maybe sure only contract owner can create events

        //otherwise: "Unauthorized access"

        //some func that creates a new event and returns the num ...
        
        //uint128 eventID = new Event(maxTickets, pricePerTicket, pricePerTicketERC20);

        //need to mint the tickets for the event

        //I use will have to loop to create tickets up to max tickets
        //for (uint128 i = 0; i < maxTickets; i++){
            //where r these being stored tho... do i need to emit an event....
         //   TicketNFT ticketNFT = new TicketNFT();
            //according to write up I think....
          //  uint256 nftId = (nextEventId << 128) + i;
            //ticketNFT.mintFromMarketPlace(msg.sender, nftId);
        //}

        /// not sure where need to  mint the ERC20... 

        uint128 ticketsSold = 0;
        uint128 nextTicketToSell = 0;

        events[currentEventId] = Event(maxTickets, pricePerTicket, pricePerTicketERC20, ticketsSold, nextTicketToSell);


        emit EventCreated(currentEventId, maxTickets, pricePerTicket, pricePerTicketERC20);

        //update event id for the next event 
        ++currentEventId;
    }

    //think this needs to be ownabale too bc need to check if access is authorized
    function setMaxTicketsForEvent(uint128 eventId, uint128 newMaxTickets) external{
        //need to make some max tickets variable.. for each event...

        //only owner can update the max tickets
        //otherwise: "Unauthorized access"
        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        //this should actually be a require 
        //require(newMaxTickets >= events[eventId].ticketsSold, "The new number of max tickets is too small!");

        if (newMaxTickets < events[eventId].maxTickets){
            revert("The new number of max tickets is too small!");
        }
        events[eventId].maxTickets = newMaxTickets;
        emit MaxTicketsUpdate(eventId, newMaxTickets);

    }

    function setPriceForTicketETH(uint128 eventId, uint256 price) external{

        //update struct 

        //only owner can update the price

        //otherwise: "Unauthorized access"

        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        events[eventId].pricePerTicket = price;

        emit PriceUpdate(eventId, price, "ETH");
    }

    function setPriceForTicketERC20(uint128 eventId, uint256 price) external{

        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        //only owner can update the price
        
        //otherwise: "Unauthorized access"

        //update struct 
        events[eventId].pricePerTicketERC20 = price;

        emit PriceUpdate(eventId, price, "ERC20");
    }

    function buyTickets(uint128 eventId, uint128 ticketCount) payable external{


         // need to calc ticket price and use the assertion 
        //assert(price * events[eventId].maxTickets < 2**256 - 1);
        //"Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets."

        // "Not enough funds supplied to buy the specified number of tickets."

        //ensure there is enough tickets to buy 
        //require(events[eventId].ticketsSold + ticketCount < events[eventId].maxTickets, "We don't have that many tickets left to sell!");
        //add to number of tickets sold

        if (events[eventId].ticketsSold + ticketCount < events[eventId].maxTickets)
        {
            revert("We don't have that many tickets left to sell!");
        }

        if (msg.value < events[eventId].pricePerTicket * ticketCount){
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }

        //check for overflow 

        if (msg.value >= events[eventId].pricePerTicket * ticketCount){
            payable(msg.sender).transfer(msg.value - events[eventId].pricePerTicket * ticketCount);
        }

        events[eventId].ticketsSold += ticketCount;

        emit TicketsBought(eventId, ticketCount, "ETH");
    }

    function buyTicketsERC20(uint128 eventId, uint128 ticketCount) external{


         // need to calc ticket price and use the assertion  
        //assert(price * events[eventId].maxTickets < 2**256 - 1);

        //also...
        //"Not enough funds supplied to buy the specified number of tickets."

        //ensure there is enough tickets to buy 
        //require(events[eventId].ticketsSold + ticketCount <= events[eventId].maxTickets, "We don't have that many tickets left to sell!");
        //add to number of tickets sold

        if (events[eventId].ticketsSold + ticketCount < events[eventId].maxTickets)
        {
            revert("We don't have that many tickets left to sell!");
        }

        events[eventId].ticketsSold += ticketCount;

        
        emit TicketsBought(eventId, ticketCount, "ERC20");

    }

    function setERC20Address(address newERC20Address) external{

        //if not the owner 
        // give err: "Unauthorized access"

        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        ERC20Address = newERC20Address;

        emit ERC20AddressUpdate(ERC20Address);

    }
}