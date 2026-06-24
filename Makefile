# ─────────────────────────────────────────────────────────────────────────────
# DevOps Lab — Makefile
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: help \
        docker-build docker-run docker-stop docker-clean docker-compose-up docker-compose-down \
        test test-cov \
        kind-start kind-delete k8s-deploy k8s-teardown k8s-status \
        ansible-run \
        tf-init tf-fmt tf-validate tf-plan tf-tflint \
        lint fmt pre-commit \
        clean

IMAGE_NAME   := devops-lab:latest
CONTAINER    := devops-lab
K8S_NS       := devops-lab
TF_DIR       := infra/terraform
ANSIBLE_DIR  := ansible

# ── Help ──────────────────────────────────────────────────────────────────────
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} \
	      /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# ── Docker ────────────────────────────────────────────────────────────────────
docker-build: ## Build the Docker image
	docker build -t $(IMAGE_NAME) ./app

docker-run: docker-build ## Build and run the container locally
	docker run --rm -p 5000:5000 \
	  -e LOG_LEVEL=INFO \
	  -e APP_ENV=development \
	  --name $(CONTAINER) $(IMAGE_NAME)

docker-stop: ## Stop and remove the container
	docker rm -f $(CONTAINER) 2>/dev/null || true

docker-clean: docker-stop ## Remove the Docker image
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

docker-compose-up: ## Start services with Docker Compose
	docker compose up --build -d

docker-compose-down: ## Tear down Docker Compose services
	docker compose down

# ── Tests ─────────────────────────────────────────────────────────────────────
test: ## Run app tests
	pip install -q -r app/requirements.txt
	PYTHONPATH=$(CURDIR) pytest app/tests/ -v

test-cov: ## Run tests with coverage report
	pip install -q -r app/requirements.txt
	PYTHONPATH=$(CURDIR) pytest app/tests/ -v \
	  --cov=app --cov-report=term-missing --cov-report=html:htmlcov

# ── Kubernetes ────────────────────────────────────────────────────────────────
kind-start: ## Create a local kind cluster
	sh scripts/setup-kind.sh create

kind-delete: ## Delete the local kind cluster
	sh scripts/setup-kind.sh delete

k8s-deploy: ## Load image into kind and apply all manifests
	kind load docker-image $(IMAGE_NAME) --name devops-lab 2>/dev/null || true
	kubectl apply -k k8s/

k8s-teardown: ## Remove all k8s resources
	kubectl delete -k k8s/ --ignore-not-found

k8s-status: ## Show pod and service status in the devops-lab namespace
	kubectl get pods,svc,hpa -n $(K8S_NS)

# ── Ansible ───────────────────────────────────────────────────────────────────
ansible-run: ## Run the deployment playbook
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml

ansible-lint: ## Lint ansible playbooks and roles
	ansible-lint $(ANSIBLE_DIR)/playbook.yml

# ── Terraform ─────────────────────────────────────────────────────────────────
tf-init: ## Initialize Terraform
	cd $(TF_DIR) && terraform init -backend=false

tf-fmt: ## Format Terraform files
	terraform fmt -recursive $(TF_DIR)

tf-validate: tf-init ## Validate Terraform configuration
	cd $(TF_DIR) && terraform validate

tf-plan: tf-init ## Run terraform plan (no-op providers)
	cd $(TF_DIR) && terraform plan

tf-tflint: ## Run tflint (requires tflint installed)
	cd $(TF_DIR) && tflint --init && tflint --recursive

# ── Code quality ──────────────────────────────────────────────────────────────
fmt: ## Format Python code with black
	black .

lint: ## Lint Python code with ruff
	ruff check .

pre-commit: ## Run all pre-commit hooks
	pre-commit run --all-files

# ── Cleanup ───────────────────────────────────────────────────────────────────
clean: docker-clean ## Clean build artefacts
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf htmlcov .coverage .pytest_cache
