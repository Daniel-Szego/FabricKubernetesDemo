/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

// InitLedger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// Save data
func (s *SmartContract) SaveData(ctx contractapi.TransactionContextInterface, id string, data string) error {

	dataByte := []byte(data)

	return ctx.GetStub().PutState(id, dataByte)
}

// Read data
func (s *SmartContract) ReadData(ctx contractapi.TransactionContextInterface, id string) (string) {
 
	retValue, err := ctx.GetStub().GetState(id)

	if err != nil {
		return "error"
	}

	retValueString := string(retValue)

	return retValueString
}

// Save priv data
func (s *SmartContract) SavePrivData(ctx contractapi.TransactionContextInterface, id string, data string) error {

	dataByte := []byte(data)

	return ctx.GetStub().PutPrivateData("testCollection", id, dataByte)

}

// Save priv data
func (s *SmartContract) GetPrivData(ctx contractapi.TransactionContextInterface, id string) (string) {

	retValue, err := ctx.GetStub().GetPrivateData("testCollection", id)

	if err != nil {
		return "error"
	}

	retValueString := string(retValue)

	return retValueString
}

// Save private data with transient
func (s *SmartContract) SavePrivDataTransient(ctx contractapi.TransactionContextInterface, id string) error {

	transData, err := ctx.GetStub().GetTransient()

	if err != nil {
		return err
	}

	privateTransientDATA, ok := transData["data"]

	if !ok {
        return fmt.Errorf("data key not found in the transient map")
	}

	return ctx.GetStub().PutPrivateData("testCollection", id, privateTransientDATA)

}


func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create test chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting test chaincode: %s", err.Error())
	}

}