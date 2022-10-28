#!/bin/bash

# This script installs HAproxy and Keepalived (in master or backup state).
# It needs 5 mandatory arguments.

set -e
passwd=$(openssl rand -base64 14)

# check for root
if [[ "$(id -u)" != "0" ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

### 0. Validate and parse positional arguments
if [ $# -eq 0 ]; then
  echo ""
  echo "This script installs HAproxy and Keepalived (in master or backup state)."
  echo ""
  echo "You need to set 5 mandatory arguments: "
  echo "      1) IP-address of VM (\"-n, --node-ip\" option)."
  echo "      2) master or backup state of Keepalived (\"-s, --keepalived-state\" option)."
  echo "      3) Keepalived's floating IP (\"-v, --keepalived-vip\" option)."
  echo "      4) IP-address of webserver1 (\"-w1, --webserver1\" option)."
  echo "      5) IP-address of webserver2 (\"-w2, --webserver2\" option)."
  echo ""
  echo "Usage: sudo $0 -n=<IP> -s=<master|backup> -v=<IP> -w1=<IP> -w2=<IP>"
  echo "Example:"
  echo "    sudo $0 -n=192.168.57.6 -s=master -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5"
  echo ""
  exit 1
fi

if [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ -z $5 ] || [ ! -z $6 ]; then
  echo "You need to set exactly 5 parameters."
  exit 1
fi

for i in "$@"; do
  case $i in
    -n=*|--node-ip=*)
      IP="${i#*=}"
      echo "IP=${i#*=}"
      shift
      ;;
    -s=*|--keepalived-state=*)
      STATE="${i#*=}"
      echo "STATE="${i#*=}""
      shift
      ;;
    -v=*|--keepalived-vip=*)
      VIP="${i#*=}"
      echo "VIP="${i#*=}""
      shift
      ;;
    -w1=*|--webserver1=*)
      WS1="${i#*=}"
      echo "WS1="${i#*=}""
      shift
      ;;
    -w2=*|--webserver2=*)
      WS2="${i#*=}"
      echo "WS2="${i#*=}""
      shift
      ;;
    -*|--*)
      echo "Unknown option, try again."
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
server webserver1 $WS1:80 check
server webserver2 $WS2:80 check
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

# MASTER mode
if [ $STATE -eq master ]; then
  cat > /etc/keepalived/keepalived.conf << EOF
vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass $passwd
    }
    virtual_ipaddress {
    $VIP # virtual IP
    }
}
EOF
fi

# BACKUP mode
if [ $STATE -eq backup ]; then
  cat > /etc/keepalived/keepalived.conf << EOF
vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass passw123
    }
    virtual_ipaddress {
    $VIP # virtual IP
    }
}
EOF
fi

## start & enable keepalived
systemctl start keepalived.service
systemctl enable keepalived.service
systemctl status keepalived.service
/usr/local/keepalived/sbin/keepalived -v
