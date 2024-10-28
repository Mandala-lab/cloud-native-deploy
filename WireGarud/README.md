## apt/apt-get

检查是否内置

```shell
wg -v
```

默认自带, 如果没有安装请手动安装:

```
apt install openresolv
apt install wireguard-tools
```

客户端样板代码:

```
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = PrivateKey
Address = CIDR
DNS = 127.0.0.1, 192.168.2.1

[Peer]
PublicKey = PublicKey
PresharedKey = PresharedKey
AllowedIPs = AllowedIPs
Endpoint = Endpoint
PersistentKeepalive = 25
EOF
```

Nginx代理

```
cat> /usr/local/nginx/conf/casdoor.conf <<EOF
server {
    listen 8000;
    http2 on;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "DENY";
    add_header Alt-Svc 'h3=":443"; ma=86400, h3-29=":443"; ma=86400';
    proxy_connect_timeout 5s;
    # 添加 Early-Data 头告知后端，防止重放攻击
    proxy_set_header Host \$host;

    location / {
            proxy_pass http://192.168.2.185:8000;  # Kubernetes集群中应用的地址和端口
            #roxy_set_header X-Real-IP \$remote_addr;
            #roxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            #proxy_set_header X-Forwarded-Proto \$scheme;
        }
}
EOF
/usr/local/nginx/sbin/nginx -s reload
```

## yum/dnf

```shell
dnf install wireguard-tools
```

Run the below command to start and enable the '**systemd-resolved**' service.  
运行以下命令以启动并启用“systemd 解析”服务。

```shell
sudo systemctl start systemd-resolved  
sudo systemctl enable systemd-resolved
```

安装wireguard工具并运行systemd解析后，设置NetworkManager以使用“systemd-solve”作为DNS后端。

打开 NetworkManager 配置文件 '/etc/NetworkManager/NetworkManager.conf'。

```shell
vi /etc/NetworkManager/NetworkManager.conf
```

将“dns”参数添加到“[main]”部分，如下所示。

```
[main]  
dns=systemd-resolved
```

删除“/etc/resolv.conf”文件，并创建由systemd-solved管理的“resolv.conf”文件的新符号链接文件。

```shell
rm -f /etc/resolv.conf  
sudo ln -s /usr/lib/systemd/resolv.conf /etc/resolv.conf
```

现在重新启动网络管理器服务以应用更改。

```shell
sudo systemctl restart NetworkManager
```

Now that the NetworkManager is configured, you are now ready to set up the wireguard client.  
现在，网络管理器已配置完毕，您现在可以设置线卫客户端了。

创建 wireguard 客户端配置文件后，您可以通过下面的“wg-quick up”命令在客户端计算机上运行 wireguard。

```shell
wg-quick up wg0
```

Now verify the '_**wg-client1**_' interface via the ip command below.  
现在通过下面的 ip 命令验证“wg-client1”接口。

```shell
ip a show wg0
```

You can also verify the DNS resolver on the wg-client1 interface via the '_resolvectl_' command below.  
您还可以通过下面的“解析”命令验证 wg-client1 接口上的 DNS 解析器。

```shell
resolvectl status wg0
```

## 参考

1. https://www.howtoforge.com/how-to-install-wireguard-vpn-on-rocky-linux-9/
2. https://linuxiac.com/how-to-set-up-wireguard-vpn-server-on-ubuntu/#step-31-generate-publicprivate-keypair
3. https://www.cyberciti.biz/faq/ubuntu-20-04-set-up-wireguard-vpn-server/
