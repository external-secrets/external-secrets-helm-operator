# external-secrets-operator

K8s operator based on operator-sdk framework to install external-secrets operator helm chart from https://github.com/external-secrets/external-secrets

Initial operator bootstrap created with:
```bash
$ operator-sdk init --plugins helm --group operator --domain external-secrets.io --version v1alpha1 --kind OperatorConfig --helm-chart=external-secrets --helm-chart-repo=https://charts.external-secrets.io/ --helm-chart-version=0.3.8
Writing kustomize manifests for you to edit...
Creating the API:
$ operator-sdk create api --group operator --version v1alpha1 --kind OperatorConfig --helm-chart external-secrets --helm-chart-repo https://charts.external-secrets.io/ --helm-chart-version 0.3.8
Writing kustomize manifests for you to edit...
Created helm-charts/external-secrets
Generating RBAC rules
WARN[0006] Using default RBAC rules: failed to generate RBAC rules: failed to get server resources: Unauthorized
```