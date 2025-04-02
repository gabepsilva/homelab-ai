# Base Server Role

This Ansible role provides a standard baseline configuration for all servers in your environment.

## Features

- **System Updates**: Ensures system packages are up-to-date
- **Essential Packages**: Installs common utilities and tools needed on every server
- **Security Hardening**:
  - SSH hardening (key-only authentication, no root login)
  - UFW firewall configured with secure defaults
  - Strong password policies
  - System timeouts for idle sessions
- **System Configuration**:
  - Timezone setup
  - NTP configuration for time synchronization

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `server_timezone` | UTC | The timezone to set on the server |
| `enable_ufw` | true | Whether to enable and configure UFW firewall |
| `ssh_port` | 22 | SSH port to use and configure in firewall |
| `additional_packages` | [] | Additional packages to install beyond the defaults |
| `perform_system_update` | true | Whether to update system packages |
| `reboot_after_kernel_update` | false | Whether to reboot after kernel updates |

## Usage

Add this role to your playbook:

```yaml
- hosts: servers
  roles:
    - role: base_server
```

## Requirements

- Ansible 2.9 or higher
- Target hosts running Ubuntu/Debian

## Author

- System Administrator

## License

MIT 