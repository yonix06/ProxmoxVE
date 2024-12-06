
# Community Scripts Contribution Guide

## Overview
Welcome to the community-scripts repository! This guide provides detailed instructions on how to contribute to the project, including code structure, best practices, and setup instructions for contributing to our repository.

## Getting Started

Before contributing, please ensure that you have the following setup:

1. **Visual Studio Code** (recommended for script development)
2. **Necessary VS Code Extensions:**
   - [Shell Syntax](https://marketplace.visualstudio.com/items?itemName=bmalehorn.shell-syntax)
   - [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
   - [Shell Format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)

### Important Notes
- Use `AppName.sh` and `AppName-install.sh` as templates when creating new scripts.
- The call to `community-scripts/ProxmoxVE` should be adjusted to reflect the correct fork URL.

---

## Structure of Installation Scripts

All installation scripts should follow this standard structure:

### 1. File Header
```bash
#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
```

### 2. Initial Setup
Every script should source the functions file and run these initial checks:

```bash
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os
```

### 3. Standard Dependencies
Common base dependencies should be installed first:

```bash
msg_info "Installing Dependencies"
$STD apt-get install -y   curl   sudo   mc 
msg_ok "Installed Dependencies"
```

### 4. File Writing Conventions

#### Writing Config Files
Use heredoc (`cat <<EOF`) for writing configuration files:

```bash
cat <<EOF >/etc/systemd/system/service.service
[Unit]
Description=Service Description
After=network.target

[Service]
Type=simple
ExecStart=/path/to/executable
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

#### Writing Environment Files
Use heredoc for environment files, with proper quoting:

```bash
cat <<EOF >/path/to/.env
VARIABLE="value"
PORT=3000
DB_NAME="${DB_NAME}"
EOF
```

### 5. Service Management
Standard way to enable and start services:

```bash
systemctl enable -q --now service.service
``` 

### 6. Cleanup Section
Every script should end with cleanup:

```bash
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
```

### 7. Progress Messages
Use standard message functions for consistent output:

```bash
msg_info "Starting task"
$STD some_command
msg_ok "Task completed"
```

### 8. Version Tracking
When installing specific versions, store the version number:

```bash
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
```

### 9. Credentials Management
Store credentials in a consistent location:

```bash
{
    echo "Application-Credentials"
    echo "Username: $USERNAME"
    echo "Password: $PASSWORD"
} >> ~/application.creds
```

### 10. Directory Structure
Use consistent paths for applications:
- Application files: `/opt/application_name/`
- Configuration files: `/etc/application_name/`
- Data files: `/var/lib/application_name/`

### 11. Error Handling
Use the standard error handling function:

```bash
catch_errors
```

### 12. Final Setup
Every script should end with:

```bash
motd_ssh
customize
```

---

## Best Practices

1. Use `$STD` for commands that should have their output suppressed.
2. Use consistent variable naming (uppercase for global variables).
3. Always quote variables that might contain spaces.
4. Use `-q` flag for quiet operation where available.
5. Use consistent indentation (2 spaces).
6. Include cleanup sections to remove temporary files and packages.
7. Use descriptive message strings in msg_info/msg_ok functions.

---

## Building Your Own Scripts

The best way to build your own scripts is to start with [our template script](https://github.com/community-scripts/ProxmoxVE/blob/main/docs/templates/example-install.sh) and then modify it to your needs.

---

## Contribution Process

### 1. Fork the Repository
Fork the repository to your own GitHub account to start contributing.

### 2. Clone the Forked Repository
Clone your fork to your local machine using:

```bash
git clone https://github.com/YOUR_USERNAME/community-scripts.git
```

### 3. Create a New Branch
Before making changes, create a new branch for your feature or fix:

```bash
git checkout -b your-feature-branch
```

### 4. Commit Your Changes
Once you’ve made the necessary changes, commit them:

```bash
git commit -m "Your commit message"
```

### 5. Push to Your Fork
Push the changes to your forked repository:

```bash
git push origin your-feature-branch
```

### 6. Create a Pull Request
Open a pull request from your feature branch to the `main` branch of the original repository. Please ensure that your pull request follows the formatting and guidelines mentioned above.

---

## Wiki Pages

- [Contributing](https://github.com/community-scripts/ProxmoxVE/wiki/Contributing)
- [Installation Guide](https://github.com/community-scripts/ProxmoxVE/wiki/Installation-Guide)
- [Script Templates](https://github.com/community-scripts/ProxmoxVE/wiki/Script-Templates)
