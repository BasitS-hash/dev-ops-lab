# DevOps Lab

This repository is a beginner-friendly DevOps lab you can run locally. It contains a small Python Flask app and infrastructure/automation examples that show common DevOps workflows: Docker, Docker Compose, Kubernetes (kind/minikube), Ansible, Terraform scaffolding, and GitHub Actions CI.

Prerequisites
- Docker
- kubectl
- kind or minikube (for local Kubernetes)
- Ansible (for provisioning example)
- Terraform (optional, provider configuration required)
- make

Quick start (local Docker)

1. Build and run with Docker Compose:

```bash
make docker-build
make docker-run
```

2. Run tests:

```bash
make test
```

Kubernetes (kind)

1. Create a kind cluster and deploy:

```bash
make kind-start
make k8s-deploy
```

2. Tear down:

```bash
make k8s-teardown
make kind-delete
```

Ansible

- See `ansible/playbook.yml` as an example. Run with:

```bash
ansible-playbook -i localhost, -c local ansible/playbook.yml
```

Terraform

- `infra/terraform` contains a starter `main.tf` with guidance. Configure the provider (AWS/Azure/GCP) before running Terraform commands.

What's included
- `app/` — sample Flask app, Dockerfile, tests
- `docker-compose.yml` — local compose file
- `k8s/` — Kubernetes Deployment & Service manifests
- `ansible/` — simple example playbook
- `infra/terraform/` — Terraform scaffold
 - `.github/workflows/ci.yml` — CI workflow to run tests and build the image
 - `pyproject.toml`, `.pre-commit-config.yaml`, `requirements-dev.txt` — formatting and linting config (Black, Ruff, pre-commit)
 - `Makefile` & `scripts/` — helper commands to run the lab

Notes
- This lab is intentionally minimal and safe to run locally. Some files (Terraform providers, cloud deployment) require credentials and are left as scaffolds with clear instructions.

Enjoy exploring and let me know if you want integrations for a specific cloud provider or more advanced CI/CD (image push, GitOps, etc.).

Publishing

This repo includes a GitHub Actions workflow that can publish a Docker image to Docker Hub when you create a GitHub Release. To enable publishing:

1. Create repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (use a Docker Hub access token) in GitHub Settings -> Secrets.
2. Create a Release (GitHub UI) or push a tag and create a release; the workflow will build and push the image with the tag name.

If you prefer GitHub Container Registry (GHCR) rather than Docker Hub, tell me and I'll add an alternative workflow for GHCR.
