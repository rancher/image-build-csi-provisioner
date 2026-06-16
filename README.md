# image-build-csi-provisioner

This repo builds hardened, statically-linked Go binaries from
[kubernetes-csi/external-provisioner](https://github.com/kubernetes-csi/external-provisioner) and packages them in a minimal
SLE BCI ([bci-nano](registry.suse.com/bci/bci-nano)) based image.

Binaries are compiled against [`rancher/hardened-build-base`](https://github.com/rancher/image-build-base),
which provides the latest supported Go toolchain (FIPS/BoringCrypto-enabled on amd64).

## Images produced

- `rancher/hardened-csi-provisioner` — CSI Provisioner Sidecar

## Building locally

```sh
make build-image-all          # build for the host architecture
make image-scan               # run Trivy against the built image(s)
```

The upstream version is controlled by the `TAG` variable in the [`Makefile`](./Makefile).
A `-buildYYYYMMDD` suffix (`BUILD_META`) is appended automatically and is required on
release tags.

## Automated updates

[Updatecli](./updatecli) keeps two things current via daily PRs:

- the upstream `external-provisioner` version (`Makefile` `TAG`), and
- the `rancher/hardened-build-base` version (`Dockerfile` `GO_IMAGE`).

## CI

- **Build**: builds every image and runs a [Trivy](https://github.com/aquasecurity/trivy) scan
  (`CRITICAL,HIGH`) on each on every PR/push.
- **Release**: on a published GitHub release, builds multi-arch images and pushes them to
  `ghcr.io/rancher`.
