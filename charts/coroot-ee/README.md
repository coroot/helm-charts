# Coroot EE Helm Chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo and install Coroot:

```console
helm repo add coroot https://coroot.github.io/helm-charts
helm repo update
helm upgrade --install --namespace coroot --create-namespace coroot coroot/coroot-operator
helm upgrade --install --namespace coroot --create-namespace coroot coroot/coroot-ee
```

## License

[Apache 2.0 License](https://github.com/coroot/helm-charts/blob/main/LICENSE).
