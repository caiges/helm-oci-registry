SHELL=/bin/bash
.PHONY: htpasswd certs ca_certs

image=registry

clean:
	rm -rf certs
	kind delete cluster
	docker rm -f registry kube_proxy || true

create_cluster:
	kind create cluster

registry: htpasswd cacerts certs
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

registry_logs:
	docker logs -f registry

htpasswd:
	htpasswd -cB -b auth.htpasswd blars tacoman

cacerts:
	mkdir -p certs
	openssl genrsa -out certs/ca.key 2048
	openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -subj '/C=US/ST=AZ/O=tacoman'

certs:
	mkdir -p certs
	openssl genrsa -out certs/registry.key 2048
	openssl req -new -key certs/registry.key -out certs/registry.csr -subj '/CN=registry' -extensions EXT -config <(printf "[dn]\nCN=registry\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:registry\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
	openssl x509 -req -in certs/registry.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/registry.crt 

verify:
	openssl s_client -CAfile /apps/certs/ca.crt -showcerts -connect registry:443 -showcerts

helm_image:
	docker build -t helmer -f helmer.Dockerfile .

helm_shell:
	docker run --rm -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint sh -e HELM_EXPERIMENTAL_OCI=1 --network host --add-host registry:127.0.0.1 helmer

demo_chart:
	docker run --rm -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint "" -e HELM_EXPERIMENTAL_OCI=1 --network host --add-host registry:127.0.0.1 helmer ./demo.sh

demo_proxy:
	docker run --rm --name kube_proxy -it -v ${HOME}/.kube:/root/.kube -v ${PWD}:/apps --entrypoint "" -e HELM_EXPERIMENTAL_OCI=1 --network host  helmer kubectl port-forward deployments/nginxtacos 9000:8080

demo_nginx:
	xdg-open http://localhost:9000

