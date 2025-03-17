#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://mafl.hywax.space/

APP="Mafl"
var_tags="dashboard"
var_cpu="2"
var_ram="2048"
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
  if [[ ! -d /opt/mafl ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/hywax/mafl/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  msg_info "Updating Mafl to v${RELEASE} (Patience)"
  systemctl stop mafl
  wget -q https://github.com/hywax/mafl/archive/refs/tags/v${RELEASE}.tar.gz
  tar -xzf v${RELEASE}.tar.gz
  cp -r mafl-${RELEASE}/* /opt/mafl/
  rm -rf mafl-${RELEASE}
  cd /opt/mafl
  yarn install
  yarn build
  systemctl start mafl
  msg_ok "Updated Mafl to v${RELEASE}"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"