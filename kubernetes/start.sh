#!/bin/bash
##
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

# useful commands

# kubectl cluster-info



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

echo "##########################################################"
echo "##### Prod network is starting #########"
echo "##########################################################"

echo "##### Setting one install #########"

kubectl create -f fabric/



echo ""
echo "##### Creating channel #########"
echo ""

# login to setup pod 

kubectl exec -it clisetup-0 sh  

peer channel create -o orderer:7050 \
-c devchannel -f /etc/hyperledger/channel/channel.tx \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlsca.example.com-cert.pem

echo ""
echo "##### Join channel #########"
echo ""

peer channel \
fetch 0 devchannel.block -c devchannel  \
-o orderer:7050  \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlsca.example.com-cert.pem


peer channel join -b devchannel.block  \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlsca.example.com-cert.pem


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

docker exec cli-setup peer lifecycle chaincode package marbles.tar.gz \
--path /chaincode/marbles/go --label marbles \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem


echo ""
echo "##### Install chaincode #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode install marbles.tar.gz \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Query installed chaincode #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode queryinstalled

echo ""
echo "##### Approve chaincode for org #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode approveformyorg --channelID devchannel --name marbles --version 1.0 --init-required --package-id marbles:78a2f9b1b1518055acf6248f0533095ecabaca6caacacc696fd56325226d6519 --sequence 1 \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Check commit readiness #########"
echo ""

docker exec cli-setup \
peer lifecycle chaincode checkcommitreadiness --channelID devchannel --name marbles --version 1.0 --init-required --sequence 1 \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Commit chaincode #########"
echo ""


docker exec cli-setup \
peer lifecycle chaincode commit \
-o orderer.example.com:7050 \
--channelID devchannel --name marbles --version 1.0 --sequence 1 --init-required \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt


docker exec cli-setup \
peer lifecycle chaincode querycommitted  \
--channelID devchannel --name marbles \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem

echo ""
echo "##### Init chaincode #########"
echo ""

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n marbles  \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":[]}' --isInit --waitForEvent


echo ""
echo "##### Test transactions - init marbles #########"
echo ""

docker exec cli-setup \
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls --cafile /etc/hyperledger/crypto/orderer/msp/tlscacerts/tlsca.example.com-cert.pem \
-C devchannel -n marbles \
--peerAddresses peer0.org1.example.com:7051 \
--tlsRootCertFiles /etc/hyperledger/crypto/peer/tls/ca.crt \
-c '{"Args":["initMarble","marble1","blue","35","tom"]}' --waitForEvent

echo ""
echo "##### Query chaincode after first aid #########"
echo ""

docker exec cli-setup \
peer chaincode query -C devchannel -n marbles -c '{"Args":["readMarble","marble1"]}'


echo "##########################################################"
echo "##### Network is finishing #########"
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


echo "##########################################################"
echo "##### Setup of network has finished #########"
echo "##########################################################"

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
