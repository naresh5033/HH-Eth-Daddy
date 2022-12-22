// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ETHDaddy is ERC721 {
    uint256 public maxSupply;
    uint256 public totalSupply; //the actual no of nfts that has been created
    address public owner;

    struct Domain {
        string name;
        uint256 cost;
        bool isOwned;
    }
    //map the domain id to domain
    mapping(uint256 => Domain) domains;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    //we ve to 1.model a domain(struct), 2.save the domains(in mapping) 3.update the total count(dynamically)/maxsupply

    function list(string memory _name, uint256 _cost) public onlyOwner {
        maxSupply++;
        domains[maxSupply] = Domain(_name, _cost, false); //struct
    }
    //minting constraint id shouldn't be 0, the id is LT maxsupply, its not already owned, and val msg val should be GTE to listed cost
    function mint(uint256 _id) public payable {
        require(_id != 0);
        require(_id <= maxSupply);
        require(domains[_id].isOwned == false);
        require(msg.value >= domains[_id].cost);
        //it can be owned after passing all the constraints
        domains[_id].isOwned = true;
        //once its owned inc the total supply
        totalSupply++;
        //safemint from erc721
        _safeMint(msg.sender, _id); 
    }

    function getDomain(uint256 _id) public view returns (Domain memory) {
        return domains[_id];
    }
    //get the bal of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    //only owner can be able to withdraw the amt, (passing the bal of this contract to owner)
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
