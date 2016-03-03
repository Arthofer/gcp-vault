resource "google_compute_instance" "vault" {
    count = "${var.node_count}"
    name = "vault-${count.index+1}"
    machine_type = "${var.machine_type}"
    zone = "${lookup(var.zones, concat("zone", count.index))}"
    tags = ["vault-server"]
    can_ip_forward = true

    disk {
        image = "${var.image}"
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        "cluster-size" = "${var.node_count}"
        "user-data" = "${template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}

resource "template_file" "cloud_config" {

    depends_on = ["template_file.etcd_discovery_url"]
    template = "${file("${var.cloud_config_template}")}"
    vars {
        "etcd_discovery_url" = "${file(var.discovery_url_file)}"
        "size" = "${var.node_count}"
        "vault_release_url" ="${var.vault_release_url}"
        "vault_service_address" = "${google_compute_address.vault_service.address}"
    }

}

resource "template_file" "etcd_discovery_url" {

    template = "/dev/null"
    provisioner "local-exec" {
        command = "curl -s https://discovery.etcd.io/new?size=${var.node_count} > ${var.discovery_url_file}"
    }
}
