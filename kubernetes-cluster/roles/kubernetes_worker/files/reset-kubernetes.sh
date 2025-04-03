#!/bin/bash
# Script to reset Kubernetes node

# Stop and disable kubelet
systemctl stop kubelet
systemctl disable kubelet

# Reset kubeadm if it exists
if command -v kubeadm &> /dev/null; then
    kubeadm reset -f
fi

# Remove Kubernetes directories
rm -rf /etc/kubernetes/
rm -rf /var/lib/kubelet/
rm -rf /etc/cni/net.d/

# Clean up network configurations
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Restart containerd
systemctl restart containerd

echo "Kubernetes reset completed." 