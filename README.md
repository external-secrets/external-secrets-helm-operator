# External Secrets Operator

[![test](https://github.com/3scale-ops/external-secrets-operator/actions/workflows/test.yaml/badge.svg)](https://github.com/3scale-ops/external-secrets-operator/actions/workflows/test.yaml)
[![build](https://github.com/3scale-ops/external-secrets-operator/actions/workflows/release.yaml/badge.svg)](https://github.com/3scale-ops/external-secrets-operator/actions/workflows/release.yaml)
[![release](https://badgen.net/github/release/3scale-ops/external-secrets-operator)](https://github.com/3scale-ops/external-secrets-operator/releases)
[![license](https://badgen.net/github/license/3scale-ops/external-secrets-operator)](https://github.com/3scale-ops/external-secrets-operator/blob/main/LICENSE)

A Kubernetes Operator based on the Operator SDK (Helm version) to configure **[official external-secrets operator helm chart](https://github.com/external-secrets/external-secrets)**, so it can be installed via OLM without having to do any change on current Helm Charts.

The usual Helm Chart file `values.yaml`, like:
```yaml
prometheus:
  enabled: true
  service:
    port: 8080
resources:
   requests:
     cpu: 10m
     memory: 96Mi
   limits:
     cpu: 100m
     memory: 256Mi
```

Need to be encapsulated into a new custom resource called `OperatorConfig`:
```yaml
apiVersion: operator.external-secrets.io/v1alpha1
kind: OperatorConfig
metadata:
  name: cluster
spec:
  prometheus:
    enabled: true
    service:
      port: 8080
  resources:
   requests:
     cpu: 10m
     memory: 96Mi
   limits:
     cpu: 100m
     memory: 256Mi
```

So the operator will create all helm chart resources, using the custom resource name as a preffix for all resources names, like for example a `Deployment` called `cluster-external-secrets`.

## Initial bootstrap

Initially, all operator files bootstraping have been created with `operator-sdk:v1.15.0` ([commit](https://github.com/3scale-ops/external-secrets-operator/commit/0694458c1d87db46331e6788b96ac82513de30d0)):
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

And then, the most important change done on predefined files was the operator `ClusterRole`, which needed extra permissions in order to be able to create all resources created by the Helm Chart ([commit](https://github.com/3scale-ops/external-secrets-operator/commit/ee344d8eddf683216af947b94b6c2a3ca6d7fe9a)).

The rest of the changes are mostly cosmetic, a kind of k8s-operator-olm envelope for the real Helm Chart at [helm-charts/external-secrets](helm-charts/external-secrets/).

## Documentation

* [Install](docs/install.md)
* [Development](docs/development.md)
* [Release](docs/release.md)

## Contributing

You can contribute by:

* Raising any issues you find using External Secrets Operator
* Fixing issues by opening [Pull Requests](https://github.com/3scale-ops/external-secrets-operator/pulls)
* Submitting a patch or opening a PR
* Improving documentation
* Talking about External Secrets Operator

All bugs, tasks or enhancements are tracked as [GitHub issues](https://github.com/3scale-ops/external-secrets-operator/issues).

## License

External Secrets Operator is under Apache 2.0 license. See the [LICENSE](LICENSE) file for details.