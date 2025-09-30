# Kubernetes Taints & Tolerations Cheat Sheet

## 🎯 Taint Effects
- **NoSchedule** → Prevents new pods from being scheduled unless they tolerate the taint.  
- **PreferNoSchedule** → Scheduler avoids these nodes, but may still schedule if needed.  
- **NoExecute** → Evicts existing pods without tolerations and prevents new ones.

---

## 🧩 Matching Matrix

| Taint                  | Toleration (Pod)                  | Match? |
|-------------------------|-----------------------------------|--------|
| `key=value:Effect`      | `key=value:Effect` (Equal)        | ✅ Yes |
| `key=value:Effect`      | `key:Effect` (Exists)             | ✅ Yes |
| `key:Effect`            | `key=value:Effect` (Equal)        | ❌ No  |
| `key:Effect`            | `key:Effect` (Exists)             | ✅ Yes |
| `key=value1:Effect`     | `key=value2:Effect` (Equal)       | ❌ No  |
| `key=value:NoSchedule`  | `key=value:NoExecute`             | ❌ No  |

---

## 🛠️ Common Kubectl Commands

```bash
# Add a taint
kubectl taint nodes NODE key=value:NoSchedule

# Remove a taint
kubectl taint nodes NODE key=value:NoSchedule-

# View taints on a node
kubectl describe node NODE | grep Taints

# List taints across all nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
