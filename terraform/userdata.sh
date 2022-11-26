#!/bin/bash
# Adding swap temporarily in case of using t3.nano
dd if=/dev/zero of=/var/cache/swapfile bs=1M count=1024;
chmod 600 /var/cache/swapfile;
mkswap /var/cache/swapfile;
swapon /var/cache/swapfile;
free -m > /var/tmp/swap.txt
yum update -y;
yum upgrade -y;
amazon-linux-extras install epel docker -y;
yum upgrade -y;
yum -y install amazon-ecr-credential-helper jq git
systemctl enable docker --now
sed -i 's/^#Port 22/Port 2020/g' /etc/ssh/sshd_config;
systemctl restart sshd;
hostnamectl set-hostname ${project_name};
timedatectl set-timezone Europe/London;

#echo "{ \"credsStore\": \"ecr-login\" }" > /etc/docker/config.json
systemctl restart docker
/usr/bin/openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=UK/ST=Bobbins/L=GreaterManchester/O=Dis/CN=supersecret.chegwin.org" \
    -keyout /root/jupyter.key  -out /root/jupyter.crt;
cd /root
git clone https://github.com/tommybobbins/sup3rS3cretMes5age.git 
wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
chmod a+x /usr/local/bin/docker-compose
cat <<"EOF" >/etc/docker/server.conf
server {
       ...
        # set DNS resolver as Docker internal DNS
        resolver 127.0.0.11 valid=10s;
        resolver_timeout 5s; 
       ...
       location / {
        # prevent dns caching and force nginx to make a dns lookup on each request.
        set $target http://web:8080;
        proxy_pass $target;
       ..
       }
}
EOF
cat <<"EOF" > /root/docker-compose.yml
version: '3.2'
services:
  vault:
    image: vault:latest
    container_name: vault
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: supersecret
    cap_add:
      - IPC_LOCK
    expose:
      - 8200
    networks:
      - skynet


  supersecret:
    build: ./sup3rS3cretMes5age
    image: algolia/supersecretmessage:latest
    container_name: supersecret
    environment:
      VAULT_ADDR: http://vault:8200
      VAULT_TOKEN: supersecret
      SUPERSECRETMESSAGE_HTTP_BINDING_ADDRESS: ":8082"
    ports:
      - "8082:8082"
    depends_on:
      - vault
    networks:
      - skynet


  nginx:
    image: nginx
    container_name: nginx
    restart: always
    networks:
      - skynet
    ports:
      - 80:80
      - 443:443
    volumes:
      - /root/jupyter.crt:/etc/nginx/self.crt
      - /root/jupyter.key:/etc/nginx/self.key
      - /root/nginx.conf:/etc/nginx/nginx.conf

      
networks:
  skynet:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.69.0/24
EOF

cat <<"EOF" > /root/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80 default;
        server_name  _;

        return 301 https://$host$request_uri;
    }

    upstream supersecret {
        server supersecret:8082;
    }

    
    ############## SuperSecret ####################
    server {
        listen      0.0.0.0:443 ssl;
        server_name   supersecret.remote.lan
                      www.supersecret.remote.lan;

        ssl_certificate     /etc/nginx/self.crt;
        ssl_certificate_key /etc/nginx/self.key;

        ssl_protocols TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA512:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:ECDH+AESGCM:ECDH+AES256:DH+AESGCM:DH+AES256:RSA+AESGCM:!aNULL:!eNULL:!LOW:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS;
        ssl_session_cache  builtin:1000  shared:SSL:10m;

        access_log  /var/log/nginx/supersecret.log ;
        error_log  /var/log/nginx/supersecret.error.log debug;

        location / {
          proxy_set_header        Host $host;
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header        X-Forwarded-Proto $scheme;
          proxy_pass              http://supersecret;
          proxy_read_timeout      90;
        }

        location ~* /(api/kernels/[^/]+/(channels|iopub|shell|stdin)|terminals/websocket)/? {
           proxy_pass http://supersecret;

           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header Host $host;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           # WebSocket support
           proxy_http_version 1.1;
           proxy_set_header      Upgrade "websocket";
           proxy_set_header      Connection "Upgrade";
           proxy_read_timeout    86400;

        }
    }

}
EOF

#sed -i 's/bobbins/${jupyter_passwd}/g' /root/docker-compose.yml;
#$(aws ecr get-login --region eu-west-1 | sed -e 's/-e none//g')
cd /root && echo "y" | /usr/local/bin/docker-compose up --detach
