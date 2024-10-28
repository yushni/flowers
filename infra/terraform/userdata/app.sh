#! /bin/bash

function verifyInstanceHasOutboundConnection() {
  for _ in {1..10}; do
    resp=$(curl -m 5 -I http://google.com)
    if [ "$resp" ]; then
      echo "Instance has outbound connection"
      return
    fi
    echo "Instance does not have outbound connection retrying in 5 seconds"
    sleep 5
  done
}

function installDocker() {
  echo "UPDATING THE SYSTEM"
  yum update -y
  echo "INSTALLING Docker"
  yum install docker -y
}

function runApp() {
  echo "RETRIEVING SMTP PARAMETERS"
  SMTP_PASSWORD=$(aws ssm get-parameter --name "/smtp/password" --region ${REGION} --with-decryption --query "Parameter.Value" --output text)
  SMTP_USERNAME=$(aws ssm get-parameter --name "/smtp/username" --region ${REGION} --with-decryption --query "Parameter.Value" --output text)
  SMTP_RECIPIENT=$(aws ssm get-parameter --name "/smtp/recipient" --region ${REGION} --with-decryption --query "Parameter.Value" --output text)

  echo "RUN POSTGRES"
  docker run postgres -p 5432:5432 \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_HOST=db \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_DB=postgres

  echo "RUN THE APP"
  docker run yurashni/flowers-app:0.4.5 -p 8080:8080 \
    -e SMTP_RECIPIENT=$SMTP_RECIPIENT \
    -e SMTP_PASSWORD=$SMTP_PASSWORD \
    -e SMTP_USERNAME=$SMTP_USERNAME \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_HOST=db \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_DB=postgres
}

function main() {
  echo "START USER DATA"

  verifyInstanceHasOutboundConnection
  installDocker
  runApp

  echo "END USER DATA"
}

main
