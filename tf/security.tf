# Firewalls for vault
resource "google_compute_firewall" "vault-allow-service" {
    name = "vault-allow-internal"
    description = "Allows TCP connections from any source to vault load balancer."
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["8200"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["vault-balancer"]
}
