#!/bin/bash
#set -e
domainName=DOMAINNAME
ordererDomainName=orderer.${domainName}
unionRootCa=$(echo $domainName | awk -F "." '{print $NF}')
unionSecond=${unionRootCa}.$(echo $domainName | awk -F "." '{print $(NF-1)}')
unionOrderer=${unionSecond}.$(echo $domainName | awk -F "." '{print $(NF-2)}')
org=ORGNAME
Org=$(echo ${org} | sed "s/^[a-z]/\U&/")
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


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${domainName}/orderers/${ordererDomainName}/msp/tlscacerts/tlsca.${domainName}-cert.pem

###################################################################



#fetch channel配置 | cli
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=./${org}/mychannel_config.json

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "${CORE_PEER_TLS_ENABLED}" -o "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
    set -x
    #获取当前channel的配置，输出为protobuf格式的文件config_block.pb
    peer channel fetch config config_block.pb -o ${ordererDomainName}:7050 -c ${CHANNEL} --cafile ${ORDERER_CA}
    set +x
  else
    set -x
    #获取当前channel的配置，输出为protobuf格式的文件config_block.pb
    cd /opt/gopath/src/github.com/hyperledger/fabric/peer
    peer channel fetch config config_block.pb -o ${ordererDomainName}:7050 -c ${CHANNEL} --tls --cafile ${ORDERER_CA}
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  #将pb格式转换为json格式，重新存放到一个新json文件中config_block.pb --> mychannel_config.json
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute New Org Scenario ==========="
    echo
    exit 1
  fi
}

#
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  #将mychannel-config.json转换为pb格式文件 mychannel_config.pb
  configtxlator proto_encode --input "./${org}/${ORIGINAL}" --type common.Config > ./${org}/mychannel_config.pb
  #将合并后的josn文件modified_config.json，转换为pb格式modified_config.pb
  configtxlator proto_encode --input "./${org}/${MODIFIED}" --type common.Config > ./${org}/modified_config.pb
  #比较mychannel_config.pb和modified_config.json，将计算出的差异部分输出到一个新的pb文件里org_update.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original ./${org}/mychannel_config.pb --updated ./${org}/modified_config.pb > ./${org}/${org}_update.pb
  #将差异pb文件 org_update.pb 转换为json格式 org_updte.json
  configtxlator proto_decode --input ./${org}/${org}_update.pb --type common.ConfigUpdate | jq . > ./${org}/${org}_update.json
  #用jq工具修改payload，生成org__update_in_envelope.json文件
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat ./${org}/${org}_update.json)'}}}' | jq . > ./${org}/${org}_update_in_envelope.json
  #将org_update_in_envelope.json文件转码为pb文件 org_update_in_envelope.pb
  configtxlator proto_encode --input ./${org}/${org}_update_in_envelope.json --type common.Envelope >"./${org}/${OUTPUT}"
  set +x
}

setGlobals (){
  peerNum=${1}
  orgName=${2}
  OrgName=$(echo ${orgName} | sed 's/^[a-z]/\U&/')

  CORE_PEER_ID=cli
  CORE_PEER_ADDRESS=peer${peerNum}.${orgName}.${domainName}:7051
  CORE_PEER_LOCALMSPID=${OrgName}MSP
  CORE_PEER_TLS_ENABLED=true
  CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/server.crt
  CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/server.key
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/users/Admin@${orgName}.${domainName}/msp
}


# cli处理新加org操作
fabircCliDynamicAddOrg (){
  echo
  echo "========= Starting add org =========== "
  echo
  # ---New---取块
  peer channel fetch 0 mychannel.block -o ${ordererDomainName}:7050 -c mychannel --tls --cafile ${ORDERER_CA}
  # 获取当前channel的配置，并转码为json
  fetchChannelConfig ${CHANNEL_NAME}
#  peer channel fetch config config_block.pb -o orderer.unichain.org.cn:7050 -c mychannel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/unichain.org.cn/orderers/orderer.unichain.org.cn/msp/tlscacerts/tlsca.unichain.org.cn-cert.pem
  # 修改新json文件，加入新org
  set -x
  jq -s ".[0] * {"channel_group":{"groups":{"Application":{"groups": {"${Org}MSP":.[1]}}}}}" ./${org}/mychannel_config.json ./${org}/${org}.json > ./${org}/modified_config.json
  set +x
  # 通过对比原来的channel和新加入org的配置pb文件，最终生成org_update_in_envelope.pb文件
  createConfigUpdate ${CHANNEL_NAME} mychannel_config.json modified_config.json  ${org}_update_in_envelope.pb
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  #使用org1的身份对其进行签名
  peer channel signconfigtx -f ./${org}/${org}_update_in_envelope.pb
  #切换org身份到org2
  setGlobals 0 org2
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"

  set -x
  #update操作隐含了signconfigtx操作
  #由第二个来进行签名，并进行update操作
  peer channel update -f ./${org}/${org}_update_in_envelope.pb -c mychannel -o ${ordererDomainName}:7050 --tls --cafile ${ORDERER_CA}
  set +x

  #设置变量
  joinChannelWithRetry 0 ${org}

  echo "END"
  #peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
  #peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
  #peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
}

############调用运行##############
fabircCliDynamicAddOrg
