# Makefile for DevOps Lab

.PHONY: help docker-build docker-run docker-stop docker-clean test kind-start kind-delete k8s-deploy k8s-teardown ansible-run tf-init tf-plan

IMAGE_NAME=devops-lab:latest
CONTAINER_NAME=devops-lab

help:
	@echo "Targets: docker-build docker-run docker-stop docker-clean test kind-start kind-delete k8s-deploy k8s-teardown ansible-run tf-init tf-plan"

docker-build:
	docker build -t $(IMAGE_NAME) ./app

docker-run: docker-build
	docker run --rm -p 5000:5000 --name $(CONTAINER_NAME) $(IMAGE_NAME)

docker-stop:
	docker rm -f $(CONTAINER_NAME) || true

docker-clean:
	docker rmi $(IMAGE_NAME) || true

test:
	pip install -r app/requirements.txt
	pytest -q

kind-start:
	sh scripts/setup-kind.sh create

kind-delete:
	sh scripts/setup-kind.sh delete

k8s-deploy:
	kubectl apply -f k8s/

k8s-teardown:
	kubectl delete -f k8s/ || true

ansible-run:
	ansible-playbook -i localhost, -c local ansible/playbook.yml

tf-init:
	cd infra/terraform && terraform init

tf-plan:
	cd infra/terraform && terraform plan
