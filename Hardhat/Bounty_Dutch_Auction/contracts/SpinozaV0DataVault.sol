// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { MarketAPI } from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import { MarketTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
// create a deal, monitor a deal, renew a deal, replicate data, insure data
contract SpinozaV0DataVault {

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

    address public owner;
    
    // cid, is either the piece cid or payload cid from ipfs 
    // mapping ( string cid => properties prop ) public data;
    mapping ( string => properties ) public data;

    event DataTokenized(string indexed cid, uint256);
    uint256 public totalTokenized;
    uint256 public totalOwned;
    

    struct properties {
        string dataType;
        // duration is deal info
        uint256 pieceSize;
        // for ipfs data, payload cid != piececid
        string payloadCid;
        // specify deals this is == replication factor

        // where the data was pinned on ipfs
        string dataURI;

        uint256 ask;

        string dealCid;

        bool funded;

        uint256 bounty;
    }


    constructor (address _owner) {
        owner = _owner;
    }
    
    

    function tokenizeData(
        properties memory prop,
        string memory cid,
        uint256 replicationFactor
        ) public onlyOwner {
            require(replicationFactor >= 8, "R.F must be greater than or equals to 8");
            data[cid] = prop;
            totalTokenized += replicationFactor;
            totalOwned += replicationFactor;
        
            emit DataTokenized(cid, prop.pieceSize);
    }


 
    function setAsk(string memory cid, uint256 amount) public {
        data[cid].ask = amount;
    }

    function setDealCid(string memory cid, string memory dealCid) public {
        data[cid].dealCid = dealCid;
    }

    // fund tokenized data only after ask has been called
    function fundTokenizedData(
        string memory cid
        ) external payable {
        require(data[cid].ask == msg.value, "ask must equal msg.value");
        data[cid].funded = true;
    }

    function swapOutDataAndPrecommit(
        string memory cid
    ) public view returns (properties memory){
        // client also adds balance to the storage market actor
        return data[cid];
    }

    function renewal(string memory cid, uint256 replicationFactor) public {
        tokenizeData(data[cid], cid, replicationFactor);
    }

    function checkDealActivation(uint64 dealID) external {
        MarketTypes.GetDealActivationReturn memory dealActivation = MarketAPI.getDealActivation(dealID);
        if (dealActivation.activated == 0) revert ("Deal Not yet Activated");
    }

}



    

 

