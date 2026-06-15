#!/bin/sh
set -e

until kubectl get nodes 2>/dev/null | grep -q "Ready"; do
  echo "Waiting for K3s..."
  sleep 5
done

kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml