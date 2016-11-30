#cloud-config

coreos:
  etcd2:
    discovery: ${etcd_discovery_url}
    advertise-client-urls: https://$private_ipv4:2379,https://$private_ipv4:4001
    initial-advertise-peer-urls: https://$private_ipv4:2380
    listen-client-urls: https://0.0.0.0:2379,https://0.0.0.0:4001
    listen-peer-urls: https://$private_ipv4:2380
  fleet:
    etcd_servers: https://$private_ipv4:4001
    public-ip: $private_ipv4
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: iptables-restore.service
      enable: true
      command: start
    - name: flanneld.service
      command: start
write_files:
  - path: /run/systemd/system/etcd2.service.d/30-certificates.conf
    permissions: 0644
    content: |
      [Service]
      # client environment variables
      Environment=ETCD_CA_FILE=/home/core/ca.pem
      Environment=ETCD_CERT_FILE=/home/core/coreos.pem
      Environment=ETCD_KEY_FILE=/home/core/coreos-key.pem
      # peer environment variables
      Environment=ETCD_PEER_CA_FILE=/home/core/ca.pem
      Environment=ETCD_PEER_CERT_FILE=/home/core/coreos.pem
      Environment=ETCD_PEER_KEY_FILE=/home/core/coreos-key.pem
  - path: /run/systemd/system/fleet.service.d/30-certificates.conf
    permissions: 0644
    content: |
      [Service]
      # client auth certs
      Environment=FLEET_ETCD_CAFILE=/home/core/ca.pem
      Environment=FLEET_ETCD_CERTFILE=/home/core/coreos.pem
      Environment=FLEET_ETCD_KEYFILE=/home/core/coreos-key.pem
