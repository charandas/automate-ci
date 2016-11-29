cat > override.tf <<EOL
variable "etcd_discovery_url" { default = "`curl -s https://discovery.etcd.io/new?size=3`" }
EOL
