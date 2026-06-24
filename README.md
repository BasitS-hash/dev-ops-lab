# DevOps Lab

[![CI](https://github.com/basitsherazi/dev-ops-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/basitsherazi/dev-ops-lab/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.11](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/downloads/)
[![Terraform ≥ 1.5](https://img.shields.io/badge/terraform-%3E%3D1.5-7B42BC.svg)](https://www.terraform.io/)
[![Kubernetes 1.29](https://img.shields.io/badge/kubernetes-1.29-326CE5.svg)](https://kubernetes.io/)

A self-contained Infrastructure-as-Code portfolio lab that wires together the core DevOps stack — Docker, Kubernetes, Ansible, Terraform, and GitHub Actions — around a small deployable Python service.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Developer Machine                        │
│                                                                  │
│  ┌──────────┐   docker compose   ┌────────────────────────────┐ │
│  │ app/     │ ─────────────────► │  devops-lab:latest         │ │
│  │ Flask    │                    │  (gunicorn, non-root user)  │ │
│  │ service  │                    └────────────────────────────┘ │
│  └──────────┘                                                    │
│       │                                                          │
│       │  kind load docker-image + kubectl apply -k k8s/         │
│       ▼                                                          │
│  ┌──────────────────────────────────────────────┐               │
│  │           kind cluster (devops-lab)           │               │
│  │  Namespace: devops-lab                        │               │
│  │                                               │               │
│  │  Deployment (2 replicas, RollingUpdate)       │               │
│  │  Service (ClusterIP :80 → :5000)              │               │
│  │  HPA (CPU 70% / Mem 80%, max 10 pods)         │               │
│  │  Ingress (nginx, devops-lab.local)            │               │
│  │  ConfigMap → env injection                    │               │
│  └──────────────────────────────────────────────┘               │
│                                                                  │
│  ansible-playbook playbook.yml   (local provisioning demo)      │
│  terraform init && terraform plan (null+random providers)        │
└─────────────────────────────────────────────────────────────────┘
                              │
                    GitHub Actions CI
                              │
          ┌──────────────────┴─────────────────────┐
          │ app-test  yaml-lint  k8s-validate        │
          │ terraform-validate  ansible-lint          │
          │ gitleaks (secret scan)                   │
          └─────────────────────────────────────────┘
```

---

## What each layer demonstrates

| Layer | Files | Skills demonstrated |
|-------|-------|---------------------|
| **App** | `app/` | Flask, gunicorn, non-root Docker, health/metrics endpoints, pytest-cov |
| **Docker** | `app/Dockerfile`, `docker-compose.yml` | Multi-stage hygiene, HEALTHCHECK, named networks, env injection |
| **Kubernetes** | `k8s/` | Deployment + Service + HPA + Ingress + ConfigMap + Kustomize |
| **Ansible** | `ansible/` | Role structure, group_vars, inventory, idempotent tasks, handlers |
| **Terraform** | `infra/terraform/` | Variables, locals, outputs, child modules, `random` provider |
| **CI/CD** | `.github/workflows/` | Parallel jobs, kubeconform, tflint, ansible-lint, gitleaks, dependabot |
| **Quality** | `pre-commit`, `pyproject.toml` | black, ruff, yamllint, terraform_fmt, gitleaks hooks |

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Docker | ≥ 24 | Build and run containers |
| Docker Compose | v2 | Local multi-service orchestration |
| kubectl | ≥ 1.29 | Apply K8s manifests |
| kind | ≥ 0.23 | Local Kubernetes cluster |
| Ansible | ≥ 2.13 | Provisioning playbook |
| Terraform | ≥ 1.5 | IaC demo |
| Python | 3.11 | App runtime and dev tooling |
| make | any | Convenience targets |

---

## Quick start

### 1. Clone and install dev tooling

```bash
git clone https://github.com/basitsherazi/dev-ops-lab.git
cd dev-ops-lab
pip install -r requirements-dev.txt
pre-commit install
```

### 2. Run with Docker Compose (fastest)

```bash
make docker-compose-up
curl http://localhost:5000/health
# {"status": "healthy", "uptime_seconds": 0.4, "version": "1.0.0"}
make docker-compose-down
```

### 3. Run tests

```bash
make test         # unit tests
make test-cov     # with HTML coverage report → htmlcov/
```

---

## Layer-by-layer quickstart

### Docker

```bash
make docker-build          # build devops-lab:latest
make docker-run            # run on :5000, auto-removed on stop
make docker-stop
```

### Kubernetes (kind)

```bash
make kind-start            # creates kind cluster named devops-lab
make docker-build          # ensure image is current
make k8s-deploy            # kind load + kubectl apply -k k8s/
make k8s-status            # pods, services, HPA

# Hit the app from inside the cluster
kubectl port-forward -n devops-lab svc/devops-lab 8080:80
curl http://localhost:8080/health

make k8s-teardown
make kind-delete
```

### Ansible

```bash
# Run the local provisioning playbook (localhost only — safe)
make ansible-run

# Lint only
make ansible-lint
```

### Terraform

```bash
make tf-init               # terraform init (no backend, no cloud creds needed)
make tf-validate           # static validation
make tf-plan               # plan against null+random providers (no cloud)
make tf-fmt                # auto-format all .tf files
```

Copy `infra/terraform/terraform.tfvars.example` → `terraform.tfvars` and edit to
override defaults:

```bash
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
```

---

## Application endpoints

| Route | Description |
|-------|-------------|
| `GET /` | Service identification (name, version, env) |
| `GET /health` | Liveness/readiness probe — uptime + version |
| `GET /metrics` | In-memory request counter, uptime, hostname |
| `GET /info` | Runtime info — app name, version, Python version, env |

---

## CI/CD pipelines

### `ci.yml` (every push / PR to main)

| Job | What it does |
|-----|-------------|
| `app-test` | ruff lint → black format check → pytest with coverage → Docker build smoke test |
| `yaml-lint` | yamllint across Ansible, K8s, Compose, and workflows |
| `k8s-validate` | kubeconform validates all manifests against Kubernetes 1.29 schema |
| `terraform-validate` | `terraform fmt -check` → `terraform init` → `terraform validate` → tflint |
| `ansible-lint` | ansible-lint against playbook |
| `gitleaks` | Full-history secret scan |

### `publish.yml` (on GitHub Release)

Builds and pushes a versioned Docker image to Docker Hub using semver tags.
Requires repository secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

---

## Publishing to Docker Hub

1. Create a Docker Hub access token at [hub.docker.com](https://hub.docker.com/settings/security)
2. Add repo secrets in GitHub → Settings → Secrets:
   - `DOCKERHUB_USERNAME` — your Docker Hub username
   - `DOCKERHUB_TOKEN` — the access token (not your password)
3. Create a GitHub Release — the `publish` workflow fires automatically

---

## Repository layout

```
dev-ops-lab/
├── app/                          # Flask application
│   ├── app.py                    # Routes: /, /health, /metrics, /info
│   ├── Dockerfile                # Non-root, gunicorn, HEALTHCHECK
│   ├── requirements.txt
│   └── tests/
│       ├── conftest.py
│       └── test_app.py           # 7 tests covering all routes
├── ansible/
│   ├── ansible.cfg               # Project-scoped config
│   ├── inventory/hosts.ini       # [webservers] localhost
│   ├── group_vars/all.yml        # Shared variables
│   ├── playbook.yml              # Deployment orchestration
│   └── roles/app-deploy/        # Role: tasks, handlers, defaults, meta
├── infra/terraform/
│   ├── versions.tf               # Terraform + provider version pins
│   ├── main.tf                   # Root module — random_id + module call
│   ├── variables.tf              # Typed variables with descriptions
│   ├── locals.tf                 # Computed common_tags + deployment_id
│   ├── outputs.tf                # Exported values
│   ├── terraform.tfvars.example  # Sample overrides (safe to commit)
│   └── modules/app-config/      # Child module — null_resource lifecycle demo
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml           # 2 replicas, RollingUpdate, probes, resources
│   ├── service.yaml              # ClusterIP
│   ├── hpa.yaml                  # autoscaling/v2 CPU+memory
│   ├── ingress.yaml              # nginx + TLS stub
│   └── kustomization.yaml        # Single-command apply
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                # 6-job parallel CI pipeline
│   │   └── publish.yml           # Docker Hub publish on release
│   └── dependabot.yml            # Weekly updates: Actions, pip, Docker
├── docker-compose.yml            # Local compose with healthcheck + named network
├── Makefile                      # 25+ targets with inline help
├── pyproject.toml                # black, ruff, pytest, coverage config
├── requirements-dev.txt          # Dev tooling: black, ruff, pre-commit
├── .pre-commit-config.yaml       # 8 hooks: black, ruff, gitleaks, yamllint, tf
├── .gitignore                    # .terraform/, *.tfstate*, .env, keys, etc.
└── scripts/setup-kind.sh         # kind cluster lifecycle helper
```

---

## Security posture

- No credentials or secrets committed — all sensitive values use GitHub Secrets or environment variables
- Gitleaks runs on every push (pre-commit hook + CI job)
- `detect-private-key` pre-commit hook blocks PEM/key files
- Dockerfile runs as a non-root system user (`app`)
- `.gitignore` excludes: `.env*`, `terraform.tfvars`, `*.tfstate*`, `*.pem`, `*.key`, SSH keys

---

## License

[MIT](LICENSE)
