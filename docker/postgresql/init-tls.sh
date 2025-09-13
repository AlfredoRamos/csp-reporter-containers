#!/bin/sh --
set -Eeo pipefail
mkdir -p /var/lib/postgresql/ssl
cd /var/lib/postgresql/ssl
cp /run/secrets/server_crt /run/secrets/server_key  ./
chown postgres:postgres .server.crt ./server.key
chmod 600 ./server.crt ./server.key
conf_file="$PGDATA/postgresql.conf"
grep -q "^ssl\s*=" "${conf_file}" || echo "ssl = on" >> "${conf_file}"
grep -q "^ssl_cert_file\s*=" "${conf_file}" || echo "ssl_cert_file = 'ssl/server.crt'" >> "${conf_file}"
grep -q "^ssl_key_file\s*=" "${conf_file}" || echo "ssl_key_file = 'ssl/server.key'" >> "${conf_file}"
