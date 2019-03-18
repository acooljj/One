#!/bin/bash
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
  #
  setFor setJoinChannels
  #
  setFor setInstallChainCodes
  #
  cat InstantiateChainCode
  #
  cat IvokeChainCode
  #
  setFor setQueryChainCodes
  #
  cat Bottom
}

echoFile > testAPIs.sh
