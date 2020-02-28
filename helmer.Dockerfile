FROM alpine/helm
RUN apk add --no-cache \
  ca-certificates \
  openssl \
  bash \
  make \
  curl
COPY certs/ca.crt /usr/local/share/ca-certificates
COPY certs/registry.crt /etc/ssl/private
RUN update-ca-certificates
# Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && mv kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl
