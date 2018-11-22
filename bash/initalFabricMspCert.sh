#!/bin/bash
set -ex
#支持n家证书生成、合并、重新生成创世纪块
#支持ca高可用<caServerAddress>
#支持动态加org脚本的一部分，包括：文件系统上的配置文件生成，org容器和cli容器的启动，
#以及cli内部添加org操作的脚本。
#cli内部添加org的脚本是通过cli的docker-compose文件，以volumes的方式挂载到了cli容器里，
#可以通过执行docker exec cli bash xxx/xxx.sh，来进行新org的签名，更新。
#xxx.json文件同样通过cli的docker-compose文件，用volumes定义，挂载在了容器里
################################################################################
#Use:
#1. ./script inital
#2. ./script dynamic
################################################################################
# #MySQL方式启动
# #准备好fabric-ca使用的mysql数据库
# cat >>/etc/mysql/my.cnf<<EOF
# [mysqld]
# sql_mode=ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
# EOF
#
# #启动mysql
# docker run -d \
# -e MYSQL_ROOT_PASSWORD=123456 \
# -p 3306:3306 \
# --name fabric-mysql \
# mysql:5.7
#
# #MySQL启动fabric-ca
# nohup ./fabric-ca-server start \
# --db.datasource "root:123456@tcp(localhost:3306)/fabric_ca?parseTime=true" \
# --db.type mysql \
# --ca.name ca \
# -b admin:adminpw \
# --cfg.affiliations.allowremove \
# --cfg.identities.allowremove &
#
# #SQLite方式启动
# #SQLite启动fabric-ca
# nohup ./fabric-ca-server start \
# --ca.name ca \
# -b admin:adminpw \
# --cfg.affiliations.allowremove \
# --cfg.identities.allowremove &
################################################################################

#var
# unichain.org.cn
# orderer.unichain.org.cn
# org[n].orderer.unichain.org.cn

domainName=unichain.org.cn
ordererDomainName=orderer.${domainName}
caServerAddress=localhost:7054
idSecret=password
adminUser=admin
adminPass=adminpw
#根证书标识
# cn
# cn.org
# cn.org.unichain
# cn.org.unichain.org[n]]
unionRootCa=$(echo $domainName | awk -F "." '{print $NF}')
unionSecond=${unionRootCa}.$(echo $domainName | awk -F "." '{print $(NF-1)}')
unionOrderer=${unionSecond}.$(echo $domainName | awk -F "." '{print $(NF-2)}')

deployDirectory=~/fabric-deploy
caDeployDirectory=${deployDirectory}/fabric-ca-files
adminDirectory=${caDeployDirectory}/admin
ordererDirectory=${caDeployDirectory}/${domainName}
ordererAdminDirectory=${ordererDirectory}/admin
ordererOrdererDirectory=${ordererDirectory}/orderer
fabricDirectory=/home/${USER}/fabric-samples
cryptogenDirectory=${fabricDirectory}/balance-transfer/artifacts/channel
cryptogenConfig=cryptogen.yaml
fabricCaClientPath=${adminDirectory}
fabricCaClientConfig=fabric-ca-client-config.yaml
fabricNetworkConfigName=network-config.yaml
balanceDeployDirectory=${fabricDirectory}/balance-cas
staticFile=~/orgList
dynamicFile=~/dynamicList



CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

#检查org列表文件是否存在
[ -f ${staticFile} ] || (echo -e "Not Found File ${staticFile} ,Placse prepare the file.\nFormat: orgname;peer0 port1,port2;peer1 port3,port4\n\nDefault: org1;peer0 7051,7053;peer1 7056,7058\n         org2;peer0 8051,8053;peer1 8056,8058\n         org3;peer0 9051,9053;peer1 9056,9058\n" && exit 1)
[ -f ${dynamicFile} ] || (echo -e "Not Found File ${dynamicFile} ,Placse prepare the file.\nFormat: orgname;peer0 port1,port2;peer1 port3,port4\n\nDefault: org4;peer0 10051,10053;peer1 10056,10058\n" && exit 1)


listFile=${staticFile}

# ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${domainName}/orderers/${ordererDomainName}/msp/tlscacerts/tlsca.${domainName}-cert.pem


####################基础配置####################
#创建目录
directiryCheck (){
  local dirName=${1}
  [[ -d ${dirName} ]] || mkdir -pv ${dirName}
}

#cd目录
directiryCd (){
  local dirName=${1}
  cd ${dirName}
  echo "进入目录： ${dirName}"
}

#机构首字母大写转换
fabricOrg (){
  Org=$(echo $org | sed 's/^[a-z]/\U&/')
}

# fabricFor (){
#   funName=${1}
#   for org in ${newOrg[@]}
#   do
#     ${funName}
#   done
# }

fabricFor (){
  funName=${1}
  grep -Ev '#|^$' ${listFile} | while read line
  do
    org=$(echo ${line} | awk -F ";" '{print $1}')
    peer0=$(echo ${line} | awk -F ";" '{print $2}' | awk '{print $2}')
    peer0_1=$(echo ${peer0} | awk -F "," '{print $1}' )
    peer0_2=$(echo ${peer0} | awk -F "," '{print $2}' )
    peer1=$(echo ${line} | awk -F ";" '{print $3}' | awk '{print $2}')
    peer1_1=$(echo ${peer1} | awk -F "," '{print $1}' )
    peer1_2=$(echo ${peer1} | awk -F "," '{print $2}' )
    ${funName}
  done
}


####################初始化配置####################
#获取ca Server命令行代码
fabricCaCmd (){
  echo "CheckOut github.com/hyperledger/fabric-ca/cmd/..."
  #首先获取fabric-ca server cmd
  [[ -d ~/go/bin ]] || go get -u github.com/hyperledger/fabric-ca/cmd/...
}

#create admin msp
fabricCreateAdmin (){
  #1.创建admin目录
  directiryCheck ${deployDirectory}
  cd ${deployDirectory}
  directiryCheck ${adminDirectory}

  lsof -i:7054 > /dev/null
  #3.使用fabric-ca生成admin凭证
  if [ $? -eq 0 ];then
    fabric-ca-client enroll -H ${adminDirectory} -u http://${adminUser}:${adminPass}@${caServerAddress}
  else
    echo "fabric-ca Server not running. Placse Start fabric-ca Server."
    exit 1
  fi
  #del old
  fabric-ca-client -H ${adminDirectory} affiliation remove --force  org1
  fabric-ca-client -H ${adminDirectory} affiliation remove --force  org2
  fabric-ca-client -H ${adminDirectory} affiliation add ${unionRootCa}
  fabric-ca-client -H ${adminDirectory} affiliation add ${unionSecond}
  fabric-ca-client -H ${adminDirectory} affiliation list
  # sleep 3
}

#create orderer msp
fabricCreateOrderer (){
  directiryCd ${caDeployDirectory}
  fabric-ca-client -H ${adminDirectory} affiliation add ${unionOrderer}
  fabric-ca-client -H ${adminDirectory} affiliation list
  directiryCheck ${ordererDirectory}/msp
  fabric-ca-client getcacert -M ${ordererDirectory}/msp
}

#create org msp
fabricCreateOrg (){
  directiryCd ${caDeployDirectory}
  fabric-ca-client -H ${adminDirectory} affiliation add ${unionOrgDomainName}
  fabric-ca-client -H ${adminDirectory} affiliation list
  directiryCheck ${org}.${domainName}/msp
  fabric-ca-client getcacert -M ${caDeployDirectory}/${org}.${domainName}/msp
}


####################证书配置####################
#cryptogen配置文件--orderer
fabricConfigCryptogenOrderer (){
  echo "OrdererOrgs:"
  echo "  - Name: Orderer"
  echo "    Domain: ${domainName}"
  echo "    Specs:"
  echo "      - Hostname: orderer"
}

#cryptogen配置文件--peer
fabricConfigCryptogenPeer (){
  echo "PeerOrgs:"
  echo "  - Name: ${Org}"
  echo "    Domain: ${org}.${domainName}"
  echo "    CA:"
  echo "    Template:"
  echo "      Count: 2"
  echo "      SANS:"
  echo "        - \"localhost\""
}

#config配置文件3-1 文件头
fabricConfigureHead (){
  local cnName=${1}
  echo "url: http://${caServerAddress}"
  echo "mspdir: msp"
  echo "tls:"
  echo "  certfiles:"
  echo "  client:"
  echo "    certfile:"
  echo "    keyfile:"
  echo "csr:"
  echo "  cn: ${cnName}"
  echo "keyrequest:"
  echo "  algo: ecdsa"
  echo "  size: 256"
  echo "  serialnumber:"
  echo "  names:"
  echo "    - C: US"
  echo "      ST: North Carolina"
  echo "      L:"
  echo "      O: Hyperledger"
  echo "      OU: Fabric"
  echo "  hosts:"
  echo "    - ${HOSTNAME}"
}

#config配置文件3-2.1 文件中间替换orderer ca
fabricConfigureOrdererCaBody (){
  local cnName=Admin@${1}
  echo "id:"
  echo "  name: ${cnName}"
  echo "  type: client"
  echo "  affiliation: ${unionOrderer}"
  echo "  maxenrollments: 0"
  echo "  attributes:"
  echo "    - name: hf.Registrar.Roles"
  echo "      value: client,orderer,peer,user"
  echo "    - name: hf.Registrar.DelegateRoles"
  echo "      value: client,orderer,peer,user"
  echo "    - name: hf.Registrar.Attributes"
  echo "      value: \"*\""
  echo "    - name: hf.GenCRL"
  echo "      value: true"
  echo "    - name: hf.Revoker"
  echo "      value: true"
  echo "    - name: hf.AffiliationMgr"
  echo "      value: true"
  echo "    - name: hf.IntermediateCA"
  echo "      value: true"
  echo "    - name: role"
  echo "      value: admin"
  echo "      ecert: true"
}

#config配置文件3-2.2 文件中间替换org ca
fabricConfigureOrgCaBody (){
  local cnName=Admin@${1}
  echo "id:"
  echo "  name: ${cnName}"
  echo "  type: client"
  echo "  affiliation: ${unionOrderer}.${org}"
  echo "  maxenrollments: 0"
  echo "  attributes:"
  echo "    - name: hf.Registrar.Roles"
  echo "      value: client,orderer,peer,user"
  echo "    - name: hf.Registrar.DelegateRoles"
  echo "      value: client,orderer,peer,user"
  echo "    - name: hf.Registrar.Attributes"
  echo "      value: \"*\""
  echo "    - name: hf.GenCRL"
  echo "      value: true"
  echo "    - name: hf.Revoker"
  echo "      value: true"
  echo "    - name: hf.AffiliationMgr"
  echo "      value: true"
  echo "    - name: hf.IntermediateCA"
  echo "      value: true"
  echo "    - name: role"
  echo "      value: admin"
  echo "      ecert: true"
}

#config配置文件3-2.3 文件中间替换orderer
fabricConfigureOrderBody (){
  echo "id:"
  echo "  name: ${ordererDomainName}"
  echo "  type: orderer"
  echo "  affiliation: ${unionOrderer}"
  echo "  maxenrollments: 0"
  echo "  attributes:"
  echo "    - name: role"
  echo "      value: orderer"
  echo "      ecert: true"
}

#config配置文件3-2.4 文件中间替换peer0
fabricConfigurePeer0Body (){
  echo "id:"
  echo "  name: peer0.${org}.${domainName}"
  echo "  type: peer"
  echo "  affiliation: ${unionOrderer}.${org}"
  echo "  maxenrollments: 0"
  echo "  attributes:"
  echo "    - name: role"
  echo "      value: peer"
  echo "      ecert: true"
}

#config配置文件3-2.5 文件中间替换peer1
fabricConfigurePeer1Body (){
  echo "id:"
  echo "  name: peer1.${org}.${domainName}"
  echo "  type: peer"
  echo "  affiliation: ${unionOrderer}.${org}"
  echo "  maxenrollments: 0"
  echo "  attributes:"
  echo "    - name: role"
  echo "      value: peer"
  echo "      ecert: true"
}

