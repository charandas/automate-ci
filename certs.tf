data "template_file" "fathm-ci-cert-requests" {
    count = "${var.ci_servers_count}"
    template = "${file("certs/coreos-host.json.tpl")}"

    vars {
        coreos_host = "${element(digitalocean_droplet.fathm-ci.*.name, count.index)}"
        coreos_host_private_ip = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, count.index)}"
    }
}

resource "null_resource" "configure-coreos-certs" {
    count = "${var.ci_servers_count}"
    depends_on = ["digitalocean_droplet.fathm-ci"]

    connection {
        host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, count.index)}"
        type = "ssh"
        user = "core",
        private_key = "${file("/home/charandas/.ssh/fathm_do")}"
    }

    provisioner "file" {
      content = "${element(data.template_file.fathm-ci-cert-requests.*.rendered, count.index)}"
      destination = "${format("certs/%s.json", element(digitalocean_droplet.fathm-ci.*.name, count.index))}"
    }

    provisioner "local-exec" {
      command = "${format("cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client-server certs/%s.json | cfssljson -bare coreos && chmod 644 coreos-key.pem", element(digitalocean_droplet.fathm-ci.*.name, count.index))}",
    }

    provisioner "file" {
      content = "coreos.pem"
      destination = "/home/core/coreos.pem"
    }

    provisioner "file" {
      content = "coreos-key.pem"
      destination = "/home/core/coreos-key.pem"
    }

    provisioner "file" {
      content = "certs/ca.pem"
      destination = "/home/core/ca.pem"
    }
}
