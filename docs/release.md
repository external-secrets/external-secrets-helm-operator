# Release

* Update Makefile variable `VERSION` to the appropiate release version. Allowed formats:
  * alpha: `VERSION ?= 0.3.8-alpha.3` - Used for operator development before doing a final release
  * stable: `VERSION ?= 0.3.8` - Used once alpha releases have been tested successfully
* **IMPORTANT**: `VERSION` (having the `-alpha` suffix or not, **must coincide with the original helm chart release**, because it is used to download the original helm chart from [Git Hub](https://github.com/external-secrets/external-secrets/releases)

## Alpha

Execute following target to generate, build and push the operator, bundle and catalog images.

```bash
make release-publish
```

## Stable

If it is an **stable** release, container images will be built in GitHub Actions,
so you only need to create and commit appropiate bundle files executing:

```bash
make prepare-release
```

- Then open a [Pull Request](https://github.com/3scale-ops/prometheus-exporter-operator/pulls), and the [Release GitHub Action](https://github.com/3scale-ops/prometheus-exporter-operator/actions/workflows/release.yaml) will automatically detect if it is new release or not, in order to create it by building/pushing new operator and bundle.

- As part of the release workflow, a:

  - Release Draft will be published, review the changelog, adding any missing information and publish the release.
  - A new Pull Request will open with the updated catalog including the new release.

- Review the Catalog Pull Request and merge it to publish the trigger the [Release Catalog GitHub Action](https://github.com/3scale-ops/prometheus-exporter-operator/actions/workflows/release-catalog.yaml). This action will automatically build and publish the new catalog image.

## OperatorHub.io

In order to make the latest release available to [OperatorHub.io](https://operatorhub.io/) we need to create a bundle and open a PR in the [community-operators](https://github.com/k8s-operatorhub/community-operators/) repository.

To create a bundle first increment the `VERSION` in the Makefile as described above. Then run the following commands in the root of the repository:

```bash
make prepare-stable-release
```

Check the generated files in the `bundle/` directory. If they look good add & commit them, open a PR against this repository. You can always use the [OperatorHub.io/preview](https://operatorhub.io/preview) page to preview the generated CSV.

```bash
git status
git add .
git commit -s -m "chore: bump version xyz"
git push
```

Once the PR is merged we need create a pull request against the community-operators repository. there's a make target that does the heavy lifting for you:

```bash
make bundle-operatorhub
```

You then just need to push to your fork and open a PR against the community-operators repository. If you're a [reviewer](https://github.com/k8s-operatorhub/community-operators/blob/main/operators/external-secrets-operator/ci.yaml) the PR gets merged automatically. The website needs some time 10-30 minutes to display the latest changes.
