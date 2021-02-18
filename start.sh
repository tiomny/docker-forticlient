#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" -o -z "$VPNRDPIP" ]; then
  echo "Variables VPNRDPIP, VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}
export RETRYDELAY=${RETRYDELAY:-10}
export RETRYCOUNT=${RETRYCOUNT:-3}

iptables -t nat -A PREROUTING -p tcp --dport 3380 -j DNAT --to-destination  ${VPNRDPIP}:3389
iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

/gateway-fix.sh &

for i in {1..$RETRYCOUNT} do
  echo "------------ VPN Starts ------------"
  /usr/bin/forticlient
  echo "------------ VPN exited ------------"
  sleep $env(RETRYDELAY)
done
