#!/bin/bash

# This script installs and configures NGINX.
# It needs 1 mandatory argument.

set -e

# check for root
if [[ "$(id -u)" != "0" ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

### 0. Validate and parse positional arguments
if [ $# -eq 0 ]; then
  echo ""
  echo "This script installs and configures NGINX."
  echo ""
  echo "You need to set 1 mandatory argument: "
  echo "      1) Demo content for NGINX index page (\"-c, --content\" option)."
  echo ""
  echo "Usage: sudo $0 -c=<"Hello World! Server 1">"
  echo "Example:"
  echo "    sudo $0 -c="<H1>Hello World! <br /> Server 1</H1>" "
  echo ""
  exit 1
fi

if [ ! -z $2 ] ; then
  echo "You need to set exactly 1 parameter."
  exit 1
fi

for i in "$@"; do
  case $i in
    -c=*|--content=*)
      CONTENT="${i#*=}"
      echo "CONTENT=${i#*=}"
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


## Install NGINX
yum install epel-release -y
yum -y update
yum install nginx -y
systemctl start nginx
systemctl enable nginx

## add firewall rules
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

## change default NGINX index page
echo "$CONTENT" | tee /usr/share/nginx/html/index.html
