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
      SUPERSECRETMESSAGE_HTTP_BINDING_ADDRESS=:80
      SUPERSECRETMESSAGE_HTTPS_BINDING_ADDRESS=:443
      SUPERSECRETMESSAGE_HTTPS_REDIRECT_ENABLED=true
      SUPERSECRETMESSAGE_TLS_AUTO_DOMAIN=secrets.chapelramblers.org
    ports:
      - "443:443"
      - "80:80"
    depends_on:
      - vault
    networks:
      - skynet


networks:
  skynet:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.69.0/24
EOF

#$(aws ecr get-login --region eu-west-1 | sed -e 's/-e none//g')
cd /root && echo "y" | /usr/local/bin/docker-compose up --detach
