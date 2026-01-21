#!/usr/bin/env bash
set -euo pipefail

CMD=${1:-help}

function create() {
  if ! command -v kind >/dev/null 2>&1; then
    echo "kind is not installed. Install from https://kind.sigs.k8s.io/"
    exit 1
  fi
  kind create cluster --name devops-lab || true
  kubectl cluster-info --context kind-devops-lab
}

function delete() {
  kind delete cluster --name devops-lab || true
}

case "$CMD" in
  create) create ;;
  delete) delete ;;
  *) echo "Usage: $0 {create|delete}" ; exit 1 ;;
esac
