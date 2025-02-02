SNAPSHOT_DATE=`bin/garden-version --date`
VERSION=`bin/garden-version`
IMAGE_BASENAME=garden-linux
PUBLIC=true
AWS_DISTRIBUTE=
BUILDDIR=.build
MAINTAINER_EMAIL="contact@gardenlinux.io"

cert/sign.pub:
	make --directory=cert MAINTAINER_EMAIL=$(MAINTAINER_EMAIL)
	@gpg --list-secret-keys $(MAINTAINER_EMAIL) > /dev/null || echo "No secret key for $(MAINTAINER_EMAIL) exists, signing disabled" 
	@diff cert/sign.pub gardenlinux.pub || echo "Not using the official key"

.PHONY: docker
docker:
	make --directory=docker build-image

all: all_dev all_prod

all_prod: ali aws gcp azure openstack vmware kvm

all_dev: ali-dev aws-dev gcp-dev azure-dev openstack-dev vmware-dev

ALI_IMAGE_NAME=$(IMAGE_BASENAME)-ali-$(VERSION)
ali: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,ali $(BUILDDIR)/ali $(SNAPSHOT_DATE)

ali-upload:
	aliyun oss cp $(BUILDDIR)/ali/$(SNAPSHOT_DATE)/rootfs.qcow2  oss://gardenlinux-development/gardenlinux/$(ALI_IMAGE_NAME).qcow2

ALI_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-dev-ali-$(VERSION)
ali-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,ali,_dev $(BUILDDIR)/ali-dev $(SNAPSHOT_DATE)

ali-dev-upload:
	aliyun oss cp $(BUILDDIR)/ali-dev/$(SNAPSHOT_DATE)/rootfs.qcow2  oss://gardenlinux-development/gardenlinux/$(ALI_DEV_IMAGE_NAME).qcow2


AWS_IMAGE_NAME=$(IMAGE_BASENAME)-aws-$(VERSION)
aws: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,aws $(BUILDDIR)/aws $(SNAPSHOT_DATE)

aws-upload:
	./bin/make-ec2-ami --bucket gardenlinux --region eu-central-1 --image-name=$(AWS_IMAGE_NAME) $(BUILDDIR)/aws/$(SNAPSHOT_DATE)/rootfs.raw --permission-public "$(PUBLIC)" --distribute "$(AWS_DISTRIBUTE)"

AWS_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-dev-aws-$(VERSION)
aws-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,aws,_dev $(BUILDDIR)/aws-dev $(SNAPSHOT_DATE)

aws-dev-upload:
	./bin/make-ec2-ami --bucket ami-debian-image-test --region eu-central-1 --image-name=$(AWS_DEV_IMAGE_NAME) $(BUILDDIR)/aws-dev/$(SNAPSHOT_DATE)/rootfs.raw --permission-public "$(PUBLIC)" --distribute "$(AWS_DISTRIBUTE)"

GCP_IMAGE_NAME=$(IMAGE_BASENAME)-gcp-$(VERSION)
gcp: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,gcp $(BUILDDIR)/gcp $(SNAPSHOT_DATE)

gcp-upload:
	./bin/make-gcp-ami --bucket gardenlinux-images --image-name $(GCP_IMAGE_NAME) --raw-image-path $(BUILDDIR)/gcp/$(SNAPSHOT_DATE)/rootfs-gcpimage.tar.gz --permission-public "$(PUBLIC)"

GCP_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-dev-gcp-$(VERSION)
gcp-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,gcp,_dev $(BUILDDIR)/gcp-dev $(SNAPSHOT_DATE)

gcp-dev-upload:
	./bin/make-gcp-ami --bucket garden-linux-test --image-name $(GCP_DEV_IMAGE_NAME) --raw-image-path $(BUILDDIR)/gcp-dev/$(SNAPSHOT_DATE)/rootfs-gcpimage.tar.gz --permission-public "$(PUBLIC)"

