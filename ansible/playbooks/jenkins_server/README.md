# Jenkins Server

## Server Information
- **Root User**: ubuntu
- **Hostname**: jenkins-server.i.psilva.org
- **Operating System**: Ubuntu 24.04.2 LTS (Noble Numbat)

## Hardware Configuration
- **CPU**: 
  - Processor: AMD EPYC 7282 16-Core Processor
  - CPU(s): 4 vCPUs
- **Memory**: 
  - Total RAM: 3.8GB
  - Type: Virtual RAM (QEMU)
  - Error Correction: Multi-bit ECC
  - Available: 3.4GB
  - Swap: None
- **Storage**: 
  - Root Volume (/): 15GB (2.4GB used)
  - Boot Volume (/boot): 881MB
  - EFI Volume (/boot/efi): 105MB
- **Network**: 
  - Interface: Virtio network device (eth0)
  - Type: Virtual Ethernet Controller
  - MAC Address: BC:24:11:86:9A:36
  - MTU: 1500

## SSH Access
Access to the server is managed through SSH with authorized keys:

1. SSH Connection Details:
   ```bash
   ssh ubuntu@jenkins-server.i.psilva.org
   ```

2. Authentication:
   - Access is restricted to authorized SSH keys only
   - Password authentication is disabled for security
   - SSH keys must be added to the authorized_keys file on the server

3. Security Notes:
   - Only authorized personnel with registered SSH keys can access the server
   - All SSH connections are logged for security monitoring
   - Default SSH port (22) is used for connections

## Jenkins Operation

### Installation
Jenkins is deployed using Ansible with the following options:
- **Rootless Podman with Quadlet**: Modern, secure deployment without root privileges
- **Base Server Configuration**: Standard security hardening and system configuration

For installation and configuration:
```bash
cd ~/git_projects/homelab-ai/jenkins-server
ansible-playbook -i ../ansible/inventory/hosts.yml jenkins_server_playbook.yml
```

### Accessing Jenkins
- Jenkins is available at: http://jenkins-server.i.psilva.org:8080
- Initial admin password can be retrieved using:
  ```bash
  cat ~/jenkins/data/secrets/initialAdminPassword
  ```
  or
  ```bash
  podman logs systemd-jenkins | grep -A 1 "initialAdminPassword"
  ```

### Container Management
Jenkins runs as a rootless Podman container managed by the user's systemd instance via Quadlet files:

- **View container status**:
  ```bash
  systemctl --user status jenkins.service
  podman ps
  ```

- **Restart Jenkins**:
  ```bash
  systemctl --user restart jenkins.service
  ```

- **Stop Jenkins**:
  ```bash
  systemctl --user stop jenkins.service
  ```

- **View logs**:
  ```bash
  journalctl --user -u jenkins.service
  ```

### Jenkins Configuration
- **Configuration directory**: `/home/ubuntu/jenkins/data`
- **Plugins**: Manage via Jenkins web UI at `Manage Jenkins > Plugins`
- **Backup**: To backup Jenkins, archive the data directory:
  ```bash
  tar -czvf jenkins-backup.tar.gz ~/jenkins/data
  ```

### Rootless Container Security Benefits
- No root privileges required for container operations
- Reduced attack surface and potential for privilege escalation
- Better resource isolation through user namespace mapping
- Compatible with system security controls

## Important Security Guidelines
- Keep your private SSH key secure and never share it
- Report any unauthorized access attempts
- Regularly rotate SSH keys following security best practices
- Change the default Jenkins admin password immediately after setup
- Restrict access to Jenkins with proper authorization strategies
- Regularly update Jenkins and its plugins
- Review container logs regularly for suspicious activity
- Maintain regular backups of Jenkins configuration data



