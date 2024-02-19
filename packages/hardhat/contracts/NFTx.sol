//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTx is ERC721URIStorage, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private currentId;

  bool public saleIsActive = false;
  uint256 public totalTickets = 10;
  uint256 public availableTickets = 10;
  uint256 public mintPrice = 0.1 ether;

  mapping (address => uint[]) public holderTokenIDs;
  mapping(address => bool) public checkIns;

  constructor() ERC721("NFTx", "NFTx") {
    currentId.increment();
  }

  function mint() public payable{

    require(availableTickets > 0, "Tickets are not available");
    require(msg.value >= mintPrice, "Not enough ETH!");
    require(saleIsActive, "Tickets are not on sale!");

    string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "NFTx #',
                        Strings.toString(currentId.current()),
                        '", "description": "A NFT-powered ticketing system", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "false" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://QmPwUPQHFKFvZjmyt3samCQTPyb2mr6mNouMc84xWdyFHj" }'
                    )
                )
            )
      );

    string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
    );

    
    _safeMint(msg.sender, currentId.current());
    console.log(tokenURI);
    _setTokenURI(currentId.current(), tokenURI);

    holderTokenIDs[msg.sender].push(currentId.current());

    currentId.increment();
    availableTickets -= 1;

  }

  function checkIn(address user) public {
        checkIns[user] = true;
        uint256 tokenId = holderTokenIDs[user][0];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "NFTix #',
                        Strings.toString(tokenId),
                        '", "description": "A NFT-powered ticketing system", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "true" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://QmTHNkB3VwuAd7cLF1vVzumX18osfwLLHiLg6QS36kgXPc" }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _setTokenURI(tokenId, tokenURI);
  }
    
  function openSale() public onlyOwner {
    saleIsActive = true;
  }

  function closeSale() public onlyOwner {
    saleIsActive = false;
  }


  function displayAvailableTickets() public view returns(uint256){
    return availableTickets;
  }

  function displayTotalTickets() public view returns(uint256){
    return totalTickets;
  }

  function confirmOwnership(address addy) public view returns (bool) {
        return holderTokenIDs[addy].length > 0;
  }


}
