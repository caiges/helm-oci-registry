SHELL=/bin/bash
image=registry

up:
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
	docker rm -f registry

logs:
	docker logs -f registry

htpasswd:
	htpasswd -cB -b auth.htpasswd blars tacoman

.PHONY: certs
certs:
	mkdir -p certs
	$(shell openssl req -x509 -out certs/registry.crt -keyout certs/registry.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=registry' -extensions EXT -config <(printf "[dn]\nCN=registry\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:registry\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth"))

helm_image:
	docker build -t helmer -f helmer.Dockerfile .
