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
- **Pure Quadlet**: Default and recommended deployment method
- **Docker Compose with Quadlet**: For complex multi-container setups
- **Podman Compose with systemd**: Compatible with Docker Compose workflows

For installation and configuration details, see the Ansible setup:
```bash
cd ~/git_projects/homelab-ai/ansible
```

### Accessing Jenkins
- Jenkins is available at: http://jenkins-server.i.psilva.org:8080
- Initial admin password: Check the ansible playbook output or run:
  ```bash
  sudo podman exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
  ```

### Container Management
Jenkins runs as a Podman container managed by systemd via quadlets:

- **View container status**:
  ```bash
  sudo systemctl status jenkins.service
  sudo podman ps
  ```

- **Restart Jenkins**:
  ```bash
  sudo systemctl restart jenkins.service
  ```

- **Stop Jenkins**:
  ```bash
  sudo systemctl stop jenkins.service
  ```

- **View logs**:
  ```bash
  sudo journalctl -u jenkins.service
  ```

### Jenkins Configuration
- **Configuration directory**: `/home/ubuntu/jenkins/data`
- **Plugins**: Manage via Jenkins web UI at `Manage Jenkins > Plugins`
- **Backup**: To backup Jenkins, archive the data directory:
  ```bash
  sudo tar -czvf jenkins-backup.tar.gz /home/ubuntu/jenkins/data
  ```


## Important Security Guidelines
- Keep your private SSH key secure and never share it
- Report any unauthorized access attempts
- Regularly rotate SSH keys following security best practices
- Change the default Jenkins admin password immediately after setup
- Restrict access to Jenkins with proper authorization strategies
- Regularly update Jenkins and its plugins



