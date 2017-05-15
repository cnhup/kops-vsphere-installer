#!/bin/bash

if [ -z "$VCSA" ]; then
  echo "Please export VCSA=[IP address of your vCenter endpoint]"
  exit 1
fi
if [ -z "$VSPHERE_USERNAME" ]; then
  echo "Please export VSPHERE_USERNAME=[your vSphere username]"
  exit 1
fi
if [ -z "$VSPHERE_PASSWORD" ]; then
  echo "Please export VSPHERE_PASSWORD=[your vSphere password]"
  exit 1
fi
if [ -z "$VCS_PATH" ]; then
  echo "Please export VCS_PATH=[your path to hold VCS files]"
  exit 1
fi

(
echo "export VCSA=${VCSA}"
echo "export S3_ENDPOINT=http://${VCSA}:9000"
echo "export TEMPLATE_URL=https://storage.googleapis.com/kops-vsphere/kops_ubuntu_16_04.ova"
echo "export NODEUP_URL=https://storage.googleapis.com/kops-vsphere/nodeup"
echo "export PROTOKUBE_IMAGE=https://storage.googleapis.com/kops-vsphere/protokube.tar.gz"
echo "export VSPHERE_USERNAME=$VSPHERE_USERNAME"
echo "export VSPHERE_PASSWORD=$VSPHERE_PASSWORD"
echo "export DNSCONTROLLER_IMAGE=cnastorage/dns-controller"
echo "export KOPS_FEATURE_FLAGS=+VSphereCloudProvider"
echo "export COREDNS_SERVER=http://${VCSA}:2379"
echo "export VCS_IMAGE=vcs_template"
) > ${VCS_PATH}/set_env

# Start CoreDNS service
cp -r ./coredns ${VCS_PATH}/
./coredns/dns.sh

# Start Minio server for kops state store
cp -r ./minio ${VCS_PATH}/
./minio/minio.sh

source ${VCS_PATH}/set_env

# Deploy VM template
./deploy-template.sh

# Download kops binary
curl -OL https://storage.googleapis.com/kops-vsphere/kops-linux-amd64
mv kops-linux-amd64 ${VCS_PATH}/kops
chmod +x ${VCS_PATH}/kops

echo "Successfully installed kops."
