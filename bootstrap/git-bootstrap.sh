#!/bin/bash
set -x
export SHARE_DIR="./volumes/share"
export IP_ADDRESS=$(hostname -i | awk '{print $1}')
export FQDN=$(host $(hostname) | cut -f 1 -d " ")
export INSTALL_BODY='{ "user": { "email": "air@binalyze.com", "username": "air@binalyze.com", "password": "LabUser2023" }, "settings": { "consoleAddress": "'${FQDN}'", "organization": "binalyze" }, "license": { "licenseKey": "AIR-TEST-LICENSE" } }'
export REGISTRATION_URL='http://127.0.0.1/api/setup/install'

echo "IP ADDRESS:"   $IP_ADDRESS | ts
echo "INSTALL BODY:" $INSTALL_BODY | ts

# Docker installation
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install \
        docker-ce docker-ce-cli \
        containerd.io docker-compose-plugin \
        --yes


# Start the environment
sudo docker compose up -d
# Wait until AIR CONSOLE is up
until $(curl --output /dev/null --silent --head --fail http://localhost); do
    echo 'Waiting AIR CONSOLE to be up' | ts
    sleep 5
done
sudo mkdir -p $SHARE_DIR
sudo chmod -R 777 $SHARE_DIR
pushd $SHARE_DIR

# REGISTRATION TO THE CONSOLE - Register the lab user
RESULT=$(curl  -o registration_response.txt -s -w "%{http_code}\n" -fvL -X POST ${REGISTRATION_URL} -H 'Content-Type: application/json' --data-raw "$INSTALL_BODY")
until [ $RESULT -eq 307 ] ; do
    
    echo 'Waiting REGISTRATION to be up' | ts
    sleep 5
    RESULT=$(curl  -o registration_response.txt  -s -w "%{http_code}\n" -fvL -X POST ${REGISTRATION_URL} -H 'Content-Type: application/json' --data-raw "$INSTALL_BODY")
     if [ $RESULT -eq 400 ] ; then
     docker compose restart
    fi
done

# Retrieve the token
until $(curl --output /dev/null --silent --head --fail http://localhost); do
    echo 'Waiting AIR CONSOLE to be up' | ts
    sleep 5
done
until $(docker compose exec mongodb  mongo airdb --quiet --eval "db.organizations.findOne({_id: 0}, {}).deploymentToken" > ./my.token); do
    echo 'Waiting database to return the token' | ts
    sleep 5
done
#docker compose exec mongodb  mongo airdb --quiet --eval "db.organizations.findOne({_id: 0}, {}).deploymentToken" > ./my.token
export TOKEN=$(cat my.token)
docker compose restart
#WAit until Nginx ssl is ready
until $(curl -k --output /dev/null --silent --head --fail https://${FQDN}); do
    echo 'Waiting AIR CONSOLE -https to be up' | ts
    sleep 30
done
# Download the Windows agent installation file
curl -vvv -k -O -J "https://${FQDN}/api/endpoints/download/0/windows/msi/x86?deployment-token=${TOKEN}"
# Self-signed certificate
cp ../web/config/ssl/cert.pem ./
# Download the Linux agent installation file
curl -vvv -k -O -J "https://${FQDN}/api/endpoints/download/0/deploy/linux?deployment-token=${TOKEN}"
popd