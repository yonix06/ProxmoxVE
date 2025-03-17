#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://sabnzbd.org/

APP="SABnzbd"
var_tags="downloader"
var_cpu="2"
var_ram="4096"
var_disk="8"
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
   if [[ ! -d /opt/sabnzbd ]]; then
      msg_error "No ${APP} Installation Found!"
      exit
   fi
   RELEASE=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
   if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
      msg_info "Updating $APP to ${RELEASE}"
      systemctl stop sabnzbd.service
      tar zxvf <(curl -fsSL https://github.com/sabnzbd/sabnzbd/releases/download/$RELEASE/SABnzbd-${RELEASE}-src.tar.gz)
      cp -rf SABnzbd-${RELEASE}/* /opt/sabnzbd
      rm -rf SABnzbd-${RELEASE}
      cd /opt/sabnzbd
      $STD python3 -m pip install -r requirements.txt
      echo "${RELEASE}" >/opt/${APP}_version.txt
      systemctl start sabnzbd.service
      msg_ok "Updated ${APP} to ${RELEASE}"
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7777${CL}"
