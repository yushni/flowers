#!/bin/bash

function enableApiTables() {
  echo "Enabling API tables..."

  yum install iptables-services -y
  systemctl enable iptables
  systemctl start iptables

  echo "API tables enabled."
}

function enableIpForwarding() {
  echo "Enabling IP forwarding..."

  echo net.ipv4.ip_forward=1 >/etc/sysctl.d/custom-ip-forwarding.conf
  sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

  echo "IP forwarding enabled."
}

function configureNAT() {
  echo "Configuring NAT..."

  /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  /sbin/iptables -F FORWARD
  service iptables save

  echo "NAT configured."
}

function registerInstanceInRouteTable() {
  echo "Registering instance in route table..."

  echo "Retrieving token from metadata service"
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  echo "Retrieving instance ID from metadata service"
  INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

  echo "Trying to create route"
  aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --instance-id $INSTANCE_ID --region ${REGION}

  echo "Trying to replace route"
  aws ec2 replace-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --instance-id $INSTANCE_ID --region ${REGION}

  echo "Trying to modify instance attribute"
  aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-source-dest-check --region ${REGION}

  echo "Instance registered in route table."
}

function main() {
  yum update -y

  enableApiTables
  enableIpForwarding
  configureNAT
  registerInstanceInRouteTable

  echo "END USER DATA"
}

main
