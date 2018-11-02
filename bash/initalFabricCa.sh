#!/bin/bash
set -xe
#var
# unichain.org.cn
# orderer.unichain.org.cn
# org[n].orderer.unichain.org.cn

domainName=unichain.org.cn
ordererDomainName=orderer.${domainName}
#根证书标识
# cn
# cn.org
# cn.org.unichain
# cn.org.unichain.org[n]]
unionRootCa=cn
unionSecond=${unionRootCa}.org
unionOrderer=${unionSecond}.unichain

deployDirectory=~/fabric-deploy
caDeployDirectory=${deployDirectory}/fabric-ca-files
adminDirectory=${caDeployDirectory}/admin
ordererDirectory=${caDeployDirectory}/${domainName}
ordererAdminDirectory=${ordererDirectory}/admin
ordererOrdererDirectory=${ordererDirectory}/orderer
cryptogenDirectory=/home/${USER}/fabric-samples/balance-transfer/artifacts/channel
cryptogenConfig=cryptogen.yaml
fabricCaClientPath=${adminDirectory}
fabricCaClientConfig=fabric-ca-client-config.yaml

idSecret=password
adminUser=admin
adminPass=adminpw

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
    fabric-ca-client enroll -H ${adminDirectory} -u http://${adminUser}:${adminPass}@localhost:7054
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
  sleep 3
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
  echo "url: http://localhost:7054"
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
  fabric-ca-client enroll -u http://Admin@${domainName}:${idSecret}@localhost:7054 -H ${ordererAdminDirectory}
  fabric-ca-client -H ${ordererAdminDirectory} affiliation list
  directiryCheck ${ordererDirectory}/msp/admincerts/
  cp ${ordererAdminDirectory}/msp/signcerts/cert.pem ${ordererDirectory}/msp/admincerts/
}

#开始操作证书生成 --org ca
fabricNewAdminOrgCa (){
  fabricOrgCaConfigure > ${fabricCaClientPath}/${fabricCaClientConfig}
  fabric-ca-client register -H ${adminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}
  fabric-ca-client enroll -u http://Admin@${orgDomainName}:${idSecret}@localhost:7054  -H ${orgAdminDirectory}
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
  fabric-ca-client enroll -u http://${ordererDomainName}:${idSecret}@localhost:7054  -H ${ordererOrdererDirectory}
  directiryCheck ${ordererOrdererDirectory}/msp/admincerts
  cp ${ordererAdminDirectory}/msp/signcerts/cert.pem ${ordererOrdererDirectory}/msp/admincerts/
}

#开始操作证书生成 --org peer0
fabricNewOrgPeer0 (){
  fabricPeer0Configure > ${orgAdminDirectory}/${fabricCaClientConfig}
  fabric-ca-client register -H ${orgAdminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}/peer0
  fabric-ca-client enroll -u http://peer0.${orgDomainName}:${idSecret}@localhost:7054 -H ${orgDirectory}/peer0
  directiryCheck ${orgDirectory}/peer0/msp/admincerts
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem ${orgDirectory}/peer0/msp/admincerts/
}

#开始操作证书生成 --org peer1
fabricNewOrgPeer1 (){
  fabricPeer1Configure > ${orgAdminDirectory}/${fabricCaClientConfig}
  fabric-ca-client register -H ${orgAdminDirectory} --id.secret=${idSecret}
  directiryCheck ${orgDirectory}/peer1
  fabric-ca-client enroll -u http://peer1.${orgDomainName}:${idSecret}@localhost:7054 -H ${orgDirectory}/peer1
  directiryCheck ${orgDirectory}/peer1/msp/admincerts
  cp ${orgAdminDirectory}/msp/signcerts/cert.pem ${orgDirectory}/peer1/msp/admincerts/
}

####################证书合并配置####################
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

#合并：将手工生成的和自动生成的合并
fabricOrdererConfigMerge (){
  local cryptoName=crypto-config-orderer
  directiryCd ${cryptogenDirectory}
  [ -d crypto-config-new ] && mv crypto-config-new crypto-config-new.bak$(date '+%FT%T') || directiryCheck crypto-config-new
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


####################修改秘钥配置####################
#查找要替换的SK文件
fabricChangeSk (){
  local cryptoName=crypto-config
  directiryCd ${cryptogenDirectory}/${cryptoName}
  echo "network-config.yaml"
  grep -nEv "#|^$" ../../network-config.yaml  | grep sk | awk -F "/" '{print $NF}'
  echo
  echo "Org1 `ls peerOrganizations/org1.${domainName}/users/Admin@org1.${domainName}/msp/keystore/`"
  echo "Org2 `ls peerOrganizations/org2.${domainName}/users/Admin@org2.${domainName}/msp/keystore/`"
}

####################总体配置####################
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
  Org=$(echo $org | sed 's/^[a-z]/\U&/')
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

####################调用运行####################
#fabric
#声明org机构
newOrg=('org1' 'org2')
#1.admin
fabricInitalAdmin
#2.orderer
fabricInitalOrderer
#3.org
for org in ${newOrg[@]}
do
  fabricInitalOrg
done

