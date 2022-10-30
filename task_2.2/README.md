## Task 2.2

[Task text](task_text_2.2.png)


### Task solution

### Ansible role
<details>
  <summary>OPEN</summary>

- VM-1 (192.168.57.4): NGINX webserver # 1  
- VM-2 (192.168.57.5): NGINX webserver # 2  
- VM-3 (192.168.57.6): HAproxy and Keepalived server # 1 (master node)  
- VM-4 (192.168.57.7): HAproxy and Keepalived server # 2 (backup node)  
- Keepalived floating (virtual) IP: 192.168.57.10  

  
### Validation of running role with simple monitoring:
![task_2.1.gif](nginx_haproxy_ha.gif)

---

#### Run Ansible playbook
```console
ansible-playbook nginx_haproxy_ha.yml -i ./hosts -K
```
[STDOUT](STDOUT_nginx_haproxy_ha.txt)  

</details>
