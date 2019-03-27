#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/chain/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org1-qJim&orgName=Org1')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"
echo

echo "POST request Enroll on Org2  ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org2-qJim&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
echo

echo "POST request Enroll on Org3  ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org3-qJim&orgName=Org3')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"
echo

echo "POST request Enroll on Org4  ..."
echo
ORG4_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org4-qJim&orgName=Org4')
echo $ORG4_TOKEN
ORG4_TOKEN=$(echo $ORG4_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG4 token is $ORG4_TOKEN"
echo

echo "POST request Enroll on Org5  ..."
echo
ORG5_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org5-qJim&orgName=Org5')
echo $ORG5_TOKEN
ORG5_TOKEN=$(echo $ORG5_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG5 token is $ORG5_TOKEN"
echo

echo "POST request Enroll on Org6  ..."
echo
ORG6_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org6-qJim&orgName=Org6')
echo $ORG6_TOKEN
ORG6_TOKEN=$(echo $ORG6_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG6 token is $ORG6_TOKEN"
echo

echo "POST request Enroll on Org7  ..."
echo
ORG7_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org7-qJim&orgName=Org7')
echo $ORG7_TOKEN
ORG7_TOKEN=$(echo $ORG7_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG7 token is $ORG7_TOKEN"
echo

echo "POST request Enroll on Org8  ..."
echo
ORG8_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org8-qJim&orgName=Org8')
echo $ORG8_TOKEN
ORG8_TOKEN=$(echo $ORG8_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG8 token is $ORG8_TOKEN"
echo

echo "POST request Enroll on Org9  ..."
echo
ORG9_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org9-qJim&orgName=Org9')
echo $ORG9_TOKEN
ORG9_TOKEN=$(echo $ORG9_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG9 token is $ORG9_TOKEN"
echo

echo "POST request Enroll on Org10  ..."
echo
ORG10_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org10-qJim&orgName=Org10')
echo $ORG10_TOKEN
ORG10_TOKEN=$(echo $ORG10_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG10 token is $ORG10_TOKEN"
echo

echo "POST request Enroll on Org11  ..."
echo
ORG11_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org11-qJim&orgName=Org11')
echo $ORG11_TOKEN
ORG11_TOKEN=$(echo $ORG11_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG11 token is $ORG11_TOKEN"
echo

echo "POST request Enroll on Org12  ..."
echo
ORG12_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org12-qJim&orgName=Org12')
echo $ORG12_TOKEN
ORG12_TOKEN=$(echo $ORG12_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG12 token is $ORG12_TOKEN"
echo

echo "POST request Enroll on Org13  ..."
echo
ORG13_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org13-qJim&orgName=Org13')
echo $ORG13_TOKEN
ORG13_TOKEN=$(echo $ORG13_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG13 token is $ORG13_TOKEN"
echo

echo "POST request Enroll on Org14  ..."
echo
ORG14_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org14-qJim&orgName=Org14')
echo $ORG14_TOKEN
ORG14_TOKEN=$(echo $ORG14_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG14 token is $ORG14_TOKEN"
echo

echo "POST request Enroll on Org15  ..."
echo
ORG15_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org15-qJim&orgName=Org15')
echo $ORG15_TOKEN
ORG15_TOKEN=$(echo $ORG15_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG15 token is $ORG15_TOKEN"
echo

echo "POST request Enroll on Org16  ..."
echo
ORG16_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org16-qJim&orgName=Org16')
echo $ORG16_TOKEN
ORG16_TOKEN=$(echo $ORG16_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG16 token is $ORG16_TOKEN"
echo

echo "POST request Enroll on Org17  ..."
echo
ORG17_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org17-qJim&orgName=Org17')
echo $ORG17_TOKEN
ORG17_TOKEN=$(echo $ORG17_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG17 token is $ORG17_TOKEN"
echo

echo "POST request Enroll on Org18  ..."
echo
ORG18_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org18-qJim&orgName=Org18')
echo $ORG18_TOKEN
ORG18_TOKEN=$(echo $ORG18_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG18 token is $ORG18_TOKEN"
echo

echo "POST request Enroll on Org19  ..."
echo
ORG19_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org19-qJim&orgName=Org19')
echo $ORG19_TOKEN
ORG19_TOKEN=$(echo $ORG19_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG19 token is $ORG19_TOKEN"
echo

echo "POST request Enroll on Org20  ..."
echo
ORG20_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Org20-qJim&orgName=Org20')
echo $ORG20_TOKEN
ORG20_TOKEN=$(echo $ORG20_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG20 token is $ORG20_TOKEN"
echo
echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
echo
echo

echo "POST request Join channel on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.unichain.org.cn","peer1.org1.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org2"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org2.unichain.org.cn","peer1.org2.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org3"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org3.unichain.org.cn","peer1.org3.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org4"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG4_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org4.unichain.org.cn","peer1.org4.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org5"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG5_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org5.unichain.org.cn","peer1.org5.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org6"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG6_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org6.unichain.org.cn","peer1.org6.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org7"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG7_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org7.unichain.org.cn","peer1.org7.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org8"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG8_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org8.unichain.org.cn","peer1.org8.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org9"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG9_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org9.unichain.org.cn","peer1.org9.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org10"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG10_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org10.unichain.org.cn","peer1.org10.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org11"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG11_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org11.unichain.org.cn","peer1.org11.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org12"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG12_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org12.unichain.org.cn","peer1.org12.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org13"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG13_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org13.unichain.org.cn","peer1.org13.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org14"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG14_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org14.unichain.org.cn","peer1.org14.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org15"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG15_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org15.unichain.org.cn","peer1.org15.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org16"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG16_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org16.unichain.org.cn","peer1.org16.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org17"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG17_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org17.unichain.org.cn","peer1.org17.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org18"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG18_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org18.unichain.org.cn","peer1.org18.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org19"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG19_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org19.unichain.org.cn","peer1.org19.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Org20"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG20_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org20.unichain.org.cn","peer1.org20.unichain.org.cn"]
}'
echo
echo

echo "POST Install chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org1.unichain.org.cn\",\"peer1.org1.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org2"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org2.unichain.org.cn\",\"peer1.org2.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org3"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org3.unichain.org.cn\",\"peer1.org3.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org4"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG4_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org4.unichain.org.cn\",\"peer1.org4.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org5"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG5_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org5.unichain.org.cn\",\"peer1.org5.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org6"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG6_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org6.unichain.org.cn\",\"peer1.org6.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org7"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG7_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org7.unichain.org.cn\",\"peer1.org7.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org8"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG8_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org8.unichain.org.cn\",\"peer1.org8.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org9"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG9_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org9.unichain.org.cn\",\"peer1.org9.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org10"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG10_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org10.unichain.org.cn\",\"peer1.org10.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org11"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG11_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org11.unichain.org.cn\",\"peer1.org11.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org12"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG12_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org12.unichain.org.cn\",\"peer1.org12.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org13"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG13_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org13.unichain.org.cn\",\"peer1.org13.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org14"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG14_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org14.unichain.org.cn\",\"peer1.org14.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org15"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG15_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org15.unichain.org.cn\",\"peer1.org15.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org16"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG16_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org16.unichain.org.cn\",\"peer1.org16.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org17"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG17_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org17.unichain.org.cn\",\"peer1.org17.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org18"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG18_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org18.unichain.org.cn\",\"peer1.org18.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org19"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG19_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org19.unichain.org.cn\",\"peer1.org19.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Org20"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG20_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.org20.unichain.org.cn\",\"peer1.org20.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo
echo "POST instantiate chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"chain\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.unichain.org.cn \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ORG1_TOKEN"
#echo
#echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
