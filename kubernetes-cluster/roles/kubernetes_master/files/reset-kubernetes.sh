#!/bin/bash

# This script resets a Kubernetes cluster and prepares for a fresh initialization
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Stopping all Kubernetes services..."
# Stop services
systemctl stop kubelet || true
systemctl stop containerd || true

echo "Killing any remaining Kubernetes processes..."
# Kill any remaining processes
pkill -f kubelet || true
pkill -f kube-apiserver || true
pkill -f kube-controller-manager || true
pkill -f kube-scheduler || true
pkill -f kube-proxy || true
pkill -f etcd || true
pkill -f flannel || true
pkill -f calico || true

echo "Cleaning up network interfaces..."
# Remove network configurations
ip link delete flannel.1 2>/dev/null || true
ip link delete cni0 2>/dev/null || true
ip link delete calico 2>/dev/null || true
ip link delete weave 2>/dev/null || true

echo "Resetting iptables..."
# Reset iptables
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

echo "Running kubeadm reset..."
# Reset kubeadm
kubeadm reset -f || true

echo "Cleaning directories..."
# Clean directories
rm -rf /etc/kubernetes/
rm -rf /var/lib/kubelet/
rm -rf /var/lib/cni/
rm -rf /var/lib/calico/
rm -rf /var/lib/etcd/
rm -rf /var/run/kubernetes/
rm -rf /run/flannel/
rm -rf /etc/cni/
mkdir -p /etc/cni/net.d
rm -rf /root/.kube
rm -rf /home/*/kubernetes_join_command.txt

echo "Checking for remaining processes on critical ports..."
# Check for processes using the problematic ports
for port in 6443 2379 2380 10250 10251 10252 10257 10259; do
    pid=$(lsof -t -i:$port || true)
    if [ ! -z "$pid" ]; then
        echo "Killing process $pid using port $port"
        kill -9 $pid || true
    fi
done

echo "Restarting services..."
# Restart services
systemctl daemon-reload
systemctl restart containerd

echo "Kubernetes reset completed successfully" 