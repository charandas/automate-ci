data "template_file" "flannel-options-env" {
    template = "${file("flannel-options.env.tpl")}"

    vars {
        coreos_host_private_ip_0 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 0)}"
        coreos_host_private_ip_1 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 1)}"
        coreos_host_private_ip_2 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 2)}"
    }
}

data "template_file" "flanneld-network-config" {
    template = "${file("flanneld-network-config.tpl")}"

    vars {
        coreos_host_private_ip_0 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 0)}"
        coreos_host_private_ip_1 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 1)}"
        coreos_host_private_ip_2 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 2)}"
    }
}

resource "null_resource" "configure-flanneld-pre" {
  count = "${var.ci_servers_count}"

  connection {
      host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address, count.index)}"
      type = "ssh"
      user = "core",
      private_key = "${file("/home/charandas/.ssh/fathm_do")}"
  }

  provisioner "file" {
    content = "${data.template_file.flannel-options-env.rendered}"
    destination = "/home/core/flannel-options.env"
  }

  provisioner "file" {
    content = "${data.template_file.flanneld-network-config.rendered}"
    destination = "/home/core/flanneld-network-config"
  }
}

resource "null_resource" "configure-flanneld" {
  count = "${var.ci_servers_count}"
  depends_on = ["null_resource.configure-flanneld-pre"]

  connection {
      host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address, count.index)}"
      type = "ssh"
      user = "core",
      private_key = "${file("/home/charandas/.ssh/fathm_do")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/core/flannel-options.env /run/flannel/options.env",
      "sudo mkdir /etc/systemd/system/flanneld.service.d",
      "sudo cp /home/core/flanneld-network-config /etc/systemd/system/flanneld.service.d/50-network-config.conf",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart flanneld"
    ]
  }
}
