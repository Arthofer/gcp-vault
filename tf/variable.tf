variable "project" { }

variable "account_file" {
    default = "account.json"
}

variable "region" {
    default = "us-central1"
}

variable "zones" {
    default = {
        zone0 = "us-central1-a"
        zone1 = "us-central1-b"
        zone2 = "us-central1-c"
        zone3 = "us-central1-f"
        zone4 = "us-central1-a"
        zone5 = "us-central1-b"
        zone6 = "us-central1-c"
        zone7 = "us-central1-f"
        zone8 = "us-central1-a"
        zone9 = "us-central1-b"
    }
}

variable "cluster_name" {
    default = "vault"
}

variable "etcd_cloud_config_template" {
    default = "artifacts/etcd_cloud_config.yaml.tpl"
}

variable "discovery_url_file" {
    default = "artifacts/discovery_url.txt"
}

variable "image" {
    default = "coreos-stable-835-9-0-v20151208"
}

variable "machine_type" {
    default = "n1-standard-1"
}

variable "node_count" {
    default = 5
}

variable "vault_release_url" {
    defualt = "https://releases.hashicorp.com/vault/0.5.1/vault_0.5.1_linux_amd64.zip"
}

variable "vault_conf_file" {
    default = "artifacts/vault.hcl"
}

variable "ca_cert_file" {
    default = "artifacts/certs/rootCA.pem"
}

variable "vault_cert_file" {
    default = "artifacts/certs/vault.crt"
}

variable "vault_key_file" {
    default = "artifacts/certs/vault.key"
}

variable "vault_client_cert_file" {
    default = "artifacts/certs/vault-client.crt"
}

variable "vault_client_key_file" {
    default = "artifacts/certs/vault-client.key"
}

variable "etcd_cert_file" {
    default = "artifacts/certs/etcd.crt"
}

variable "etcd_key_file" {
    default = "artifacts/certs/etcd.key"
}

variable "etcd_client_cert_file" {
    default = "artifacts/certs/etcd-client.crt"
}

variable "etcd_client_key_file" {
    default = "artifacts/certs/etcd-client.key"
}

