# Kubernetes Cluster Deployment

This directory contains Ansible playbooks and roles for deploying a Kubernetes cluster.

## Structure

- `roles/`: Contains the roles for configuring Kubernetes master and node components
  - `kubernetes_master/`: Role for configuring Kubernetes control plane components
  - `kubernetes_node/`: Role for configuring Kubernetes worker nodes
- `inventory/`: Contains the inventory files defining the hosts
- `kubernetes_master_playbook.yml`: Playbook for deploying Kubernetes master nodes
- `kubernetes_node_playbook.yml`: Playbook for deploying Kubernetes worker nodes (to be created)

## Prerequisites

- Target servers with Ubuntu/Debian-based OS
- SSH access to the target servers
- Python 3 installed on the control node
- Ansible installed on the control node

## Configuration

Before running the playbooks, update the inventory files in the `inventory/` directory with the appropriate host information and variables.

### Master Node Configuration

Edit the inventory file to set:
- `apiserver_advertise_address`: The IP address to advertise for the Kubernetes API server
- `pod_network_cidr`: The CIDR range for pod networking (default: 192.168.0.0/16 for Calico)
- `kubernetes_version`: The Kubernetes version to install (default: 1.28.1)

## Deployment

### Deploy Kubernetes Master

```bash
ansible-playbook -i inventory/hosts.yml kubernetes_master_playbook.yml
```

### Deploy Kubernetes Worker Nodes (coming soon)

```bash
ansible-playbook -i inventory/hosts.yml kubernetes_node_playbook.yml
```

## Post-Installation

After deploying the master node, a join command will be generated and stored in the home directory of the user on the master node. This command can be used to join worker nodes to the cluster.

You can access the Kubernetes cluster using `kubectl` on the master node or by copying the Kubernetes configuration to your local machine.

## Components

- **Container Runtime**: containerd
- **Network Plugin**: Calico
- **DNS**: CoreDNS (included with Kubernetes)

## Troubleshooting

If you encounter issues during deployment:

1. Check connectivity to the target servers
2. Verify that the prerequisites are met
3. Review the Ansible logs for detailed error information
4. Ensure that the target servers meet the system requirements for Kubernetes 