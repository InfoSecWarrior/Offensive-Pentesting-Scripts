#!/bin/bash

SCRIPT_NAME=$0

#------------------------
# COLORS
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'
bold=$(tput bold)
#------------------------

function Banner() { echo -e "
 ___        __      ____             __        __              _
|_ _|_ __  / _| ___/ ___|  ___  ___  \ \      / /_ _ _ __ _ __(_) ___  _ __
 | || '_ \| |_ / _ \___ \ / _ \/ __|  \ \ /\ / / _  | '__| '__| |/ _ \| '__|
 | || | | |  _| (_) |__) |  __/ (__    \ V  V / (_| | |  | |  | | (_) | |
|___|_| |_|_|  \___/____/ \___|\___|    \_/\_/ \__,_|_|  |_|  |_|\___/|_|
 github.com/InfoSecWarrior                              by ${green}@ArmourInfosec${reset}
----------------------------------------------------------------------------
"
}

Banner

# get ssh connection for root access
read -p "Target SSH username: " ssh_username
read -p "Target SSH IP address: " ssh_ip
read -p "Target SSH IP port number: " ssh_port
read -s -p "Target SSH root user password: " ssh_password

# SSH into remote server and set up tunnel
sshpass -p $ssh_password ssh -o StrictHostKeyChecking=no $ssh_username@$ssh_ip -p $ssh_port << EOF

# Enable root login and tunneling
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
sed -i 's/#PermitTunnel yes/PermitTunnel yes/' /etc/ssh/sshd_config
systemctl restart sshd

EOF

# Connect to remote server and check if rpm or dpkg is installed
if sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" -p "$ssh_port" "rpm --help" &> /dev/null; then
    echo "rpm base package manager"
    # install iptables and iproute using rpm
    sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" -p "$ssh_port" "yum install iptables iproute -y"
elif sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" -p "$ssh_port" "dpkg --help" &> /dev/null; then
    echo "dpkg base package manager"
    # install iptables using apt-get
    sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" -p "$ssh_port" "apt-get update && apt-get install iptables -y"
else
    echo "Neither rpm nor dpkg command is installed"
fi

# Connect to remote server and run ip addr show command
sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no "$ssh_username@$ssh_ip" -p "$ssh_port" "ip addr show && route" > output.txt

# Extract IP and interface name from output
IP=$(grep -oP 'inet \K\S+' output.txt | sed -n 2p | awk -F '/' '{print $1}')
IP_GW=$(grep -oP 'inet \K\S+' output.txt | sed -n 2p)
interface_name=$(grep -oP '\d+: [a-zA-Z0-9@_.-]+' output.txt | head -n2 | tail -n1 | cut -d' ' -f2)
Range=$(tail -n 1 output.txt | awk '{print $1}')

# Print results
echo "Target IP Address: ${IP[0]}"
echo "Target IP Address With GW : $IP_GW"
echo "Target IP Interface Name: $interface_name"
echo "Target IP Ragne : $Range"
# ssh into the server and modify sshd_config
ssh -f "$ssh_username@$ssh_ip" -p "$ssh_port" -w any:any sleep 5

# create VPN tunnel on local machine
ip addr add 10.0.0.1/24 peer $IP_GW dev tun0
ifconfig tun0 up

# create VPN tunnel on server
sshpass -p $ssh_password ssh $ssh_username@$ssh_ip -p $ssh_port "ip addr add 10.0.0.2/24 peer 10.0.0.1/24 dev tun0 && ifconfig tun0 up && echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -t nat -A POSTROUTING -s 10.0.0.1 -o $interface_name -j MASQUERADE && iptables-save"

# add route for VPN network
route add -net $Range/24 gw $IP