#config配置文件3-3 文件固定结尾
fabricConfigureBottom (){
  echo "enrollment:"
  echo "  profile:"
  echo "  label:"
  echo "caname:"
  echo "bccsp:"
  echo "    default: SW"
  echo "    sw:"
  echo "        hash: SHA2"
  echo "        security: 256"
  echo "        filekeystore:"
  echo "            keystore: msp/keystore"
}

#network-config.yaml配置文件7-1
fabricNetworkConfigHeader (){
  echo "---"
  echo "name: \"balance-transfer\""
  echo "x-type: \"hlfv1\""
  echo "description: \"Balance Transfer Network\""
  echo "version: \"1.0\""
  echo "channels:"
  echo "  mychannel:"
  echo "    orderers:"
  echo "      - ${ordererDomainName}"
  echo "    peers:"
}

#network-config.yaml配置文件7-2
fabricNetworkConfigPeers (){
  echo "      peer0.${org}.${domainName}:"
  echo "        endorsingPeer: true"
  echo "        chaincodeQuery: true"
  echo "        ledgerQuery: true"
  echo "        eventSource: true"
  echo "      peer1.${org}.${domainName}:"
  echo "        endorsingPeer: false"
  echo "        chaincodeQuery: true"
  echo "        ledgerQuery: true"
  echo "        eventSource: false"
}

#network-config.yaml配置文件7-3
fabricNetworkConfigChaincode (){
  echo "    chaincodes:"
  echo "      - mycc:v0"
  echo "organizations:"
}

#network-config.yaml配置文件7-4
fabricNetworkConfigOrgs (){
  fabricOrg
  local sk_ii=$(ls ${balanceDeployDirectory}/artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/keystore/)
  echo "  ${Org}:"
  echo "    mspid: ${Org}MSP"
  echo "    peers:"
  echo "      - peer0.${org}.${domainName}"
  echo "      - peer1.${org}.${domainName}"
  echo "    certificateAuthorities:"
  echo "      - ca"
  echo "    adminPrivateKey:"
  echo "      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/keystore/${sk_ii}"
  echo "    signedCert:"
  echo "      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/signcerts/cert.pem"
}

#network-config.yaml配置文件7-5
fabricNetworkConfigOrderer (){
  echo "orderers:"
  echo "  ${ordererDomainName}:"
  echo "    url: grpcs://localhost:7050"
  echo "    grpcOptions:"
  echo "      ssl-target-name-override: ${ordererDomainName}"
  echo "    tlsCACerts:"
  echo "      path: artifacts/channel/crypto-config/ordererOrganizations/${domainName}/orderers/${ordererDomainName}/tls/ca.crt"
  echo "peers:"
}

#network-config.yaml配置文件7-6
fabricNetworkConfigOrgPeers (){
  echo "  peer0.${org}.${domainName}:"
  echo "    url: grpcs://localhost:${peer0_1}"
  echo "    grpcOptions:"
  echo "      ssl-target-name-override: peer0.${org}.${domainName}"
  echo "    tlsCACerts:"
  echo "      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/tls/ca.crt"
  echo "  peer1.${org}.${domainName}:"
  echo "    url: grpcs://localhost:${peer1_1}"
  echo "    grpcOptions:"
  echo "      ssl-target-name-override: peer1.${org}.${domainName}"
  echo "    tlsCACerts:"
  echo "      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/tls/ca.crt"
}

#network-config.yaml配置文件7-7
fabricNetworkConfigBottom (){
  echo "certificateAuthorities:"
  echo "  ca:"
  echo "    url: http://${caServerAddress}"
  echo "    httpOptions:"
  echo "      verify: false"
  echo "    registrar:"
  echo "      - enrollId: ${adminUser}"
  echo "        enrollSecret: ${adminPass}"
  echo "    caName: ca"
}

#org[x].yaml配置文件
fabricOrgYaml (){
  fabricOrg
  echo "---"
  echo "name: \"balance-transfer-${org}\""
  echo "x-type: \"hlfv1\""
  echo "description: \"Balance Transfer Network - client definition for ${Org}\""
  echo "version: \"1.0\""
  echo "client:"
  echo "  organization: ${Org}"
  echo "  credentialStore:"
  echo "    path: \"./fabric-client-kv-${org}\""
  echo "    cryptoStore:"
  echo "      path: \"/tmp/fabric-client-kv-${org}\""
  echo "    wallet: wallet-name"
}

#docker-compose.yaml配置文件3-1
fabricDockerComposeConfigOrderer (){
  echo "version: '2'"
  echo "services:"
  echo "  ${ordererDomainName}:"
  echo "    container_name: ${ordererDomainName}"
  echo "    image: hyperledger/fabric-orderer"
  echo "    environment:"
  echo "      - ORDERER_GENERAL_LOGLEVEL=debug"
  echo "      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0"
  echo "      - ORDERER_GENERAL_GENESISMETHOD=file"
  echo "      - ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/genesis.block"
  echo "      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP"
  echo "      - ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/crypto/orderer/msp"
  echo "      - ORDERER_GENERAL_TLS_ENABLED=true"
  echo "      - ORDERER_GENERAL_TLS_PRIVATEKEY=/etc/hyperledger/crypto/orderer/tls/server.key"
  echo "      - ORDERER_GENERAL_TLS_CERTIFICATE=/etc/hyperledger/crypto/orderer/tls/server.crt"
  echo "      - ORDERER_GENERAL_TLS_ROOTCAS=[/etc/hyperledger/crypto/orderer/tls/ca.crt]"
  echo "    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/orderers"
  echo "    command: orderer"
  echo "    ports:"
  echo "      - 7050:7050"
  echo "    volumes:"
  echo "        - ./channel:/etc/hyperledger/configtx"
  echo "        - ./channel/crypto-config/ordererOrganizations/${domainName}/orderers/${ordererDomainName}/:/etc/hyperledger/crypto/orderer"
}

