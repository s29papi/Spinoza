// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { PowerAPI } from "@zondax/filecoin-solidity/contracts/v0.8/PowerAPI.sol";
import { PowerTypes } from "@zondax/filecoin-solidity/contracts/v0.8/types/PowerTypes.sol";
import { BigIntCBOR } from "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import { SpinozaV0Spool } from "./SpinozaV0Spool.sol";


contract SpinozaV0Lend {
    // sp id to sp state
    mapping ( uint64 => storageProviderState ) public registeredStorageProviders;
    mapping ( address => uint64 ) public storageProvidersbyAddress;
    mapping(address => uint256) public spinBalances;
    mapping(address => uint256) public filecoinBalances;

    event Deposited(address depositor, uint256 filecoinAmount);
    event Withdrawn(address withdrawer, uint256 filecoinAmount);
    event Borrowed(address borrower, uint256 filecoinAmount);
    event Repayed(address borrower, uint256 filecoinAmount);
    event Liquidated(address borrower, uint256 filecoinAmount);

    uint256 minerRawPower;
    uint256 fee = 5;

    struct storageProviderState {
        bool passedDuediligence;
        address minerAddr;
        storageProviderStatus status;
        marketState market;
    }

    struct marketState {
        address marketAddr;
        uint256 collateral;
        uint256 storagePrice;
    }

    enum storageProviderStatus {
        notRegistered,
        Registered,
        MarketCreated
    }

    modifier onlySP {
        require (
            registeredStorageProviders[storageProvidersbyAddress[msg.sender]].status == storageProviderStatus(1),
            "Only Sp can call this function."
        );
        _;
    }

    modifier onlyOnce {
        require (
            registeredStorageProviders[storageProvidersbyAddress[msg.sender]].status == storageProviderStatus(2),
            "Sp can call this function only once."
        );
        _;
    }



   
    
 

    // replace with better scope
    function setDummyMinerRawPower() external {
      uint64 minerID = 1129;
      PowerTypes.MinerRawPowerReturn memory rawPowerRet = PowerAPI.minerRawPower(minerID);
      if (!rawPowerRet.meets_consensus_minimum) revert ("LESS_THAN_CONSENSUS_MINIMUM");
        bytes memory raw_byte_power = BigIntCBOR.serializeBigInt(rawPowerRet.raw_byte_power);
        bytes32 temp_raw_byte_power = bytes32(raw_byte_power);
        uint256 raw_uint_power = uint256(temp_raw_byte_power);
        minerRawPower = raw_uint_power;
    }
    
    // for now the criteria for an Sp registering is that it meets the MinerRawPower
    function registerAsSp(
        uint64 minerID
    ) external {
        PowerTypes.MinerRawPowerReturn memory rawPowerRet = PowerAPI.minerRawPower(minerID);
        if (!rawPowerRet.meets_consensus_minimum) revert ("LESS_THAN_CONSENSUS_MINIMUM");
        bytes memory raw_byte_power = BigIntCBOR.serializeBigInt(rawPowerRet.raw_byte_power);
        bytes32 temp_raw_byte_power = bytes32(raw_byte_power);
        uint256 raw_uint_power = uint256(temp_raw_byte_power);
        if (minerRawPower < raw_uint_power) revert ("LESS_THAN_MINIMUM_RAWPOWER()");

        storageProvidersbyAddress[msg.sender]         = minerID;
        registeredStorageProviders[minerID].minerAddr = msg.sender;
        registeredStorageProviders[minerID].status    = storageProviderStatus(1);
    }

    // create market creates a storage pool that swaps in data and swaps in the amount to store the data
    // can only be created once by registered sp
    function createMarket(
        uint256 collateral, 
        uint256 storagePrice) 
        external payable onlySP onlyOnce  {
            require(msg.value == fee, "You are required to pay a fee");
            SpinozaV0Spool spinozaV0Spool = new SpinozaV0Spool(msg.sender);
            registeredStorageProviders[storageProvidersbyAddress[msg.sender]].market.marketAddr = address(spinozaV0Spool);
            registeredStorageProviders[storageProvidersbyAddress[msg.sender]].market.collateral = collateral;
            registeredStorageProviders[storageProvidersbyAddress[msg.sender]].market.storagePrice = storagePrice;
    }

    // Both sPs and investors deposit file coin to mint spin tokens
    // staked spin mean storage capacity
    // held spin means interest
    function deposit() public payable {
        require(msg.value > 0, "Amount must be positive");
        uint256 filecoinAmount = msg.value;
        filecoinBalances[msg.sender] += filecoinAmount;
        spinBalances[msg.sender] += filecoinAmount / 100; 
        emit Deposited(msg.sender, filecoinAmount);
    }

    function borrow(uint256 filecoinAmount) public onlySP {
        require(spinBalances[msg.sender] >= filecoinAmount / 100, "Not enough Spin tokens");
        spinBalances[msg.sender] -= filecoinAmount / 100;
        filecoinBalances[msg.sender] += filecoinAmount;
        emit Borrowed(msg.sender, filecoinAmount);
    }

    function withdraw(uint256 filecoinAmount) public {
        // spin balances not tracked
        require(filecoinBalances[msg.sender] >= filecoinAmount, "Not enough funds");
        filecoinBalances[msg.sender] -= filecoinAmount;
        emit Withdrawn(msg.sender, filecoinAmount);
    }

    function repay(uint256 filecoinAmount) public {
        require(filecoinBalances[msg.sender] >= filecoinAmount, "Not enough borrowed funds");
        filecoinBalances[msg.sender] -= filecoinAmount;
        spinBalances[msg.sender] += filecoinAmount / 100;
        emit Repayed(msg.sender, filecoinAmount);
    }

    receive() external payable {  }

}