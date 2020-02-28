# OCI Registry Helm Charts!

This project provides a demo of using OCI-compliant registries as storage for Helm charts.

Requires:

- Docker
- [Kind](https://kind.sigs.k8s.io/)
- Make
- OpenSSL

# Getting Started

- Create the Kind cluster: `make create_cluster`.
- Start the registry: `make registry`.
- Create the Helm image: `make helm_image`.
- Run the demo and supply the password `tacoman` when requested: `make demo_chart`.
- Start the `kubectl` port forward: `make demo_proxy`.
- Open up the webpage hosted by Nginx: `make demo_nginx`.

What have we done?

- Created a local Kubernetes cluster.
- Started an OCI-compliant image registry on your host.
- Stored a Helm chart as an OCI image on the image registry.
- Instructed Helm to deploy a chart stored on the image registry.