AZURE_IMAGE_NAME=$(IMAGE_BASENAME)-az-$(VERSION)
azure: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,azure $(BUILDDIR)/azure $(SNAPSHOT_DATE)

azure-upload:
	./bin/make-azure-ami --resource-group garden-linux --storage-account-name gardenlinux --image-path=$(BUILDDIR)/azure/$(SNAPSHOT_DATE)/rootfs.vhd --image-name=$(AZURE_IMAGE_NAME)

AZURE_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-dev-az-$(VERSION)
azure-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,azure,_dev $(BUILDDIR)/azure-dev $(SNAPSHOT_DATE)

azure-dev-upload:
	./bin/make-azure-ami --resource-group garden-linux --storage-account-name gardenlinux --image-path=$(BUILDDIR)/azure-dev/$(SNAPSHOT_DATE)/rootfs.vhd --image-name=$(AZURE_DEV_IMAGE_NAME)


OPENSTACK_IMAGE_NAME=$(IMAGE_BASENAME)-openstack-$(VERSION)
openstack: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,openstack $(BUILDDIR)/openstack $(SNAPSHOT_DATE)

openstack-upload:
	./bin/upload-openstack $(BUILDDIR)/openstack/$(SNAPSHOT_DATE)/rootfs.vmdk $(OPENSTACK_IMAGE_NAME)

OPENSTACK_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-openstack-dev-$(VERSION)
openstack-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,openstack,_dev $(BUILDDIR)/openstack-dev $(SNAPSHOT_DATE)

openstack-dev-upload: 
	./bin/upload-openstack $(BUILDDIR)/openstack-dev/$(SNAPSHOT_DATE)/rootfs.vmdk $(OPENSTACK_DEV_IMAGE_NAME)

openstack-qcow2: docker cert/sign.pub
	./build.sh --features server,cloud,gardener,openstack-qcow2 $(BUILDDIR)/openstack-qcow2 $(SNAPSHOT_DATE)

VMWARE_DEV_IMAGE_NAME=$(IMAGE_BASENAME)-vmware-dev-$(VERSION)
vmware-dev: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,vmware,_dev $(BUILDDIR)/vmware-dev $(SNAPSHOT_DATE)

vmware: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,gardener,vmware $(BUILDDIR)/vmware $(SNAPSHOT_DATE)

cloud: docker cert/sign.pub
	./build.sh --no-build --features server,cloud $(BUILDDIR)/cloud $(SNAPSHOT_DATE)

kvm: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,kvm,_dev $(BUILDDIR)/kvm $(SNAPSHOT_DATE)

pxe: docker cert/sign.pub
	./build.sh --no-build --features server,cloud,_pxe $(BUILDDIR)/pxe $(SNAPSHOT_DATE)

pxe-dev: docker cert/sign.pub
	./build.sh --no-build --features server,metal,_dev,_pxe $(BUILDDIR)/pxe $(SNAPSHOT_DATE)

anvil: docker cert/sign.pub
	./build.sh --no-build --features server,cloud-anvil,kvm,_dev $(BUILDDIR)/anvil $(SNAPSHOT_DATE)

onmetal: metal
metal: docker cert/sign.pub
	./build.sh --no-build --features server,metal $(BUILDDIR)/metal $(SNAPSHOT_DATE)

metal-dev: docker cert/sign.pub
	./build.sh --no-build --features server,metal,_dev $(BUILDDIR)/metal $(SNAPSHOT_DATE)

clean:
	@echo "emptying $(BUILDDIR)"
	@rm -rf $(BUILDDIR)
	@echo "deleting all containers running gardenlinux/build-image"
	@-docker container rm $$(docker container ls -a | awk '{ print $$1,$$2 }' | grep gardenlinux/build-image: | awk '{ print $$1 }') 2> /dev/null || true
	@echo "deleting all images of gardenlinux/build-image"
	@-docker image rm --force $$(docker image ls -a | awk '{ print $$1,$$3 }' | grep gardenlinux/build-image | awk '{ print $$2 }' | sort -u) 2> /dev/null || true

