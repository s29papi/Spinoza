// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { SpinozaV0DataVault } from "./SpinozaV0DataVault.sol";

contract SpinozaV0Spool {


    address storageProvider;
    event SwapedData( string dataType, uint256 indexed pieceSize,  string indexed payloadCid,  string indexed dataURI,  uint256 ask, bool funded);

        
    constructor (address _storageProvider) {
        storageProvider = _storageProvider;
    }


    function swapInDataAndWaitforPreCommit(address datavault, string memory cid) external {
       SpinozaV0DataVault.properties memory value = SpinozaV0DataVault(datavault).swapOutDataAndPrecommit(cid);
       emit SwapedData(value.dataType, value.pieceSize, value.payloadCid, value.dataURI, value.ask, value.funded);
    }





}