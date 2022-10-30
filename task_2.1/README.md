## TASK 2.1
[Task text](task_text_2.1.png)


### Task solution

### 1. Bash scripts
<details>
  <summary>OPEN</summary>

1. **[Install NGINX script](install_nginx.sh)**
2. **[Install HAproxy and Keepalived script](install_haproxy_keepalived.sh)**

![schema](task_2.1_schema.png)  

- VM-1 (192.168.57.4): NGINX webserver # 1  
- VM-2 (192.168.57.5): NGINX webserver # 2  
- VM-3 (192.168.57.6): HAproxy and Keepalived server # 1 (master node)  
- VM-4 (192.168.57.7): HAproxy and Keepalived server # 2 (backup node)  
- Keepalived floating (virtual) IP: 192.168.57.10  

  
### Validation of working balancer and keepalived router failover:
![task_2.1.gif](task_2.1.gif)

---

#### Run NGINX installing script on VM-1
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_nginx.sh
sudo chmod +x install_nginx.sh
sudo ./install_nginx.sh -c="<H1>Hello World! <br /> Server 1</H1>"
```
[STDOUT](VM-1_output.txt)  

---

#### Run NGINX installing script on VM-2
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_nginx.sh
sudo chmod +x install_nginx.sh
sudo ./install_nginx.sh -c="<H1>Hello World! <br /> Server 2</H1>"
```
[STDOUT](VM-2_output.txt)  

---

#### Run HAproxy and Keepalived installing script on VM-3 (master node)
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_haproxy_keepalived.sh -n=192.168.57.6 -s=master -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="
```
[STDOUT](VM-3_output.txt)  

---

#### Run HAproxy and Keepalived installing script on VM-4 (backup node)
```console
cd ~
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
sudo ./install_haproxy_keepalived.sh -n=192.168.57.7 -s=backup -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="
```
[STDOUT](VM-4_output.txt)  
</details>

### 2. Docker compose
<details>
  <summary>OPEN</summary>

**Infra:**  
```text
One node architecture.
  
Docker container NGINX-1:
    IP: 192.168.57.3
    Port HTTP: 81
    Instances:
        - nginx #1

Docker container NGINX-2:
    IP: 192.168.57.3
    Port HTTP: 82
    Instances:
        - nginx #2

Docker container HAPROXY:
    IP: 192.168.57.3
    Port HTTP: 91
    Instances:
        - haproxy
        - keepalived
```

  **Files:**  
1. **[docker-compose.yml](compose/docker-compose.yml)**  
2. **[additional files](compose/)**

### Validation of working balancer:
![task_2.1_compose.gif](compose/task_2.1_compose.gif)
  
</details>
