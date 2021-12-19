// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    mapping(bytes32 => uint) requestResults;
    mapping(address => uint[]) userRequests;
    string constant baseUrl = "https://ayadhan.herokuapp.com/validate";
    
    /**
     * Network: Matic Testnet
     * Oracle: 0x0bDDCD124709aCBf9BB3F824EbC61C87019888bb (Matrixed.link   
     * Node)
     * Job ID: 2bb15c3f9cfc4336b95012872ff05092
     * Fee: 0.01 LINK
     */
    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        oracle = 0x0bDDCD124709aCBf9BB3F824EbC61C87019888bb;
        jobId = "2bb15c3f9cfc4336b95012872ff05092";
        fee = 0.01 * 10 ** 18; // (Varies by network and job)
    }
    
    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function submitRequest(string memory url) public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", url);
        request.add("path", "comparisonCode");
                
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 comparisonCode) public recordChainlinkFulfillment(_requestId)
    {
        requestResults[_requestId] = comparisonCode;
    }

    function createRequest(string memory prevFenHex, string memory curFenHex) public returns(uint) {
        string memory url = string(abi.encodePacked(baseUrl, '/', prevFenHex, '/', curFenHex));
        uint requestId = uint(submitRequest(url));
        userRequests[msg.sender].push(requestId);
        return requestId;
    }

    function getRequestResult(uint _requestId) public view returns (uint) {
        return requestResults[bytes32(_requestId)];
    }

    function getMyRequestIds() public view returns (uint[] memory) {
        return userRequests[msg.sender];
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
