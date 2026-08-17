ENV_DIR = environments/local
MINISTACK_NAME = ministack

.PHONY: up down init plan apply destroy fmt lint test

up:
	@echo "Subindo container do MiniStack..."
	docker run -d -p 4566:4566 -v /var/run/docker.sock:/var/run/docker.sock --name $(MINISTACK_NAME) ministackorg/ministack:full || true

down:
	@echo "Parando MiniStack..."
	docker stop $(MINISTACK_NAME) && docker rm $(MINISTACK_NAME)

init:
	cd $(ENV_DIR) && terraform init

plan:
	cd $(ENV_DIR) && terraform plan

apply:
	cd $(ENV_DIR) && terraform apply -auto-approve

destroy:
	cd $(ENV_DIR) && terraform destroy -auto-approve

fmt:
	terraform fmt -recursive

lint:
	tflint --recursive
	trivy config .

test: fmt init plan
