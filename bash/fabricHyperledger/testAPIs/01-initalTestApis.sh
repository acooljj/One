#!/bin/bash
# 生成的testAPIs.sh只能执行到实例化

setFor (){
  ofile=~/orgList
  funcName=${1}
  grep -Ev "#|^$" ${ofile} | while read line
  do
    orgName=$(echo ${line} | awk -F ";" '{print $1}')
    OrgName=$(echo ${orgName} | sed 's/^[a-z]/\U&/g')
    ORGNAME=$(echo ${orgName} | tr a-z A-Z)
    echo
    ${funcName}
  done
}

setEnrollTokens (){
  cat Erolls | sed -e "s/Org1/${OrgName}/g" -e "s/ORG1/${ORGNAME}/g"
}

setJoinChannels (){
  cat JoinChannels | sed -e "s/Org1/${OrgName}/g" -e "s/ORG1/${ORGNAME}/g" -e "s/org1/${orgName}/g"
}

setInstallChainCodes (){
  cat  InstallChainCodes | sed -e "s/Org1/${OrgName}/g" -e "s/ORG1/${ORGNAME}/g" -e "s/org1/${orgName}/g"
}

setQueryChainCodes (){
  cat QueryChainCodes | sed -e "s/Org1/${OrgName}/g" -e "s/ORG1/${ORGNAME}/g" -e "s/org1/${orgName}/g"
}




echoFile (){
  #Top
  cat Head
  #ErollToken
  setFor setEnrollTokens
  #create channel
  cat CreateChannel
  #join channel
  setFor setJoinChannels
  #install chaincode
  setFor setInstallChainCodes
  #instantiate chaincode
  cat InstantiateChainCode
  # #ivoke chaincode  --no use
  # cat IvokeChainCode
  # #query chaincode  --no use
  # setFor setQueryChainCodes
  #
  cat Bottom
}

echoFile > testAPIs.sh
