#!/usr/bin/env bash
set -euo pipefail

# 0) Кластер
kind create cluster --config ./.infrastructure/cluster.yml || true

# 1) Namespaces
kubectl apply -f ./.infrastructure/mysql/ns.yml
kubectl apply -f ./.infrastructure/app/ns.yml

# 2) Лейбли/taints нод (імена нод у kind):
# kind-control-plane, kind-worker, kind-worker2, kind-worker3
kubectl label nodes kind-worker  app=mysql   --overwrite
kubectl label nodes kind-worker2 app=mysql   --overwrite
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
kubectl label nodes kind-worker3 app=todoapp --overwrite

# 3) MySQL стек
kubectl apply -f ./.infrastructure/mysql/secret.yml
kubectl apply -f ./.infrastructure/mysql/configMap.yml
kubectl apply -f ./.infrastructure/mysql/service.yml
kubectl apply -f ./.infrastructure/mysql/statefulSet.yml
kubectl -n mysql rollout status sts/mysql --timeout=180s

# 4) App стек
kubectl apply -f ./.infrastructure/app/secret.yml
kubectl apply -f ./.infrastructure/app/deployment.yml
kubectl apply -f ./.infrastructure/app/service.yml
kubectl -n todo rollout status deploy/todo-app --timeout=180s

# 5) Вивід для перевірки
echo "[Nodes labels/taints]"
kubectl get nodes --show-labels | sed 's/,/\n    /g'
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" taints="}{.spec.taints}{"\n"}{end}'
echo "[MySQL pods]"
kubectl -n mysql get po -o wide
echo "[TODO pods]"
kubectl -n todo get po -o wide
