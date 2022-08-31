// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol";


contract MyToken is ERC721, ERC721Enumerable, ERC2981, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; // Counter to identify the current TokenID 

    /**
    * @dev Paramaters provided for deployment
    */
    uint256 venueSize;
    uint public mintRate;
    /* string public contractURI; */


   /**
    * @dev Constructor
    */
    constructor(
        uint96 _royaltyFeesInBips,
        /* string memory _contractURI,*/
        string memory _eventName,
        string memory _ticketSymbol,
        uint256 _venueSize,
        uint256 _mintRate
    ) ERC721(_eventName, _ticketSymbol) {
        setRoyaltyInfo(owner(), _royaltyFeesInBips);
        /*contractURI = _contractURI;*/
        venueSize = _venueSize;
        mintRate = (_mintRate * 1 ether);
    }

/* MODIFIERS */

    /**
    * @dev Checks if we have tickets
    */
    modifier isAvailable(){
        require((_tokenIdCounter.current() < venueSize), "Sold out");
        _;
    }

/* FUNCTIONS */

    /**
    * @dev To Pause and unpause event, controls whenNotPaused modifier
    */
    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }

    /*
    * @dev Minting a new Ticket
    */
    function safeMint(address to, uint256 _amount) public payable isAvailable /*whenNotPaused*/{
        // Require the amount of tickets wanting to be purchased does not exceed venue size
        require(_amount <= (venueSize - _tokenIdCounter.current()), "Not enough avaliable tickets");

        // Require that the wallet has enough to purchase tickets
        require(msg.value >= (mintRate * _amount), "Not enough ether");

        // For the amount of tickets purchased
        for(uint256 i = 0; i < _amount; i++){
            _tokenIdCounter.increment(); // Increment tokenId
            _safeMint(to, _tokenIdCounter.current()); // Mint ticket at current tokenId
        }
    }

    /**
    * @dev To transfer ticket from one wallet to another
    */

   
   
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable) // attempted override 
    {
        super._beforeTokenTransfer(from, to, tokenId); // Inheriting from OpenZeopplin
    } 
   
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /*
    @dev Royalties for artist from each transfer
    */
    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    /*function setContractURI(string calldata _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }*/
    
}

