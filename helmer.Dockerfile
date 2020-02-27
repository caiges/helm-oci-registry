FROM alpine/helm
RUN apk add --no-cache \
  ca-certificates \
  openssl \
  bash \
  make
COPY certs/ca.crt /usr/local/share/ca-certificates
COPY certs/registry.crt /etc/ssl/private
RUN update-ca-certificates

