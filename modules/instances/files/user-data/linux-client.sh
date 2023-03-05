#!/bin/bash
set -x

export INIT_DIR='/tmp/binalyze'
export TOKEN_URL='http://${ServerName}:9999/share/my.token'
export DOWNLOAD_URL='api/endpoints/download/0/deploy/linux'
export DEPLOY_URL='http://${ServerName}:9999/share/deploy.sh'
# Binalyze agent environment variables are required by the installation script
export AIR_CONSOLE_ADDRESS='${ServerName}'
export AIR_DEPLOYMENT_TOKEN=""
##############################################################################
mkdir -p $${INIT_DIR}
pushd $${INIT_DIR}

# Waiting for Share Service to provide the token
RESULT=""
until [[ $${RESULT} -eq 200 ]] ; do
    echo 'Waiting for share service provide the token' 
    sleep 5
    RESULT=$(curl -o /dev/null -s -w "%%{http_code}\n" -fv -X HEAD $${TOKEN_URL}) 
done
AIR_DEPLOYMENT_TOKEN=$(curl $${TOKEN_URL}) 

RESULT=""
until [[ $${RESULT} -eq 200 ]] ; do
    echo 'Waiting AIR Console installation script to be up' 
    sleep 5
    #RESULT=$(curl q-k -o /dev/null -s -w "%%{http_code}\n" -fv -X HEAD "https://${ServerName}/$${DOWNLOAD_URL}?deployment-token=$${AIR_DEPLOYMENT_TOKEN}" )
    RESULT=$(curl -k -o /dev/null -s -w "%%{http_code}\n" -fv -X HEAD $${DEPLOY_URL} )
done


curl -vvv  "$${DEPLOY_URL}" | sudo sh
popd