#docker-compose.yaml配置文件3-2
fabricDockerComposeConfigOrgVolumes (){
  fabricOrg
  echo "        - ./channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/:/etc/hyperledger/crypto/peer${Org}"
}

#docker-compose.yaml配置文件3-3
fabricDockerComposeConfigPeers (){
  fabricOrg
  echo "  peer0.${org}.${domainName}:"
  echo "    container_name: peer0.${org}.${domainName}"
  echo "    extends:"
  echo "      file:   base.yaml"
  echo "      service: peer-base"
  echo "    environment:"
  echo "      - CORE_PEER_ID=peer0.${org}.${domainName}"
  echo "      - CORE_PEER_LOCALMSPID=${Org}MSP"
  echo "      - CORE_PEER_ADDRESS=peer0.${org}.${domainName}:7051"
  echo "    ports:"
  echo "      - ${peer0_1}:7051"
  echo "      - ${peer0_2}:7053"
  echo "    volumes:"
  echo "        - ./channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/:/etc/hyperledger/crypto/peer"
  echo "    depends_on:"
  echo "      - ${ordererDomainName}"
  echo "  peer1.${org}.${domainName}:"
  echo "    container_name: peer1.${org}.${domainName}"
  echo "    extends:"
  echo "      file:   base.yaml"
  echo "      service: peer-base"
  echo "    environment:"
  echo "      - CORE_PEER_ID=peer1.${org}.${domainName}"
  echo "      - CORE_PEER_LOCALMSPID=${Org}MSP"
  echo "      - CORE_PEER_ADDRESS=peer1.${org}.${domainName}:7051"
  echo "    ports:"
  echo "      - ${peer1_1}:7051"
  echo "      - ${peer1_2}:7053"
  echo "    volumes:"
  echo "        - ./channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/:/etc/hyperledger/crypto/peer"
  echo "    depends_on:"
  echo "      - ${ordererDomainName}"
}

#channel/configtx.yaml配置文件6-1
fabricChannelConfigtxConfigureHeader (){
  echo "---"
  echo "Organizations:"
  echo "    - &OrdererOrg"
  echo "        Name: OrdererMSP"
  echo "        ID: OrdererMSP"
  echo "        MSPDir: crypto-config/ordererOrganizations/${domainName}/msp"
}

#channel/configtx.yaml配置文件6-2
fabricChannelConfigtxConfigureOrgs (){
  fabricOrg
  echo "    - &${Org}"
  echo "        Name: ${Org}MSP"
  echo "        ID: ${Org}MSP"
  echo "        MSPDir: crypto-config/peerOrganizations/${org}.${domainName}/msp"
  echo "        AnchorPeers:"
  echo "            - Host: peer0.${org}.${domainName}"
  echo "              Port: 7051"
}

#channel/configtx.yaml配置文件6-3
fabricChannelConfigtxConfigureApplicationOrderer (){
  echo "Application: &ApplicationDefaults"
  echo "    Organizations:"
  echo "Orderer: &OrdererDefaults"
  echo "    OrdererType: solo"
  echo "    Addresses:"
  echo "        - ${ordererDomainName}:7050"
  echo "    BatchTimeout: 2s"
  echo "    BatchSize:"
  echo "        MaxMessageCount: 10"
  echo "        AbsoluteMaxBytes: 98 MB"
  echo "        PreferredMaxBytes: 512 KB"
  echo "    Kafka:"
  echo "        Brokers:"
  echo "            - 127.0.0.1:9092"
  echo "    Organizations:"
  echo "Profiles:"
  echo "    TwoOrgsOrdererGenesis:"
  echo "        Orderer:"
  echo "            <<: *OrdererDefaults"
  echo "            Organizations:"
  echo "                - *OrdererOrg"
  echo "        Consortiums:"
  echo "            SampleConsortium:"
  echo "                Organizations:"
}

#channel/configtx.yaml配置文件6-4
fabricChannelConfigtxConfigureOrgsOrdererGenesis (){
  fabricOrg
  echo "                    - *${Org}"
}

#channel/configtx.yaml配置文件6-5
fabricChannelConfigtxConfigureApplicationOrg (){
  echo "    TwoOrgsChannel:"
  echo "        Consortium: SampleConsortium"
  echo "        Application:"
  echo "            <<: *ApplicationDefaults"
  echo "            Organizations:"
}

#channel/configtx.yaml配置文件6-6
fabricChannelConfigtxConfigureOrgsChannels (){
  fabricOrg
  echo "                - *${Org}"
}

#config.js 配置文件3-1
fabricConfigJsHeader (){
	echo "var util = require('util');"
	echo "var path = require('path');"
	echo "var hfc = require('fabric-client');"
	echo "var file = 'network-config%s.yaml';"
	echo "var env = process.env.TARGET_NETWORK;"
	echo "if (env)"
	echo "	file = util.format(file, '-' + env);"
	echo "else"
	echo "	file = util.format(file, '');"
	echo "hfc.setConfigSetting('network-connection-profile-path',path.join(__dirname, 'artifacts' ,file));"
}
#config.js 配置文件3-2
fabricConfigJsOrgs (){
  fabricOrg
	echo "hfc.setConfigSetting('${Org}-connection-profile-path',path.join(__dirname, 'artifacts', '${org}.yaml'));"
}
#config.js 配置文件3-3
fabricConfigJsBottom (){
	echo "hfc.addConfigFile(path.join(__dirname, 'config.json'));"
}
####################合并文件配置####################
#生成Orderer CA configure
fabricOrdererCaConfigure (){
  fabricConfigureHead admin
  fabricConfigureOrdererCaBody ${domainName}
  fabricConfigureBottom
}

#生成org CA configure
fabricOrgCaConfigure (){
  fabricConfigureHead admin
  fabricConfigureOrgCaBody ${org}.${domainName}
  fabricConfigureBottom
}

#生成orderer configure
fabricOrdererConfigure (){
  fabricConfigureHead Admin@${domainName}
  fabricConfigureOrderBody
  fabricConfigureBottom
}

