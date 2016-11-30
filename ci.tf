resource "digitalocean_droplet" "fathm-ci" {
    count = "${var.ci_servers_count}"
    image = "coreos-stable"
    name = "fathm-ci-${format("%02d", count.index+1)}"
    region = "nyc1"
    size = "512mb"
    private_networking = true
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
    user_data = "${data.template_file.cloud_config.rendered}"
    }
