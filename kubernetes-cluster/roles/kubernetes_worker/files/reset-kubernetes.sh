#!/bin/bash
# Script to reset Kubernetes node

# Reset Kubernetes cluster
kubeadm reset -f

# Stop and disable kubelet and containerd
systemctl stop kubelet
systemctl disable kubelet

# Remove Kubernetes directories
rm -rf /etc/kubernetes/
rm -rf /var/lib/kubelet/
rm -rf /var/lib/etcd/
rm -rf $HOME/.kube/

# Reset iptables rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Restart containerd
systemctl restart containerd

echo "Kubernetes reset complete"
exit 0 