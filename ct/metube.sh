#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/alexta69/metube

APP="MeTube"
var_tags="media;youtube"
var_cpu="1"
var_ram="1024"
var_disk="10"
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
  if [[ ! -d /opt/metube ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Stopping ${APP} Service"
  systemctl stop metube
  msg_ok "Stopped ${APP} Service"

  msg_info "Updating ${APP} to latest Git"
  cd /opt
  if [ -d metube_bak ]; then
    rm -rf metube_bak
  fi
  mv metube metube_bak
  $STD git clone https://github.com/alexta69/metube /opt/metube
  cd /opt/metube/ui
  $STD npm install
  $STD node_modules/.bin/ng build
  cd /opt/metube
  cp /opt/metube_bak/.env /opt/metube/
  $STD pip3 install pipenv
  $STD pipenv install

  if [ -d "/opt/metube_bak" ]; then
    rm -rf /opt/metube_bak
  fi
  msg_ok "Updated ${APP} to latest Git"

  msg_info "Starting ${APP} Service"
  systemctl start metube
  sleep 1
  msg_ok "Started ${APP} Service"
  msg_ok "Updated Successfully!\n"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8081${CL}"