#!/bin/bash
exec > /var/log/app-startup.log 2>&1
set -x

apt-get update
apt-get install -y python3 python3-psycopg2

# Fetch the DB password from Secret Manager using this VM's service account
TOKEN=$(curl -s -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')

DB_PASSWORD=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://secretmanager.googleapis.com/v1/projects/${project_id}/secrets/${secret_id}/versions/latest:access" \
  | python3 -c 'import sys,json,base64; print(base64.b64decode(json.load(sys.stdin)["payload"]["data"]).decode())')

cat > /etc/app.env <<ENVEOF
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=$DB_PASSWORD
ENVEOF
chmod 600 /etc/app.env

cat > /opt/app.py <<'PYEOF'
import os, json
from http.server import BaseHTTPRequestHandler, HTTPServer
import psycopg2

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            conn = psycopg2.connect(
                host=os.environ["DB_HOST"],
                dbname=os.environ["DB_NAME"],
                user=os.environ["DB_USER"],
                password=os.environ["DB_PASSWORD"],
                connect_timeout=5,
            )
            cur = conn.cursor()
            cur.execute("SELECT version(), now()")
            row = cur.fetchone()
            conn.close()
            body = json.dumps({"tier": "app", "database": "connected",
                               "server_time": str(row[1]), "version": row[0]})
            code = 200
        except Exception as e:
            body = json.dumps({"tier": "app", "database": "error", "detail": str(e)})
            code = 500
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body.encode())

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PYEOF

cat > /etc/systemd/system/app.service <<'SVCEOF'
[Unit]
Description=Three-tier demo app
After=network-online.target

[Service]
EnvironmentFile=/etc/app.env
ExecStart=/usr/bin/python3 /opt/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable --now app
