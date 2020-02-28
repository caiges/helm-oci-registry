SHELL=/bin/bash
.PHONY: htpasswd certs ca_certs

image=registry

.PHONY: help
help: ## Display this help section.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Remove certs, Kind cluster and containers.
	rm -rf certs
	kind delete cluster
	docker rm -f registry kube_proxy || true

create_cluster: ## Create a Kind K8s cluster.
	kind create cluster

registry: htpasswd cacerts certs ## Start the image registry.
	docker network create --attachable registry || true
	docker run -d -p 443:443 --restart=always --name registry \
	--network host \
	-v ${PWD}/auth.htpasswd:/etc/docker/registry/auth.htpasswd \
	-v ${PWD}/certs:/certs \
	-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
	-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
	-e REGISTRY_AUTH="{htpasswd: {realm: registry, path: /etc/docker/registry/auth.htpasswd}}" \
	-e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/etc/docker/registry/auth.htpasswd \
	registry:2

registry_logs: ## Follow registry logs.
	docker logs -f registry

htpasswd: ## Configure registry auth.
	htpasswd -cB -b auth.htpasswd blars tacoman

cacerts: ## Generate CA certificate.
	mkdir -p certs
	openssl genrsa -out certs/ca.key 2048
	openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -subj '/C=US/ST=AZ/O=tacoman'

certs: ## Generate registry certificates.
	mkdir -p certs
	openssl genrsa -out certs/registry.key 2048
	openssl req -new -key certs/registry.key -out certs/registry.csr -subj '/CN=registry' -extensions EXT -config <(printf "[dn]\nCN=registry\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:registry\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
	openssl x509 -req -in certs/registry.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/registry.crt 

verify: ## Verify registry certificate against CA.
	openssl s_client -CAfile /apps/certs/ca.crt -showcerts -connect registry:443 -showcerts

helm_image: ## Build the Helm image.
	docker build -t helmer -f helmer.Dockerfile .

helm_shell: ## Drop into the Helm image.
	docker run --rm -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint sh -e HELM_EXPERIMENTAL_OCI=1 --network host --add-host registry:127.0.0.1 helmer

demo_chart: ## Push Helm chart to registry, export and deploy it.
	docker run --rm -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint "" -e HELM_EXPERIMENTAL_OCI=1 --network host --add-host registry:127.0.0.1 helmer ./demo.sh

demo_proxy: ## Start proxy to deployed Chart in K8s.
	docker run --rm --name kube_proxy -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint "" -e HELM_EXPERIMENTAL_OCI=1 --network host helmer kubectl port-forward deployments/nginxtacos 9000:8080

demo_nginx: ## Open webpage hosted by the deployed Nginx Helm chart.
	xdg-open http://localhost:9000

