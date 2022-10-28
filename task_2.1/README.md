## TASK 2.1
Task's text


### 
```console
wget -N https://raw.githubusercontent.com/sudmed/servionica_cloud_task/main/task_2.1/install_haproxy_keepalived.sh
sudo chmod +x install_haproxy_keepalived.sh
```
#### Example run on VM-3
`sudo ./install_haproxy_keepalived.sh -n=192.168.57.6 -s=master -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="`  
** OUTPUT **


#### Example run on VM-4
`sudo ./install_haproxy_keepalived.sh -n=192.168.57.7 -s=backup -v=192.168.57.10 -w1=192.168.57.4 -w2=192.168.57.5 -p="eyhZK+8TmdkWLH+SXuQ="`  
** OUTPUT **

