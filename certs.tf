data "template_file" "fathm-ci-cert-requests" {
    count = "${var.ci_servers_count}"
    template = "${file("${var.certs_path}/coreos.json.tpl")}"

    vars {
        coreos_host = "${element(digitalocean_droplet.fathm-ci.*.name, count.index)}"
        coreos_host_private_ip = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address_private, count.index)}"
    }
}

resource "null_resource" "configure-coreos-certs" {
    count = "${var.ci_servers_count}"

    connection {
        host = "${element(digitalocean_droplet.fathm-ci.*.ipv4_address, count.index)}"
        type = "ssh"
        user = "core",
        private_key = "${file("/home/charandas/.ssh/fathm_do")}"
    }

    provisioner "local-exec" {
      command = <<EOF
echo ${jsonencode(element(data.template_file.fathm-ci-cert-requests.*.rendered, count.index))} > tmp/${var.certs_path}/coreos-${count.index}.json &&
cfssl gencert -ca=${var.certs_path}/ca.pem -ca-key=${var.certs_path}/ca-key.pem -config=${var.certs_path}/ca-config.json -profile=client-server tmp/${var.certs_path}/coreos-${count.index}.json |
cfssljson -bare tmp/${var.certs_path}/coreos-${count.index} &&
chmod 644 tmp/${var.certs_path}/coreos-${count.index}-key.pem
EOF
    }

    provisioner "file" {
      source = "tmp/${var.certs_path}/coreos-${count.index}.pem"
      destination = "/home/core/coreos.pem"
    }

    provisioner "file" {
      source = "tmp/${var.certs_path}/coreos-${count.index}-key.pem"
      destination = "/home/core/coreos-key.pem"
    }

    provisioner "file" {
      source = "${var.certs_path}/ca.pem"
      destination = "/home/core/ca.pem"
    }
}
