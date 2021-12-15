# Install

## Manual deploy
* To manually install the operator (on all its dependant resources) on default namespace `external-secrets-operator-system` without using OLM, you can use the following make target (which uses `kustomize`):
```bash
$ make deploy
```
* Then create any `OperatorConfig` resource type (you can find an example [here](../config/samples/operator_v1alpha1_operatorconfig.yaml)).
* Once tested, delete created operator resources using the following make target:
```bash
$ make undeploy
```

## OLM manual deploy
* If you want to install a specific version of the operator via OLM on a **manual** way, you can use for example the following command:
```bash
operator-sdk run bundle ghcr.io/external-secrets/external-secrets-helm-operator-bundle:0.3.8-alpha.3 --namespace external-secrets
```
* Then create any `OperatorConfig` resource type (you can find an example [here](../config/samples/operator_v1alpha1_operatorconfig.yaml)).
* If you want to test an operator upgrade of a newer version, execute for example:
```bash
operator-sdk run bundle-upgrade ghcr.io/external-secrets/external-secrets-helm-operator-bundle:0.3.8-alpha.4 --namespace external-secrets
```

## OLM automatic deploy
* If you want to install the operator via OLM on an **automatic** way subscribing to a catalog, you can need to follow the following steps.

* First you need to deploy an specific `CatalogSource` in which operator releases will be published:
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: external-secrets-operator-catalog
  namespace: external-secrets
spec:
  sourceType: grpc
  image: ghcr.io/external-secrets/external-secrets-helm-operator-catalog:latest
  displayName: External Secrets Operator
  updateStrategy:
    registryPoll:
      interval: 30m
```
* Then you need to create an `OperatorGroup`, so you set the target namespaces in which the external-secrets-operator will watch for `OperatorConfig` custom resources (so it will be set operator ENVVAR `WATCH_NAMESPACE`):
```yaml
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: external-secrets
  namespace: external-secrets
spec:
  targetNamespaces:
    - external-secrets
```
* Finally create an operator `Subscription` on a given channel (`alpha`/`stable`) with `Automatic`/`Manual` installation (with `Manual` it will ask you confirmation to install an operator upgrade):
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: external-secrets-operator
  namespace: external-secrets
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: external-secrets-operator
  source: external-secrets-operator-catalog
  sourceNamespace: external-secrets
```
* Now you can create any `OperatorConfig` resource type (you can find an example [here](../config/samples/operator_v1alpha1_operatorconfig.yaml)).