#!/bin/bash

echo "Start the deployment of VM template. This process may take several minutes."
docker run --rm -t --name ovftool \
	cnastorage/ovftool \
	ovftool --noSSLVerify --diskMode=thin \
	--datastore=vsanDatastore \
	--name=${VCS_IMAGE} \
	${TEMPLATE_URL} \
	vi://${VSPHERE_USERNAME}:${VSPHERE_PASSWORD}@${VCSA}/VSAN-DC/host/VSAN-Cluster/

# Remove ovftool container image after deployment finished
docker rmi cnastorage/ovftool
