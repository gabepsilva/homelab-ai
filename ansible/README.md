# Ansible Configuration for Homelab

This directory contains Ansible playbooks and roles for managing servers in the homelab environment.

## Structure

- **roles/**
  - **base_server/** - Standard configuration applied to all servers
  - **jenkins_podman/** - Deploys Jenkins using rootless Podman with Quadlet
  - _(more roles will be added as needed)_
- **inventory/** 
  - **hosts.yml** - Contains server definitions and groups
- **ansible.cfg** - Ansible configuration
- **base_server_playbook.yml** - Playbook to apply the base server configuration

## Usage

### Prerequisites

1. Install Ansible on your control machine:
   ```bash
   sudo apt update
   sudo apt install ansible
   ```

2. Ensure SSH access to target servers with key-based authentication

### Running Playbooks

To apply the base server configuration to all servers:

```bash
cd ~/git_projects/homelab-ai/ansible
ansible-playbook base_server_playbook.yml
```

To deploy Jenkins server (located in jenkins-server directory):

```bash
cd ~/git_projects/homelab-ai/jenkins-server
ansible-playbook -i ../ansible/inventory/hosts.yml jenkins_server_playbook.yml
```

To apply to specific servers or groups:

```bash
ansible-playbook base_server_playbook.yml --limit jenkins-server
```

### Checking Syntax

```bash
ansible-playbook base_server_playbook.yml --syntax-check
```

### Dry Run (Check Mode)

```bash
ansible-playbook base_server_playbook.yml --check
```

## Server Groups

- **jenkins_servers** - Jenkins server instances
- _(more groups will be added as needed)_

## Roles

### base_server

Provides baseline configuration for all servers, including:
- System updates and essential packages
- SSH hardening
- Basic security configuration
- NTP and timezone settings

### jenkins_podman

Deploys Jenkins CI/CD server:
- Uses rootless Podman containers for security
- Implements Quadlet for systemd integration
- Configures persistent storage
- Sets proper permissions

## Security Notes

- Playbooks assume SSH key-based authentication is set up
- Passwords are not stored in plaintext in any files
- Sensitive data should be encrypted using Ansible Vault when needed
- Containers run as non-root users for enhanced security 