#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://wallosapp.com/

APP="Wallos"
var_tags="finance"
var_cpu="1"
var_ram="1024"
var_disk="5"
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
  if [[ ! -d /opt/wallos ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/ellite/Wallos/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Updating ${APP} to ${RELEASE}"
    cd /opt
    wget -q "https://github.com/ellite/Wallos/archive/refs/tags/v${RELEASE}.zip"
    mkdir -p /opt/logos
    mv /opt/wallos/db/wallos.db /opt/wallos.db
    mv /opt/wallos/images/uploads/logos /opt/logos/
    unzip -q v${RELEASE}.zip
    rm -rf /opt/wallos
    mv Wallos-${RELEASE} /opt/wallos
    rm -rf /opt/wallos/db/wallos.empty.db
    mv /opt/wallos.db /opt/wallos/db/wallos.db
    mv /opt/logos/* /opt/wallos/images/uploads/logos
    chown -R www-data:www-data /opt/wallos
    chmod -R 755 /opt/wallos
    mkdir -p /var/log/cron
    $STD curl http://localhost/endpoints/db/migrate.php
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Reload Apache2"
    systemctl reload apache2
    msg_ok "Apache2 Reloaded"

    msg_info "Cleaning Up"
    rm -R /opt/v${RELEASE}.zip
    msg_ok "Cleaned"
    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"