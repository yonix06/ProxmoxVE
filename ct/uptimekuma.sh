#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://uptime.kuma.pet/

APP="Uptime Kuma"
var_tags="analytics;monitoring"
var_cpu="1"
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
  if [[ ! -d /opt/uptime-kuma ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
    if ! command -v npm >/dev/null 2>&1; then
      echo "Installing NPM..."
      $STD apt-get install -y npm
      echo "Installed NPM..."
    fi
  fi
  LATEST=$(curl -sL https://api.github.com/repos/louislam/uptime-kuma/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
  msg_info "Stopping ${APP}"
  $STD sudo systemctl stop uptime-kuma
  msg_ok "Stopped ${APP}"

  cd /opt/uptime-kuma

  msg_info "Pulling ${APP} ${LATEST}"
  $STD git fetch --all
  $STD git checkout $LATEST --force
  msg_ok "Pulled ${APP} ${LATEST}"

  msg_info "Updating ${APP} to ${LATEST}"
  $STD npm install --production
  $STD npm run download-dist
  msg_ok "Updated ${APP}"

  msg_info "Starting ${APP}"
  $STD sudo systemctl start uptime-kuma
  msg_ok "Started ${APP}"
  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3001${CL}"
