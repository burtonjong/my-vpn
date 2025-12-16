#!/bin/bash
set -e
# Able to see the logs when connecting with ssm
exec > >(tee /var/log/user-data.log)
exec 2>&1
echo "Starting WireGuard setup..."

# install wireguard and iptables 
apt update -y
apt install -y awscli wireguard iptables

# ip forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# creating wireguard directory
mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

# creating server/client keys
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key
wg genkey | tee /etc/wireguard/client_private.key | wg pubkey > /etc/wireguard/client_public.key
chmod 600 /etc/wireguard/client_private.key

# read keys
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/client_private.key)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
CLIENT_PUBLIC_KEY=$(cat /etc/wireguard/client_public.key)

# define client IP
SERVER_IP="10.16.16.1/24"
CLIENT_IP="10.16.16.2/32"
OUT_IFACE=$(ip route | awk '/default/ {print $5}')

# wireguard server config
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
Address = $SERVER_IP
ListenPort = ${wireguard_port}
PostUp   = iptables -t nat -A POSTROUTING -o ${OUT_IFACE} -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o ${OUT_IFACE} -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP
EOF


# wireguard client config
cat > /home/ubuntu/wg-client.conf <<EOF
[Interface]
Address = $CLIENT_IP
PrivateKey = $CLIENT_PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $(curl -s ifconfig.me):${wireguard_port}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

chmod 600 /etc/wireguard/wg0.conf
chmod 600 /home/ubuntu/wg-client.conf
chown ubuntu:ubuntu /home/ubuntu/wg-client.conf

# enable and start wireguard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

CLIENT_CONFIG=$(cat /home/ubuntu/wg-client.conf)
aws ssm put-parameter \
    --name "/wireguard/client-config" \
    --value "$CLIENT_CONFIG" \
    --type "SecureString" \
    --overwrite \
    --region ${aws_region}

echo "Finished wireguard setup script"