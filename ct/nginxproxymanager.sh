#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://nginxproxymanager.com/

APP="Nginx Proxy Manager"
var_tags="proxy"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP" 
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /lib/systemd/system/npm.service ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if ! command -v pnpm &> /dev/null; then  
    msg_info "Installing pnpm"
    #export NODE_OPTIONS=--openssl-legacy-provider
    $STD npm install -g pnpm@8.15
    msg_ok "Installed pnpm"
  fi
  RELEASE=$(curl -s https://api.github.com/repos/NginxProxyManager/nginx-proxy-manager/releases/latest |
    grep "tag_name" |
    awk '{print substr($2, 3, length($2)-4) }')
  msg_info "Stopping Services"
  systemctl stop openresty
  systemctl stop npm
  msg_ok "Stopped Services"

  msg_info "Cleaning Old Files"
  rm -rf /app \
    /var/www/html \
    /etc/nginx \
    /var/log/nginx \
    /var/lib/nginx \
    $STD /var/cache/nginx
  msg_ok "Cleaned Old Files"

  msg_info "Downloading NPM v${RELEASE}"
  wget -q https://codeload.github.com/NginxProxyManager/nginx-proxy-manager/tar.gz/v${RELEASE} -O - | tar -xz
  cd nginx-proxy-manager-${RELEASE}
  msg_ok "Downloaded NPM v${RELEASE}"

  msg_info "Setting up Enviroment"
  ln -sf /usr/bin/python3 /usr/bin/python
  ln -sf /usr/bin/certbot /opt/certbot/bin/certbot
  ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx
  ln -sf /usr/local/openresty/nginx/ /etc/nginx
  sed -i "s|\"version\": \"0.0.0\"|\"version\": \"$RELEASE\"|" backend/package.json
  sed -i "s|\"version\": \"0.0.0\"|\"version\": \"$RELEASE\"|" frontend/package.json
  sed -i 's|"fork-me": ".*"|"fork-me": "Proxmox VE Helper-Scripts"|' frontend/js/i18n/messages.json
  sed -i "s|https://github.com.*source=nginx-proxy-manager|https://helper-scripts.com|g" frontend/js/app/ui/footer/main.ejs
  sed -i 's+^daemon+#daemon+g' docker/rootfs/etc/nginx/nginx.conf
  NGINX_CONFS=$(find "$(pwd)" -type f -name "*.conf")
  for NGINX_CONF in $NGINX_CONFS; do
    sed -i 's+include conf.d+include /etc/nginx/conf.d+g' "$NGINX_CONF"
  done
  mkdir -p /var/www/html /etc/nginx/logs
  cp -r docker/rootfs/var/www/html/* /var/www/html/
  cp -r docker/rootfs/etc/nginx/* /etc/nginx/
  cp docker/rootfs/etc/letsencrypt.ini /etc/letsencrypt.ini
  cp docker/rootfs/etc/logrotate.d/nginx-proxy-manager /etc/logrotate.d/nginx-proxy-manager
  ln -sf /etc/nginx/nginx.conf /etc/nginx/conf/nginx.conf
  rm -f /etc/nginx/conf.d/dev.conf
  mkdir -p /tmp/nginx/body \
    /run/nginx \
    /data/nginx \
    /data/custom_ssl \
    /data/logs \
    /data/access \
    /data/nginx/default_host \
    /data/nginx/default_www \
    /data/nginx/proxy_host \
    /data/nginx/redirection_host \
    /data/nginx/stream \
    /data/nginx/dead_host \
    /data/nginx/temp \
    /var/lib/nginx/cache/public \
    /var/lib/nginx/cache/private \
    /var/cache/nginx/proxy_temp
  chmod -R 777 /var/cache/nginx
  chown root /tmp/nginx
  echo resolver "$(awk 'BEGIN{ORS=" "} $1=="nameserver" {print ($2 ~ ":")? "["$2"]": $2}' /etc/resolv.conf);" >/etc/nginx/conf.d/include/resolvers.conf
  if [ ! -f /data/nginx/dummycert.pem ] || [ ! -f /data/nginx/dummykey.pem ]; then
    $STD openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/O=Nginx Proxy Manager/OU=Dummy Certificate/CN=localhost" -keyout /data/nginx/dummykey.pem -out /data/nginx/dummycert.pem
  fi
  mkdir -p /app/global /app/frontend/images
  cp -r backend/* /app
  cp -r global/* /app/global
  $STD python3 -m pip install --no-cache-dir certbot-dns-cloudflare
  msg_ok "Setup Enviroment"

  msg_info "Building Frontend"
  cd ./frontend
  $STD pnpm install
  $STD pnpm upgrade
  $STD pnpm run build
  cp -r dist/* /app/frontend
  cp -r app-images/* /app/frontend/images
  msg_ok "Built Frontend"

  msg_info "Initializing Backend"
  $STD rm -rf /app/config/default.json
  if [ ! -f /app/config/production.json ]; then
    cat <<'EOF' >/app/config/production.json
{
  "database": {
    "engine": "knex-native",
    "knex": {
      "client": "sqlite3",
      "connection": {
        "filename": "/data/database.sqlite"
      }
    }
  }
}
EOF
  fi
  cd /app
  $STD pnpm install
  msg_ok "Initialized Backend"

  msg_info "Starting Services"
  sed -i 's/user npm/user root/g; s/^pid/#pid/g' /usr/local/openresty/nginx/conf/nginx.conf
  sed -i 's/su npm npm/su root root/g' /etc/logrotate.d/nginx-proxy-manager
  sed -i 's/include-system-site-packages = false/include-system-site-packages = true/g' /opt/certbot/pyvenv.cfg
  systemctl enable -q --now openresty
  systemctl enable -q --now npm
  msg_ok "Started Services"

  msg_info "Cleaning up"
  rm -rf ~/nginx-proxy-manager-*
  msg_ok "Cleaned"

  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:81${CL}"
