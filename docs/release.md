# Release
* Update Makefile variable `VERSION` to the appropiate release version. Allowed formats:
  * alpha: `VERSION ?= 0.3.8-alpha.3` - Used for operator development before doing a final release
  * stable: `VERSION ?= 0.3.8` - Used once alpha releases have been tested successfully
* **IMPORTANT**: `VERSION` (having the `-alpha` suffix or not, **must coincide with the original helm chart release**, because it is used to download the original helm chart from [Git Hub](https://github.com/external-secrets/external-secrets/releases)


## Alpha
* If it is an **alpha** release, execute the following target to create appropiate `alpha` bundle files:
```bash
make prepare-alpha-release
```
* Then you can manually execute opetator, bundle and catalog build/push:
```bash
make docker-build
make docker-push
make bundle-publish
```

## Stable
* But if it is an **stable** release, execute the following target to create appropiate `alpha` and `stable` bundle files:
```bash
make prepare-stable-release
```
* Then open a [Pull Request](https://github.com/external-secrets/external-secrets-helm-operator/pulls), and a GitHub Action will automatically detect if it is new release or not, in order to create it by building/pushing new operator, bundle and catalog images, as well as creating a GitHub release draft.

## OperatorHub.io
In order to make the latest release available to [OperatorHub.io](https://operatorhub.io/) we need to create a bundle and open a PR in the [community-operators](https://github.com/k8s-operatorhub/community-operators/) repository.


```bash
make prepare-stable-release
# then: commit & open pr
```

Once the PR is merged we need to push the bundle to operatorhub.
```bash
make bundle-operatorhub
```