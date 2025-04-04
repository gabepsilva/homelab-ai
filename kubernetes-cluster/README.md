# Kubernetes Cluster Setup

This repository contains Ansible roles and playbooks for setting up a Kubernetes cluster with master and worker nodes.

## Prerequisites

- Ubuntu servers for master and worker nodes
- Ansible installed on your local machine
- SSH access to all nodes

## Directory Structure

```
kubernetes-cluster/
├── README.md
├── deploy-master.yml - Playbook to deploy master nodes
├── deploy-worker.yml - Playbook to deploy worker nodes
├── hosts.ini - Inventory file with node definitions
├── roles/
    ├── kubernetes_master/ - Role for setting up master nodes
    ├── kubernetes_worker/ - Role for setting up worker nodes
```

## Installation Instructions

### 1. Configure Inventory

Edit the `hosts.ini` file to include your master and worker nodes:

```ini
[kubernetes_master_nodes]
master-node.example.com ansible_user=ubuntu

[kubernetes_worker_nodes]
worker-node1.example.com ansible_user=ubuntu
worker-node2.example.com ansible_user=ubuntu

[kubernetes:children]
kubernetes_master_nodes
kubernetes_worker_nodes
```

### 2. Deploy Master Node

Run the dedicated master deployment playbook:

```bash
ansible-playbook -i hosts.ini deploy-master.yml
```

The master deployment includes:
- Container runtime installation
- Kubernetes components (kubelet, kubeadm, kubectl)
- Cluster initialization
- Network plugin deployment (Calico by default)
- Configuration of cluster administration

### 3. Deploy Worker Nodes

Run the worker deployment playbook:

```bash
ansible-playbook -i hosts.ini deploy-worker.yml
```

## Manual Worker Node Addition

If you need to add a worker node manually:

1. SSH into the new worker node

2. On the master node, generate a join command:
   ```bash
   kubeadm token create --print-join-command
   ```

3. Run the generated command on the worker node:
   ```bash
   sudo kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash <hash>
   ```

## Labeling Worker Nodes

To label a node as a worker:

```bash
kubectl label node <node-name> node-role.kubernetes.io/worker=worker
```

To verify the node has been labeled correctly:

```bash
kubectl get nodes --show-labels
```

## Troubleshooting

- If nodes fail to join the cluster, check network connectivity and firewall settings
- Verify that all required ports are open between nodes
- Check the logs with `journalctl -xeu kubelet`

## Maintenance

- To drain a node for maintenance: `kubectl drain <node-name> --ignore-daemonsets`
- To remove a node: `kubectl delete node <node-name>`

## Advanced Node Management

### Draining Worker Nodes

To safely evict all pods from a worker node before maintenance:

```bash
# Drain a node (will cordon first, then evict pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# To make the node schedulable again after maintenance
kubectl uncordon <node-name>
```

### Tainting Nodes

Taints can be used to repel pods from specific nodes unless they have matching tolerations:

```bash
# Add a taint to a node
kubectl taint nodes <node-name> key=value:NoSchedule

# Remove a taint from a node
kubectl taint nodes <node-name> key:NoSchedule-

# Common taint effects: NoSchedule, PreferNoSchedule, NoExecute
```

### Restarting Kubernetes Services

#### On Master Nodes:

```bash
# Restart kubelet
sudo systemctl restart kubelet

# Restart all Kubernetes control plane components
sudo systemctl restart kubelet kube-apiserver kube-controller-manager kube-scheduler

# Check status
sudo systemctl status kubelet
```

#### On Worker Nodes:

```bash
# Restart kubelet service
sudo systemctl restart kubelet

# Check kubelet status
sudo systemctl status kubelet
```

#### Restarting the Container Runtime:

```bash
# For Docker
sudo systemctl restart docker

# For containerd
sudo systemctl restart containerd
```

Always verify cluster health after restarting components:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Running Tests

After deploying your cluster, you can verify its functionality using the included test playbooks:

### Testing the Kubernetes Cluster and Calico

Run the general cluster test playbook to verify basic Kubernetes functionality and Calico network policies:

```bash
ansible-playbook -i hosts.ini test-cluster.yml
```

This test validates:
- Kubernetes core components
- Calico network policies
- Inter-pod communication
- Worker node Calico connectivity

### Testing MetalLB Load Balancer

After installing MetalLB, run the MetalLB test playbook to verify LoadBalancer functionality:

```bash
ansible-playbook -i hosts.ini test-metallb.yml
```

This test validates:
- MetalLB deployment status
- LoadBalancer service IP assignment
- Network connectivity to load-balanced services
- Proper IP allocation from the configured pool
- Multiple service allocation