#生成org peer0 configure
fabricPeer0Configure (){
  fabricConfigureHead Admin@${org}.${domainName}
  fabricConfigurePeer0Body
  fabricConfigureBottom
}

#生成org peer1 configure
fabricPeer1Configure (){
  fabricConfigureHead Admin@${org}.${domainName}
  fabricConfigurePeer1Body
  fabricConfigureBottom
}

#生成network-config.yaml configure
fabricNetworkConfig (){
  fabricNetworkConfigHeader
  # for org in ${newOrg[@]};do fabricNetworkConfigPeers;done
  fabricFor fabricNetworkConfigPeers
  fabricNetworkConfigChaincode
  # for org in ${newOrg[@]};do fabricNetworkConfigOrgs;done
  fabricFor fabricNetworkConfigOrgs
  fabricNetworkConfigOrderer
  # for org in ${newOrg[@]};do fabricNetworkConfigOrgPeers;done
  fabricFor fabricNetworkConfigOrgPeers
  fabricNetworkConfigBottom
}

#生成docker-compose.yaml configure
fabricDockerComposeConfig (){
  fabricDockerComposeConfigOrderer
  # for org in ${newOrg[@]};do fabricDockerComposeConfigOrgVolumes;done
  fabricFor fabricDockerComposeConfigOrgVolumes
  # for org in ${newOrg[@]};do fabricDockerComposeConfigPeers;done
  fabricFor fabricDockerComposeConfigPeers
}

#生成configtx.yaml configure
fabricConfigtxConfig (){
  fabricChannelConfigtxConfigureHeader
  fabricFor fabricChannelConfigtxConfigureOrgs
  fabricChannelConfigtxConfigureApplicationOrderer
  fabricFor fabricChannelConfigtxConfigureOrgsOrdererGenesis
  fabricChannelConfigtxConfigureApplicationOrg
  fabricFor fabricChannelConfigtxConfigureOrgsChannels
}

#生成config.js configure
fabricConfigJsConfig (){
  fabricConfigJsHeader
  fabricFor fabricConfigJsOrgs
  fabricConfigJsBottom
}

fabricOrgYamlConfig (){
  fabricOrgYaml > ${balanceDeployDirectory}/artifacts/${org}.yaml
}
####################生成证书配置####################
#cryptogen生成证书 Orderer
fabricCryptogenOrderer (){
  directiryCd ${cryptogenDirectory}
  fabricConfigCryptogenOrderer > ${cryptogenDirectory}/${cryptogenConfig}.orderer
  [[ -d crypto-config-orderer ]] && mv crypto-config-orderer crypto-config-orderer.bak$(date '+%FT%T')
  cryptogen generate --config cryptogen.yaml.orderer --output="crypto-config-orderer"
  directiryCd ${caDeployDirectory}
  cp -rf ${cryptogenDirectory}/crypto-config-orderer/ordererOrganizations/${domainName}/msp/tlscacerts/ ${caDeployDirectory}/${domainName}/msp/
}

#cryptogen生成证书 Peer
fabricCryptogenPeer (){
  directiryCd ${cryptogenDirectory}
  fabricConfigCryptogenPeer > ${cryptogenDirectory}/${cryptogenConfig}.${org}
  [[ -d crypto-config-${org} ]] && mv crypto-config-${org} crypto-config-${org}.bak$(date '+%FT%T')
  cryptogen generate --config cryptogen.yaml.${org} --output="crypto-config-${org}"
  directiryCd ${caDeployDirectory}
  cp -rf ${cryptogenDirectory}/crypto-config-${org}/peerOrganizations/${orgDomainName}/msp/tlscacerts/ ${caDeployDirectory}/${orgDomainName}/msp/
}

#开始操作证书生成 --orderer ca
fabricNewAdminOrdererCa (){
  fabricOrdererCaConfigure > ${fabricCaClientPath}/${fabricCaClientConfig}
  fabric-ca-client register -H ${adminDirectory} --id.secret=${idSecret}
  directiryCheck ${ordererAdminDirectory}
  fabric-ca-client enroll -u http://Admin@${domainName}:${idSecret}@${caServerAddress} -H ${ordererAdminDirectory}
  fabric-ca-client -H ${ordererAdminDirectory} affiliation list
  directiryCheck ${ordererDirectory}/msp/admincerts/
  cp ${ordererAdminDirectory}/msp/signcerts/cert.pem ${ordererDirectory}/msp/admincerts/
}

#开始操作证书生成 --org ca
fabricNewAdminOrgCa (){
  fabricOrgCaConfigure > ${fabricCaClientPath}/${fabricCaClientConfig}
  fabric-ca-client register -H ${adminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}
  fabric-ca-client enroll -u http://Admin@${orgDomainName}:${idSecret}@${caServerAddress}  -H ${orgAdminDirectory}
  fabric-ca-client -H ${orgAdminDirectory} affiliation list
  directiryCheck ${orgDirectory}/msp/admincerts/
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem  ${orgDirectory}/msp/admincerts/
  directiryCheck ${orgAdminDirectory}/msp/admincerts/
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem  ${orgAdminDirectory}/msp/admincerts/
}

#开始操作证书生成 --orderer
fabricNewOrderer (){
  fabricOrdererConfigure > ${ordererAdminDirectory}/${fabricCaClientConfig}
  fabric-ca-client register -H ${ordererAdminDirectory} --id.secret=${idSecret}
  directiryCheck ${ordererOrdererDirectory}
  fabric-ca-client enroll -u http://${ordererDomainName}:${idSecret}@${caServerAddress}  -H ${ordererOrdererDirectory}
  directiryCheck ${ordererOrdererDirectory}/msp/admincerts
  cp ${ordererAdminDirectory}/msp/signcerts/cert.pem ${ordererOrdererDirectory}/msp/admincerts/
}

