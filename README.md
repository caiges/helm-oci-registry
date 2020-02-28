# OCI Registry Helm Charts!

This project provides a demo of using OCI-compliant registries as storage for Helm charts. It will create a Kind Kubernetes cluster, start a container registry, store a Nginx Helm chart there and use it for a deployment of Nginx to the Kind Kubernetes cluster.

Requires:

- Docker
- [Kind](https://kind.sigs.k8s.io/)
- Make
- OpenSSL

# Getting Started

- Create the Kind cluster: `make clustercreate`.
- Generate the CA certificates: `make cacerts`.
- Generate the Registry certificates: `make certs`.
- Start the registry: `make registry`.
- Create the Helm image: `make helm_image`.
- Run the demo: `make demo_chart`.
- Start the `kubectl` port forward: `make demo_proxy`.
- Open up the webpage hosted by Nginx: `make demo_nginx`.

What have we done?

- Created a local Kubernetes cluster.
- Started an OCI-compliant image registry.
- Stored a Helm chart as an OCI image on the image registry.
- Instructed Helm to deploy a chart stored on the image registry.
