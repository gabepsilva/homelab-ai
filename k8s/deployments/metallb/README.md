# Kubernetes Deployments

This directory contains Kubernetes manifests for deploying applications and services in the cluster.

## MetalLB

### Description
MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

### Version Information
- MetalLB version: v0.14.9 (stable release compatible with modern Kubernetes)
- Kubernetes compatibility: Kubernetes 1.13.0 or later
- Calico compatibility: Compatible with Calico 3.18+ using L2 advertisement mode

### Files
- `metallb.yaml`: Complete manifests for deploying MetalLB including namespace, RBAC, controller, speaker, and IP address pool configuration.

### Deployment Instructions
1. First, install MetalLB CRDs using the official manifests:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
   ```

2. If you encounter webhook validation errors, temporarily disable the webhook validation:
   ```bash
   kubectl delete -n metallb-system validatingwebhookconfiguration metallb-webhook-configuration
   ```

3. Apply the manifests to your cluster:
   ```bash
   kubectl apply -f metallb.yaml
   ```

4. Verify the deployment:
   ```bash
   kubectl get pods -n metallb-system
   kubectl get ipaddresspool -n metallb-system
   kubectl get l2advertisement -n metallb-system
   ```

### IP Address Configuration
The configuration in `metallb.yaml` sets up an IP address pool from `10.10.13.0` to `10.10.15.255`. 
You can modify this range in the `IPAddressPool` resource to match your network environment if needed.

### Calico Integration Notes
When using with Calico:

1. For L2 mode (current configuration): Works with standard Calico setup as it doesn't conflict with Calico's BGP functionality.

2. For BGP mode (if needed later):
   - As of Calico 3.18+, Calico can be configured to announce the LoadBalancer IPs via BGP
   - Simply use MetalLB with an IPAddressPool but without any BGPAdvertisement CR
   - Configure Calico to announce service cluster IPs and external IPs

### Usage
Once deployed, you can create LoadBalancer services, and MetalLB will automatically assign them external IPs from the configured pool:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app
``` 