# Template for initial configuration bash script
data "template_file" "cloud_config" {
    template = "${file("cloud-config.tpl")}"

    vars {
        etcd_discovery_url = "${var.etcd_discovery_url}"
    }
}
