FROM alpine/helm
RUN apk add --no-cache ca-certificates openssl bash
COPY certs/registry.crt /tmp/registry.crt
RUN bash -c "ln -s /etc/ssl/certs/registry.pem $(openssl x509 -noout -hash -in /tmp/registry.crt)"
RUN update-ca-certificates

