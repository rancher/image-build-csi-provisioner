SEVERITIES = HIGH,CRITICAL

UNAME_M = $(shell uname -m)
ifndef TARGET_PLATFORMS
	ifeq ($(UNAME_M), x86_64)
		TARGET_PLATFORMS:=linux/amd64
	else ifeq ($(UNAME_M), aarch64)
		TARGET_PLATFORMS:=linux/arm64
	else
		TARGET_PLATFORMS:=linux/$(UNAME_M)
	endif
endif

REPO ?= ghcr.io/rancher
PKG ?= github.com/kubernetes-csi/external-provisioner
BUILD_META=-build$(shell date +%Y%m%d)
TAG ?= ${GITHUB_ACTION_TAG}

ifeq ($(TAG),)
TAG := v6.3.0$(BUILD_META)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG $(TAG) needs to end with build metadata: $(BUILD_META))
endif

.PHONY: build-image-csi-provisioner
build-image-csi-provisioner: IMAGE = $(REPO)/hardened-csi-provisioner:$(TAG)
build-image-csi-provisioner:
	docker buildx build \
		--platform=$(TARGET_PLATFORMS) \
		--build-arg PKG=$(PKG) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--target csi-provisioner \
		--tag $(IMAGE) \
		--load \
	.

.PHONY: push-image-csi-provisioner
push-image-csi-provisioner: IMAGE = $(REPO)/hardened-csi-provisioner:$(TAG)
push-image-csi-provisioner:
	docker buildx build \
		$(IID_FILE_FLAG) \
		--sbom=true \
		--attest type=provenance,mode=max \
		--platform=$(TARGET_PLATFORMS) \
		--build-arg PKG=$(PKG) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--target csi-provisioner \
		--tag $(IMAGE) \
		--push \
		.

.PHONY: build-image-all
build-image-all: build-image-csi-provisioner

.PHONY: push-image-all
push-image-all: push-image-csi-provisioner

.PHONY: image-scan
image-scan:
	trivy image --severity $(SEVERITIES) --no-progress --ignore-unfixed $(REPO)/hardened-csi-provisioner:$(TAG)

.PHONY: log
log:
	@echo "TARGET_PLATFORMS=$(TARGET_PLATFORMS)"
	@echo "REPO=$(REPO)"
	@echo "PKG=$(PKG)"
	@echo "TAG=$(TAG:$(BUILD_META)=)"
	@echo "BUILD_META=$(BUILD_META)"
	@echo "UNAME_M=$(UNAME_M)"
