# Kubernetes Cluster Deployment

This directory contains Ansible playbooks and roles for deploying a Kubernetes cluster.

## Structure

- `roles/`: Contains the roles for configuring Kubernetes master and node components
  - `kubernetes_master/`: Role for configuring Kubernetes control plane components
  - `kubernetes_node/`: Role for configuring Kubernetes worker nodes
- `inventory/`: Contains the inventory files defining the hosts
- `kubernetes_master_playbook.yml`: Playbook for deploying Kubernetes master nodes
- `kubernetes_node_playbook.yml`: Playbook for deploying Kubernetes worker nodes
- `deploy-kubernetes.yml`: Main playbook for deploying the entire cluster
- `deploy-worker.yml`: Playbook for deploying only worker nodes
- `nginx-test.yml`: Sample deployment for testing cluster functionality

## Prerequisites

- Target servers with Ubuntu/Debian-based OS
- SSH access to the target servers
- Python 3 installed on the control node
- Ansible installed on the control node

## Configuration

Before running the playbooks, update the inventory files in the `hosts.ini` file with the appropriate host information and variables.

### Master Node Configuration

Edit the inventory file to set:
- `apiserver_advertise_address`: The IP address to advertise for the Kubernetes API server
- `pod_network_cidr`: The CIDR range for pod networking (default: 192.168.0.0/16 for Calico)
- `kubernetes_version`: The Kubernetes version to install (default: 1.28.15)

## Deployment

### Deploy Kubernetes Master

```bash
ansible-playbook -i hosts.ini deploy-kubernetes.yml --limit kubernetes_master_nodes
```

### Deploy Kubernetes Worker Nodes

There are two methods to deploy worker nodes:

#### Method 1: Using Ansible Playbook
```bash
ansible-playbook -i hosts.ini deploy-worker.yml
```

#### Method 2: Direct Join Command
For faster deployment, you can apply the join command directly:

1. Get the join command from the master node:
```bash
ssh user@master_node "cat kubernetes_join_command.txt"
```

2. Run the join command on each worker node:
```bash
ssh user@worker_node "sudo <join_command>"
```

3. Manually label the node as a worker (if using direct join method):
```bash
kubectl label node <node-name> node-role.kubernetes.io/worker=worker
```

> **Note**: When using the Ansible playbook method, worker nodes are automatically labeled with the `worker` role for better visualization in `kubectl get nodes` output.

## Operating the Kubernetes Cluster

### Master Node Operations

#### Check Cluster Status
```bash
kubectl get nodes
kubectl get pods -A
```

#### Deploy Applications
```bash
kubectl apply -f your-application.yml
```

#### Scale Deployments
```bash
kubectl scale deployment deployment-name --replicas=3
```

#### View Logs
```bash
kubectl logs pod-name
```

#### Execute Commands in Pods
```bash
kubectl exec -it pod-name -- /bin/bash
```

#### Access Kubernetes Dashboard (Optional)
1. Deploy the dashboard:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

2. Create a service account and get token:
```bash
kubectl create serviceaccount admin-user -n kubernetes-dashboard
kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
kubectl -n kubernetes-dashboard create token admin-user
```

3. Start the proxy:
```bash
kubectl proxy
```

4. Access dashboard at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

### Worker Node Operations

#### Check Node Status
```bash
sudo systemctl status kubelet
```

#### Troubleshoot Node Issues
```bash
sudo journalctl -u kubelet
```

#### Drain Node for Maintenance
From the master node:
```bash
kubectl drain node-name --ignore-daemonsets
```

#### Uncordon Node After Maintenance
From the master node:
```bash
kubectl uncordon node-name
```

### Network Testing

Test pod-to-pod communication:
```bash
kubectl exec -it pod-name -- ping other-pod-ip
```

### Upgrading the Cluster

1. Upgrade the control plane:
```bash
sudo apt update
sudo apt-mark unhold kubeadm && sudo apt install -y kubeadm=VERSION
sudo apt-mark hold kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply vX.Y.Z
```

2. Upgrade kubelet and kubectl on the control plane:
```bash
sudo apt-mark unhold kubelet kubectl && sudo apt install -y kubelet=VERSION kubectl=VERSION
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

3. Upgrade worker nodes (after control plane is upgraded):
```bash
# On worker nodes:
sudo apt update
sudo apt-mark unhold kubeadm && sudo apt install -y kubeadm=VERSION
sudo apt-mark hold kubeadm
sudo kubeadm upgrade node
sudo apt-mark unhold kubelet kubectl && sudo apt install -y kubelet=VERSION kubectl=VERSION
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

## Post-Installation

After deploying the master node, a join command will be generated and stored in the `kubernetes_join_command.txt` file in the home directory of the user on the master node. This command can be used to join worker nodes to the cluster.

### Setting Up Local kubectl Access

To access and manage your Kubernetes cluster from your local machine, follow these steps:

