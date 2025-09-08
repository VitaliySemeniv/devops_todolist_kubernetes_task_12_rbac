#!/usr/bin/env bash
set -euo pipefail

# 0) Створити кластер (якщо ще не створений)
kind create cluster --config ./cluster.yml || true

# 1) БАЗА: простори імен (мінімум — todo)
kubectl get ns todo >/dev/null 2>&1 || kubectl create ns todo

# 2) Застосувати RBAC (ServiceAccount + Role + RoleBinding)
kubectl apply -f ./.infrastructure/security/rbac.yml

# 3) Розгорнути застосунок
kubectl apply -f ./.infrastructure/app/deployment.yml

# 4) Дочекатися готовності
kubectl -n todo rollout status deploy/todo-app --timeout=180s

# 5) Вивести ключову інфу
echo "[Pods]"
kubectl -n todo get pods -o wide
echo "[SA on pod]"
kubectl -n todo get pod -l app=todoapp -o jsonpath='{.items[0].spec.serviceAccountName}'; echo
