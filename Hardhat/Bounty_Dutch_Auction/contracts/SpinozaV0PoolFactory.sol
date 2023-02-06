// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./SpinozaV0DataVault.sol";



contract SpinozaV0DataVaultFactory {

  
    event VaultCreated(address indexed vaultCreated);
    function createVault(address owner) external {
        // calc precise creation + runtime code and change this to inlina-as..
         SpinozaV0DataVault sDVault  = new SpinozaV0DataVault(owner);


        emit VaultCreated(address(sDVault)) ;
        // have a require here to check if it errored
    }




}