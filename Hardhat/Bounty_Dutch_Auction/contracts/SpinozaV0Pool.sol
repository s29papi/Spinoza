// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// create a deal, monitor a deal, renew a deal, replicate data, insure data
contract SpinozaV0Pool {

    address public owner;
    
    mapping ( string cid => properties prop ) public data;

    uint256 public totalTokenized;
    uint256 public totalOwned;

    struct properties {
        string dataType;
        // duration is deal info
        string payloadCid;
        // specify deals this is == replication factor

        // where the data was pinned on ipfs
        string dataURI;

    }


    constructor (address _owner) {
        owner = _owner;
    }
    
    // 1 create a deal with an offchain replication worker
    // a client has pinned data on ipfs on his desktop that he would wont to externally and perpetually store 
    // on filecoin

    // create a way were a client can take data on computer or server pin on ipfs
    // get filecoin predeal parameter
    // new deal post this pre-deal parameters on chain
    // a deal is a mapping and an enum monitored in this contract
    // replication workers know about this deal through events
    // replication workers bid for this deal by listing offers
    // an offer is taking based on a bounty based-dutch auction mechanism and the replication worker reputation stake is freezed
    // the data is represented on chain as an erc721 token
    // on deal activation the replication worker interacts with the storage market actor and call deal active
    // a deal activated nft can then be used to unlock stake plus earn rewards

    // penalty a replication worker is unable to replicate this data on the network he faces a soft slash used to compensate the client 
    // creates an nft owned by this contract
    // 

    function tokenizeData(properties calldata prop) external {
        require(prop.payloadCid != "", "empty payload cid")
        require(prop.dataURI != "", "empty data URI")
        require(prop.dataType != "", "specify data type")
        data[prop.payloadCid] = prop;
        totalTokenized += 1;
        totalOwned += 1;

        // catch error with errors or require
    }
    // to be in the factory createDataPool a single sided amm, contains all about deal and data market
    // function auctionTokenizedData() e

    function fundTokenizedData() external {

    }

    function destroyTokenizedData(string memory _payloadCid) external view returns (string memory) {
        return "Not Yet Supported at the moment";
        // cancels all deals that this token_data was used and frees sps up
    }

}


 

    

 
