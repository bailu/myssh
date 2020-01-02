# myssh
快捷ssh登录工具，根据原生ssh config配置，列出主机清单，选择主机序号后登录

config格式
``` 
# 这里是下面Host的注释，注意与#中间空格
Host t2
    HostName 10.1.1.1
    User root

# 这里是下面Host的注释，注意与#中间空格
Host test
    HostName 10.1.2.40
    Port 996
    User username
    IdentityFile ~/.ssh/id_rsa
```    

建立命令快捷方式，方便全局输入myssh可用， `ln -s ~/myssh.sh /usr/local/bin/myssh` 
