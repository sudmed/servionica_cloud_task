#!/bin/bash

# This script installs HAproxy and Keepalived (in master or backup state).
#
# The node's IP-address must be given as command-line argument `-ip` (e.g. -ip=192.168.57.6).
# The Keepalived state must be given as as command-line argument `-ke_st` (e.g. -ke_st=master OR -ke_st=backup).
# The Keepalived Floating (virtual) IP must be given as command-line argument `-ke_vip` (e.g. -ke_vip=192.168.57.10).
#
# Usage: sudo ./install_haproxy_keepalived.sh -ip -ke_st -ke_vip


set -e

# check for root
if [[ "$(id -u)" != "0" ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi


### 0. Parse positional arguments
if [ $# -eq 0 ]
then
  echo
  echo "This script installs HAproxy and Keepalived (in master or backup state)."
  echo "It needs 3 mandatory arguments: "
  echo "      1) IP-address of VM (`-ip=` option),"
  echo "      2) master or backup state of Keepalived (`-ke_st=` option),"
  echo "      3) Keepalived's floating IP (`-ke_vip=` option)."
  echo
  echo "Usage: sudo ./install_haproxy_keepalived.sh -ip -ke_st -ke_vip"
  echo "Example:"
  echo "    sudo ./install_haproxy_keepalived.sh -ip=192.168.57.6 -ke_st=master -ke_vip=192.168.57.10"
  exit 1
fi


for i in "$@"; do
  case $i in
    -ip=*|--node_ip=*)
      IP="${i#*=}"
      shift # past argument=value
      ;;
    -ke_st=*|--keepalived_state=*)
      KE_STATE="${i#*=}"
      shift # past argument=value
      ;;
    -ke_vip=*|--keepalived_vip=*)
      KE_VIP="${i#*=}"
      shift # past argument=value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument with no value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done


### 1. HAproxy

## install prerequisites
yum -y update
yum install gcc pcre-devel tar make -y

## compile and build from sources the last haproxy
cd /usr/src/
wget http://www.haproxy.org/download/2.6/src/haproxy-2.6.6.tar.gz
tar xzvf haproxy-2.6.6.tar.gz
cd /usr/src/haproxy-2.6.6
make TARGET=linux-glibc
make install

## configure haproxy
useradd -r haproxy
mkdir /etc/haproxy
mkdir -p /var/lib/haproxy
touch /var/lib/haproxy/stats
ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy
cp /usr/src/haproxy-2.6.6/examples/haproxy.init /etc/init.d/haproxy
chmod 755 /etc/init.d/haproxy
systemctl daemon-reload
chkconfig haproxy on

## change haproxy config
cat > /etc/haproxy/haproxy.cfg << EOF
global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon
defaults
log global
mode http
option httplog
option dontlognull
timeout connect 5000
timeout client 50000
timeout server 50000
#frontend
frontend http_front
bind *:80
stats uri /haproxy?stats
default_backend http_back
#round robin balancing backend http
backend http_back
balance roundrobin
#balance leastconn
mode http
server webserver1 192.168.57.4:80 check
server webserver2 192.168.57.5:80 check
EOF

## restart haproxy
systemctl restart haproxy
systemctl status haproxy

## add firewall rules
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-port=8181/tcp
firewall-cmd --reload

## check version
systemctl status haproxy
haproxy -v



### 2. Keepalived

## install prerequisites
yum -y update
yum -y install kernel-headers kernel-devel gcc libnl libnl-devel

## compile and build from sources the last Keepalived
cd /usr/src/
wget https://keepalived.org/software/keepalived-2.2.7.tar.gz
tar -xvf keepalived-2.2.7.tar.gz
cd keepalived-2.2.7
./configure --prefix=/usr/local/keepalived --sysconf=/etc
make && make install
touch /etc/keepalived/keepalived.conf
# SLAVE node @ 192.168.57.6/24
cat > /etc/keepalived/keepalived.conf << EOF
vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass passw123
    }
    virtual_ipaddress {
    192.168.57.10 # virtual IP
    }
}
EOF

## start & enable keepalived
systemctl start keepalived.service
systemctl enable keepalived.service
systemctl status keepalived.service
/usr/local/keepalived/sbin/keepalived -v
