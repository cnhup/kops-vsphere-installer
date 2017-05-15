#!/bin/bash

if ! type "docker" > /dev/null; then
systemctl enable docker
if [ $? -ne 0 ] || [ "`systemctl is-enabled docker`" != "enabled" ] ; then
echo "Failed to enable docker service"
exit 1
fi
systemctl start docker
if [ $? -ne 0 ] || [ "`systemctl is-active docker`" != "active" ] ; then
echo "Failed to start docker service"
exit 1
fi
fi

docker run -d --net=host \
    --name etcd \
    --volume=${VCS_PATH}/skydns:/skydns \
    quay.io/coreos/etcd:v3.1.3 \
    /usr/local/bin/etcd \
    --name my-etcd \
    --data-dir /skydns \
    --listen-client-urls http://0.0.0.0:2379 \
    --advertise-client-urls http://0.0.0.0:2379 \
    --listen-peer-urls http://0.0.0.0:2380 \
    --initial-advertise-peer-urls http://0.0.0.0:2380 \
    --initial-cluster my-etcd=http://0.0.0.0:2380 \
    --initial-cluster-state new \
    --auto-compaction-retention 1
if [ $? -ne 0 ] || [ -z $(docker ps | awk '{print $NF}' | grep -w etcd) ]; then
echo "ETCD container is not running. Exit"
exit 1
fi

curl -XPUT http://127.0.0.1:2379/v2/keys/skydns/local/skydns/dns/ns/ns1 -d value='{"host":"192.168.0.1"}'
if [ $? -ne 0 ] ; then
echo "Failed to insert initial value for dns namedomain skydns.local"
exit 1
fi

docker run -d --net=host --name coredns --volume=${VCS_PATH}/coredns:/root coredns/coredns:006 -conf=/root/Corefile
if [ $? -ne 0 ] || [ -z $(docker ps | awk '{print $NF}' | grep -w coredns) ]; then
echo "CoreDNS container is not running. Exit"
exit 1
fi
