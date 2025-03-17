#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: TheRealVira
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://pf2etools.com/

APP="Pf2eTools"
var_tags="wiki"
var_cpu="1"
var_ram="512"
var_disk="6"
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

  if [[ ! -d "/opt/${APP}" ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -s https://api.github.com/repos/Pf2eToolsOrg/Pf2eTools/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f "/opt/${APP}_version.txt" ]]; then
    msg_info "Updating System"
    $STD apt-get update
    $STD apt-get -y upgrade
    msg_ok "Updated System"

    msg_info "Updating ${APP}"
    cd /opt
    wget -q "https://github.com/Pf2eToolsOrg/Pf2eTools/archive/refs/tags/${RELEASE}.zip"
    unzip -q ${RELEASE}.zip
    rm -rf "/opt/${APP}"
    mv ${APP}-${RELEASE:1} /opt/${APP}
    cd /opt/Pf2eTools
    $STD npm install
    $STD npm run build
    chown -R www-data: "/opt/${APP}"
    chmod -R 755 "/opt/${APP}"
    echo "${RELEASE}" >"/opt/${APP}_version.txt"
    msg_ok "Updated ${APP}"

    msg_info "Cleaning Up"
    rm -rf /opt/${RELEASE}.zip
    msg_ok "Cleanup Completed"
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
