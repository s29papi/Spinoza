// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


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

        bool funded;

    }


    constructor (address _owner) {
        owner = _owner;
    }
    
    

    function tokenizeData(
        properties memory prop,
        string memory cid,
        uint256 replicationFactor
        ) external onlyOwner {
            require(replicationFactor >= 8, "R.F must be greater than or equals to 8");
            data[cid] = prop;
            totalTokenized += replicationFactor;
            totalOwned += replicationFactor;
        
            emit DataTokenized(cid, prop.pieceSize);
    }


 
    function setAsk(string memory cid, uint256 amount) public {
        data[cid].ask = amount;
    }

    // fund tokenized data only after ask has been called
    function fundTokenizedData(
        uint256 amount, 
        string memory cid
        ) external payable {
        require(data[cid].ask == amount, "ask must equal msg.value");
        data[cid].funded = true;
    }

    function swapOutDataAndPrecommit(
        string memory cid
    ) public view returns (properties memory){
       
        // client also adds balance to the storage market actor
        return data[cid];
    }

  





    function destroyTokenizedData(string memory _cid) external view returns (string memory) {
        return "Not Yet Supported at the moment";
    }


    function setPayloadCid(string memory _payloadCid) external onlyOwner {
        data[_payloadCid].payloadCid = _payloadCid;
    }

    function getDataUri(string memory _cid) public view returns (string memory) {
        return data[_cid].dataURI;
    }



}


 

    

 

