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
  echo "STARTING Docker"
  systemctl start docker
}

function runApp() {
  echo "RUN THE APP"
  docker run -d -p 80:80 -e ${REGION} yurashni/flowers-app:0.4.6
}

function main() {
  echo "START USER DATA"

  verifyInstanceHasOutboundConnection
  installDocker
  runApp

  echo "END USER DATA"
}

main
