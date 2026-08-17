ENV_DIR ?= environments/local

MINISTACK_NAME ?= ministack
AWS_REGION ?= us-east-1
CLUSTER_NAME ?= local-k8s

K3S_CONTAINER ?= ministack-eks-$(AWS_REGION)-$(CLUSTER_NAME)
K3S_API_PORT ?= 16443

KUBECONFIG_FILE ?= $(HOME)/.kube/ministack-$(CLUSTER_NAME).yaml
KUBE_CONTEXT ?= ministack-local-k8s

K8S_MANIFEST ?= k8s/app-demo.yaml
K8S_NAMESPACE ?= demo

.PHONY: up down init plan apply destroy kubeconfig deploy-app status fmt fmt-check lint validate test

up:
	@echo "Iniciando MiniStack..."
	@if docker inspect $(MINISTACK_NAME) >/dev/null 2>&1; then \
		if [ "$$(docker inspect -f '{{.State.Running}}' $(MINISTACK_NAME))" = "true" ]; then \
			echo "MiniStack ja esta em execucao."; \
		else \
			docker start $(MINISTACK_NAME) >/dev/null; \
			echo "MiniStack iniciado."; \
		fi; \
	else \
		docker run -d \
			-p 4566:4566 \
			-v /var/run/docker.sock:/var/run/docker.sock \
			--name $(MINISTACK_NAME) \
			ministackorg/ministack:full; \
	fi

down:
	@echo "Parando MiniStack..."
	@docker rm -f $(MINISTACK_NAME) >/dev/null 2>&1 || true

init:
	terraform -chdir=$(ENV_DIR) init

plan:
	terraform -chdir=$(ENV_DIR) plan

apply:
	terraform -chdir=$(ENV_DIR) apply -auto-approve

destroy:
	terraform -chdir=$(ENV_DIR) destroy -auto-approve

kubeconfig:
	@echo "Configurando kubeconfig do cluster $(CLUSTER_NAME)..."
	@if ! docker inspect $(K3S_CONTAINER) >/dev/null 2>&1; then \
		echo "Erro: container $(K3S_CONTAINER) nao encontrado."; \
		echo "Execute 'make apply' antes de gerar o kubeconfig."; \
		exit 1; \
	fi
	@if [ "$$(docker inspect -f '{{.State.Running}}' $(K3S_CONTAINER))" != "true" ]; then \
		echo "Erro: container $(K3S_CONTAINER) nao esta em execucao."; \
		exit 1; \
	fi
	@mkdir -p "$(dir $(KUBECONFIG_FILE))"
	@set -eu; \
	tmp_file=$$(mktemp); \
	trap 'rm -f "$$tmp_file"' EXIT; \
	docker exec $(K3S_CONTAINER) cat /etc/rancher/k3s/k3s.yaml > "$$tmp_file"; \
	test -s "$$tmp_file"; \
	sed -i 's|server: https://.*:6443|server: https://127.0.0.1:$(K3S_API_PORT)|' "$$tmp_file"; \
	install -m 600 "$$tmp_file" "$(KUBECONFIG_FILE)"
	@current_context=$$(kubectl --kubeconfig "$(KUBECONFIG_FILE)" config current-context); \
	if [ "$$current_context" != "$(KUBE_CONTEXT)" ]; then \
		kubectl --kubeconfig "$(KUBECONFIG_FILE)" \
			config rename-context "$$current_context" "$(KUBE_CONTEXT)" >/dev/null; \
	fi
	@echo "Kubeconfig criado em: $(KUBECONFIG_FILE)"
	@echo "Contexto: $(KUBE_CONTEXT)"
	@echo "API Server: https://127.0.0.1:$(K3S_API_PORT)"

deploy-app:
	@test -f "$(KUBECONFIG_FILE)" || \
		(echo "Erro: kubeconfig nao encontrado. Execute 'make kubeconfig' primeiro." && exit 1)
	@test -f "$(K8S_MANIFEST)" || \
		(echo "Erro: manifesto $(K8S_MANIFEST) nao encontrado." && exit 1)
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" apply -f "$(K8S_MANIFEST)"
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" \
		rollout status deployment/demo-app \
		--namespace "$(K8S_NAMESPACE)" \
		--timeout=120s

status:
	@test -f "$(KUBECONFIG_FILE)" || \
		(echo "Erro: kubeconfig nao encontrado. Execute 'make kubeconfig' primeiro." && exit 1)
	@echo "=== Kubernetes Nodes ==="
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" get nodes -o wide
	@echo
	@echo "=== Demo Workload ==="
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" \
		get deployment,pods,service \
		--namespace "$(K8S_NAMESPACE)"

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -check -recursive

lint:
	tflint --init
	tflint --recursive
	trivy config .

validate:
	terraform -chdir=$(ENV_DIR) init -backend=false
	terraform -chdir=$(ENV_DIR) validate

test: fmt-check lint validate