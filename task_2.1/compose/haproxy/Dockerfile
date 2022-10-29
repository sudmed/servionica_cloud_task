# HAProxy server #1

FROM haproxy:2.6.6-alpine
USER root
RUN apk update && apk upgrade
RUN apk add --no-cache bash curl ipvsadm iproute2 openrc keepalived
EXPOSE 91