#开始操作证书生成 --org peer0
fabricNewOrgPeer0 (){
  fabricPeer0Configure > ${orgAdminDirectory}/${fabricCaClientConfig}
  fabric-ca-client register -H ${orgAdminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}/peer0
  fabric-ca-client enroll -u http://peer0.${orgDomainName}:${idSecret}@${caServerAddress} -H ${orgDirectory}/peer0
  directiryCheck ${orgDirectory}/peer0/msp/admincerts
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem ${orgDirectory}/peer0/msp/admincerts/
}

#开始操作证书生成 --org peer1
fabricNewOrgPeer1 (){
  fabricPeer1Configure > ${orgAdminDirectory}/${fabricCaClientConfig}
  fabric-ca-client register -H ${orgAdminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}/peer1
  fabric-ca-client enroll -u http://peer1.${orgDomainName}:${idSecret}@${caServerAddress} -H ${orgDirectory}/peer1
  directiryCheck ${orgDirectory}/peer1/msp/admincerts
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem ${orgDirectory}/peer1/msp/admincerts/
}

#开始操作network-config文件生成
fabricNewNetworkConfig (){
    fabricNetworkConfig > ${balanceDeployDirectory}/artifacts/${fabricNetworkConfigName}
}

#开始操作生成org[x].yaml configure
fabricNewOrgYaml (){
  fabricFor fabricOrgYamlConfig
}

#开始操作docker-compose.yaml文件生成
fabricNewDockerComposeConfig (){
  fabricDockerComposeConfig > ${balanceDeployDirectory}/artifacts/docker-compose.yaml
}

#开始操作configtx.yaml文件生成
fabricNewConfigtxConfig (){
  fabricConfigtxConfig > ${balanceDeployDirectory}/artifacts/channel/configtx.yaml
}

