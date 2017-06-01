#!/bin/sh

echo "Check and fix multiple gateways..."

while [ true ]; do

  EXISTING_DEF_REMOTE_GW=$(ip route show | grep default | grep ppp0 | awk '{ print $3 }')

  if [ -z "$EXISTING_DEF_REMOTE_GW"  ]
  then
      # the gateway is OK, there is no default gateway on ppp0 interface
      sleep 5
  else
      # there is a default gateway on ppp0 interface
      echo "Fixing default gateway"
      route del -net 0.0.0.0 gw "$EXISTING_DEF_REMOTE_GW" netmask 0.0.0.0 dev ppp0
      route add "$VPNRDPIP" gw "$EXISTING_DEF_REMOTE_GW" dev ppp0
      echo "Default gateway fixed"
  fi

done
