# VirtFS Mount Role

This Ansible role mounts a VirtFS shared directory from the hypervisor to the VM.

## Requirements

- The VM must be configured with a VirtFS shared directory 
- The mount tag must be configured in the VM (default: "myshare")

## Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `virtfs_mount_tag` | The mount tag specified in the VM configuration | "myshare" |

## Example VM Configuration

```
-virtfs local,id=myshare,path=/GPool1/appdata/jenkins-server,security_model=passthrough,mount_tag=myshare
```

## Functionality

This role:
1. Creates a mount point at `/mnt/<hostname>` 
2. Mounts the VirtFS shared directory at this location
3. Configures the mount to persist across reboots by adding an entry to `/etc/fstab`

## Note

The mount path is dynamically generated based on the inventory hostname, taking the first part before any domain name (e.g., "j-jenkins-server" from "jenkins-server.i.psilva.org"). 