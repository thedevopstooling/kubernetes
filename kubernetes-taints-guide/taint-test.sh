#!/bin/bash
# taint-test.sh - Validate taint configurations in a Kubernetes cluster

set -euo pipefail

# Step 1: Create test node taint
echo ">>> Applying taint to test-node..."
kubectl taint nodes test-node dedicated=test:NoSchedule --overwrite

# Step 2: Deploy pod with toleration
echo ">>> Deploying pod with toleration..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod-with-toleration
spec:
  tolerations:
  - key: dedicated
    operator: Equal
    value: test
    effect: NoSchedule
  containers:
  - name: test
    image: busybox
    command: ["sleep", "30"]
EOF

kubectl wait --for=condition=Ready pod/test-pod-with-toleration --timeout=30s

# Step 3: Deploy pod without toleration (should stay Pending)
echo ">>> Deploying pod without toleration (expected Pending)..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod-no-toleration
spec:
  containers:
  - name: test
    image: busybox
    command: ["sleep", "30"]
EOF

sleep 10
kubectl get pods | grep test-pod-no-toleration

# Step 4: Test NoExecute taint eviction
echo ">>> Testing NoExecute eviction..."
kubectl taint nodes test-node maintenance=true:NoExecute --overwrite
sleep 5
kubectl get pods -o wide

echo ">>> Test complete."
