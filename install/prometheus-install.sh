#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://prometheus.io/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  sudo \
  mc
msg_ok "Installed Dependencies"

msg_info "Installing Prometheus"
RELEASE=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus
wget -q https://github.com/prometheus/prometheus/releases/download/v${RELEASE}/prometheus-${RELEASE}.linux-amd64.tar.gz
tar -xf prometheus-${RELEASE}.linux-amd64.tar.gz
mv prometheus-${RELEASE}.linux-amd64/prometheus prometheus-${RELEASE}.linux-amd64/promtool /usr/local/bin/
mv prometheus-${RELEASE}.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
msg_ok "Installed Prometheus"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
Restart=always
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.listen-address=0.0.0.0:9090
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now prometheus
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
rm -rf prometheus-${RELEASE}.linux-amd64 prometheus-${RELEASE}.linux-amd64.tar.gz
msg_ok "Cleaned"
