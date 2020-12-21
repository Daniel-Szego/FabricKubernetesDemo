
# Admin@org1.example.com

kubectl create secret generic admin.org1.example.com.msp.tlscacerts --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem -o yaml

kubectl create secret generic admin.org1.example.com.msp.cacerts --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/cacerts/ca.org1.example.com-cert.pem -o yaml

kubectl create secret generic admin.org1.example.com.msp.keystore --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk -o yaml

kubectl create secret generic admin.org1.example.com.msp.signcerts --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin.org1.example.com-cert.pem -o yaml

kubectl create secret generic admin.org1.example.com.msp --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/ -o yaml

# Admin@org1.example.com secrets : tls

kubectl create secret generic admin.org1.example.com.tls.ca --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/ca.crt -o yaml

kubectl create secret generic admin.org1.example.com.tls.client.crt --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt -o yaml

kubectl create secret generic admin.org1.example.com.tls.client.key --from-file=crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key -o yaml

# Peer0 secrets : msp

kubectl create secret generic peer0.org1.example.com.msp.cacerts --from-file=crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/ca.org1.example.com-cert.pem -o yaml

kubectl create secret generic peer0.org1.example.com.msp.keystore --from-file=crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/keystore/priv_sk -o yaml

kubectl create secret generic peer0.org1.example.com.msp.signcerts --from-file=crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/signcerts/peer0.org1.example.com-cert.pem -o yaml

kubectl create secret generic peer0.org1.example.com.msp --from-file=crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/ -o yaml

# Peer0 secrets : tls

kubectl create secret generic peer0.org1.example.com.tls --from-file=crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ -o yaml

# Orderer secrets : msp

kubectl create secret generic orderer.example.com.msp.cacerts --from-file=crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/ca.example.com-cert.pem -o yaml

kubectl create secret generic orderer.example.com.msp.keystore --from-file=crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/keystore/priv_sk -o yaml

kubectl create secret generic orderer.example.com.msp.signcerts --from-file=crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/orderer.example.com-cert.pem -o yaml

kubectl create secret generic orderer.example.com.msp --from-file=crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/ -o yaml

# Orderer secrets : tls

kubectl create secret generic orderer.example.com.tls --from-file=crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ -o yaml

kubectl create secret generic orderer.example.com.tls.ordertlscacert --from-file=crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem -o yaml

# Orderer import genesis block and channel configuration

kubectl create secret generic allchannelconfigs --from-file=config/ -o yaml

kubectl create secret generic genesis.block --from-file=config/genesis.block -o yaml

kubectl create secret generic channel.tx --from-file=config/channel.tx -o yaml

kubectl create secret generic orgmspanchors.tx --from-file=config/Org1MSPanchors.tx -o yaml


