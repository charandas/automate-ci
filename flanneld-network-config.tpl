[Service]
Environment="ETCD_SSL_DIR=/home/core"
ExecStartPre=/usr/bin/etcdctl --endpoints https://${coreos_host_private_ip_0}:2379,https://${coreos_host_private_ip_1}:2379,https://${coreos_host_private_ip_2}:2379 \
  --ca-file /home/core/ca.pem --cert-file /home/core/coreos.pem --key-file /home/core/coreos-key.pem \
  set /coreos.com/network/config '{ "Network": "10.0.0.0/8","SubnetLen": 20, "SubnetMin": "10.10.0.0", "SubnetMax": "10.99.0.0", "Backend": { "Type": "vxlan" } }'
