# Prerequisite
If running on a PhotonOS without docker enabled:
```bash
tdnf -y install docker
insmod /usr/lib/modules/$(uname -r)/kernel/net/bridge/bridge.ko
systemctl enable docker
systemctl start docker
```

# Docker Usage

```bash
export VCS_PATH=[your path to hold VCS files]
docker run -it --net=host -v ${VCS_PATH}:${VCS_PATH} -e "VCS_PATH=${VCS_PATH}" -e "VCSA=[IP address of your vCenter]" -e "VSPHERE_USERNAME=[your vSphere username]" -e 'VSPHERE_PASSWORD=[your vSphere password]' -v /var/run/docker.sock:/var/run/docker.sock cnastorage/vcs-installer
```

# Script Usage

```bash
export VCSA=[IP address of your vCenter]
export VSPHERE_USERNAME=[your vSphere username]
export VSPHERE_PASSWORD=[your vSphere password]
export VCS_PATH=[your path to hold VCS files]
./install.sh
```

# Run kops
```bash
source ${VCS_PATH}/set_env
${VCS_PATH}/kops create cluster cluster1.skydns.local --cloud=vsphere --zones=vmware-zone --dns-zone=skydns.local --networking=flannel --vsphere-server=${VCSA} --vsphere-datacenter=VSAN-DC --vsphere-resource-pool=VSAN-Cluster --vsphere-datastore=vsanDatastore --dns private --vsphere-coredns-server=http://${VCSA}:2379 --image=${VCS_IMAGE} --yes
```
