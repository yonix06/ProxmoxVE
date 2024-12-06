
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

## Structure of Installation Scripts (ct/AppName.sh)

All installation scripts should follow this standard structure:

### 1. File Header
```bash
#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: [YourUserName]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: [SOURCE_URL]
```

- You only need to add here your username & the source_url (website of the AppName-Project or github) 
- if this an existing Script set after the current Author an "| Co-Author [YourUserName]" 

### 2. App Default Values
```bash
# App Default Values
APP="[APP_NAME]"
TAGS="[TAGS]"
var_cpu="[CPU]"
var_ram="[RAM]"
var_disk="[DISKSIZE]"
var_os="[OS]"
var_version="[VERSION]"
var_unprivileged="[UNPRIVILEGED]"
```

=> You need here to increase all values.
An Special Value is missing in default, because its not needed in every script and need to remove before create an PR:
=> var_verbose="yes|no" - that enable the verbose mode, and you can see all outputs of the Script.

Declaration of values:
- APP => Is the name of the application, must match the ct\AppName.sh
- TAGS => These are tags that are displayed in Proxmox (colored dots). Do not use too many!
- var_cpu => Number of used CPU-Cores
- var_ram => Number of used RAM in MB
- var_disk => Number of hard disk capacities used in GB
- var_os => Operating system (alpine | debian | ubuntu)
- var_version => Version of OS (3.20 | 11;12 | 20.04, 22.04, 24.04, 24.10)
- var_unprivileged => 1 = UNPRIVILEGED LXC Container | 0 = PRIVILEGED LXC Container

=> Following Values are default by build.func:
- TAGS="community-script" (is default, not need to add this, only new TAGS)
- var_cpu="1"
- var_ram="1024"
- var_disk="4"
- var_unprivileged="1"
- var_verbose="no"

Example:
```bash
# App Default Values
APP="Google"
TAGS="searching;website"
var_cpu="2"
var_ram="4096"
var_disk="10"
var_os="debian"
var_version="12"
var_unprivileged="0"
```
=> That Create an privileged LXC with name "google" (ct\google.sh) with 2 CPU Cores, 4096 MB RAM, 10 GB HDD Space, in Debian 12.

### 3. App Output & Base Settings
```bash
# App Output & Base Settings
header_info "$APP"
base_settings
```

- header_info is an function created in build.func and set the "APP" Value into an ASCII-Header.
- base_settings are used to overwrite the variable values of 2. or to accept all other default values.

### 4. Core
```bash
# Core
variables
color
catch_errors
```

- variables is an build.func function that This function processes the input and prepares variables for further use in the script.
- color is an build.func function that sets all icons, colors and formattings in the scripts.
- catch_errors is an build.func function that enables error handling in the script by setting options and defining a trap for the ERR signal.

### 5. Update-Script Part
```bash
function update_script() {
    header_info
    check_container_storage
    check_container_resources

    # Update-Code
}
```

- header_info called the ASCII-Generated AppName with every call of the function
- check_container_storage check the available storage and give output if it to less
- check_container_resources check the ressources (var_cpu / var_ram) if it to less and give user Output

Then comes the whole update function of the Script himself.

### 6. Script-End
```bash
start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:[PORT]${CL}"
```

- "start" is an build.func function to start the Whiptail Dialogue for Update or Create LXC
- "build_container" is an build.func function, this function collects user settings and integrates all the collected information.
- "description" is an build.func function, sets the description of the LXC container
 

## Structure of Installation Scripts (install/AppName-install.sh)

All installation scripts should follow this standard structure:

### 1. File Header
Every script should source the functions file and run these initial checks:

```bash
#!/usr/bin/env bash

# Copyright (c) 2021-2024 community-scripts ORG
# Author: [YourUserName]
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
```
- You only need to add here your username 
- if this an existing Script set after the current Author an "| Co-Author [YourUserName]" 

### 2. Import Functions und Setup
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
cat <<EOF >/etc/systemd/system/${APPLICATION}.service
[Unit]
Description=${APPLICATION} Service Description
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
