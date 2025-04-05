# README: Configuring Sudo for Jenkins User in Proxmox

## Overview

This document outlines the steps taken to configure the `jenkins` user in Proxmox to run the `qm list` command without requiring a password. This setup is useful for automating tasks that involve querying the status of virtual machines.

## Steps to Create a User and Configure Sudo Access

### 1. Create a User in Proxmox

- Log in to your Proxmox server via SSH as a user with sudo privileges.
- Use the following command to create a new user (replace `jenkins` with your desired username):
  ```bash
  sudo useradd -m jenkins
  ```
- Set a password for the new user:
  ```bash
  sudo passwd jenkins
  ```

### 2. Add User to PAM for Authentication

- Ensure that the user is configured to use PAM for authentication. This is typically the default setting in Proxmox, but you can verify it in the Proxmox web interface under **Datacenter > Permissions > Users**.

### 3. Add User to the Sudo Group

- To grant the `jenkins` user sudo privileges, add it to the sudo group:
  ```bash
  sudo usermod -aG sudo jenkins
  ```

### 4. Open the Sudoers File

- Use the `visudo` command to safely edit the sudoers file:
  ```bash
  sudo visudo
  ```

### 5. Add the Sudoers Entry

- Add the following line to allow the `jenkins` user to run the `qm list` command without a password:
  ```bash
  jenkins ALL=(ALL) NOPASSWD: /usr/sbin/qm list
  ```
- Ensure that this line is placed before any general rules that require a password.

### 6. Verify the Path

- Confirm the path to the `qm` command by running:
  ```bash
  which qm
  ```
- Make sure the path in the sudoers entry matches the output of the `which` command.

### 7. Test the Configuration

- After saving the changes, test the configuration by running:
  ```bash
  sudo /usr/sbin/qm list
  ```
- The command should execute without prompting for a password.

### 8. Troubleshooting

- If the command still prompts for a password, double-check the following:
  - Ensure there are no syntax errors in the sudoers file.
  - Verify that the `jenkins` user is correctly specified.
  - Check for any conflicting entries in the sudoers file.

### 9. Set Up SSH Key-Based Authentication

- Retrieve the existing SSH public and private keys from 1Password.
- Copy the public key to the Proxmox server for the `jenkins` user:
  ```bash
  ssh-copy-id jenkins@<proxmox_server_ip>
  ```
- Ensure that the `jenkins` user can connect to the Proxmox server without a password:
  ```bash
  ssh jenkins@<proxmox_server_ip>
  ```
- If prompted for a password, ensure that the public key was copied correctly and that the SSH service is running on the Proxmox server.
- **Note:** The public and private keys, along with the passphrase for the private key, are stored in 1Password. Ensure you have access to 1Password to retrieve these credentials.

## Conclusion

By following these steps, the `jenkins` user can now execute the `qm list` command without needing to enter a password, facilitating automation and integration with CI/CD pipelines in Proxmox. Additionally, the user has been created and configured properly for authentication and sudo access.