#### 1. Install kubectl Locally

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl
```

**macOS (using Homebrew):**
```bash
brew install kubectl
```

**Windows (using Chocolatey):**
```powershell
choco install kubernetes-cli
```

#### 2. Copy the Kubernetes Configuration

**Linux/macOS:**
```bash
mkdir -p ~/.kube
scp user@master_node:~/.kube/config ~/.kube/config
```

**Windows:**
```powershell
mkdir ~\.kube
scp user@master_node:~/.kube/config ~\.kube\config
```

#### 3. Update the Config File (if needed)

If you're accessing the cluster from outside the local network and using different hostnames/IPs:

```bash
# Edit the config file
nano ~/.kube/config

# Update server URL in the config if needed, e.g.,
# Change from: server: https://internal-ip:6443
# To: server: https://external-ip-or-domain:6443
```

#### 4. Verify Configuration

Test your connection to the cluster:

```bash
kubectl cluster-info
kubectl get nodes
```

If you want to have multiple cluster configurations, you can:

```bash
# Save the config with a specific name
cp ~/.kube/config ~/.kube/my-homelab-config

# Use a specific config file
kubectl --kubeconfig=~/.kube/my-homelab-config get nodes

# Or set it temporarily in your session
export KUBECONFIG=~/.kube/my-homelab-config
kubectl get nodes
```

## Components

- **Container Runtime**: containerd
- **Network Plugin**: Calico
- **DNS**: CoreDNS (included with Kubernetes)

## Calico Network Configuration

Calico is a networking and security solution that enables Kubernetes networking through a pure IP networking fabric and provides a rich set of security features.

### Features

- **Pod Networking**: Calico assigns IP addresses to pods and handles the routing between nodes
- **Network Policy**: Calico provides fine-grained network policy enforcement based on the Kubernetes Network Policy API
- **IPAM**: Calico's IP Address Management system efficiently allocates and manages IP addresses across the cluster
- **BGP Networking**: For advanced setups, Calico can use BGP for routing without an overlay (when using native routing)

### Customizing Calico

To customize the Calico installation:

1. Download the Calico manifest from the deployment node
```bash
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
```

2. Edit the manifest to customize configurations such as:
   - Pod CIDR range
   - MTU settings
   - IP Auto Detection method
   - Feature enablement

3. Apply the modified manifest
```bash
kubectl apply -f calico.yaml
```

### Verifying Calico Installation

To verify Calico is working correctly:

```bash
# Check Calico pods status
kubectl get pods -n calico-system

# Verify BGP status (if using BGP)
kubectl exec -n calico-system calico-node-xxxxx -- calico-node -bird-ready
kubectl exec -n calico-system calico-node-xxxxx -- calico-node -felix-ready
```

## Testing Calico Network Connectivity

After deploying your Kubernetes cluster with Calico CNI, you can verify that the network is functioning correctly with these steps:

### 1. Check Pod Status
```bash
kubectl get pods -n kube-system
```

All Calico pods (calico-node and calico-kube-controllers) should be in the `Running` state.

### 2. Test Pod-to-Pod Communication
Deploy a test application:
```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=4
```

Check pod distribution and IP addresses:
```bash
kubectl get pods -o wide
```

Test connectivity between pods:
```bash
# Get a pod name
export POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')

# Install curl in the pod
kubectl exec -it $POD_NAME -- /bin/bash -c 'apt-get update && apt-get install -y curl'

# Test connectivity to another pod (replace with actual pod IP)
kubectl exec -it $POD_NAME -- curl -s <OTHER_POD_IP>
```

### 3. Test Service Access
Create a test service:
```bash
kubectl expose deployment nginx --port=80 --type=NodePort
```

Get the assigned NodePort:
```bash
kubectl get svc nginx
```

Access the service from outside the cluster:
```bash
curl http://<NODE_IP>:<NODE_PORT>
```

If all tests pass, your Calico network implementation is working correctly.

## Backup and Restore

### Backup etcd
```bash
sudo ETCDCTL_API=3 etcdctl --endpoints=https://localhost:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save etcd-snapshot.db
```

### Restore etcd
```bash
sudo ETCDCTL_API=3 etcdctl --endpoints=https://localhost:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot restore etcd-snapshot.db
```

## Troubleshooting

If you encounter issues during deployment or operation:

1. Check connectivity to the target servers
2. Verify that the prerequisites are met
3. Review the Ansible logs for detailed error information
4. Ensure that the target servers meet the system requirements for Kubernetes
5. Common issues and solutions:
   - **Pods stuck in pending**: Check node resources, taints, or network issues
   - **Node NotReady**: Check kubelet service, container runtime, or network issues
   - **Network issues**: Verify CNI plugin is deployed and configured correctly
   - **API server unreachable**: Check API server pod status and logs

For persistent issues, examine specific component logs:
```bash
kubectl logs -n kube-system kube-apiserver-master
kubectl logs -n kube-system kube-controller-manager-master
kubectl logs -n kube-system kube-scheduler-master
kubectl logs -n kube-system etcd-master
``` 