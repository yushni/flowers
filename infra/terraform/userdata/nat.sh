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

  /sbin/iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
  /sbin/iptables -F FORWARD
  service iptables save

  echo "NAT configured."
}

function main() {
  yum update -y

  enableApiTables
  enableIpForwarding
  configureNAT

  echo "END USER DATA"
}

main
