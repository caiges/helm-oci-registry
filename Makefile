SHELL=/bin/bash
image=registry

up: htpasswd
	docker network create --attachable registry || true
	docker run -d -p 443:443 --restart=always --name registry \
	--network registry \
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

down:
	docker rm -f registry || true

logs:
	docker logs -f registry

htpasswd:
	htpasswd -cB -b auth.htpasswd blars tacoman

.PHONY: certs ca_certs

cacerts:
	mkdir -p certs
	openssl genrsa -out certs/ca.key 2048
	openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -subj '/C=US/ST=AZ/O=tacoman'

certs:
	mkdir -p certs
	openssl genrsa -out certs/registry.key 2048
	openssl req -new -key certs/registry.key -out certs/registry.csr -subj '/CN=registry' -extensions EXT -config <(printf "[dn]\nCN=registry\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:registry\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
	openssl x509 -req -in certs/registry.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/registry.crt 

helm_image:
	docker build -t helmer -f helmer.Dockerfile .

helm_shell:
	docker run -it -v ${PWD}:/apps --entrypoint sh -e HELM_EXPERIMENTAL_OCI=1 --network registry helmer

verify:
	openssl s_client -CAfile /apps/certs/ca.crt -showcerts -connect registry:443 -showcerts
