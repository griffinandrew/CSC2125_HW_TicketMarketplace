// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ITicketNFT} from "./interfaces/ITicketNFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TicketNFT} from "./TicketNFT.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol"; 
import {ITicketMarketplace} from "./interfaces/ITicketMarketplace.sol";
import "hardhat/console.sol";

contract TicketMarketplace is ITicketMarketplace {
    // your code goes here (you can do it!)

    address public nftContract;
    address public ERC20Address;
    uint128 public currentEventId = 0;
    address public owner;

    constructor(address _erc20Address) {
        //nftContract = _nftContract;
        owner = msg.sender;
        ERC20Address = _erc20Address;
        TicketNFT nft = new TicketNFT();
        nftContract = address(nft);
    }

    mapping(uint128 => Event) public events; // eventId => Event struct

    struct Event {
        uint128 maxTickets;
        uint256 pricePerTicket;
        uint256 pricePerTicketERC20;
        uint128 nextTicketToSell;
    }

    function createEvent(uint128 maxTickets, uint256 pricePerTicket, uint256 pricePerTicketERC20) external {

        //maybe sure only contract owner can create events
        //otherwise: "Unauthorized access"
        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        /// not sure where need to mint the ERC20... 

        uint128 nextTicketToSell = 0;
        //create the event struct
        events[currentEventId] = Event(maxTickets, pricePerTicket, pricePerTicketERC20, nextTicketToSell);

        emit EventCreated(currentEventId, maxTickets, pricePerTicket, pricePerTicketERC20);

        //update event id for the next event 
        ++currentEventId;
    }

    //think this needs to be ownabale too bc need to check if access is authorized
    function setMaxTicketsForEvent(uint128 eventId, uint128 newMaxTickets) external{
        //only owner can update the max tickets
        //otherwise: "Unauthorized access"
        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        //ensure that the new max tickets is greater than the current max tickets
        if (newMaxTickets < events[eventId].maxTickets){
            revert("The new number of max tickets is too small!");
        }
        events[eventId].maxTickets = newMaxTickets;
        emit MaxTicketsUpdate(eventId, newMaxTickets);

    }

    function setPriceForTicketETH(uint128 eventId, uint256 price) external{
        //only owner can update the price
        //otherwise: "Unauthorized access"
        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        events[eventId].pricePerTicket = price;

        emit PriceUpdate(eventId, price, "ETH");
    }

    function setPriceForTicketERC20(uint128 eventId, uint256 price) external{
        //only owner can update the price
        //otherwise: "Unauthorized access"
        if (msg.sender != owner){
            revert("Unauthorized access");
        }

        //update struct 
        events[eventId].pricePerTicketERC20 = price;

        emit PriceUpdate(eventId, price, "ERC20");
    }

    function buyTickets(uint128 eventId, uint128 ticketCount) payable external{
        // need to calc ticket price and use the assertion 
        //assert(price * events[eventId].maxTickets < 2**256 - 1);
        //"Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets."

        // "Not enough funds supplied to buy the specified number of tickets."

        //check for overflow
        unchecked {
            if (events[eventId].pricePerTicket * ticketCount / ticketCount != events[eventId].pricePerTicket){
                revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
            }
        }

        //ensure there is enough tickets to buy 

        if (events[eventId].nextTicketToSell + ticketCount > events[eventId].maxTickets)
        {
            revert("We don't have that many tickets left to sell!");
        }

        //msg.val is the amount of eth sent to the contract
        if (msg.value < events[eventId].pricePerTicket * ticketCount){
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }
    
        //events[eventId].nextTicketToSell += ticketCount;

        //need to calc the nft id to send to function

        //should be mints as many tickets as the user bought

        for (uint128 i = 0; i < ticketCount; ++i){

            uint256 id = eventId;
            uint256 next = events[eventId].nextTicketToSell;
            uint256 nftId = (id << 128) + next;
            console.log("nftId before mint: ", nftId);

            ITicketNFT(nftContract).mintFromMarketPlace(msg.sender, nftId);
            events[eventId].nextTicketToSell++;
            console.log("nftId: ", nftId);
            console.log("nextTicketToSell: ", events[eventId].nextTicketToSell);
            console.log("eventId: ", eventId);
            console.log("pricePerTicket: ", events[eventId].pricePerTicket);
            console.log("user account ", msg.sender);
            console.log("owner account: ", owner);
        }


        emit TicketsBought(eventId, ticketCount, "ETH");
    }

    function buyTicketsERC20(uint128 eventId, uint128 ticketCount) external{

        //check for overflow
        unchecked {
            if (events[eventId].pricePerTicketERC20 * ticketCount / ticketCount != events[eventId].pricePerTicketERC20){
                revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
            }
        }

        if (events[eventId].nextTicketToSell + ticketCount > events[eventId].maxTickets)
        {
            revert("We don't have that many tickets left to sell!");
        }

        if (IERC20(ERC20Address).balanceOf(msg.sender) < events[eventId].pricePerTicketERC20 * ticketCount){
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }

        //should now mint 
        for (uint128 i = 0; i < ticketCount; ++i){
            uint256 id = eventId;
            uint256 next = events[eventId].nextTicketToSell;
            uint256 nftId = (id << 128) + next;
            //console.log("eventId << 128:", eventId << 128);
            console.log("nftId before mint: ", nftId);
            
            ITicketNFT(nftContract).mintFromMarketPlace(msg.sender, nftId);
            events[eventId].nextTicketToSell++;
            console.log("nftId: ", nftId);
            console.log("nextTicketToSell: ", events[eventId].nextTicketToSell);
            console.log("eventId: ", eventId);
            console.log("pricePerTicketERC20: ", events[eventId].pricePerTicketERC20);
            console.log("user account ", msg.sender);
            console.log("owner account: ", owner);
        }

        IERC20 token = IERC20(ERC20Address);

        token.transferFrom(msg.sender, address(this), events[eventId].pricePerTicketERC20 * ticketCount);

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