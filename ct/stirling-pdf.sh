#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://www.stirlingpdf.com/

APP="Stirling-PDF"
var_tags="pdf-editor"
var_cpu="2"
var_ram="2048"
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
  if [[ ! -d /opt/Stirling-PDF ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  systemctl stop stirlingpdf
  if [[ -n $(dpkg -l | grep -w ocrmypdf) ]] && [[ -z $(dpkg -l | grep -w qpdf) ]]; then
    $STD apt-get remove -y ocrmypdf
    $STD apt-get install -y qpdf
  fi
  RELEASE=$(curl -s https://api.github.com/repos/Stirling-Tools/Stirling-PDF/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  wget -q https://github.com/Stirling-Tools/Stirling-PDF/archive/refs/tags/v$RELEASE.tar.gz
  tar -xzf v$RELEASE.tar.gz
  cd Stirling-PDF-$RELEASE
  chmod +x ./gradlew
  $STD ./gradlew build
  cp -r ./build/libs/Stirling-PDF-*.jar /opt/Stirling-PDF/
  cp -r scripts /opt/Stirling-PDF/
  cd ~
  rm -rf Stirling-PDF-$RELEASE v$RELEASE.tar.gz
  ln -sf /opt/Stirling-PDF/Stirling-PDF-$RELEASE.jar /opt/Stirling-PDF/Stirling-PDF.jar
  systemctl start stirlingpdf
  msg_ok "Updated ${APP} to v$RELEASE"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"