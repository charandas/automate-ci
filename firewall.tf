data "template_file" "fathm-ci-firewall-rules" {
    template = "${file("rules-save.tpl")}"

    vars {
        coreos_host_private_ip_0 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 0)}"
        coreos_host_private_ip_1 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 1)}"
        coreos_host_private_ip_2 = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, 2)}"
    }
}

resource "null_resource" "configure-firewall-pre" {
  count = "${var.ci_servers_count}"

  connection {
      host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address, count.index)}"
      type = "ssh"
      user = "core",
      private_key = "${file("/home/charandas/.ssh/fathm_do")}"
  }

  provisioner "file" {
    content = "${data.template_file.fathm-ci-firewall-rules.rendered}"
    destination = "/home/core/rules-save"
  }
}

resource "null_resource" "configure-firewall" {
  count = "${var.ci_servers_count}"
  depends_on = ["null_resource.configure-firewall-pre"]

  connection {
      host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address, count.index)}"
      type = "ssh"
      user = "core",
      private_key = "${file("/home/charandas/.ssh/fathm_do")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/core/rules-save /var/lib/iptables/rules-save"
    ]
  }
}