#开始操作config.js 文件生成
fabricNewConfigJsConfig (){
  fabricConfigJsConfig > ${balanceDeployDirectory}/config.js
}
####################证书清理配置####################
#清理自动生成的认证文件
fabricOrdererConfigClean (){
  local cryptoName=crypto-config-orderer
  directiryCd ${cryptogenDirectory}/${cryptoName}
  rm -r ./ordererOrganizations/${domainName}/msp/*
  rm -r ./ordererOrganizations/${domainName}/orderers/orderer.${domainName}/msp/{admincerts,cacerts,keystore,signcerts}
  rm -r ./ordererOrganizations/${domainName}/users/Admin@${domainName}/msp/{cacerts,keystore,signcerts}
}

fabricPeerConfigClean (){
  local cryptoName=crypto-config-${org}
  directiryCd ${cryptogenDirectory}/${cryptoName}
  rm -r ./peerOrganizations/${org}.${domainName}/msp/*
  rm -r ./peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/msp/{admincerts,cacerts,keystore,signcerts}
  rm -r ./peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/msp/{admincerts,cacerts,keystore,signcerts}
  rm -r ./peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/{admincerts,cacerts,keystore,signcerts}
}

####################证书合并配置####################
#合并：将手工生成的和自动生成的合并
fabricOrdererConfigMerge (){
  local cryptoName=crypto-config-orderer
  directiryCd ${cryptogenDirectory}
  [ -d crypto-config-new ] && mv crypto-config-new crypto-config-new.$(date +%FT%T) || directiryCheck crypto-config-new
  [ -d crypto-config-new/ordererOrganizations ] || directiryCheck crypto-config-new/ordererOrganizations
  directiryCd ${cryptogenDirectory}/${cryptoName}
  cp -r ${caDeployDirectory}/${domainName}/msp/* ./ordererOrganizations/${domainName}/msp
  cp -r ${caDeployDirectory}/${domainName}/orderer/msp/* ./ordererOrganizations/${domainName}/orderers/orderer.${domainName}/msp
  cp -r ${caDeployDirectory}/${domainName}/admin/msp/* ./ordererOrganizations/${domainName}/users/Admin@${domainName}/msp
  cp -r ./ordererOrganizations/${domainName} ../crypto-config-new/ordererOrganizations
}

fabricPeerConfigMerge (){
  local cryptoName=crypto-config-${org}
  directiryCd ${cryptogenDirectory}
  [ -d crypto-config-new/peerOrganizations ] || directiryCheck crypto-config-new/peerOrganizations
  directiryCd ${cryptogenDirectory}/${cryptoName}
  cp -r ${caDeployDirectory}/${org}.${domainName}/msp/* ./peerOrganizations/${org}.${domainName}/msp
  cp -r ${caDeployDirectory}/${org}.${domainName}/peer0/msp/* ./peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/msp
  cp -r ${caDeployDirectory}/${org}.${domainName}/peer1/msp/* ./peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/msp
  cp -r ${caDeployDirectory}/${org}.${domainName}/admin/msp/* ./peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp
  cp -r ./peerOrganizations/${org}.${domainName} ../crypto-config-new/peerOrganizations
}

#创世纪块文件重新生成
fabricRebrithBlock (){
  directiryCd ${balanceDeployDirectory}/artifacts/channel
  mv genesis.block genesis.block.bak
  mv mychannel.tx mychannel.tx.bak
  configtxgen -profile TwoOrgsOrdererGenesis -outputBlock genesis.block
  configtxgen -profile TwoOrgsChannel -outputCreateChannelTx mychannel.tx -channelID mychannel
}

###################################################################
###############START---动态执行文件---START#########################
###################################################################
dockerCli (){
  Cmd=$@
  docker exec cli ${Cmd}
}

#新org configtx配置文件 | bash
fabricConfigtxNewOrg (){
  fabricOrg
  echo "Organizations:"
  echo "    - &${Org}"
  echo "        Name: ${Org}MSP"
  echo "        ID: ${Org}MSP"
  echo "        MSPDir: crypto-config/peerOrganizations/${org}.${domainName}/msp"
  echo "        AnchorPeers:"
  echo "            - Host: peer0.${org}.${domainName}"
  echo "              Port: 7051"
}

#new org docker-compose configure file | bash
fabricConfigDockerCompose (){
  fabricOrg
  echo "version: '2'"
  echo "services:"
  echo "  peer0.${org}.${domainName}:"
  echo "    container_name: peer0.${org}.${domainName}"
  echo "    extends:"
  echo "      file:   base.yaml"
  echo "      service: peer-base"
  echo "    environment:"
  echo "      - CORE_PEER_ID=peer0.${org}.${domainName}"
  echo "      - CORE_PEER_LOCALMSPID=${Org}MSP"
  echo "      - CORE_PEER_ADDRESS=peer0.${org}.${domainName}:7051"
  echo "    ports:"
  echo "      - ${peer0_1}:7051"
  echo "      - ${peer0_2}:7053"
  echo "    volumes:"
  echo "        - ./channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/:/etc/hyperledger/crypto/peer"
  echo "  peer1.${org}.${domainName}:"
  echo "    container_name: peer1.${org}.${domainName}"
  echo "    extends:"
  echo "      file:   base.yaml"
  echo "      service: peer-base"
  echo "    environment:"
  echo "      - CORE_PEER_ID=peer1.${org}.${domainName}"
  echo "      - CORE_PEER_LOCALMSPID=${Org}MSP"
  echo "      - CORE_PEER_ADDRESS=peer1.${org}.${domainName}:7051"
  echo "    ports:"
  echo "      - ${peer1_1}:7051"
  echo "      - ${peer1_2}:7053"
  echo "    volumes:"
  echo "        - ./channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/:/etc/hyperledger/crypto/peer"
}

#docker-compose-cli configure file | bash
fabricCliConfigure (){
  echo "version: '2'"
  echo "services:"
  echo "  cli:"
  echo "    container_name: cli"
  echo "    image: hyperledger/fabric-tools"
  echo "    tty: true"
  echo "    stdin_open: true"
  echo "    environment:"
  echo "      - GOPATH=/opt/gopath"
  echo "      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock"
  echo "      - CORE_LOGGING_LEVEL=INFO"
  echo "      - CORE_PEER_ID=cli"
  echo "      - CORE_PEER_ADDRESS=peer0.org1.${domainName}:7051"
  echo "      - CORE_PEER_LOCALMSPID=Org1MSP"
  echo "      - CORE_PEER_TLS_ENABLED=true"
  echo "      - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.${domainName}/peers/peer0.org1.${domainName}/tls/server.crt"
  echo "      - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.${domainName}/peers/peer0.org1.${domainName}/tls/server.key"
  echo "      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.${domainName}/peers/peer0.org1.${domainName}/tls/ca.crt"
  echo "      - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.${domainName}/users/Admin@org1.${domainName}/msp"
  echo "    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer"
  echo "    command: /bin/bash"
  echo "    volumes:"
  echo "        - /var/run/:/host/var/run/"
  echo "        - ./channel/crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/"
  echo "        - ./channel/${org}.json:/opt/gopath/src/github.com/hyperledger/fabric/peer/${org}/${org}.json"
  echo "        - ./channel/${org}.sh:/opt/gopath/src/github.com/hyperledger/fabric/peer/${org}/${org}.sh"
}

fabricNewCliConfig (){
  fabricCliConfigure > ./artifacts/docker-compose-cli.yaml
}

fabricCli (){
  directiryCd ${balanceDeployDirectory}
  fabricNewCliConfig
  docker-compose -f ./artifacts/docker-compose-cli.yaml up -d
  if [ $? != 0 ];then
    echo "docker-compose-cli start failure."
    exit 1
  fi
}

#新configtx配置生成json | bash
fabricNewConfigtxNewOrg (){
  [ -f configtx.yaml ] && mv configtx.yaml configtx.yaml.$(date '+%FT%H-%M-%S')
  fabricConfigtxNewOrg > configtx.yaml
  configtxgen -printOrg ${Org}MSP > ./${org}.json
}

fabricBashAddOrgCa (){
  #合并证书
  cp -r ${cryptogenDirectory}/crypto-config-new/peerOrganizations/${org}.${domainName} ./artifacts/channel/crypto-config/peerOrganizations
}

fabricCliBashFileWget (){
  wget -N https://zbx-fabric.oss-cn-beijing.aliyuncs.com/dynamicAddOrg.sh
  mv dynamicAddOrg.sh ${org}.sh
  sed -i "s/ORGNAME/${org}/" ./${org}.sh
  sed -i "s/DOMAINNAME/${domainName}/" ./${org}.sh
}

fabricNetworkConfigNewOrgConfig (){
  fabricOrg
  local sk_ii=$(ls ${balanceDeployDirectory}/artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/keystore/)

  Peers="      peer0.${org}.${domainName}:\n        endorsingPeer: true\n        chaincodeQuery: true\n        ledgerQuery: true\n        eventSource: true\n      peer1.${org}.${domainName}:\n        endorsingPeer: false\n        chaincodeQuery: true\n        ledgerQuery: true\n        eventSource: false"
  Orgs="  ${Org}:\n    mspid: ${Org}MSP\n    peers:\n      - peer0.${org}.${domainName}\n      - peer1.${org}.${domainName}\n    certificateAuthorities:\n      - ca\n    adminPrivateKey:\n      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/keystore/${sk_ii}\n    signedCert:\n      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/users/Admin@${org}.${domainName}/msp/signcerts/cert.pem"
  OrgPeers="  peer0.${org}.${domainName}:\n    url: grpcs://localhost:${peer0_1}\n    grpcOptions:\n      ssl-target-name-override: peer0.${org}.${domainName}\n    tlsCACerts:\n      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer0.${org}.${domainName}/tls/ca.crt\n  peer1.${org}.${domainName}:\n    url: grpcs://localhost:${peer1_1}\n    grpcOptions:\n      ssl-target-name-override: peer1.${org}.${domainName}\n    tlsCACerts:\n      path: artifacts/channel/crypto-config/peerOrganizations/${org}.${domainName}/peers/peer1.${org}.${domainName}/tls/ca.crt"
}

fabricBashAddOrgConfigure (){
  fabricNetworkConfigNewOrgConfig
  # 修改network-config，增加新org
  networkConfig=./artifacts/network-config.yaml
  addNetworkPeerNum=$(grep -n "chaincodes" ${networkConfig} | awk -F ":" '{print $1}') #在行号之前添加
  sed -i "${addNetworkPeerNum}i\\${Peers}" ${networkConfig}
  addNetworkOrgNum=$(grep -n "orderers" ${networkConfig} | head -n 2 | tail -n 1 | awk -F ":" '{print $1}') #在行号之前添加
  sed -i "${addNetworkOrgNum}i\\${Orgs}" ${networkConfig}
  addNetworkPeerOrgNum=$(grep -n "certificateAuthorities" ${networkConfig} | tail -n 1 | awk -F ":" '{print $1}') #在行号之前添加
  sed -i "${addNetworkPeerOrgNum}i\\${OrgPeers}" ${networkConfig}

  # 创建新org的docker-compose
  fabricConfigDockerCompose > ./artifacts/docker-compose-${org}.yaml
  docker-compose -f ./artifacts/docker-compose-${org}.yaml up -d

  # 修改config.js，增加新org
  addConfigOrgNum=$(grep -n '' config.js | awk -F ":" END'{print $1}') #在行号之前添加
  fabricConfigJsOrgs
  grep "$(eval fabricConfigJsOrgs)" config.js >/dev/null ||  sed -i "${addConfigOrgNum}i\\$(eval fabricConfigJsOrgs)" config.js

  #生成新的org.yaml文件
  fabricOrgYaml > artifacts/${org}.yaml
  # 拷贝出新的configtx.org.yaml文件
  fabricConfigtxNewOrg > artifacts/channel/configtx.${org}.yaml
  mv artifacts/channel/configtx.yaml artifacts/channel/configtx.yaml.bak
  mv artifacts/channel/configtx.${org}.yaml artifacts/channel/configtx.yaml
  # 生成新org的json文件
  directiryCd artifacts/channel
  configtxgen -profile configtx.yaml -printOrg ${Org}MSP > ./${org}.json
  fabricCliBashFileWget
}

###################################################################
#################END---动态执行文件---END###########################
###################################################################

######################初始化总体配置################################
#1.admin
fabricInitalAdmin (){
  #获取ca server cmd
  fabricCaCmd
  #初始化admin CA目录和联盟
  fabricCreateAdmin
}

#2.orderer ca --> orderer
fabricInitalOrderer (){
  #添加orderer机构进联盟
  fabricCreateOrderer
  #用cryptogen生成证书(tls)
  fabricCryptogenOrderer
  #生成orderer CA文件
  fabricNewAdminOrdererCa
  fabricNewOrderer
  fabricOrdererConfigClean
  fabricOrdererConfigMerge
}

#3.org ca --> peer0 AND peer1
fabricInitalOrg (){
  fabricOrg
  orgDomainName=${org}.${domainName}
  orgDirectory=${caDeployDirectory}/${org}.${domainName}
  orgAdminDirectory=${orgDirectory}/admin
  unionOrgDomainName=${unionOrderer}.${org}

  fabricCreateOrg
  fabricCryptogenPeer
  fabricNewAdminOrgCa
  fabricNewOrgPeer0
  fabricNewOrgPeer1
  fabricPeerConfigClean
  fabricPeerConfigMerge
}

#4.configure ---> runApp AND testAPIs
fabricInitalRunApp (){
  cp -r ${fabricDirectory}/balance-transfer ${balanceDeployDirectory}
  directiryCd ${balanceDeployDirectory}/artifacts/channel
  echo
  echo "Clean cryptogen-config directory..."
  rm -r $(ls -F | grep "/$" | grep -v "new/")
  mv crypto-config-new crypto-config
  echo "Clean succeed.Rename cryptogen-config"
  echo
  directiryCd ${balanceDeployDirectory}
  sed -i "s/example.com/${domainName}/g" testAPIs.sh
  sed -i "s/affiliation: userOrg.toLowerCase() + '.department1'/affiliation: \'${unionOrderer}.\' + userOrg.toLowerCase()/" app/helper.js
  sed -i "s/60000/600000/g" app/instantiate-chaincode.js

  fabricNewNetworkConfig
  fabricNewDockerComposeConfig
  fabricNewOrgYaml
  fabricNewConfigtxConfig
  fabricNewConfigJsConfig
  fabricRebrithBlock
}

######################动态加org总体配置#############################
#bash端操作步骤
fabricBashDynamicAddOrg (){
  #加org的准备
  #1. 创建证书，初始化新的org
  fabricInitalOrg
  #2. 合并到旧的org上
  directiryCd ${balanceDeployDirectory}
  fabricBashAddOrgCa
  #3. 将新org追加到配置文件
  fabricBashAddOrgConfigure
  #4. 添加Cli配置文件，并启动
  fabricCli
  #5. 在cli端操作更新
  dockerCli bash ${org}/${org}.sh
  echo
  echo "restart: PORT=4000 node app"
  echo
  echo "1.run: install chaincode(is ok)"
  echo "2.run: invoke cc && query cc"
}

#########################初始化调用运行#############################
#n家机构静态初始化
fabricStaticInitalization (){
  # 1.初始化admin
  fabricInitalAdmin
  # 2.初始化orderer
  fabricInitalOrderer
  # 3.初始化org
  fabricFor fabricInitalOrg
  # 4.runapp && testapi
  fabricInitalRunApp
  sed -i "s/inital)fabricStaticInitalization;;/#inital)fabricStaticInitalization;;/g" ~/$0
  echo "提示: 初始化操作只能执行一次！！！"
}

#########################动态化调用运行#############################
#
fabricDyncmicallyAddOrg (){
  #重新指定listFile文件
  listFile=${dynamicFile}
  #1.生成文件-->添加org-->
  fabricFor fabricBashDynamicAddOrg
}


############调用运行##############
status=${1}
case $status in
  inital)fabricStaticInitalization;;
  dynamic)fabricDyncmicallyAddOrg;;
  *)echo "Usage: $0 [inital|dynamic]";;
esac
