#Fabric scripts for Kubernetes demo

These scripts are for demonstration only, do yours own research and tests before using in production

FABRIC STRUCTURE:
- 1 Organisation
- 1 Peer
- 1 node Ordering service
- 1 CouchDB
- 1 Setup container

DOCKER:

 folders:
 - chaincode: marbles chaincode
 - config: generated configuration files, like genesisblock or channel config file
 - core: core.yaml config file for the peer
 - crypto-config generated crypto material

 scripts:
 - generate.sh - generate crypto materials and config files
 - start.sh - start the network
 - teardown.sh - delete the network (docker volumes might need to be deleted manually)

explorer: http://localhost:8080
prometheus: http://localhost:9090
grafana: http://localhost:3000 (admin / admin)
kibana: http://localhost:5601
elasctisearch: http://localhost:9200
logtash: http://localhost:9600  
fluentd: http://localhost:9292 (username="admin" and password="changeme")

KUBERNETES: 

 folders:
 - chaincode: marbles chaincode
 - config: generated configuration files, like genesisblock or channel config file
 - crypto-config generated crypto material
 - fabric: fabric kubernetes config files, like
   - configMaps.yaml: general config maps and setup script
   - CouchDB.yaml: Kubernetes couchdb file
   - Orderer.yaml: Kubernetes orderer configuration file
   - Peer.yaml: Kubernetes peer configuration file
   - persitentvolume.yaml: Persitent volume claims for the setup
   - SetupJob.yaml: creating channel, configuring anchor peer, installing chaincode

 scripts:
 - generate.sh - generate crypto materials and config files
 - importsecrets.sh - import certificates to
 - start.sh - install the network
 - checking if the network setup is successful look at the set result of the setupjob  (like with kubectl logs <job-pod-name>)
 - teardown.sh - delete the network (some of the secrets and configs might need to be  deleted manually, like with kubectl delete secret)

Start 