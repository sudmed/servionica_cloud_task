## TASK 2.1
[Task text](task_text_2.1.png)


### Task solution


## First way: Bash scripts
1. **[Install NGINX](install_nginx.sh)**
2. **[Install HAproxy and Keepalived](install_haproxy_keepalived.sh)**

#### Validation: run NGINX installing script on VM-1
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_nginx.sh -c="<H1>Hello World! <br /> Server 1</H1>"
```

#### Validation: run NGINX installing script on VM-2
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_nginx.sh -c="<H1>Hello World! <br /> Server 2</H1>"
```

#### Validation: run HAproxy and Keepalived installing script on VM-3
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_haproxy_keepalived.sh -n=192.168.57.6 -s=master -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="
```
**OUTPUT**
```console

```

#### Validation: run HAproxy and Keepalived installing script on VM-4
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_haproxy_keepalived.sh -n=192.168.57.7 -s=backup -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="
```
**OUTPUT**
```console

```

