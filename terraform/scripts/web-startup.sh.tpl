#!/bin/bash
exec > /var/log/web-startup.log 2>&1
set -x

apt-get update
apt-get install -y nginx

cat > /etc/nginx/sites-available/default <<'NGINXEOF'
server {
    listen 80 default_server;
    server_name _;

    location = /health {
        return 200 "web tier ok\n";
    }

    location / {
        proxy_pass http://${app_ip}:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_connect_timeout 5s;
    }
}
NGINXEOF

systemctl restart nginx
