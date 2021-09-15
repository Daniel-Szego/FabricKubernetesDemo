#!/bin/bash
##
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo

echo "##########################################################"
echo "##### Preparing files #########"
echo "##########################################################"

echo "Chaincode File path:"
echo $1
echo "Client File path:"
echo $2
echo "with explorer"
echo $3

#mkdir -p balancetracker-chaincode/src
#cp -R $1/src/main balancetracker-chaincode/src
#cp $1/build.gradle balancetracker-chaincode
#cp $1/settings.gradle balancetracker-chaincode
#rm -rf balancetracker-chaincode/test

echo "##########################################################"
echo "##### Dev network is starting #########"
echo "##########################################################"

# Shutting down exisiting network
docker-compose -f docker-compose.yml down

# Starting hyperledger fabricchannel
docker-compose -f docker-compose.yml up -d \
orderer.example.com \
peer0.org1.example.com \
couchdb \
cli-setup \
logger \
cli-idemix

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=30
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel

echo ""
echo "##### Creating channel #########"
echo ""

docker exec \
cli-setup peer channel create -o orderer.example.com:7050 \
-c devchannel -f /etc/hyperledger/channel/channel.tx \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Join channel #########"
echo ""

docker exec cli-setup \
peer channel \
fetch 0 bcchannel.block -c devchannel  \
-o orderer.example.com:7050  \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec cli-setup \
peer channel join -b bcchannel.block  \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem


echo ""
echo "##### List channels #########"
echo ""

docker exec cli-setup peer channel list

echo ""
echo "##### Update Anchor peer #########"
echo ""

docker exec cli-setup peer channel update -o orderer.example.com:7050 \
-c devchannel -f /etc/hyperledger/channel/Org1MSPanchors.tx \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem


echo ""
echo "##### Package chaincode #########"
echo ""

docker exec cli-setup peer lifecycle chaincode package test.tar.gz \
--path /chaincode/test/go --label test \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem


echo ""
echo "##### Install chaincode #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode install test.tar.gz \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Query installed chaincode #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode queryinstalled

package_id=$(docker exec cli-setup peer lifecycle chaincode queryinstalled | grep 'Package ID' | sed 's/Package ID:* //' | sed 's/,.*//')
echo ${package_id}

echo ""
echo "##### Approve chaincode for org #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode approveformyorg --channelID devchannel --name test --version 1.0 --init-required --package-id ${package_id} --sequence 1 \
-o orderer.example.com:7050 \
--collections-config /privdatacollection/privdatacollection.json \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Check commit readiness #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode checkcommitreadiness --channelID devchannel --name test --version 1.0 --init-required --sequence 1 \
-o orderer.example.com:7050 \
--collections-config /privdatacollection/privdatacollection.json \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Commit chaincode #########"
echo ""


docker exec cli-setup \
peer lifecycle chaincode commit \
-o orderer.example.com:7050 \
--channelID devchannel --name test --version 1.0 --sequence 1 --init-required \
--collections-config /privdatacollection/privdatacollection.json \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt


docker exec cli-setup \
peer lifecycle chaincode querycommitted  \
--channelID devchannel --name test \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Init chaincode #########"
echo ""

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n test  \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":[]}' --isInit --waitForEvent


echo ""
echo "##### Test transactions - normal #########"
echo ""

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n test \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":["SaveData","id1","data1"]}' --waitForEvent

echo ""
echo "##### Query chaincode after normal #########"
echo ""

docker exec cli-setup \
peer chaincode query -C devchannel -n test -c '{"Args":["ReadData","id1"]}'


echo ""
echo "##### Test transactions - private data #########"
echo ""

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n test \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":["SavePrivData","id1","data1"]}' --waitForEvent

echo ""
echo "##### Query chaincode private data #########"
echo ""

docker exec cli-setup \
peer chaincode query -C devchannel -n test -c '{"Args":["GetPrivData","id1"]}'

echo ""
echo "##### Test transactions - tranisent field and private data #########"
echo ""

export testTrasient=$(echo -n "test transient data" | base64 | tr -d \\n)

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n test \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":["SavePrivDataTransient","id2"]}' \
--transient "{\"data\":\"$testTrasient\"}" \
--waitForEvent

echo ""
echo "##### Query chaincode private data for transient #########"
echo ""

docker exec cli-setup \
peer chaincode query -C devchannel -n test -c '{"Args":["GetPrivData","id2"]}'


echo ""
echo "##### Test transactions - Idemix#########"
echo ""

docker exec cli-idemix \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n test \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":["SaveData","id1","data1"]}' --waitForEvent


echo "##########################################################"
echo "##### Network is finishing #########"
echo "##########################################################"

echo "##########################################################"
echo "##### Start monitoring tools #########"
echo "##########################################################"


echo "##### explorerdb #########"
docker-compose -f docker-compose.yml up -d explorerdb

echo "##### explorer #########"
docker-compose -f docker-compose.yml up -d explorer

echo "##### prometheus and grafana #########"
docker-compose -f docker-compose.yml up -d prometheus grafana

echo "##### start ELK #########"
#docker-compose -f docker-compose.yml up -d elasticsearch logstash kibana

echo "##### start flutned #########"
#docker-compose -f docker-compose.yml up -d logger

echo "##########################################################"
echo "##### End start monitoring tools #########"
echo "##########################################################"

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0


: '