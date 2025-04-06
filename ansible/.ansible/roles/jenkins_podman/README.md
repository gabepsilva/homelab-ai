# Jenkins Podman Role

This role deploys a Jenkins server using Podman with Quadlet integration for systemd management.

## Features

- Uses Podman to run Jenkins in a rootless container (no root privileges required)
- Implements modern Quadlet configuration for systemd integration (replacing deprecated `podman generate systemd`)
- Persists Jenkins data in a volume on the virtfs shared directory
- Sets up proper system configuration and permissions

## Requirements

- Podman installed on the target system
- Systemd as the init system
- A non-root user to run the container (defined by systemd_user)
- The virtfs_mount role applied (automatically included as a dependency)

## Role Variables

Variables are defined in `defaults/main.yml`:

```yaml
# Jenkins configuration
jenkins_image: docker.io/jenkins/jenkins:jdk21
jenkins_container_name: jenkins
jenkins_http_port: 8080
jenkins_agent_port: 50000
jenkins_home_dir: "/mnt/{{ inventory_hostname.split('.')[0] }}/jenkins/data"
jenkins_volume_name: jenkins_home

# Podman configuration
podman_socket_enabled: false
systemd_user: ubuntu
```

## Example Playbook

```yaml
- name: Deploy Jenkins server
  hosts: jenkins_servers
  become: true
  roles:
    - role: base_server
      tags: 
        - base
        - system
    - role: jenkins_podman
      tags: jenkins
```

## Operation and Management

### Starting Jenkins
After installation, Jenkins starts automatically and is managed by systemd:

```bash
# Check service status
systemctl --user status jenkins.service

# Manually start the service
systemctl --user start jenkins.service
```

### Stopping Jenkins
```bash
systemctl --user stop jenkins.service
```

### Restarting Jenkins
```bash
systemctl --user restart jenkins.service
```

### Viewing Logs
```bash
# View Jenkins service logs
journalctl --user -u jenkins.service

# View container logs directly
podman logs systemd-jenkins
```

### Accessing Jenkins

1. Access Jenkins at `http://your-server-ip:8080`
2. Get the initial admin password:
   ```bash
   cat ~/jenkins/data/secrets/initialAdminPassword
   ```
   or
   ```bash
   podman logs systemd-jenkins | grep -A 1 "initialAdminPassword"
   ```
3. Follow the initial setup wizard

## Troubleshooting

If Jenkins fails to start:

1. Check port availability:
   ```bash
   lsof -i :8080
   ```

2. Check service logs:
   ```bash
   journalctl --user -xeu jenkins.service
   ```

3. Verify permissions on the data directory:
   ```bash
   ls -la ~/jenkins/data
   ```

## License

MIT 