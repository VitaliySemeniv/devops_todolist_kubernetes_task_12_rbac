# Validation

## 1) Ноди, лейбли, taints
kubectl get nodes -o wide
kubectl get nodes --show-labels
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" taints="}{.spec.taints}{"\n"}{end}'
# Очікування:
# - два worker-и з label app=mysql і taint app=mysql:NoSchedule
# - один worker з label app=todoapp і без taint app=mysql

## 2) MySQL
kubectl -n mysql get sts,pods,svc,pvc
kubectl -n mysql get pod -l app=mysql -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.spec.nodeName}{"\n"}{end}'
# Очікування: кожен mysql-pod на СВОЇЙ ноді (anti-affinity) і лише на нодах app=mysql (nodeAffinity+toleration).

## 3) ToDo app
kubectl -n todo get deploy,po,svc -o wide
kubectl -n todo get pod -l app=todoapp -o jsonpath='{range .items[*]}{.metadata.name}{" -> "}{.spec.nodeName}{"\n"}{end}'
# Очікування: репліки на різних нодах (anti-affinity); по можливості — на app=todoapp (preferred nodeAffinity).

## 4) Діагностика (якщо Pending)
kubectl -n mysql describe po -l app=mysql | sed -n '1,120p'
kubectl -n todo  describe po -l app=todoapp | sed -n '1,120p'
