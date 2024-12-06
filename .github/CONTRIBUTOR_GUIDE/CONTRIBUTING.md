<div align="center">
  <a href="#">
    <img src="https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/images/logo.png" height="100px" />
 </a>
</div>
<h2 align="center">Contributing to Proxmox VE Helper Scripts</h2>

Everybody is invited and welcome to contribute to Proxmox VE Helper Scripts. 

- Pull requests submitted against [**main**](https://github.com/community-scripts/ProxmoxVE/tree/main) are meticulously scrutinized, so please do not take it personally if the project maintainer rejects your request. By adhering to the established patterns and conventions throughout the codebase, you greatly increase the likelihood that your changes will get merged into [**main**](https://github.com/community-scripts/ProxmoxVE/tree/main).

- It is important to stress that complaining about a decision after it has been made is not productive behavior for the pull request submitter. It is crucial for all contributors to respect the decision-making process and collaborate effectively towards achieving the best possible outcome for the project.

- The repository will only accept Alpine applications that make use of the Alpine Package Keeper.

## Table of Contents
- [Getting Started](#getting-started)
- [Script Flow Overview](#script-flow-overview)
- [Important Files and Functions](#important-files-and-functions)
  - [`AppName.sh`](#appnamesh)
  - [`AppName-install.sh`](#appname-installsh)
  - [`build.func`](#buildfunc)
  - [`install.func`](#installfunc)
  - [`create_lxc`](#create_lxc)
- [How to Contribute](#how-to-contribute)
  - [Forking the Repository](#forking-the-repository)
  - [Creating a Branch](#creating-a-branch)
  - [Writing Clear Commit Messages](#writing-clear-commit-messages)
  - [Submitting a Pull Request](#submitting-a-pull-request)
- [Good Practices for Issues and Pull Requests](#good-practices-for-issues-and-pull-requests)
- [Issue and Pull Request Templates](#issue-and-pull-request-templates)
- [Additional Resources](#additional-resources)

## Getting Started

Before contributing to this project, ensure you have the following prerequisites:
1. **A Proxmox VE server or testing environment** for verifying your changes.
2. **Familiarity with LXC containers**, Proxmox, and **Bash scripting**.
3. **A GitHub account** and appropriate access to the repository.

## Script Flow Overview

The Proxmox VE Helper Scripts follow a defined sequence when setting up an LXC container or performing other tasks. Here's an overview of the flow:

## Script Flow Overview

The Proxmox VE Helper Scripts follow a defined sequence when setting up an LXC container or performing other tasks. Here's an overview of the flow:

1. **Main Command Execution**  
   The process begins when you execute the following command:
   ```bash
   bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/AppName.sh)"
   ```
   
2. **Calling `build.func`**  
   The **`AppName.sh`** script invokes **`build.func`**, which prepares the environment for installation and configuration.

3. **Executing `install.func`**  
   After the environment is set up, **`build.func`** calls **`install.func`**, which handles the installation of necessary software and configuration.

4. **Creating the LXC Container (`create_lxc`)**  
   Finally, **`install.func`** triggers **`create_lxc`** to create an LXC container with default values (disk size, CPU, RAM, etc.).

5. **Container Creation Completion**  
   The LXC container is created, and the process concludes by reporting the success or failure of the container setup.

## Important Files and Functions

### `AppName.sh`

This is the main entry script for initiating the process. It is responsible for:
- Starting the installation by calling **`build.func`**.
- Calling **`install.func`** after system setup.
- Managing the flow to ensure the container is correctly created.

### `AppName-install.sh`

This script typically manages specific installation tasks, such as setting up software inside the container. It is invoked within **`install.func`**.

### `build.func`

The **`build.func`** function:
- Prepares the system environment.
- Installs necessary packages or tools.
- Verifies storage availability and prepares LXC templates.

### `install.func`

The **`install.func`** function:
- Handles the installation and configuration of software packages inside the container.
- Sets up user permissions, network interfaces, and other container settings.

### `create_lxc`

The **`create_lxc`** function:
- Creates the LXC container using Proxmox commands.
- Applies default configurations like disk size, CPU, RAM, and network settings.
- Reports on the success or failure of the creation process.

## How to Contribute

We welcome contributions to the project! Please follow the steps below to ensure a smooth contribution process.

### Forking the Repository

Start by forking the repository to your own GitHub account:
1. Navigate to the [repository page](https://github.com/community-scripts/ProxmoxVE).
2. Click the **Fork** button in the upper-right corner.

### Creating a Branch

Always create a new branch for your changes to avoid conflicts:

git checkout -b feature/your-feature

### Writing Clear Commit Messages

Ensure your commit messages are clear and descriptive:
- **Good example:** `Added support for custom disk sizes in create_lxc`
- **Bad example:** `Fixed stuff`

### Submitting a Pull Request

After pushing your changes to your fork, create a pull request (PR):
1. Go to the **Pull Requests** tab on GitHub.
2. Click **New Pull Request** and select the branch with your changes.
3. Provide a detailed description of your changes, why you made them, and what problem they solve.

## Good Practices for Issues and Pull Requests

To help ensure your pull request is accepted and that issues are useful, please follow these best practices:

### For Pull Requests:
- Ensure your code is **well-documented**.
- **Test** your changes on a Proxmox environment before submitting.
- Follow the **project’s coding style** and conventions.
- Link to any relevant **issues** if applicable.

### For Issues:
- Always provide a **clear description** of the problem.
- If reporting a bug, include steps to **reproduce** it.
- If suggesting a new feature, explain its **use case**.

## Issue and Pull Request Templates

We’ve set up templates to make reporting issues and submitting pull requests easier. These templates will guide you in providing the required information for issues and PRs.

### Issue Template

The issue template will ask for the following:
- Steps to reproduce the issue.
- Expected behavior.
- Actual behavior.
- Any error logs or relevant system information.

### Pull Request Template

The pull request template will ask for:
- A summary of the changes made.
- Any relevant issues the PR addresses.
- A description of how to test the changes.

These templates are automatically populated when you create a new issue or PR.

## Additional Resources

- [Proxmox Documentation](https://pve.proxmox.com/pve-docs/)
- [GitHub Documentation on Pull Requests](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request)
- [Open Source Guides: Starting an Open Source Project](https://opensource.guide/)


--

## Creating New Scripts

When creating new scripts for the ProxmoxVE Helper Scripts repository, we recommend using **Visual Studio Code** (VS Code) for a smooth development experience. Follow these steps and guidelines to ensure your contributions meet the project’s standards.

### Template Usage

Start by using the following scripts as templates for your new script:
- **`AppName.sh`**  
  This is the main script that handles the high-level flow and calls the necessary functions. It serves as the entry point for the process.

- **`AppName-install.sh`**  
  This script is typically used for the installation process within the container, handling the actual setup of software and services.

These templates help ensure consistency across all scripts and make it easier for contributors to follow the project's structure.

### Visual Studio Code Setup

To ensure high code quality and to avoid common mistakes, it's recommended to use the following Visual Studio Code extensions:

1. **Shell Syntax**  
   [Shell Syntax Extension](https://marketplace.visualstudio.com/items?itemName=bmalehorn.shell-syntax)  
   This extension adds syntax highlighting and IntelliSense for shell scripts, making it easier to write and read your Bash scripts.

2. **ShellCheck**  
   [ShellCheck Extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)  
   ShellCheck is a static analysis tool for shell scripts. It helps identify common errors, potential issues, and improvements in your scripts. It runs automatically as you write your script and provides useful suggestions.

3. **Shell Format**  
   [Shell Format Extension](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)  
   This extension automatically formats your shell scripts according to best practices, ensuring clean, readable code.

### Script Modification

When creating a new script, you’ll need to adjust the call in the **`AppName.sh`** script. Specifically, the URL used in the following command must point to your **fork** of the repository, not the main `community-scripts/ProxmoxVE` URL:

```bash
bash -c "$(wget -qLO - https://github.com/YOUR_FORK_URL/raw/main/ct/AppName.sh)"
